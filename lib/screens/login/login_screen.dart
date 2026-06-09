import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lacakind_frontend/screens/login/bloc/login_bloc.dart';
import 'package:lacakind_frontend/styles/theme_cubit.dart';
import 'package:lacakind_frontend/widgets/label_text_field.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();

    _emailController.addListener(() {
      context.read<LoginBloc>().add(
        LoginEvent.emailChanged(_emailController.text),
      );
    });
    _passwordController.addListener(() {
      context.read<LoginBloc>().add(
        LoginEvent.passwordChanged(_passwordController.text),
      );
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Form(
            key: _formKey,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    children: [
                      IconButton(
                        icon: Icon(
                          context.watch<ThemeCubit>().state == ThemeMode.light
                              ? Icons.dark_mode
                              : Icons.light_mode,
                        ),
                        onPressed: () {
                          context.read<ThemeCubit>().toggleTheme();
                        },
                      ),
                      LabelTextField(
                        label: "Email",
                        hintText: "Masukkan email",
                        controller: _emailController,
                      ),
                      const SizedBox(height: 12),
                      BlocBuilder<LoginBloc, LoginState>(
                        buildWhen: (previous, current) => previous.obscurePassword != current.obscurePassword,
                        builder: (context, state) {
                          final obscurePassword = state.obscurePassword;
                          return LabelTextField(
                            label: "Password",
                            hintText: "Masukkan password",
                            controller: _passwordController,
                            obscureText: obscurePassword,
                            suffixIcon: IconButton(
                              onPressed: () {
                                const event =
                                    LoginEvent.obscurePasswordToggled();
                                context.read<LoginBloc>().add(event);
                              },
                              icon: Icon(
                                obscurePassword
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 44,
                        width: double.infinity,
                        child: FilledButton(
                          onPressed: () {
                            context.read<LoginBloc>().add(const LoginEvent.loginSubmitted());
                          },
                          child: const Text("Login"),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
