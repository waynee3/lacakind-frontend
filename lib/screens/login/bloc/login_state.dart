part of 'login_bloc.dart';

@freezed
sealed class LoginState with _$LoginState {
  const factory LoginState.initial({
    @Default('') String email,
    @Default('') String password,
    @Default(true) bool obscurePassword,
    @Default(false) bool isLoading,
    @Default(false) bool isSuccess,
    @Default('') String errorMessage,
  }) = _Initial;
}