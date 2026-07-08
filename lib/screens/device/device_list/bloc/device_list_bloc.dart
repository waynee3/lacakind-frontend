import 'dart:typed_data';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:lacakind_frontend/container.dart';
import 'package:lacakind_frontend/data/models/device_model.dart';
import 'package:lacakind_frontend/data/repositories/device_repository.dart';

part 'device_list_event.dart';
part 'device_list_state.dart';
part 'device_list_bloc.freezed.dart';

class DeviceListBloc extends Bloc<DeviceListEvent, DeviceListState> {
  String? _serialNumber;
  String? _status;
  String? _modelType;
  String? _location;

  DeviceListBloc() : super(const DeviceListState.initial()) {
    on<DeviceListEvent>((event, emit) async {
      switch (event) {
        case _Started():
          await _onStarted(event, emit);
        case _Searched():
          await _onSearched(event, emit);
        case _LoadMore():
          await _onLoadMore(emit);
        case _SelectedAll():
          _onSelectedAll(emit);
        case _SelectedDevice():
          _onSelectedDevice(event, emit);
        case _Added():
          await _onAdded(event, emit);
        case _Updated():
          await _onUpdated(event, emit);
        case _Deleted():
          await _onDeleted(event, emit);
        case _BulkDeleted():
          await _onBulkDeleted(emit);
        case _Imported():
          await _onImported(event, emit);
      }
    });
  }

  Future<(List<DeviceModel>?, String?)> _fetch(int page) =>
      deviceRepo.getDevices(
        serialNumber: _serialNumber,
        status: _status,
        modelType: _modelType,
        location: _location,
        page: page,
      );

  bool _reachedEnd(List<DeviceModel> page) =>
      page.length < DeviceRepository.pageSize;

  Future<void> _onStarted(
      _Started event, Emitter<DeviceListState> emit) async {
    _serialNumber = event.serialNumber;
    _status = event.status;
    _modelType = event.modelType;
    _location = event.location;

    emit(state.copyWith(
      isLoading: true,
      errorMessage: '',
      currentPage: 1,
      hasMore: true,
      devices: [],
      selectedIds: [],
    ));

    final (data, error) = await _fetch(1);
    if (error != null) {
      emit(state.copyWith(isLoading: false, errorMessage: error));
      return;
    }
    emit(state.copyWith(
      isLoading: false,
      devices: data!,
      currentPage: 1,
      hasMore: !_reachedEnd(data),
    ));
  }

  Future<void> _onSearched(
      _Searched event, Emitter<DeviceListState> emit) async {
    _serialNumber = event.serialNumber.isEmpty ? null : event.serialNumber;
    _status = null;
    _modelType = null;
    _location = null;

    emit(state.copyWith(
      isLoading: true,
      errorMessage: '',
      currentPage: 1,
      hasMore: true,
      devices: [],
      selectedIds: [],
    ));

    final (data, error) = await _fetch(1);
    if (error != null) {
      emit(state.copyWith(isLoading: false, errorMessage: error));
      return;
    }
    emit(state.copyWith(
      isLoading: false,
      devices: data!,
      currentPage: 1,
      hasMore: !_reachedEnd(data),
    ));
  }

  Future<void> _onLoadMore(Emitter<DeviceListState> emit) async {
    if (!state.hasMore || state.isLoadingMore || state.isLoading) return;
    final nextPage = state.currentPage + 1;
    emit(state.copyWith(isLoadingMore: true, errorMessage: ''));
    final (data, error) = await _fetch(nextPage);
    if (error != null) {
      emit(state.copyWith(isLoadingMore: false, errorMessage: error));
      return;
    }
    emit(state.copyWith(
      isLoadingMore: false,
      devices: [...state.devices, ...data!],
      currentPage: nextPage,
      hasMore: !_reachedEnd(data),
    ));
  }

  void _onSelectedAll(Emitter<DeviceListState> emit) {
    final allIds = state.devices.map((d) => d.id).toList();
    final allSelected = allIds.every((id) => state.selectedIds.contains(id));
    emit(state.copyWith(selectedIds: allSelected ? [] : allIds));
  }

  void _onSelectedDevice(
      _SelectedDevice event, Emitter<DeviceListState> emit) {
    final updated = List<String>.from(state.selectedIds);
    if (updated.contains(event.id)) {
      updated.remove(event.id);
    } else {
      updated.add(event.id);
    }
    emit(state.copyWith(selectedIds: updated));
  }

