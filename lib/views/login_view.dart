import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:parking_user/blocs/auth/auth_bloc.dart';
import 'package:parking_user/blocs/auth/auth_event.dart';
import 'package:parking_user/blocs/auth/auth_state.dart';
import 'package:parking_user/views/registration_view.dart';


class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final TextEditingController _emailController    = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onLoginPressed() {
    final email    = _emailController.text.trim();
    final password = _passwordController.text;
    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Fyll i e-post och lösenord")),
      );
      return;
    }
    // Skicka eventet till AuthBloc
    context.read<AuthBloc>().add(LoginRequested(email, password));
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthError) {
          // Visa felmeddelande från BLoC
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
        // Vid AuthAuthenticated kör AuthGate om du har en sådan,
        // alternativt kan du navigera här om du vill:
        // if (state is AuthAuthenticated) { … }
      },
      builder: (context, state) {
        final isLoading = state is AuthLoading;

        return Scaffold(
          appBar: AppBar(title: const Text('Logga in')),
          body: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // E-postfält
                TextField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'E-post',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 16),

                // Lösenordsfält
                TextField(
                  controller: _passwordController,
                  decoration: const InputDecoration(
                    labelText: 'Lösenord',
                    border: OutlineInputBorder(),
                  ),
                  obscureText: true,
                ),
                const SizedBox(height: 24),

                // Logga in-knapp eller loader
                isLoading
                    ? const CircularProgressIndicator()
                    : ElevatedButton(
                        onPressed: _onLoginPressed,
                        child: const Text('Logga in'),
                      ),
                const SizedBox(height: 16),

                // Navigering till registreringssida
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const RegistrationView(),
                      ),
                    );
                  },
                  child: const Text('Registrera dig'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
