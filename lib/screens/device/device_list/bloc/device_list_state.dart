part of 'device_list_bloc.dart';

@freezed
sealed class DeviceListState with _$DeviceListState {
  const factory DeviceListState.initial({
    @Default([]) List<DeviceModel> devices,
    @Default([]) List<String> selectedIds,
    @Default(false) bool isLoading,
    @Default(false) bool isSuccess,
    @Default('') String errorMessage,
    @Default('') String successMessage,
  }) = _Initial;
}