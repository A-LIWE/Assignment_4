import 'package:flutter/material.dart';
import 'vehicles_view.dart';
import 'start_parking_view.dart';
import 'manage_parkings_view.dart';

class HomeView extends StatelessWidget {
  const HomeView({
    super.key,
    required this.userPersonalNumber,
    required this.userName,
  });

  final String userPersonalNumber;
  final String userName;

  @override
  Widget build(BuildContext context) {
    return NavigationMenu(
      userPersonalNumber: userPersonalNumber,
      userName: userName,
    );
  }
}

class NavigationMenu extends StatefulWidget {
  const NavigationMenu({
    super.key,
    required this.userPersonalNumber,
    required this.userName,
  });

  final String userPersonalNumber;
  final String userName;

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
          ManageParkingsView(key: const PageStorageKey('manage_parkings_view')),
        ],
      ),
    );
  }
}
