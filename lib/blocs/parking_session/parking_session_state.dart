import 'package:equatable/equatable.dart';
import 'package:parking_user/models/models.dart';

/// Bas-state för ParkingSessionBloc
abstract class ParkingSessionState extends Equatable {
  @override
  List<Object?> get props => [];
}

/// Innan något laddats
class SessionsInitial extends ParkingSessionState {}

/// När vi väntar på API-svar
class SessionsLoading extends ParkingSessionState {}

/// När vi har en lista med alla sessions
class SessionsLoaded extends ParkingSessionState {
  final List<ParkingSession> sessions;
  SessionsLoaded(this.sessions);

  @override
  List<Object?> get props => [sessions];
}

class SessionStarted extends ParkingSessionState {
  /// Den nya session som just startades
  final ParkingSession session;
  SessionStarted(this.session);
  @override
  List<Object?> get props => [session];
}

/// Fel‐state
class SessionsError extends ParkingSessionState {
  final String message;
  SessionsError(this.message);

  @override
  List<Object?> get props => [message];
}
