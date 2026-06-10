part of 'device_detail_bloc.dart';

@freezed
sealed class DeviceDetailState with _$DeviceDetailState {
  const factory DeviceDetailState.initial({
    DeviceModel? device,
    @Default(false) bool isLoading,
    @Default('') String errorMessage,
  }) = _Initial;
}
 