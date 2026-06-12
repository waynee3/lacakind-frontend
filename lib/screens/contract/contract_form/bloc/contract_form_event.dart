part of 'contract_form_bloc.dart';

@freezed
sealed class ContractFormEvent with _$ContractFormEvent {
  const factory ContractFormEvent.started() = _Started;
  const factory ContractFormEvent.startedEdit(String id) = _StartedEdit;
  const factory ContractFormEvent.contractIdChanged(String value) = _ContractIdChanged;
  const factory ContractFormEvent.clientChanged(ClientModel? value) = _ClientChanged;
  const factory ContractFormEvent.contractTypeChanged(String value) = _ContractTypeChanged;
  const factory ContractFormEvent.startDateChanged(DateTime value) = _StartDateChanged;
  const factory ContractFormEvent.endDateChanged(DateTime? value) = _EndDateChanged;
  const factory ContractFormEvent.statusChanged(String value) = _StatusChanged;
  const factory ContractFormEvent.paymentStatusChanged(String value) = _PaymentStatusChanged;
  const factory ContractFormEvent.notesChanged(String value) = _NotesChanged;
  const factory ContractFormEvent.submitted() = _Submitted;
}
 