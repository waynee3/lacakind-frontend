part of 'lifecycle_log_bloc.dart';

@freezed
sealed class LifecycleLogEvent with _$LifecycleLogEvent {
  const factory LifecycleLogEvent.started({
    String? serialNumber,
    String? clientName,
    String? action,
    DateTime? startDate,
    DateTime? endDate,
  }) = _Started;
 
  const factory LifecycleLogEvent.loadMore() = _LoadMore;
}
 