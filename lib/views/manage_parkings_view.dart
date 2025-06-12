import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:parking_user/blocs/auth/auth_bloc.dart';
import 'package:parking_user/blocs/auth/auth_event.dart';
import 'package:parking_user/blocs/parking_session/parking_session_bloc.dart';
import 'package:parking_user/blocs/parking_session/parking_session_event.dart';
import 'package:parking_user/blocs/parking_session/parking_session_state.dart';

class ManageParkingsView extends StatelessWidget {
  const ManageParkingsView({
    super.key,
    required String userPersonalNumber,
    required this.toggleTheme,
  });

  final VoidCallback toggleTheme;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Hantera parkeringar')),
      body: BlocBuilder<ParkingSessionBloc, ParkingSessionState>(
        buildWhen:
            (previous, current) =>
                current is SessionsInitial ||
                current is SessionsLoading ||
                current is SessionsLoaded,
        builder: (ctx, state) {
          if (state is SessionsLoading || state is SessionsInitial) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is SessionsLoaded) {
            final now = DateTime.now();
            final activeSessions =
                state.sessions.where((s) {
                  // Om endTime fortfarande kan vara null: räkna dem som aktiva
                  if (s.endTime == null) return true;
                  // Annars: aktiv om sluttiden är i framtiden
                  return s.endTime!.isAfter(now);
                }).toList();
            final historicalSessions =
                state.sessions.where((s) {
                  // Endast de som verkligen är avslutade
                  return s.endTime != null && s.endTime!.isBefore(now);
                }).toList();

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Aktiva parkeringar
                  Text('Aktiva parkeringar', style: theme.textTheme.titleLarge),
                  const SizedBox(height: 8.0),
                  activeSessions.isEmpty
                      ? const Text('Inga aktiva parkeringar.')
                      : ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: activeSessions.length,
                        separatorBuilder:
                            (_, __) => const SizedBox(height: 8.0),
                        itemBuilder: (context, index) {
                          final session = activeSessions[index];
                          return Card(
                            child: ListTile(
                              title: Text(
                                '${session.parkingSpace.address} – ${session.vehicle.registrationNumber}',
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'Startad: ${session.startTime.toString().substring(0, 16)}',
                                  ),
                                  Text(
                                    'Avslutas: ${session.endTime?.toString().substring(0, 16) ?? '–'}',
                                  ),
                                ],
                              ),
                              trailing: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                ),
                                onPressed: () {
                                  context.read<ParkingSessionBloc>().add(
                                    EndSession(
                                      session.vehicle.registrationNumber,
                                    ),
                                  );
                                },
                                child: const Text('Avsluta'),
                              ),
                            ),
                          );
                        },
                      ),

                  const SizedBox(height: 24.0),

                  // Historik
                  Text('Historik', style: theme.textTheme.titleLarge),
                  const SizedBox(height: 8.0),
                  historicalSessions.isEmpty
                      ? const Text('Ingen historik tillgänglig.')
                      : ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: historicalSessions.length,
                        separatorBuilder:
                            (_, __) => const SizedBox(height: 8.0),
                        itemBuilder: (context, index) {
                          final session = historicalSessions[index];
                          return Card(
                            child: ListTile(
                              title: Text(
                                '${session.parkingSpace.address} – ${session.vehicle.registrationNumber}',
                              ),
                              subtitle: Text(
                                'Startad: ${session.startTime.toString().substring(0, 16)}\n'
                                'Avslutad: ${session.endTime!.toString().substring(0, 16)}',
                              ),
                              trailing: IconButton(
                                icon: const Icon(Icons.delete),
                                onPressed: () {
                                  context.read<ParkingSessionBloc>().add(
                                    DeleteSession(
                                      session.vehicle.registrationNumber,
                                    ),
                                  );
                                },
                              ),
                            ),
                          );
                        },
                      ),

                  const SizedBox(height: 80),

                  // Logga ut knapp
                  Center(
                    child: ElevatedButton(
                      onPressed: () {
                        context.read<AuthBloc>().add(LogoutRequested());
                      },
                      child: const Text('Logga ut'),
                    ),
                  ),
                  // Darkmode knapp
                  Positioned(
                    bottom: 16,
                    right: 16,
                    child: IconButton(
                      iconSize: 32,
                      onPressed: toggleTheme,
                      icon: Icon(
                        Theme.of(context).brightness == Brightness.dark
                            ? Icons.wb_sunny
                            : Icons.nights_stay,
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}
