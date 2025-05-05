import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:parking_user/blocs/parking_space/parking_space_bloc.dart';
import 'package:parking_user/blocs/parking_space/parking_space_event.dart';
import 'package:parking_user/blocs/parking_space/parking_space_state.dart';
import 'package:parking_user/models/models.dart';
import '../mocks.dart';

void main() {
  late ParkingSpaceBloc bloc;
  late MockParkingSpaceRepository mockRepo;

  final space1 = ParkingSpace('A1', 'Gatan 1', 30.0);
  final space2 = ParkingSpace('B2', 'Gatan 2', 45.5);
  final allSpaces = [space1, space2];

  setUp(() {
    mockRepo = MockParkingSpaceRepository();
    bloc = ParkingSpaceBloc(mockRepo);
  });

  tearDown(() {
    bloc.close();
  });

  test('initial state är ParkingSpaceInitial', () {
    expect(bloc.state, isA<ParkingSpaceInitial>());
  });

  blocTest<ParkingSpaceBloc, ParkingSpaceState>(
    'LoadParkingSpaces: success',
    build: () {
      when(() => mockRepo.getAll()).thenAnswer((_) async => allSpaces);
      return bloc;
    },
    act: (b) => b.add(LoadParkingSpaces()),
    expect: () => [
      isA<ParkingSpaceLoading>(),
      isA<ParkingSpaceLoaded>().having((s) => s.allSpaces, 'allSpaces', allSpaces),
    ],
  );

  blocTest<ParkingSpaceBloc, ParkingSpaceState>(
    'LoadParkingSpaces: error',
    build: () {
      when(() => mockRepo.getAll()).thenThrow(Exception('Nätverksfel'));
      return bloc;
    },
    act: (b) => b.add(LoadParkingSpaces()),
    expect: () => [
      isA<ParkingSpaceLoading>(),
      isA<ParkingSpaceError>().having((e) => e.message, 'message', contains('Nätverksfel')),
    ],
  );

  blocTest<ParkingSpaceBloc, ParkingSpaceState>(
    'FilterParkingSpaces: filtrerar lokalt',
    build: () => bloc,
    seed: () => ParkingSpaceLoaded(
      allSpaces: allSpaces,
      filteredSpaces: allSpaces,
    ),
    act: (b) => b.add(FilterParkingSpaces('Gatan 1')),
    expect: () => [
      isA<ParkingSpaceLoaded>().having((s) => s.filteredSpaces, 'filtered', [space1]),
    ],
  );

  blocTest<ParkingSpaceBloc, ParkingSpaceState>(
    'SelectParkingSpace: sparar valt space',
    build: () => bloc,
    seed: () => ParkingSpaceLoaded(
      allSpaces: allSpaces,
      filteredSpaces: allSpaces,
    ),
    act: (b) => b.add(SelectParkingSpace(space2)),
    expect: () => [
      isA<ParkingSpaceLoaded>().having((s) => s.selected, 'selected', space2),
    ],
  );
}
