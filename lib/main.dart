import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:parking_user/blocs/auth/auth_bloc.dart';
import 'package:parking_user/blocs/parking_session/parking_session_bloc.dart';
import 'package:parking_user/blocs/parking_session/parking_session_event.dart';
import 'package:parking_user/blocs/parking_space/parking_space_bloc.dart';
import 'package:parking_user/blocs/parking_space/parking_space_event.dart';
import 'package:parking_user/blocs/vehicle/vehicle_bloc.dart';
import 'package:parking_user/blocs/vehicle/vehicle_event.dart';
import 'package:parking_user/repositories/notification_repository.dart';
import 'package:parking_user/repositories/repositories.dart';
import 'package:parking_user/views/auth_gate.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

final GlobalKey<MyAppState> myAppKey = GlobalKey<MyAppState>();

Future<void> _configureLocalTimeZone() async {
  // On the web or Linux, flutter_timezone isn't supported, so skip.
  if (kIsWeb || Platform.isLinux) {
    return;
  }

  // 1. Load all available time zones
  tz.initializeTimeZones();

  // 2. On Windows you can just use the default (skip the rest)
  if (Platform.isWindows) {
    return;
  }

  // 3. Query the device’s current timezone
  final String timeZoneName = await FlutterTimezone.getLocalTimezone();

  // 4. Tell the tz package what “local” means
  tz.setLocalLocation(tz.getLocation(timeZoneName));
}

Future<FlutterLocalNotificationsPlugin> initializeNotifications() async {
  var flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  var initializationSettingsAndroid = const AndroidInitializationSettings(
    'notification_2',
  );
  var initializationSettingsDarwin = const DarwinInitializationSettings();
  var initializationSettingsLinux = const LinuxInitializationSettings(
    defaultActionName: 'Open notification',
  );

  const WindowsInitializationSettings initializationSettingsWindows =
      WindowsInitializationSettings(
        appName: 'parking_user',
        appUserModelId: 'Com.Example.App',
        guid: '9ccd69ae-137d-420e-8c05-e1452333751e',
      );
  var initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
    iOS: initializationSettingsDarwin,
    macOS: initializationSettingsDarwin,
    windows: initializationSettingsWindows,
    linux: initializationSettingsLinux,
  );

  await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  return flutterLocalNotificationsPlugin;
}

late FlutterLocalNotificationsPlugin notificationPlugin;

Future<void> requestPermissions() async {
  if (Platform.isIOS) {
    final impl = notificationPlugin
        .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>();
    await impl?.requestPermissions(alert: true, badge: true, sound: true);
  }
  if (Platform.isMacOS) {
    final impl = notificationPlugin
        .resolvePlatformSpecificImplementation<MacOSFlutterLocalNotificationsPlugin>();
    await impl?.requestPermissions(alert: true, badge: true, sound: true);
  }
  if (Platform.isAndroid) {
    final impl = notificationPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    await impl?.requestNotificationsPermission();
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // ← viktigt!

  await _configureLocalTimeZone();

  notificationPlugin = await initializeNotifications();

  await requestPermissions();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

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
            final sessionRepo = ParkingSessionRepository();
            final notifRepo   = NotificationRepository(notificationPlugin);
            return ParkingSessionBloc(sessionRepo, notifRepo)
              ..add(LoadSessions());
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
