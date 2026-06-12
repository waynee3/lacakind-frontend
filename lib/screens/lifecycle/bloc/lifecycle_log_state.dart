part of 'lifecycle_log_bloc.dart';

@freezed
sealed class LifecycleLogState with _$LifecycleLogState {
  const factory LifecycleLogState.initial({
    @Default([]) List<BulkOperationModel> logs,
    @Default(false) bool isLoading,
    @Default(false) bool isLoadingMore,
    @Default(true)  bool hasMore,
    @Default(1)     int  currentPage,
    @Default('')    String errorMessage,
  }) = _Initial;
}
 