  Future<void> _reloadPage1(
    Emitter<DeviceListState> emit, {
    required String successMessage,
  }) async {
    final (data, fetchError) = await _fetch(1);
    emit(state.copyWith(
      isLoading: false,
      errorMessage: fetchError ?? '',
      devices: data ?? state.devices,
      currentPage: 1,
      hasMore: data != null ? !_reachedEnd(data) : state.hasMore,
      selectedIds: [],
      isSuccess: fetchError == null,
      successMessage: fetchError == null ? successMessage : '',
    ));
  }

  Future<void> _onAdded(_Added event, Emitter<DeviceListState> emit) async {
    emit(state.copyWith(isLoading: true, errorMessage: '', isSuccess: false));
    final error = await deviceRepo.addDevice(event.data);
    if (error != null) {
      emit(state.copyWith(isLoading: false, errorMessage: error));
      return;
    }
    await _reloadPage1(emit, successMessage: 'Device added successfully');
  }

  Future<void> _onUpdated(_Updated event, Emitter<DeviceListState> emit) async {
    emit(state.copyWith(isLoading: true, errorMessage: '', isSuccess: false));
    final error =
        await deviceRepo.updateDeviceBySerial(event.serialNumber, event.data);
    if (error != null) {
      emit(state.copyWith(isLoading: false, errorMessage: error));
      return;
    }
    await _reloadPage1(emit, successMessage: 'Device updated successfully');
  }

  Future<void> _onDeleted(_Deleted event, Emitter<DeviceListState> emit) async {
    emit(state.copyWith(isLoading: true, errorMessage: '', isSuccess: false));
    final error = await deviceRepo.deleteDevice(event.id);
    if (error != null) {
      emit(state.copyWith(isLoading: false, errorMessage: error));
      return;
    }
    await _reloadPage1(emit, successMessage: 'Device deleted successfully');
  }

  Future<void> _onBulkDeleted(Emitter<DeviceListState> emit) async {
    if (state.selectedIds.isEmpty) return;
    final serials = state.devices
        .where((d) => state.selectedIds.contains(d.id))
        .map((d) => d.serialNumber)
        .toList();
    emit(state.copyWith(isLoading: true, errorMessage: '', isSuccess: false));
    final error = await deviceRepo.bulkDeleteDevices(serials);
    if (error != null) {
      emit(state.copyWith(isLoading: false, errorMessage: error));
      return;
    }
    await _reloadPage1(
      emit,
      successMessage:
          'Deleted ${serials.length} device${serials.length == 1 ? '' : 's'}',
    );
  }

  Future<void> _onImported(
      _Imported event, Emitter<DeviceListState> emit) async {
    emit(state.copyWith(
        isLoading: true, errorMessage: '', importErrors: [], isSuccess: false));

    final result = await deviceRepo.importDevices(
      filePath: event.filePath,
      fileBytes: event.fileBytes,
      fileName: event.fileName,
    );

    if (result.fatalError != null) {
      emit(state.copyWith(isLoading: false, errorMessage: result.fatalError!));
      return;
    }

    final inserted = result.inserted ?? 0;
    final rowErrors = result.errors;

    if (inserted == 0) {
      emit(state.copyWith(
        isLoading: false,
        errorMessage:
            '${rowErrors.length} row${rowErrors.length == 1 ? '' : 's'} failed to import.',
        importErrors: rowErrors,
      ));
      return;
    }

    _serialNumber = null;
    _status = null;
    _modelType = null;
    _location = null;

    final hasRowErrors = rowErrors.isNotEmpty;
    final (data, fetchError) = await _fetch(1);

    emit(state.copyWith(
      isLoading: false,
      errorMessage: fetchError ?? '',
      devices: data ?? state.devices,
      currentPage: 1,
      hasMore: data != null ? !_reachedEnd(data) : state.hasMore,
      selectedIds: [],
      isSuccess: fetchError == null,
      successMessage: fetchError == null
          ? 'Imported $inserted device${inserted == 1 ? '' : 's'}'
              '${hasRowErrors ? ' (${rowErrors.length} row error${rowErrors.length == 1 ? '' : 's'})' : ''}'
          : '',
      importErrors: rowErrors,
    ));
  }
}