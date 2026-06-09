import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:lacakind_frontend/container.dart';
import 'package:lacakind_frontend/routes/routes.dart';

part 'login_event.dart';
part 'login_state.dart';
part 'login_bloc.freezed.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  LoginBloc() : super(const LoginState.initial()) {
    on<LoginEvent>((event, emit) async {
      switch (event) {
        case _EmailChanged():
          _onEmailChanged(event, emit);
        case _PasswordChanged():
          _onPasswordChanged(event, emit);
        case _ObscurePasswordToggled():
          _onObscurePasswordToggled(event, emit);
        case _LoginSubmitted():
          await _onLoginSubmitted(event, emit);
      }
    });
  }

  void _onEmailChanged(_EmailChanged event, Emitter<LoginState> emit) {
    emit(state.copyWith(email: event.email, errorMessage: ''));
  }

  void _onPasswordChanged(_PasswordChanged event, Emitter<LoginState> emit) {
    emit(state.copyWith(password: event.password, errorMessage: ''));
  }

  void _onObscurePasswordToggled(_ObscurePasswordToggled event, Emitter<LoginState> emit) {
    emit(state.copyWith(obscurePassword: !state.obscurePassword));
  }

  Future<void> _onLoginSubmitted(_LoginSubmitted event, Emitter<LoginState> emit) async {
    emit(state.copyWith(isLoading: true, errorMessage: ''));
    final error = await authRepo.login(state.email, state.password);
    if (error != null) {
      emit(state.copyWith(isLoading: false, errorMessage: error));
      return;
    }
    emit(state.copyWith(isLoading: false, isSuccess: true));
    router.go('/dashboard');
  }
}