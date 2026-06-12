part of 'dashboard_bloc.dart';

@freezed
sealed class DashboardState with _$DashboardState {
  const factory DashboardState.initial({
    DashboardModel? data,
    @Default(false) bool isLoading,
    @Default('') String errorMessage,
  }) = _Initial;
}
 