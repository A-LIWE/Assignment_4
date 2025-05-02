import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:parking_user/blocs/vehicle/vehicle_bloc.dart';
import 'package:parking_user/blocs/vehicle/vehicle_event.dart';
import 'package:parking_user/blocs/vehicle/vehicle_state.dart';
import 'package:logger/logger.dart';
import 'package:parking_user/models/models.dart';

final logger = Logger();

class VehiclesView extends StatelessWidget {
final String userPersonalNumber;
  final String userName;

  const VehiclesView({
    super.key,
    required this.userPersonalNumber,
    required this.userName,
  });

  

 @override
  Widget build(BuildContext context) {
    return
      Scaffold(
        appBar: AppBar(title: const Text('Dina fordon')),
        body: BlocBuilder<VehicleBloc, VehicleState>(
          builder: (context, state) {
            if (state is VehiclesLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is VehiclesError) {
              return Center(child: Text('Fel: ${state.message}'));
            }

            if (state is VehiclesLoaded) {
              // Filtrera på personalNumber
              final vehicles = state.vehicles
                  .where((v) => v.owner?.personalNumber == userPersonalNumber)
                  .toList();

              if (vehicles.isEmpty) {
                return const Center(child: Text('Inga fordon hittades.'));
              }

              return ListView.builder(
                itemCount: vehicles.length,
                itemBuilder: (context, index) {
                  final v = vehicles[index];
                  return Dismissible(
                    key: Key(v.registrationNumber),
                    background: Container(
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 20),
                      color: Colors.red,
                      child: const Icon(Icons.delete, color: Colors.white),
                    ),
                    direction: DismissDirection.endToStart,
                    confirmDismiss: (direction) async {
                      context.read<VehicleBloc>().add(DeleteVehicle(v.registrationNumber));
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Raderade ${v.registrationNumber}')),
                      );
                      return true;
                    },
                    child: ListTile(
                      title: Text(v.registrationNumber),
                      subtitle: Text(v.vehicleType),
                    ),
                  );
                },
              );
            }

            // initial state
            return const SizedBox.shrink();
          },
        ),

        // Lägg till nytt fordon
        floatingActionButton: FloatingActionButton(
          onPressed: () => _showAddDialog(context),
          child: const Icon(Icons.add),
        ),
      );
    
  }

  void _showAddDialog(BuildContext context) {
    String registrationNumber = '';
    String? selectedVehicleType;
    final formKey = GlobalKey<FormState>();
    const vehicleTypes = ['Bil', 'Motorcykel', 'Moped', 'Buss'];

    showDialog<void>(
      context: context,
      builder: (dialogCtx) {
        return AlertDialog(
          title: const Text("Lägg till nytt fordon"),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Regnr
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Registreringsnummer'),
                  textCapitalization: TextCapitalization.characters,
                  onChanged: (v) => registrationNumber = v,
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Fyll i regnr';
                    final norm = v.toUpperCase();
                    final regex = RegExp(r'^[A-Z]{3}\d{2}[A-Z0-9]$');
                    if (!regex.hasMatch(norm)) return 'Format: AAA99X';
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                // Fordonstyp
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(labelText: 'Fordonstyp'),
                  items: vehicleTypes
                      .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                      .toList(),
                  onChanged: (v) => selectedVehicleType = v,
                  validator: (v) => v == null ? 'Välj typ' : null,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(dialogCtx), child: const Text('Avbryt')),
            ElevatedButton(
              onPressed: () {
                if (formKey.currentState?.validate() != true) return;
                Navigator.pop(dialogCtx);

                // Skapa Vehicle‐objekt och skicka AddVehicle
                final owner = Person(userName, userPersonalNumber);
                final newV = Vehicle(registrationNumber, selectedVehicleType!, owner);

                context.read<VehicleBloc>().add(AddVehicle(newV));
              },
              child: const Text('Lägg till'),
            ),
          ],
        );
      },
    );
  }
}
