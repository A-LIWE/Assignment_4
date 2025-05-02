import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:parking_user/blocs/parking_session/parking_session_bloc.dart';
import 'package:parking_user/blocs/parking_session/parking_session_event.dart';
import 'package:parking_user/blocs/parking_space/parking_space_bloc.dart';
import 'package:parking_user/blocs/parking_space/parking_space_event.dart';
import 'package:parking_user/blocs/vehicle/vehicle_bloc.dart';
import 'package:parking_user/blocs/vehicle/vehicle_event.dart';
import 'package:parking_user/providers/auth_provider.dart';
import 'package:parking_user/repositories/repositories.dart';
import 'package:parking_user/views/auth_gate.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final GlobalKey<MyAppState> myAppKey = GlobalKey<MyAppState>();
final supabase = Supabase.instance.client;

Future<void> main() async {
  await Supabase.initialize(
    url: 'https://ywvoteqcrohgusjawaqg.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Inl3dm90ZXFjcm9oZ3VzamF3YXFnIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDAxNDM3NjUsImV4cCI6MjA1NTcxOTc2NX0.3mnwht5XOgYNM6Zn5qK-qft_5FJZvTtP-13AggbUycw',
  );
  runApp(
    MultiProvider(
      providers: [
        // AuthProvider för att lyssna på "inloggad eller ej"
        ChangeNotifierProvider(create: (_) => AuthProvider()),

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