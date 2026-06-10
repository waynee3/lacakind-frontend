import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:lacakind_frontend/data/models/device_model.dart';

part 'device_detail_event.dart';
part 'device_detail_state.dart';
part 'device_detail_bloc.freezed.dart';

class DeviceDetailBloc extends Bloc<DeviceDetailEvent, DeviceDetailState> {
  DeviceDetailBloc() : super(const DeviceDetailState.initial()) {
    on<DeviceDetailEvent>((event, emit) async {
      switch (event) {
        case _Started():
          emit(state.copyWith(device: event.device, isLoading: false));
      }
    });
  }
}
 