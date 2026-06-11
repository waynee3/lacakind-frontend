part of 'client_form_bloc.dart';

@freezed
sealed class ClientFormEvent with _$ClientFormEvent {
  const factory ClientFormEvent.started() = _Started;
  const factory ClientFormEvent.startedEdit(String id) = _StartedEdit;
  const factory ClientFormEvent.nameChanged(String value) = _NameChanged;
  const factory ClientFormEvent.locationChanged(String value) = _LocationChanged;
  const factory ClientFormEvent.contactPersonChanged(String value) = _ContactPersonChanged;
  const factory ClientFormEvent.emailChanged(String value) = _EmailChanged;
  const factory ClientFormEvent.phoneChanged(String value) = _PhoneChanged;
  const factory ClientFormEvent.addressChanged(String value) = _AddressChanged;
  const factory ClientFormEvent.notesChanged(String value) = _NotesChanged;
  const factory ClientFormEvent.submitted() = _Submitted;
}
 