import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:lacakind_frontend/container.dart';
import 'package:lacakind_frontend/data/enums/device_status.dart';

part 'device_form_event.dart';
part 'device_form_state.dart';
part 'device_form_bloc.freezed.dart';

class DeviceFormBloc extends Bloc<DeviceFormEvent, DeviceFormState> {
  DeviceFormBloc() : super(const DeviceFormState.initial()) {
    on<DeviceFormEvent>((event, emit) async {
      switch (event) {
        case _Started():
          emit(const DeviceFormState.initial());
        case _StartedEdit():
          await _onStartedEdit(event, emit);
        case _SerialNumberChanged():
          emit(state.copyWith(serialNumber: event.value));
        case _ModelTypeChanged():
          emit(state.copyWith(modelType: event.value));
        case _StatusChanged():
          emit(state.copyWith(status: event.value));
        case _LocationChanged():
          emit(state.copyWith(location: event.value));
        case _SupplierChanged():
          emit(state.copyWith(supplier: event.value));
        case _BatchNumberChanged():
          emit(state.copyWith(batchNumber: event.value));
        case _CostChanged():
          emit(state.copyWith(cost: event.value));
        case _PurchaseDateChanged():
          emit(state.copyWith(purchaseDate: event.value));
        case _ActivationDateChanged():
          emit(state.copyWith(activationDate: event.value));
        case _WarrantyExpiryChanged():
          emit(state.copyWith(warrantyExpiry: event.value));
        case _Submitted():
          await _onSubmitted(emit);
      }
    });
  }
 
  Future<void> _onStartedEdit(
      _StartedEdit event, Emitter<DeviceFormState> emit) async {
    emit(state.copyWith(isLoading: true, errorMessage: ''));
    final (device, error) = await deviceRepo.getDeviceById(event.id);
    if (error != null) {
      emit(state.copyWith(isLoading: false, errorMessage: error));
      return;
    }
    final d = device!;
    emit(DeviceFormState.initial(
      editingId: d.id,
      serialNumber: d.serialNumber,
      modelType: d.modelType ?? '',
      status: d.status,
      location: d.currentLocation ?? '',
      supplier: d.supplier ?? '',
      batchNumber: d.batchNumber ?? '',
      cost: d.cost?.toString() ?? '',
      purchaseDate: d.purchaseDate,
      activationDate: d.activationDate,
      warrantyExpiry: d.warrantyExpiry,
      isLoading: false,
    ));
  }
 
  Future<void> _onSubmitted(Emitter<DeviceFormState> emit) async {
    if (state.serialNumber.trim().isEmpty) {
      emit(state.copyWith(errorMessage: 'Serial number is required'));
      return;
    }
    emit(state.copyWith(isLoading: true, errorMessage: ''));
 
    final payload = <String, dynamic>{
      'serialNumber': state.serialNumber.trim(),
      if (state.modelType.isNotEmpty) 'modelType': state.modelType.trim(),
      if (state.status != null) 'status': state.status!.value,
      if (state.location.isNotEmpty) 'currentLocation': state.location.trim(),
      if (state.supplier.isNotEmpty) 'supplier': state.supplier.trim(),
      if (state.batchNumber.isNotEmpty) 'batchNumber': state.batchNumber.trim(),
      if (state.cost.isNotEmpty) 'cost': double.tryParse(state.cost) ?? 0.0,
      if (state.purchaseDate != null)
        'purchaseDate': state.purchaseDate!.toIso8601String(),
      if (state.activationDate != null)
        'activationDate': state.activationDate!.toIso8601String(),
      if (state.warrantyExpiry != null)
        'warrantyExpiry': state.warrantyExpiry!.toIso8601String(),
    };
 
    final String? error;
    if (state.editingId != null) {
      error = await deviceRepo.updateDevice(state.editingId!, payload);
    } else {
      error = await deviceRepo.addDevice(payload);
    }
 
    if (error != null) {
      emit(state.copyWith(isLoading: false, errorMessage: error));
      return;
    }
    emit(state.copyWith(isLoading: false, isSuccess: true));
  }
}