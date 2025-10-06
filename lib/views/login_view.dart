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
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {});
  }

  void _onLoginPressed() {
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          backgroundColor: Colors.red.shade600,
          content: Row(
            children: [
              const Icon(Icons.cancel, color: Colors.white),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Fyll i e-post och lösenord!',
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
          duration: const Duration(seconds: 3),
        ),
      );
      return;
    }
    // Skicka eventet till AuthBloc
    context.read<AuthBloc>().add(LoginRequested(email, password));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          WidgetsBinding.instance.addPostFrameCallback((_) {});
          if (state is AuthAuthenticated) {
            // Visa välkomst-snackbar
            WidgetsBinding.instance.addPostFrameCallback((_) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  behavior: SnackBarBehavior.floating,
                  margin: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  backgroundColor: Colors.green.shade600,
                  content: Row(
                    children: [
                      const Icon(Icons.check_circle, color: Colors.white),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Välkommen ${state.username}!',
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                  duration: const Duration(seconds: 3),
                ),
              );
            });
            Future.delayed(const Duration(milliseconds: 300), () {
              if (!mounted) return;
              Navigator.pop(context);
            });
          } else if (state is AuthError) {
            // Visa fel-snackbar
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                behavior: SnackBarBehavior.floating,
                margin: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                backgroundColor: Colors.red.shade600,
                content: Text(
                  state.message,
                  style: const TextStyle(color: Colors.white),
                ),
                duration: const Duration(seconds: 3),
              ),
            );
          }
        },
        builder: (context, state) {
          final isLoading = state is AuthLoading;

          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment:
                  CrossAxisAlignment
                      .center, // se till att barnen är centrerade horisontellt
              children: [
                // Här lägger vi in ikonen
                Image.asset(
                  'assets/images/parking_icon.png',
                  width: 180,
                  height: 180,
                ),

                const SizedBox(height: 8),

                const Text(
                  'Välkommen till Parkera Fint',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(255, 242, 132, 54),
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 32),
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
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(
                          255,
                          242,
                          132,
                          54,
                        ),
                        foregroundColor: Colors.black, // 👈 textfärg blir svart
                        minimumSize: const Size(200, 50),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        textStyle: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
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
                  child: const Text(
                    'Registrera dig',
                    style: TextStyle(
                      fontSize: 18, // valfri större storlek
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
