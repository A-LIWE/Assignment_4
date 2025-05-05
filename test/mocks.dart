import 'package:mocktail/mocktail.dart';
import 'package:parking_user/repositories/repositories.dart';
import 'package:parking_user/models/models.dart';

class MockVehicleRepository extends Mock implements VehicleRepository {}

class FakeVehicle extends Fake implements Vehicle {}

class MockParkingSpaceRepository extends Mock implements ParkingSpaceRepository {}

class FakeParkingSpace extends Fake implements ParkingSpace {}
class MockParkingSessionRepository extends Mock
    implements ParkingSessionRepository {}