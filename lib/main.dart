import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'providers/turnos_provider.dart';
import 'screens/onboarding_screen.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Se leen los datos guardados antes de mostrar la primera pantalla.
  final auth = AuthProvider();
  final turnos = TurnosProvider();
  await Future.wait([auth.cargar(), turnos.cargar()]);

  runApp(ClinicaApp(auth: auth, turnos: turnos));
}

class ClinicaApp extends StatelessWidget {
  final AuthProvider auth;
  final TurnosProvider turnos;

  const ClinicaApp({super.key, required this.auth, required this.turnos});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: auth),
        ChangeNotifierProvider.value(value: turnos),
      ],
      child: MaterialApp(
        title: 'Clínica - Turnos',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.theme,
        home: const OnboardingScreen(),
      ),
    );
  }
}
