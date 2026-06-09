part of 'device_bloc.dart';

@freezed
sealed class DeviceState with _$DeviceState {
  const factory DeviceState.initial({
    @Default([]) List<DeviceModel> devices,
    @Default([]) List<String> selectedIds,
    @Default(false) bool isLoading,
    @Default(false) bool isSuccess,
    @Default('') String errorMessage,
    @Default('') String successMessage,
  }) = _Initial;
}