part of 'device_list_bloc.dart';

@freezed
sealed class DeviceListEvent with _$DeviceListEvent {
  const factory DeviceListEvent.started({
    String? serialNumber,
    String? status,
    String? modelType,
    String? location,
    @Default(1) int page,
  }) = _Started;
  const factory DeviceListEvent.onSearch(String serialNumber) = _Searched;
  const factory DeviceListEvent.selectAll() = _SelectedAll;
  const factory DeviceListEvent.selectDevice(String id) = _SelectedDevice;
  const factory DeviceListEvent.addDevice(Map<String, dynamic> data) = _Added;
  const factory DeviceListEvent.updateDevice(String id, Map<String, dynamic> data) = _Updated;
  const factory DeviceListEvent.deleteDevice(String id) = _Deleted;
}