part of 'device_detail_bloc.dart';

@freezed
sealed class DeviceDetailEvent with _$DeviceDetailEvent {
  const factory DeviceDetailEvent.started(DeviceModel device) = _Started;
}
 