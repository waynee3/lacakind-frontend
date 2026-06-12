part of 'contract_list_bloc.dart';

@freezed
sealed class ContractListEvent with _$ContractListEvent {
  const factory ContractListEvent.started({
    String? contractId,
    String? clientName,
    String? contractType,
    String? startDate,
    String? endDate,
    String? status,
    String? paymentStatus,
  }) = _Started;
  const factory ContractListEvent.onSearch(String query) = _OnSearch;
  const factory ContractListEvent.loadMore() = _LoadMore;
  const factory ContractListEvent.deleteContract(String id) = _DeleteContract;
}
