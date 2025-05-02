import 'package:mocktail/mocktail.dart';
import 'package:parking_user/repositories/repositories.dart';
import 'package:parking_user/models/models.dart';

// Mock för VehicleRepository
class MockVehicleRepository extends Mock implements VehicleRepository {}

// Eftersom vi i Bloc hanterar Vehicle-objekt behöver vi också registrera
// ett fallback-value för when() om vi använder argumentmatchers:
class FakeVehicle extends Fake implements Vehicle {}

/// 1) Mocka repository‐klassen
class MockParkingSpaceRepository extends Mock implements ParkingSpaceRepository {}

/// 2) Registrera en fake‐klass för alla typer som du matchar med any<Foo>()
class FakeParkingSpace extends Fake implements ParkingSpace {}

class MockParkingSessionRepository extends Mock
    implements ParkingSessionRepository {}

    /// Fake-klass för ParkingSession, behövs när du använder argument-matchers
class FakeParkingSession extends Fake implements ParkingSession {}