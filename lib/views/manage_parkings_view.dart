import 'package:flutter/material.dart';
import 'package:parking_user/main.dart';
import 'package:parking_user/models/models.dart';
import 'package:parking_user/repositories/repositories.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class ManageParkingsView extends StatefulWidget {
  const ManageParkingsView({super.key});

  @override
  State<ManageParkingsView> createState() => _ManageParkingsViewState();
}

class _ManageParkingsViewState extends State<ManageParkingsView> {
  bool isLoading = false;
  List<ParkingSession> activeSessions = [];
  List<ParkingSession> historicalSessions = [];

  @override
  void initState() {
    super.initState();
    _fetchParkingSessions();
  }

  Future<void> _fetchParkingSessions() async {
    setState(() {
      isLoading = true;
    });
    try {
      final sessionRepo = ParkingSessionRepository();
      final sessions =
          await sessionRepo.getAll(); 
      
      final active = sessions.where((s) => s.endTime == null).toList();
      final historical = sessions.where((s) => s.endTime != null).toList();

      if (!mounted) return;
      setState(() {
        activeSessions = active;
        historicalSessions = historical;
      });
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Fel vid hämtning av parkeringar: $error")),
      );
    }
    if (!mounted) return;
    setState(() {
      isLoading = false;
    });
  }

  /// Avslutar en aktiv parkeringssession genom att sätta endTime till nuvarande tid.
  Future<void> _endParking(ParkingSession session) async {
    try {
      
      session.endTime = DateTime.now();
      final sessionRepo = ParkingSessionRepository();
      await sessionRepo.update(
        session.vehicle.registrationNumber,
        newEndTime: DateTime.now(),
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Parkering avslutad för ${session.vehicle.registrationNumber}",
          ),
        ),
      );
      _fetchParkingSessions();
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Fel vid avslut av parkering: $error")),
      );
    }
  }

  /// Raderar en historisk parkeringssession baserat på dess uuid.
  Future<void> _deleteHistoricalSession(String regNum) async {
    try {
      final sessionRepo = ParkingSessionRepository();
      await sessionRepo.delete(regNum);
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Parkering raderad")));
      _fetchParkingSessions();
    } catch (error) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Fel vid radering: $error")));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Hantera parkeringar')),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Sektion: Aktiva parkeringar
                const Text(
                  "Aktiva parkeringar",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                activeSessions.isEmpty
                    ? const Text("Inga aktiva parkeringar hittades.")
                    : ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: activeSessions.length,
                      separatorBuilder: (context, index) => const Divider(),
                      itemBuilder: (context, index) {
                        final session = activeSessions[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 4.0),
                          child: ListTile(
                            title: Text(
                              '${session.parkingSpace.address} - ${session.vehicle.registrationNumber}',
                              style: const TextStyle(fontSize: 18),
                            ),
                            subtitle: Text(
                              'Starttid: ${session.formattedStartTime}',
                            ),
                            trailing: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                              ),
                              onPressed: () => _endParking(session),
                              child: const Text("Avsluta"),
                            ),
                          ),
                        );
                      },
                    ),
                const SizedBox(height: 24),
                // Sektion: Historik
                Text("Historik", style: theme.textTheme.titleLarge),
                const SizedBox(height: 8),
                historicalSessions.isEmpty
                    ? const Text("Ingen historik tillgänglig.")
                    : ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: historicalSessions.length,
                      separatorBuilder: (context, index) => const Divider(),
                      itemBuilder: (context, index) {
                        final session = historicalSessions[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 4.0),
                          child: ListTile(
                            title: Text(
                              '${session.parkingSpace.address} - ${session.vehicle.registrationNumber}',
                              style: const TextStyle(fontSize: 18),
                            ),
                            subtitle: Text(
                              'Starttid: ${session.formattedStartTime}\nSluttid: ${session.formattedEndTime}',
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed:
                                  () => _deleteHistoricalSession(
                                    session.vehicle.registrationNumber,
                                  ),
                            ),
                          ),
                        );
                      },
                    ),
                const SizedBox(height: 80),
                // Logga ut-knapp
                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      context.read<AuthProvider>().logout();
                    },
                    child: const Text("Logga ut"),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
          // Darkmode toggle-knapp
          Positioned(
            bottom: 16,
            right: 16,
            child: IconButton(
              iconSize: 32,
              onPressed: () => myAppKey.currentState?.toggleTheme(),
              icon: Icon(
                Theme.of(context).brightness == Brightness.dark
                    ? Icons.wb_sunny
                    : Icons.nights_stay,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
