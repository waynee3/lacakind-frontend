part of 'client_list_bloc.dart';

@freezed
sealed class ClientListState with _$ClientListState {
  const factory ClientListState.initial({
    @Default([]) List<ClientModel> clients,
    @Default(false) bool isLoading,
    @Default(false) bool isLoadingMore,
    @Default(true) bool hasMore,
    @Default(1) int currentPage,
    @Default('') String errorMessage,
    @Default(false) bool isSuccess,
    @Default('') String successMessage,
  }) = _Initial;
}
