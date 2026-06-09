part of 'device_bloc.dart';

@freezed
sealed class DeviceEvent with _$DeviceEvent {
  const factory DeviceEvent.started({
    String? serialNumber,
    String? status,
    String? modelType,
    String? location,
    @Default(1) int page,
  }) = _Started;
  const factory DeviceEvent.onSearch(String serialNumber) = _Searched;
  const factory DeviceEvent.selectAll() = _SelectedAll;
  const factory DeviceEvent.selectDevice(String id) = _SelectedDevice;
  const factory DeviceEvent.addDevice(Map<String, dynamic> data) = _Added;
  const factory DeviceEvent.updateDevice(String id, Map<String, dynamic> data) = _Updated;
  const factory DeviceEvent.deleteDevice(String id) = _Deleted;
}