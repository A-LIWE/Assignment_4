import 'package:equatable/equatable.dart';
import 'package:parking_user/models/models.dart';

abstract class VehicleEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

/// Sätt igång hämtning av alla fordon
class LoadVehicles extends VehicleEvent {}

class AddVehicle extends VehicleEvent {
  final Vehicle vehicle;
  AddVehicle(this.vehicle);
}

/// Ta bort ett fordon
class DeleteVehicle extends VehicleEvent {
  final String registrationNumber;
  DeleteVehicle(this.registrationNumber);

  @override
  List<Object?> get props => [registrationNumber];
}
// Lägg till fler events (AddVehicle, UpdateVehicle) vid behov