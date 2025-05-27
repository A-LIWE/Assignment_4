import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:parking_user/blocs/auth/auth_bloc.dart';
import 'package:parking_user/blocs/parking_session/parking_session_bloc.dart';
import 'package:parking_user/blocs/parking_session/parking_session_event.dart';
import 'package:parking_user/blocs/parking_space/parking_space_bloc.dart';
import 'package:parking_user/blocs/parking_space/parking_space_event.dart';
import 'package:parking_user/blocs/vehicle/vehicle_bloc.dart';
import 'package:parking_user/blocs/vehicle/vehicle_event.dart';
import 'package:parking_user/repositories/repositories.dart';
import 'package:parking_user/views/auth_gate.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

final GlobalKey<MyAppState> myAppKey = GlobalKey<MyAppState>();


void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // ← viktigt!
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(
    MultiProvider(
      providers: [
        // AuthProvider för att lyssna på "inloggad eller ej"
        BlocProvider(create: (_) => AuthBloc()),

        // Exempel: VehicleBloc som hämtar fordon
        BlocProvider<VehicleBloc>(
          create: (_) {
            final bloc = VehicleBloc(VehicleRepository());
            bloc.add(LoadVehicles()); // kör initial Load
            return bloc;
          },
        ),

        BlocProvider<ParkingSpaceBloc>(
          create: (_) {
            final bloc = ParkingSpaceBloc(ParkingSpaceRepository());
            bloc.add(LoadParkingSpaces()); 
            return bloc;
          },
        ),

        BlocProvider<ParkingSessionBloc>(
          create: (_) {
            final bloc = ParkingSessionBloc(ParkingSessionRepository());
            bloc.add(LoadSessions()); 
            return bloc;
          },
        ),
      ],
      child: MyApp(key: myAppKey),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({required super.key});
  
  @override
  MyAppState createState() => MyAppState();
}

class MyAppState extends State<MyApp> {
  // Startar med systemets tema (kan vara ljus eller mörkt beroende på enhetens inställningar)
  ThemeMode _themeMode = ThemeMode.system;
  
  /// Toggle för att växla mellan dark och light mode.
  void toggleTheme() {
    setState(() {
      _themeMode =
          (_themeMode == ThemeMode.light) ? ThemeMode.dark : ThemeMode.light;
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Parking User',
      theme: ThemeData(
        brightness: Brightness.light,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.orange),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.orange,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      themeMode: _themeMode,
      home: const AuthGate(),
    );
  }
}