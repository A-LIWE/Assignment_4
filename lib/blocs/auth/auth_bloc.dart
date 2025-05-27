import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final FirebaseAuth _firebaseAuth;

  AuthBloc({FirebaseAuth? firebaseAuth})
    : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
      super(AuthInitial()) {
    on<LoginRequested>(_onLoginRequested);
    on<RegisterRequested>(_onRegisterRequested);
    on<LogoutRequested>(_onLogoutRequested);
  }

  Future<void> _onLoginRequested(
    LoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final cred = await _firebaseAuth.signInWithEmailAndPassword(
        email: event.email,
        password: event.password,
      );
      final user = cred.user!;
      emit(AuthAuthenticated(user.uid, user.email!));
    } on FirebaseAuthException catch (e) {
      String msg;
      switch (e.code) {
        case 'user-not-found':
          msg = 'Inget konto hittades på den e-postadressen.';
          break;
        case 'wrong-password':
          msg = 'Fel lösenord.';
          break;
        default:
          msg = e.message ?? 'Fel vid inloggning.';
      }
      emit(AuthError(msg));
    } catch (e) {
      emit(AuthError('Okänt fel: $e'));
    }
  }

  Future<void> _onRegisterRequested(
  RegisterRequested event,
  Emitter<AuthState> emit,
) async {
  emit(AuthLoading());

  // 1) Kontrollera att inget konto redan ligger på den emailen (valfritt)
  //    eller gör en dubblettkontroll på personnummer i en query om du vill.
  //    Om du bara vill förhindra dubletter av email räcker det med AuthException-koden
  //    'email-already-in-use'.

  try {
    // 2) Skapa Firebase Auth‐konto (email+lösen)
    final cred = await _firebaseAuth.createUserWithEmailAndPassword(
      email: event.email,
      password: event.password,
    );
    final user = cred.user!;

    // 3) Spara resten av användardatan under collection "users/{uid}"
    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .set({
      'personal_number': event.personalNumber,
      'name'           : event.username,
      'email'          : event.email,
      'created_at'     : FieldValue.serverTimestamp(),
    });

    // 4) Informera UI
    emit(AuthRegistered(event.username));
    emit(AuthAuthenticated(user.uid, user.email!));

  } on FirebaseAuthException catch (e) {
    final msg = switch (e.code) {
      'weak-password'        => 'Lösenordet är för svagt.',
      'email-already-in-use' => 'Det finns redan ett konto med den här e-posten.',
      _                      => e.message ?? 'Fel vid registrering.',
    };
    emit(AuthError(msg));

  } on FirebaseException catch (e) {
    // Firestore‐fel vid set()
    emit(AuthError('Fel vid skapande av användardokument: ${e.message ?? e}'));

  } catch (e) {
    emit(AuthError('Okänt fel: $e'));
  }
}

  Future<void> _onLogoutRequested(
    LogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    await _firebaseAuth.signOut();
    emit(AuthUnauthenticated());
  }
}
