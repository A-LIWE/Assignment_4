import 'package:equatable/equatable.dart';
import 'package:parking_user/models/models.dart';


/// Bas-event för ParkingSessionBloc
abstract class ParkingSessionEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

/// Ladda alla parkeringssessioner
class LoadSessions extends ParkingSessionEvent {}

/// Avsluta en aktiv parkering (sätter endTime)
class EndSession extends ParkingSessionEvent {
  final String registrationNumber;
  EndSession(this.registrationNumber);

  @override
  List<Object?> get props => [registrationNumber];
}

/// Ta bort en historisk session
class DeleteSession extends ParkingSessionEvent {
  final String registrationNumber;
  DeleteSession(this.registrationNumber);

  @override
  List<Object?> get props => [registrationNumber];
}

/// Event för att starta ny parkering
class StartSession extends ParkingSessionEvent {
  final ParkingSession session;
  StartSession(this.session);

  @override
  List<Object?> get props => [session];
}
