import 'package:mocktail/mocktail.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:parking_user/blocs/parking_session/parking_session_bloc.dart';
import 'package:parking_user/blocs/parking_session/parking_session_event.dart';
import 'package:parking_user/blocs/parking_session/parking_session_state.dart';
import 'package:parking_user/models/models.dart';
import '../mocks.dart';

void main() {
  late ParkingSessionBloc bloc;
  late MockParkingSessionRepository mockRepo;
  late MockNotificationRepository mockNotifRepo;

  // Exempel‐objekt för testerna
  final dummyVehicle = Vehicle('ABC123', 'BIL', null);
  final dummySpace = ParkingSpace('P1', 'Adress 1', 30);
  final session1 = ParkingSession(
    dummyVehicle,
    dummySpace,
    DateTime(2025, 5, 1, 8, 0),
  );
  final session2 = ParkingSession(
    dummyVehicle,
    dummySpace,
    DateTime(2025, 5, 1, 9, 0),
  );

  setUpAll(() {
    registerFallbackValue(session1);
  });

  setUp(() {
    mockRepo = MockParkingSessionRepository();
    mockNotifRepo =MockNotificationRepository();
    bloc = ParkingSessionBloc(mockRepo, mockNotifRepo);
  });

  tearDown(() {
    bloc.close();
  });

  test('initial state är SessionsInitial', () {
    expect(bloc.state, isA<SessionsInitial>());
  });

  blocTest<ParkingSessionBloc, ParkingSessionState>(
    'LoadSessions – lyckad hämtning ger [SessionsLoading, SessionsLoaded]',
    build: () {
      when(
        () => mockRepo.getAll(),
      ).thenAnswer((_) async => [session1, session2]);
      return bloc;
    },
    act: (b) => b.add(LoadSessions()),
    expect:
        () => [
          isA<SessionsLoading>(),
          isA<SessionsLoaded>().having((s) => s.sessions, 'sessions', [
            session1,
            session2,
          ]),
        ],
  );

  blocTest<ParkingSessionBloc, ParkingSessionState>(
    'LoadSessions – fel i repo ger [SessionsLoading, SessionsError]',
    build: () {
      when(() => mockRepo.getAll()).thenThrow(Exception('Serverfel'));
      return bloc;
    },
    act: (b) => b.add(LoadSessions()),
    expect:
        () => [
          isA<SessionsLoading>(),
          isA<SessionsError>().having(
            (s) => s.message,
            'message',
            contains('Serverfel'),
          ),
        ],
  );

  blocTest<ParkingSessionBloc, ParkingSessionState>(
    'StartSession – lyckat start ger [SessionsLoading, SessionStarted, SessionsLoaded]',
    build: () {
      when(() => mockRepo.add(any())).thenAnswer(
        (_) async =>
            '✅ Parkering startad för ${session1.vehicle.registrationNumber}.',
      );
      when(() => mockRepo.getAll()).thenAnswer((_) async => [session1]);
      return bloc;
    },
    act: (b) => b.add(StartSession(session1)),
    expect:
        () => [
          isA<SessionsLoading>(),
          isA<SessionStarted>().having((e) => e.session, 'session', session1),
          isA<SessionsLoaded>().having((s) => s.sessions, 'sessions', [
            session1,
          ]),
        ],
  );

  blocTest<ParkingSessionBloc, ParkingSessionState>(
    'StartSession – om repo kastar, ger [SessionsLoading, SessionsError]',
    build: () {
      when(() => mockRepo.add(any())).thenThrow(Exception('Redan aktiv'));
      return bloc;
    },
    act: (b) => b.add(StartSession(session1)),
    expect:
        () => [
          isA<SessionsLoading>(),
          isA<SessionsError>().having(
            (s) => s.message,
            'message',
            contains('Redan aktiv'),
          ),
        ],
  );

  blocTest<ParkingSessionBloc, ParkingSessionState>(
    'EndSession – lyckat avslut ger [SessionsLoading, SessionsLoaded]',
    seed: () => SessionsLoaded([session1]),
    build: () {
      when(
        () => mockRepo.update(any(), newEndTime: any(named: 'newEndTime')),
      ).thenAnswer(
        (_) async =>
            '✅ Parkering avslutad kl ${session2.endTime!.hour.toString().padLeft(2, '0')}:'
            '${session2.endTime!.minute.toString().padLeft(2, '0')}.',
      );
      when(() => mockRepo.getAll()).thenAnswer((_) async => [session2]);
      return bloc;
    },
    act: (b) => b.add(EndSession(session1.vehicle.registrationNumber)),
    expect:
        () => [
          isA<SessionsLoading>(),
          isA<SessionsLoaded>().having((s) => s.sessions, 'sessions', [
            session2,
          ]),
        ],
  );

  blocTest<ParkingSessionBloc, ParkingSessionState>(
    'EndSession – fel i repo ger [SessionsLoading, SessionsError]',
    seed: () => SessionsLoaded([session1]),
    build: () {
      when(
        () => mockRepo.update(any(), newEndTime: any(named: 'newEndTime')),
      ).thenThrow(Exception('Ingen aktiv session'));
      return bloc;
    },
    act: (b) => b.add(EndSession(session1.vehicle.registrationNumber)),
    expect:
        () => [
          isA<SessionsLoading>(),
          isA<SessionsError>().having(
            (s) => s.message,
            'message',
            contains('Ingen aktiv session'),
          ),
        ],
  );
}
