import 'package:equatable/equatable.dart';
import '../../models/models.dart';

abstract class VehicleState extends Equatable {
  @override
  List<Object?> get props => [];
}

class VehiclesInitial extends VehicleState {}

class VehiclesLoading extends VehicleState {}

class VehiclesLoaded extends VehicleState {
  final List<Vehicle> vehicles;
  VehiclesLoaded(this.vehicles);

  @override
  List<Object?> get props => [vehicles];
}

class VehiclesError extends VehicleState {
  final String message;
  VehiclesError(this.message);

  @override
  List<Object?> get props => [message];
}