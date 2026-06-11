part of 'device_list_bloc.dart';

@freezed
sealed class DeviceListState with _$DeviceListState {
  const factory DeviceListState.initial({
    @Default([]) List<DeviceModel> devices,
    @Default([]) List<String> selectedIds,
    @Default(false) bool isLoading,
    @Default(false) bool isLoadingMore,
    @Default(true) bool hasMore,
    @Default(1) int currentPage,
    @Default(false) bool isSuccess,
    @Default('') String errorMessage,
    @Default('') String successMessage,
    @Default([]) List<String> importErrors,
  }) = _Initial;
}
 