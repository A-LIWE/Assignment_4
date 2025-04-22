import 'package:flutter/material.dart';
import 'package:parking_user/providers/auth_provider.dart';
import 'package:parking_user/views/registration_view.dart';
import 'package:provider/provider.dart';


class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final _controller = TextEditingController();
  bool _loading = false;

  Future<void> _onLoginPressed() async {
    final pn = _controller.text.trim();
    if (pn.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Var god ange personnummer")),
      );
      return;
    }

     setState(() => _loading = true);
    try {
      await context.read<AuthProvider>().login(pn);
      // AuthGate kommer nu att visa HomeView automatiskt
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Logga in')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _controller,
              decoration: const InputDecoration(
                labelText: 'Personnummer',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            _loading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _onLoginPressed,
                    child: const Text('Logga in'),
                  ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const RegistrationView()),
                );
              },
              child: const Text('Registrera dig'),
            ),
          ],
        ),
      ),
    );
  }
}
