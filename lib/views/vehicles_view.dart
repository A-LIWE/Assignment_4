import 'package:flutter/material.dart';
import 'package:parking_user/repositories/repositories.dart';
import 'package:logger/logger.dart';
import 'package:parking_user/models/models.dart';

final logger = Logger();

class VehiclesView extends StatefulWidget {
  const VehiclesView({
    super.key,
    required this.userPersonalNumber,
    required this.userName,
  });

  final String userPersonalNumber;
  final String userName;

  @override
  State<VehiclesView> createState() => _VehiclesViewState();
}

class _VehiclesViewState extends State<VehiclesView> {
  List<Vehicle> vehicles = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchVehicles();
  }

  Future<void> _fetchVehicles() async {
    setState(() {
      isLoading = true;
    });
    try {
      final vehicleRepo = VehicleRepository();
      final data = await vehicleRepo.getAll(); 
      
      // Filtrera fordon baserat på personnummer
      final filteredVehicles =
          data
              .where(
                (v) => v.owner?.personalNumber == widget.userPersonalNumber,
              )
              .toList();

      if (!mounted) return;

      if (data.isEmpty) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Inga fordon hittades")));
      } else {
        setState(() {
          vehicles = filteredVehicles;
        });
      }
    } catch (error, stackTrace) {
      logger.e(
        "Fel vid hämtning av fordon",
        error: error,
        stackTrace: stackTrace,
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Fel vid hämtning av fordon: $error")),
      );
    }
    setState(() {
      isLoading = false;
    });
  }

  // Raderar fordon baserat på fordonets registreringsnummer
  Future<void> _deleteVehicle(String registrationNumber) async {
    try {
      final vehicleRepo = VehicleRepository();
      final message = await vehicleRepo.delete(registrationNumber);

      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    } catch (error) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Fel vid radering: $error")));
    }
  }

  Future<void> _addVehicle(BuildContext parentContext) async {
    String registrationNumber = "";
    String? selectedVehicleType; 
    final List<String> vehicleTypes = ['Bil', 'Motorcykel', 'Moped', 'Buss'];

    final formKey = GlobalKey<FormState>();

    await showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text("Lägg till nytt fordon"),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Registreringsnummer med validering
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: "Registreringsnummer",
                  ),
                  textCapitalization: TextCapitalization.characters,
                  onChanged: (value) {
                    registrationNumber = value;
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Ange registreringsnummer";
                    }
                    // Omvandla till versaler för validering
                    final normalized = value.toUpperCase();
                    final regex = RegExp(r'^[A-Z]{3}\d{2}[A-Z0-9]$');
                    if (!regex.hasMatch(normalized)) {
                      return "Ogiltigt regnr Format: AAA99X";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                // Dropdown för fordonstyp
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(labelText: "Fordonstyp"),
                  value: selectedVehicleType,
                  items:
                      vehicleTypes
                          .map(
                            (type) => DropdownMenuItem(
                              value: type,
                              child: Text(type),
                            ),
                          )
                          .toList(),
                  onChanged: (value) {
                    selectedVehicleType = value;
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Välj fordonstyp";
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text("Avbryt"),
            ),
            ElevatedButton(
              onPressed: () async {
                if (!formKey.currentState!.validate()) {
                  return;
                }
                Navigator.pop(dialogContext);
                final owner = Person(
                  widget.userName,
                  widget.userPersonalNumber,
                );
                final newVehicle = Vehicle(
                  registrationNumber,
                  selectedVehicleType!,
                  owner,
                );
                final vehicleRepo = VehicleRepository();
                try {
                  await vehicleRepo.add(newVehicle);
                  if (!mounted) return;
                  _fetchVehicles();
                } catch (error) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text(error.toString())));
                }
              },
              child: const Text("Lägg till"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Mina fordon")),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : ListView.builder(
                itemCount: vehicles.length,
                itemBuilder: (context, index) {
                  final vehicle = vehicles[index];
                  return Dismissible(
                    key: Key(vehicle.uuid),
                    direction: DismissDirection.endToStart,
                    // Bekräfta radering med en alertdialog innan fordonet tas bort
                    confirmDismiss: (direction) async {
                      return await showDialog<bool>(
                        context: context,
                        builder:
                            (context) => AlertDialog(
                              title: const Text("Radera fordon"),
                              content: Text(
                                "Är du säker på att du vill radera fordonet ${vehicle.registrationNumber}?",
                              ),
                              actions: [
                                TextButton(
                                  onPressed:
                                      () => Navigator.of(context).pop(false),
                                  child: const Text("Avbryt"),
                                ),
                                TextButton(
                                  onPressed:
                                      () => Navigator.of(context).pop(true),
                                  child: const Text("Radera"),
                                ),
                              ],
                            ),
                      );
                    },
                    onDismissed: (direction) async {
                      // Anropa din raderingslogik
                      await _deleteVehicle(vehicle.registrationNumber);
                      // Ta bort fordonet lokalt från listan
                      setState(() {
                        vehicles.removeAt(index);
                      });
                    },
                    // Ange en "tom" bakgrund för att inte visa någon färg i vänstra delen
                    background: Container(),
                    // secondaryBackground används för att visa bakgrund vid svepning från höger till vänster.
                    secondaryBackground: Container(
                      color: Colors.transparent,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Container(
                            width: MediaQuery.of(context).size.width * 0.2,
                            height: double.infinity,
                            color: Colors.red,
                            child: const Icon(
                              Icons.delete,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                    child: ListTile(
                      title: Text(vehicle.registrationNumber),
                      subtitle: Text(vehicle.vehicleType),
                    ),
                  );
                },
              ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await _addVehicle(context);
        },
        label: Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Text(
              'Lägg till fordon',
              style: TextStyle(fontSize: 15), // justera textstorlek här
            ),
            SizedBox(width: 8),
            Icon(Icons.add),
          ],
        ),
      ),
    );
  }
}
