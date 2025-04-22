import 'package:flutter/material.dart';
import 'package:parking_user/repositories/repositories.dart';
import 'package:parking_user/models/models.dart';
import 'package:parking_user/views/vehicles_view.dart';

class StartParkingView extends StatefulWidget {
  const StartParkingView({super.key, required this.userPersonalNumber, required this.userName});

  final String userPersonalNumber;
  final String userName;

  @override
  State<StartParkingView> createState() => _StartParkingViewState();
}

class _StartParkingViewState extends State<StartParkingView> {
  bool isLoading = false;
  List<ParkingSpace> parkingSpaces = [];
  List<ParkingSpace> filteredParkingSpaces = [];
  List<Vehicle> vehicles = [];
  ParkingSpace? selectedSpace;
  Vehicle? selectedVehicle;
  String searchQuery = "";

  @override
  void initState() {
    super.initState();
    _fetchParkingSpaces();
    _fetchVehicles();
  }

  Future<void> _fetchParkingSpaces() async {
    setState(() {
      isLoading = true;
    });
    try {
      final parkingSpaceRepo = ParkingSpaceRepository();
      final data = await parkingSpaceRepo.getAll();
      setState(() {
        parkingSpaces = data;
        filteredParkingSpaces = List.from(parkingSpaces);
      });
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Fel vid hämtning av parkeringsplatser: $error")),
      );
    }
    if (!mounted) return;
    setState(() {
      isLoading = false;
    });
  }

  Future<void> _fetchVehicles() async {
    setState(() {
      isLoading = true;
    });
    try {
      final vehicleRepo = VehicleRepository();
      final data = await vehicleRepo.getAll();
      // Filtrera fordon baserat på personnummer
      final filteredVehicles = data
          .where((v) => v.owner?.personalNumber == widget.userPersonalNumber)
          .toList();
      if (!mounted) return;
      if (data.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Inga fordon hittades")),
        );
      } else {
        setState(() {
          vehicles = filteredVehicles;
        });
      }
    } catch (error, stackTrace) {
      logger.e("Fel vid hämtning av fordon", error: error, stackTrace: stackTrace);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Fel vid hämtning av fordon: $error")),
      );
    }
    setState(() {
      isLoading = false;
    });
  }

  // sökfunktion, filtrerar på address
  void _filterParkingSpaces(String query) {
    setState(() {
      searchQuery = query;
      if (query.isEmpty) {
        filteredParkingSpaces = List.from(parkingSpaces);
      } else {
        filteredParkingSpaces = parkingSpaces.where((space) {
          return space.address.toLowerCase().contains(query.toLowerCase());
        }).toList();
      }
    });
  }

  Future<void> _startParking() async {
    if (selectedSpace == null || selectedVehicle == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Vänligen välj både parkeringsplats och fordon.")),
      );
      return;
    }

    final startTime = DateTime.now();
    final newSession = ParkingSession(selectedVehicle!, selectedSpace!, startTime);
    
    try {
      await ParkingSessionRepository().add(newSession);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Parkering startad kl ${startTime.hour}:${startTime.minute.toString().padLeft(2, '0')}"),
        ),
      );
      setState(() {
        selectedSpace = null;
        selectedVehicle = null;
      });
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Fel vid start av parkering: $error")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Starta parkering"),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    decoration: const InputDecoration(
                      labelText: "Sök på adress",
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) {
                      _filterParkingSpaces(value);
                    },
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Välj en ledig parkeringsplats:",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: filteredParkingSpaces.length,
                    separatorBuilder: (context, index) => const Divider(),
                    itemBuilder: (context, index) {
                      final space = filteredParkingSpaces[index];
                      return ListTile(
                        title: Text(
                          space.address,
                          style: const TextStyle(fontSize: 18),
                        ),
                        subtitle: Text("Pris per timme: ${space.formattedPrice}"),
                        selected: selectedSpace == space,
                        onTap: () {
                          setState(() {
                            selectedSpace = space;
                          });
                        },
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    "Välj vilket fordon du vill parkera med:",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: vehicles.length,
                    separatorBuilder: (context, index) => const Divider(),
                    itemBuilder: (context, index) {
                      final vehicle = vehicles[index];
                      return ListTile(
                        title: Text(
                          vehicle.registrationNumber,
                          style: const TextStyle(fontSize: 18),
                        ),
                        subtitle: Text(vehicle.vehicleType),
                        selected: selectedVehicle == vehicle,
                        onTap: () {
                          setState(() {
                            selectedVehicle = vehicle;
                          });
                        },
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                  Center(
                    child: ElevatedButton(
                      onPressed: _startParking,
                      child: const Text(
                        "Starta parkering",
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}