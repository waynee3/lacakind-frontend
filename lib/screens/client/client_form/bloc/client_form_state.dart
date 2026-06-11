part of 'client_form_bloc.dart';

@freezed
sealed class ClientFormState with _$ClientFormState {
  const factory ClientFormState.initial({
    String? editingId,
    @Default('') String name,
    @Default('') String location,
    @Default('-') String contactPerson,
    @Default('-') String email,
    @Default('-') String phone,
    @Default('-') String address,
    @Default('-') String notes,
    @Default(false) bool isLoading,
    @Default(false) bool isSuccess,
    @Default('') String errorMessage,
  }) = _Initial;
}
 