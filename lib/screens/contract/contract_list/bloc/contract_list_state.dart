part of 'contract_list_bloc.dart';

@freezed
sealed class ContractListState with _$ContractListState {
  const factory ContractListState.initial({
    @Default([]) List<ContractModel> contracts,
    @Default(false) bool isLoading,
    @Default(false) bool isLoadingMore,
    @Default(true) bool hasMore,
    @Default(1) int currentPage,
    @Default('') String errorMessage,
    @Default(false) bool isSuccess,
    @Default('') String successMessage,
  }) = _Initial;
}
