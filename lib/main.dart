import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/appointment_provider.dart';
import 'screens/main_layout_screen.dart';
import 'services/hive_service.dart';

/// Entry point of the QueueEase app
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive local storage
  await HiveService.init();

  runApp(const QueueEaseApp());
}

/// Root widget for the QueueEase application
class QueueEaseApp extends StatelessWidget {
  const QueueEaseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => AppointmentProvider()..loadAppointments(),
      child: MaterialApp(
        title: 'QueueEase',
        debugShowCheckedModeBanner: false,

        // Material 3 theme configuration
        theme: ThemeData(
          useMaterial3: true,
          colorSchemeSeed: const Color(0xFF6C3CE1),
          fontFamily: 'Roboto',
          scaffoldBackgroundColor: const Color(0xFFF8F9FC),
        ),

        home: const MainLayoutScreen(),
      ),
    );
  }
}
