import 'package:equatable/equatable.dart';

abstract class AuthState extends Equatable {
  @override
  List<Object?> get props => [];
}

/// Inget har hänt ännu
class AuthInitial extends AuthState {}

/// Vi håller på och loggar in/registrerar/utloggning
class AuthLoading extends AuthState {}

class AuthRegistered extends AuthState {
  final String username;
  AuthRegistered(this.username);

  @override
  List<Object?> get props => [username];
}

/// Inloggning/registrering lyckades, FirebaseUser (User) finns i backend
class AuthAuthenticated extends AuthState {
  final String uid;
  final String email;
  final String username;
  AuthAuthenticated(this.uid, this.email, this.username,);

  @override
  List<Object?> get props => [uid, email, username];
}

/// Autentisering misslyckades
class AuthError extends AuthState {
  final String message;
  AuthError(this.message);

  @override
  List<Object?> get props => [message];
}

/// Användaren är inte inloggad
class AuthUnauthenticated extends AuthState {}