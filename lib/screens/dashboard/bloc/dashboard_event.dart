part of 'dashboard_bloc.dart';

@freezed
sealed class DashboardEvent with _$DashboardEvent {
  const factory DashboardEvent.started() = _Started;
  const factory DashboardEvent.refresh() = _Refresh;
}
 