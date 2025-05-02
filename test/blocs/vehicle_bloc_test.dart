import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:parking_user/blocs/vehicle/vehicle_bloc.dart';
import 'package:parking_user/blocs/vehicle/vehicle_event.dart';
import 'package:parking_user/blocs/vehicle/vehicle_state.dart';
import 'package:parking_user/models/models.dart';
import '../mocks.dart';

void main() {
  late VehicleBloc bloc;
  late MockVehicleRepository mockRepo;

  // Testdata: några enkla Vehicle-objekt
  final vehicle1 = Vehicle('ABC123', 'Bil', null);
  final vehicle2 = Vehicle('XYZ999', 'Bus', null);
  final allVehicles = [vehicle1, vehicle2];

  setUp(() {
    mockRepo = MockVehicleRepository();
    bloc = VehicleBloc(mockRepo);
  });

  test('Initial state är VehiclesInitial', () {
    expect(bloc.state, isA<VehiclesInitial>());
  });

  blocTest<VehicleBloc, VehicleState>(
    'När LoadVehicles läggs på, och getAll lyckas, '
    'så skall den emitta [VehiclesLoading, VehiclesLoaded]',
    build: () {
      when(() => mockRepo.getAll()).thenAnswer((_) async => allVehicles);
      return bloc;
    },
    act: (bloc) => bloc.add(LoadVehicles()),
    expect: () => [isA<VehiclesLoading>(), VehiclesLoaded(allVehicles)],
    verify: (_) {
      verify(() => mockRepo.getAll()).called(1);
    },
  );

  blocTest<VehicleBloc, VehicleState>(
  'När LoadVehicles läggs på, och getAll kastar, '
  'så skall den emitta [VehiclesLoading, VehiclesError]',
  build: () {
    when(() => mockRepo.getAll()).thenThrow(Exception('Nätverksfel'));
    return bloc;
  },
  act: (b) => b.add(LoadVehicles()),
  expect: () => [
    isA<VehiclesLoading>(),
    isA<VehiclesError>().having(
      (e) => e.message,
      'felmeddelande',
      contains('Nätverksfel'),
    ),
  ],
);

  blocTest<VehicleBloc, VehicleState>(
  'DeleteVehicle… utan det raderade fordonet',
  build: () {
    when(() => mockRepo.delete(any()))
      .thenAnswer((_) async => ''); // returnerar en String
    when(() => mockRepo.getAll())
      .thenAnswer((_) async {
        // returnera listan *utan* fordonet som raderats
        return allVehicles
            .where((v) => v.registrationNumber != vehicle1.registrationNumber)
            .toList();
      });
    return bloc;
  },
  seed: () => VehiclesLoaded(allVehicles),
  act: (b) => b.add(DeleteVehicle(vehicle1.registrationNumber)),
  expect: () => [
    isA<VehiclesLoading>(),
    isA<VehiclesLoaded>().having(
      (s) => s.vehicles.map((v) => v.registrationNumber).toList(),
      'remaining',
      ['XYZ999'],
    ),
  ],
  verify: (_) {
    verify(() => mockRepo.delete(vehicle1.registrationNumber)).called(1);
    verify(() => mockRepo.getAll()).called(1);
  },
);}
