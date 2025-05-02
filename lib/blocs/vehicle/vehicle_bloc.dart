import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:parking_user/models/models.dart';
import 'vehicle_event.dart';
import 'vehicle_state.dart';
import '../../repositories/repositories.dart';

class VehicleBloc extends Bloc<VehicleEvent, VehicleState> {
  final VehicleRepository _repo;
  VehicleBloc(this._repo) : super(VehiclesInitial()) {
    on<LoadVehicles>((event, emit) async {
      emit(VehiclesLoading());
      try {
        final vehicles = await _repo.getAll();
        emit(VehiclesLoaded(vehicles));
      } catch (e) {
        emit(VehiclesError(e.toString()));
      }
    });

    on<AddVehicle>((event, emit) async {
      if (state is VehiclesLoaded) {
        final current = (state as VehiclesLoaded).vehicles;
        // Optimistisk uppdatering: emitea en state med det nya fordonet direkt
        final optimistic = List<Vehicle>.from(current)..add(event.vehicle);
        emit(VehiclesLoaded(optimistic));
        // Visa loading­-indikator
        try {
          // Lägg till på servern
          await _repo.add(event.vehicle);

          // Hämta om uppdaterad lista från servern
          final refreshed = await _repo.getAll();

          // Emitera uppdaterad lista
          emit(VehiclesLoaded(refreshed));

        } catch (err) {
          // om något går fel, rulla tillbaka till ursprunglig lista
          emit(VehiclesLoaded(current));
          emit(VehiclesError('Kunde inte lägga till fordon: $err'));
        }
      }
    });

    on<DeleteVehicle>((event, emit) async {
      emit(VehiclesLoading());
      try {
        // 1) Radera på servern
        await _repo.delete(event.registrationNumber);

        // 2) Hämta om hela listan
        final all = await _repo.getAll();

        // 3) Emitera det nya state:t
        emit(VehiclesLoaded(all));
      } catch (e) {
        emit(VehiclesError('Kunde inte radera fordon: $e'));
      }
    });
  }
}
