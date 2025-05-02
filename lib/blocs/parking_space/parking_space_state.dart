import 'package:equatable/equatable.dart';
import 'package:parking_user/models/models.dart';

abstract class ParkingSpaceState extends Equatable {
  @override
  List<Object?> get props => [];
}

/// Initialt state innan något laddats
class ParkingSpaceInitial extends ParkingSpaceState {}

/// Visas medan vi hämtar parkeringsplatser
class ParkingSpaceLoading extends ParkingSpaceState {}

/// När vi fått en lista parkeringsplatser (med valfri filtrering)
class ParkingSpaceLoaded extends ParkingSpaceState {
  final List<ParkingSpace> allSpaces;
  final List<ParkingSpace> filteredSpaces;
  final ParkingSpace? selected;

  ParkingSpaceLoaded({
    required this.allSpaces,
    required this.filteredSpaces,
    this.selected,
  });

  @override
  List<Object?> get props => [
        allSpaces,
        filteredSpaces,
        selected,
      ];
}

/// Vid felhämtning
class ParkingSpaceError extends ParkingSpaceState {
  final String message;
  ParkingSpaceError(this.message);

  @override
  List<Object?> get props => [message];
}
