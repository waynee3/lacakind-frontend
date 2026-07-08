import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lacakind_frontend/core/toast.dart';
import 'package:lacakind_frontend/screens/login/bloc/login_bloc.dart';
import 'package:lacakind_frontend/styles/theme_cubit.dart';

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
    _emailController    = TextEditingController();
    _passwordController = TextEditingController();

    _emailController.addListener(() => context
        .read<LoginBloc>()
        .add(LoginEvent.emailChanged(_emailController.text)));
    _passwordController.addListener(() => context
        .read<LoginBloc>()
        .add(LoginEvent.passwordChanged(_passwordController.text)));
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<LoginBloc>().add(const LoginEvent.loginSubmitted());
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return BlocListener<LoginBloc, LoginState>(
      listenWhen: (prev, curr) =>
          prev.errorMessage != curr.errorMessage && curr.errorMessage.isNotEmpty,
      listener: (context, state) {
        AppToast.error(context, state.errorMessage);
      },
      child: Material(
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
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'LacakInd',
                              style: textTheme.titleLarge
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            IconButton(
                              icon: Icon(
                                context.watch<ThemeCubit>().state ==
                                        ThemeMode.light
                                    ? Icons.dark_mode
                                    : Icons.light_mode,
                              ),
                              onPressed: () =>
                                  context.read<ThemeCubit>().toggleTheme(),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Masukkan akun anda untuk melanjutkan',
                          style: textTheme.bodySmall
                              ?.copyWith(color: Colors.grey),
                        ),
                        const SizedBox(height: 24),
                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: const InputDecoration(
                            labelText: 'Email',
                            hintText: 'Masukkan email',
                          ),
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) {
                              return 'Email wajib diisi';
                            }
                            return null;
                          },
                          onFieldSubmitted: (_) => _submit(),
                        ),
                        const SizedBox(height: 12),
                        BlocBuilder<LoginBloc, LoginState>(
                          buildWhen: (prev, curr) =>
                              prev.obscurePassword != curr.obscurePassword,
                          builder: (context, state) {
                            return TextFormField(
                              controller: _passwordController,
                              obscureText: state.obscurePassword,
                              decoration: InputDecoration(
                                labelText: 'Password',
                                hintText: 'Masukkan password',
                                suffixIcon: IconButton(
                                  onPressed: () => context
                                      .read<LoginBloc>()
                                      .add(const LoginEvent
                                          .obscurePasswordToggled()),
                                  icon: Icon(state.obscurePassword
                                      ? Icons.visibility_outlined
                                      : Icons.visibility_off_outlined),
                                ),
                              ),
                              validator: (v) {
                                if (v == null || v.isEmpty) {
                                  return 'Password wajib diisi';
                                }
                                return null;
                              },
                              onFieldSubmitted: (_) => _submit(),
                            );
                          },
                        ),
                        const SizedBox(height: 20),
                        BlocBuilder<LoginBloc, LoginState>(
                          buildWhen: (prev, curr) =>
                              prev.isLoading != curr.isLoading,
                          builder: (context, state) {
                            return SizedBox(
                              height: 44,
                              width: double.infinity,
                              child: FilledButton(
                                onPressed: state.isLoading ? null : _submit,
                                child: state.isLoading
                                    ? const SizedBox(
                                        width: 18,
                                        height: 18,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white,
                                        ),
                                      )
                                    : const Text('Login'),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}