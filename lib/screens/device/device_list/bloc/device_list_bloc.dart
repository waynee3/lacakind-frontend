import 'dart:typed_data';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:lacakind_frontend/container.dart';
import 'package:lacakind_frontend/data/models/device_model.dart';

part 'device_list_event.dart';
part 'device_list_state.dart';
part 'device_list_bloc.freezed.dart';

class DeviceListBloc extends Bloc<DeviceListEvent, DeviceListState> {
  DeviceListBloc() : super(const DeviceListState.initial()) {
    on<DeviceListEvent>((event, emit) async {
      switch (event) {
        case _Started():
          await _onStarted(event, emit);
        case _Searched():
          await _onSearched(event, emit);
        case _SelectedAll():
          _onSelectedAll(event, emit);
        case _SelectedDevice():
          _onSelectedDevice(event, emit);
        case _Added():
          await _onAdded(event, emit);
        case _Updated():
          await _onUpdated(event, emit);
        case _Deleted():
          await _onDeleted(event, emit);
        case _Imported():
          await _onImported(event, emit);
      }
    });
  }

  Future<void> _onStarted(_Started event, Emitter<DeviceListState> emit) async {
    emit(state.copyWith(isLoading: true, errorMessage: ''));
    final (data, error) = await deviceRepo.getDevices(
      serialNumber: event.serialNumber,
      status: event.status,
      modelType: event.modelType,
      location: event.location,
      page: event.page,
    );
    if (error != null) {
      emit(state.copyWith(isLoading: false, errorMessage: error));
      return;
    }
    if (data != null) {
      emit(state.copyWith(isLoading: false, devices: data));
    }
  }

  Future<void> _onSearched(
    _Searched event,
    Emitter<DeviceListState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, errorMessage: ''));
    final (data, error) = await deviceRepo.getDevices(
      serialNumber: event.serialNumber,
    );
    if (error != null) {
      emit(state.copyWith(isLoading: false, errorMessage: error));
      return;
    }
    if (data != null) {
      emit(state.copyWith(isLoading: false, devices: data));
    }
  }

  void _onSelectedAll(_SelectedAll event, Emitter<DeviceListState> emit) {
    final allIds = state.devices.map((d) => d.id).toList();
    final allSelected = allIds.every((id) => state.selectedIds.contains(id));
    emit(state.copyWith(selectedIds: allSelected ? [] : allIds));
  }

  void _onSelectedDevice(_SelectedDevice event, Emitter<DeviceListState> emit) {
    final updated = List<String>.from(state.selectedIds);
    if (updated.contains(event.id)) {
      updated.remove(event.id);
    } else {
      updated.add(event.id);
    }
    emit(state.copyWith(selectedIds: updated));
  }

  Future<void> _onAdded(_Added event, Emitter<DeviceListState> emit) async {
    emit(state.copyWith(isLoading: true, errorMessage: ''));
    final error = await deviceRepo.addDevice(event.data);
    if (error != null) {
      emit(state.copyWith(isLoading: false, errorMessage: error));
      return;
    }
    final (data, fetchError) = await deviceRepo.getDevices();
    if (fetchError != null) {
      emit(state.copyWith(isLoading: false, errorMessage: fetchError));
      return;
    }
    if (data != null) {
      emit(
        state.copyWith(
          isLoading: false,
          isSuccess: true,
          successMessage: 'Device added',
          devices: data,
        ),
      );
    }
  }

  Future<void> _onUpdated(_Updated event, Emitter<DeviceListState> emit) async {
    emit(state.copyWith(isLoading: true, errorMessage: ''));
    final error = await deviceRepo.updateDevice(event.id, event.data);
    if (error != null) {
      emit(state.copyWith(isLoading: false, errorMessage: error));
      return;
    }
    final (data, fetchError) = await deviceRepo.getDevices();
    if (fetchError != null) {
      emit(state.copyWith(isLoading: false, errorMessage: fetchError));
      return;
    }
    if (data != null) {
      emit(
        state.copyWith(
          isLoading: false,
          isSuccess: true,
          successMessage: 'Device updated',
          devices: data,
        ),
      );
    }
  }

  Future<void> _onDeleted(_Deleted event, Emitter<DeviceListState> emit) async {
    emit(state.copyWith(isLoading: true, errorMessage: ''));
    final error = await deviceRepo.deleteDevice(event.id);
    if (error != null) {
      emit(state.copyWith(isLoading: false, errorMessage: error));
      return;
    }
    final (data, fetchError) = await deviceRepo.getDevices();
    if (fetchError != null) {
      emit(state.copyWith(isLoading: false, errorMessage: fetchError));
      return;
    }
    if (data != null) {
      emit(
        state.copyWith(
          isLoading: false,
          isSuccess: true,
          successMessage: 'Device deleted',
          devices: data,
        ),
      );
    }
  }

  Future<void> _onImported(
    _Imported event,
    Emitter<DeviceListState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, errorMessage: '', importErrors: []));
    final result = await deviceRepo.importDevices(
      filePath: event.filePath,
      fileBytes: event.fileBytes,
      fileName: event.fileName,
    );
    if (result.fatalError != null) {
      emit(state.copyWith(isLoading: false, errorMessage: result.fatalError!));
      return;
    }
    final (data, fetchError) = await deviceRepo.getDevices();
    final inserted = result.inserted ?? 0;
    final hasRowErrors = result.errors.isNotEmpty;
    emit(
      state.copyWith(
        isLoading: false,
        devices: data ?? state.devices,
        errorMessage: fetchError ?? '',
        isSuccess: inserted > 0,
        successMessage: inserted > 0
            ? 'Imported $inserted device${inserted == 1 ? '' : 's'}'
                  '${hasRowErrors ? ' (${result.errors.length} row error${result.errors.length == 1 ? '' : 's'})' : ''}'
            : '',
        importErrors: result.errors,
      ),
    );
  }
}
