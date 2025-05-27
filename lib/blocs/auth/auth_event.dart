import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

/// När användaren försöker logga in med e-post & lösenord
class LoginRequested extends AuthEvent {
  final String email;
  final String password;
  LoginRequested(this.email, this.password);

  @override
  List<Object?> get props => [email, password];
}

/// När användaren försöker registrera sig
class RegisterRequested extends AuthEvent {
  final String email;
  final String password;
  final String username;
  final String personalNumber;

  RegisterRequested({
    required this.email,
    required this.password,
    required this.username,
    required this.personalNumber,
  });

  @override
  List<Object?> get props => [
        email,
        password,
        username,
        personalNumber,
      ];
}

/// När användaren loggar ut
class LogoutRequested extends AuthEvent {}