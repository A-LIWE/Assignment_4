import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:parking_user/repositories/notification_repository.dart';
import 'package:parking_user/repositories/repositories.dart';
import 'parking_session_event.dart';
import 'parking_session_state.dart';

class ParkingSessionBloc
    extends Bloc<ParkingSessionEvent, ParkingSessionState> {
  final ParkingSessionRepository _repo;
  final NotificationRepository _notifRepo;

  ParkingSessionBloc(this._repo, this._notifRepo) : super(SessionsInitial()) {
    // 1) Ladda alla sessioner
    on<LoadSessions>((event, emit) async {
      emit(SessionsLoading());
      try {
        final all = await _repo.getAll(); // antag getAll() returnerar alla sessioner
        emit(SessionsLoaded(all));
      } catch (e) {
        final msg = e.toString().replaceFirst(RegExp(r'^Exception:?\s*'), '');
        emit(SessionsError(msg));
      }
    });

    // 2) Starta ny session
    on<StartSession>((event, emit) async {
      emit(SessionsLoading());
      try {
        await _repo.add(event.session);

        emit (SessionStarted(event.session));

        if (event.session.endTime != null) {
          await _notifRepo.scheduleReminder(
            id: event.session.vehicle.registrationNumber,
            title: 'Parkering snart slut',
            body:
                'Din parkering på ${event.session.parkingSpace.address} går ut om 15 min',
            endTime: event.session.endTime!,
          );
        }

        final all = await _repo.getAll();
        emit(SessionsLoaded(all));
      } catch (e) {
        final msg = e.toString().replaceFirst(RegExp(r'^Exception:?\s*'), '');
        emit(SessionsError(msg));
      }
    });

    // 3) Avsluta aktuell session
    on<EndSession>((event, emit) async {
      emit(SessionsLoading());
      try {
        await _repo.update(event.registrationNumber, newEndTime: DateTime.now());
        await _notifRepo.cancelReminder(event.registrationNumber);
        final all = await _repo.getAll();
        emit(SessionsLoaded(all));
      } catch (e) {
        final msg = e.toString().replaceFirst(RegExp(r'^Exception:?\s*'), '');
        emit(SessionsError(msg));
      }
    });

    // 4) Radera historisk session
    on<DeleteSession>((event, emit) async {
      emit(SessionsLoading());
      try {
        await _repo.delete(event.registrationNumber);
        final all = await _repo.getAll();
        emit(SessionsLoaded(all));
      } catch (e) {
        final msg = e.toString().replaceFirst(RegExp(r'^Exception:?\s*'), '');
        emit(SessionsError(msg));
      }
    });
  }
}
