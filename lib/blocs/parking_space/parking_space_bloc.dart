import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:parking_user/blocs/parking_space/parking_space_event.dart';
import 'package:parking_user/blocs/parking_space/parking_space_state.dart';
import '../../repositories/repositories.dart';

class ParkingSpaceBloc extends Bloc <ParkingSpaceEvent, ParkingSpaceState> {
  final ParkingSpaceRepository _repo;
  
   ParkingSpaceBloc(this._repo) : super(ParkingSpaceInitial()) {
    on<LoadParkingSpaces>((e, emit) async {
      emit(ParkingSpaceLoading());
      try {
        final all = await _repo.getAll();
        emit(ParkingSpaceLoaded(
          allSpaces: all,
          filteredSpaces: all,
        ));
      } catch (err) {
        emit(ParkingSpaceError('Kunde inte hämta parkeringsplatser: $err'));
      }
    });

    on<FilterParkingSpaces>((e, emit) {
      final current = state;
      if (current is ParkingSpaceLoaded) {
        final filtered = current.allSpaces
            .where((s) =>
                s.address.toLowerCase().contains(e.query.toLowerCase()))
            .toList();
        emit(ParkingSpaceLoaded(
          allSpaces: current.allSpaces,
          filteredSpaces: filtered,
          selected: current.selected,
        ));
      }
    });

    on<SelectParkingSpace>((e, emit) {
      final current = state;
      if (current is ParkingSpaceLoaded) {
        emit(ParkingSpaceLoaded(
          allSpaces: current.allSpaces,
          filteredSpaces: current.filteredSpaces,
          selected: e.space,
        ));
      }
    });
  }
}