import 'package:equatable/equatable.dart';
import 'package:parking_user/models/models.dart';

abstract class ParkingSpaceEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadParkingSpaces extends ParkingSpaceEvent {}

/// Filtrera parkeringsplatser baserat på söksträng
class FilterParkingSpaces extends ParkingSpaceEvent {
  final String query;
  FilterParkingSpaces(this.query);
  @override
  List<Object?> get props => [query];
}

/// Markera ett parkeringsutrymme som valt
class SelectParkingSpace extends ParkingSpaceEvent {
  final ParkingSpace space;
  SelectParkingSpace(this.space);
  @override
  List<Object?> get props => [space];
}
