import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:parking_user/blocs/parking_session/parking_session_bloc.dart';
import 'package:parking_user/blocs/parking_session/parking_session_event.dart';
import 'vehicles_view.dart';
import 'start_parking_view.dart';
import 'manage_parkings_view.dart';

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
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: NavigationBar(
        onDestinationSelected: (int index) {
          setState(() {
            currentPageIndex = index;
          });
          if (index == 2) {
            context.read<ParkingSessionBloc>().add(LoadSessions());
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
