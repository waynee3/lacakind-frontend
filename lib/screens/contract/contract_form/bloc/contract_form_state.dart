part of 'contract_form_bloc.dart';

@freezed
sealed class ContractFormState with _$ContractFormState {
  const factory ContractFormState.initial({
    String? editingId,
    @Default('') String contractId,
    @Default('') String contractRef,
    ClientModel? selectedClient,
    @Default([]) List<ClientModel> clients,
    @Default('Rental') String contractType,
    DateTime? startDate,
    DateTime? endDate,
    @Default('Active') String status,
    @Default('Not Paid') String paymentStatus,
    @Default('') String notes,
    @Default(false) bool isLoading,
    @Default(false) bool isSuccess,
    @Default('') String errorMessage,
  }) = _Initial;
}
 