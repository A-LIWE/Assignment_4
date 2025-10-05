import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:parking_user/blocs/auth/auth_event.dart';
import 'package:parking_user/blocs/parking_session/parking_session_bloc.dart';
import 'package:parking_user/blocs/parking_session/parking_session_event.dart';
import 'vehicles_view.dart';
import 'start_parking_view.dart';
import 'manage_parkings_view.dart';
import 'package:parking_user/blocs/auth/auth_bloc.dart';

class HomeView extends StatelessWidget {
  const HomeView({
    super.key,
    required this.userPersonalNumber,
    required this.userName,
    required this.toggleTheme,
  });

  final String userPersonalNumber;
  final String userName;
  final VoidCallback toggleTheme;

  @override
  Widget build(BuildContext context) {
    return NavigationMenu(
      userPersonalNumber: userPersonalNumber,
      userName: userName,
      toggleTheme: toggleTheme,
    );
  }
}

class NavigationMenu extends StatefulWidget {
  const NavigationMenu({
    super.key,
    required this.userPersonalNumber,
    required this.userName,
    required this.toggleTheme,
  });

  final String userPersonalNumber;
  final String userName;
  final VoidCallback toggleTheme;

  @override
  State<NavigationMenu> createState() => _NavigationMenuState();
}

class _NavigationMenuState extends State<NavigationMenu> {
  int currentPageIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          content: Text('Välkommen ${widget.userName}!'),
          duration: const Duration(seconds: 3),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: NavigationBar(
        onDestinationSelected: (int index) {
          if (index == 3) {
            showModalBottomSheet(
              context: context,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              ),
              builder: (_) {
                final isDark = Theme.of(context).brightness == Brightness.dark;
                return SafeArea(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ListTile(
                        leading: Icon(
                          isDark ? Icons.wb_sunny : Icons.nights_stay,
                        ),
                        title: Text(isDark ? 'Ljust läge' : 'Mörkt läge'),
                        onTap: () {
                          Navigator.pop(context);
                          widget.toggleTheme();
                        },
                      ),
                      ListTile(
                        leading: const Icon(Icons.logout),
                        title: const Text('Logga ut'),
                        onTap: () {
                          Navigator.pop(context);
                          context.read<AuthBloc>().add(LogoutRequested());
                        },
                      ),
                    ],
                  ),
                );
              },
            );
          } else {
            setState(() {
              currentPageIndex = index;
            });

            if (index == 2) {
              context.read<ParkingSessionBloc>().add(LoadSessions());
            }
          }
        },
        indicatorColor: Colors.amber,
        selectedIndex: currentPageIndex,
        destinations: const <Widget>[
          NavigationDestination(
            selectedIcon: Icon(Icons.directions_car),
            icon: Icon(Icons.directions_car_outlined),
            label: 'Fordon',
          ),
          NavigationDestination(
            selectedIcon: Icon(Icons.local_parking),
            icon: Icon(Icons.local_parking_outlined),
            label: 'Starta parkering',
          ),
          NavigationDestination(
            selectedIcon: Icon(Icons.timer),
            icon: Icon(Icons.timer_outlined),
            label: 'Aktiva',
          ),
          NavigationDestination(
            selectedIcon: Icon(Icons.settings),
            icon: Icon(Icons.settings_outlined),
            label: 'Inställningar',
          ),
        ],
      ),
      // IndexedStack gör att vyerna inte behövs laddas om varje gång, de behåller sitt state och behöver inte göra nya API anrop
      body: IndexedStack(
        index: currentPageIndex,
        children: [
          VehiclesView(
            key: const PageStorageKey('vehicles_view'),
            userPersonalNumber: widget.userPersonalNumber,
            userName: widget.userName,
          ),
          StartParkingView(
            key: const PageStorageKey('start_parking_view'),
            userPersonalNumber: widget.userPersonalNumber,
            userName: widget.userName,
          ),
          ManageParkingsView(
            userPersonalNumber: widget.userPersonalNumber,
            toggleTheme: widget.toggleTheme,
          ),
        ],
      ),
    );
  }
}
