import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:lacakind_frontend/container.dart';
import 'package:lacakind_frontend/data/models/device_model.dart';

part 'device_detail_event.dart';
part 'device_detail_state.dart';
part 'device_detail_bloc.freezed.dart';

class DeviceDetailBloc extends Bloc<DeviceDetailEvent, DeviceDetailState> {
  DeviceDetailBloc() : super(const DeviceDetailState.initial()) {
    on<DeviceDetailEvent>((event, emit) async {
      switch (event) {
        case _Started():
          await _onStarted(event, emit);
        case _DeleteRequested():
          await _onDeleteRequested(emit);
      }
    });
  }
 
  Future<void> _onStarted(_Started event, Emitter<DeviceDetailState> emit) async {
    emit(state.copyWith(isLoading: true, errorMessage: ''));
    final (device, error) = await deviceRepo.getDeviceById(event.deviceId);
    if (error != null) {
      emit(state.copyWith(isLoading: false, errorMessage: error));
      return;
    }
    emit(state.copyWith(isLoading: false, device: device));
  }
 
  Future<void> _onDeleteRequested(Emitter<DeviceDetailState> emit) async {
    final id = state.device?.id;
    if (id == null) return;
    emit(state.copyWith(isLoading: true, errorMessage: ''));
    final error = await deviceRepo.deleteDevice(id);
    if (error != null) {
      emit(state.copyWith(isLoading: false, errorMessage: error));
      return;
    }
    emit(state.copyWith(isLoading: false, isDeleted: true));
  }
}
 




