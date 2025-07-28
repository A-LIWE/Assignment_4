import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:parking_user/blocs/auth/auth_bloc.dart';
import 'package:parking_user/blocs/auth/auth_state.dart';
import 'package:parking_user/main.dart';
import 'login_view.dart';
import 'home_view.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is AuthLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state is AuthAuthenticated) {
          return HomeView(
            userPersonalNumber: state.uid, // eller annat fält
            userName: state.email,
            toggleTheme: () => myAppKey.currentState?.toggleTheme(),
          );
        }
        // initial, error eller unauthenticated → login
        return const LoginView();
      },
    );
  }
}