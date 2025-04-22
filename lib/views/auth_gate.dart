import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'login_view.dart';
import 'home_view.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});
  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    if (!auth.isAuthenticated) {
      return const LoginView();
    } else {
      return HomeView(
        userPersonalNumber: auth.userPersonalNumber!,
        userName: auth.userName!,
      );
    }
  }
}