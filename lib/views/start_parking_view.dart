import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:parking_user/blocs/parking_session/parking_session_bloc.dart';
import 'package:parking_user/blocs/parking_session/parking_session_event.dart';
import 'package:parking_user/blocs/parking_session/parking_session_state.dart';
import 'package:parking_user/blocs/parking_space/parking_space_bloc.dart';
import 'package:parking_user/blocs/parking_space/parking_space_state.dart';
import 'package:parking_user/blocs/vehicle/vehicle_bloc.dart';
import 'package:parking_user/blocs/vehicle/vehicle_state.dart';
import '../models/models.dart';


class StartParkingView extends StatefulWidget {
  const StartParkingView({
    super.key,
    required this.userPersonalNumber,
    required this.userName,
  });

  final String userPersonalNumber;
  final String userName;

  @override
  State<StartParkingView> createState() => _StartParkingViewState();
}

class _StartParkingViewState extends State<StartParkingView> {
  String _searchQuery = "";

  void _onSearchChanged(String q) => setState(() => _searchQuery = q);

  void _showVehiclePicker(BuildContext ctx, ParkingSpace space) {
    Vehicle? selectedVehicle;
    showModalBottomSheet(
      context: ctx,
      isScrollControlled: true,
      builder: (bottomCtx) => Padding(
        padding: MediaQuery.of(bottomCtx).viewInsets,
        child: StatefulBuilder(
          builder: (context, setModalState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 16),
                Text("Starta parkering på", style: Theme.of(ctx).textTheme.titleMedium),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text(space.address,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
                const Divider(),

                // Fordonslista
                BlocBuilder<VehicleBloc, VehicleState>(
                  builder: (_, vState) {
                    if (vState is VehiclesLoading) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (vState is VehiclesError) {
                      return Center(child: Text(vState.message));
                    } else if (vState is VehiclesLoaded) {
                      final yourVehicles = vState.vehicles
                          .where((v) =>
                              v.owner?.personalNumber == widget.userPersonalNumber)
                          .toList();
                      if (yourVehicles.isEmpty) {
                        return const Padding(
                          padding: EdgeInsets.all(16),
                          child: Text("Inga fordon registrerade."),
                        );
                      }
                      return Column(
                        children: yourVehicles.map((v) {
                          return RadioListTile<Vehicle>(
                            title: Text(v.registrationNumber),
                            subtitle: Text(v.vehicleType),
                            value: v,
                            groupValue: selectedVehicle,
                            onChanged: (sel) => setModalState(() => selectedVehicle = sel),
                          );
                        }).toList(),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),

                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ElevatedButton(
                    onPressed: selectedVehicle == null
                        ? null
                        : () {
                            final session = ParkingSession(
                              selectedVehicle!,
                              space,
                              DateTime.now(),
                            );
                            // Dispatcha event
                            ctx.read<ParkingSessionBloc>().add(StartSession(session));
                            Navigator.pop(bottomCtx);
                          },
                    child: const Text("Starta parkering"),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ParkingSessionBloc, ParkingSessionState>(
      listener: (ctx, state) {
        if (state is SessionStarted) {
          final t = state.session.startTime;
          ScaffoldMessenger.of(ctx).showSnackBar(
            SnackBar(
              content: Text(
                "Parkering startad kl med fordon... ${t.hour}:${t.minute.toString().padLeft(2, '0')}",
              ),
            ),
          );
        } else if (state is SessionsError) {
          ScaffoldMessenger.of(ctx).showSnackBar(
            SnackBar(content: Text("Fel vid start av parkering: ${state.message}")),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(title: const Text("Starta parkering")),
        body: Column(
          children: [
            // 1) Sökfält
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                decoration: const InputDecoration(
                  labelText: "Sök parkeringsplats",
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(),
                ),
                onChanged: _onSearchChanged,
              ),
            ),

            // 2) Lista parkeringsplatser
            Expanded(
              child: BlocBuilder<ParkingSpaceBloc, ParkingSpaceState>(
                builder: (_, state) {
                  if (state is ParkingSpaceLoading) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (state is ParkingSpaceError) {
                    return Center(child: Text(state.message));
                  } else if (state is ParkingSpaceLoaded) {
                    final spaces = state.filteredSpaces.where((s) {
                      return s.address
                          .toLowerCase()
                          .contains(_searchQuery.toLowerCase());
                    }).toList();
                    if (spaces.isEmpty) {
                      return const Center(child: Text("Inga parkeringsplatser hittades."));
                    }
                    return ListView.separated(
                      itemCount: spaces.length,
                      separatorBuilder: (_, __) => const Divider(),
                      itemBuilder: (_, i) {
                        final space = spaces[i];
                        return ListTile(
                          title: Text(space.address),
                          subtitle: Text(
                            space.pph % 1 == 0
                                ? "${space.pph.toInt()} kr/tim"
                                : "${space.pph} kr/tim",
                          ),
                          onTap: () => _showVehiclePicker(context, space),
                        );
                      },
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}