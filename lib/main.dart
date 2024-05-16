import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:pdfshits/routes/auth_route.dart';
import 'package:pdfshits/routes/home_route.dart';
import 'package:pdfshits/routes/redirect_route.dart';
import 'package:pdfshits/themes/theme.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await Supabase.initialize(
    url: "https://zorxewdwmjeavwhlyjqm.supabase.co",
    anonKey:
    "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Inpvcnhld2R3bWplYXZ3aGx5anFtIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MTU4NDE2OTMsImV4cCI6MjAzMTQxNzY5M30.rOOT2sEciMLr8F5BDPaaG0bCKCF9I3M9bo9FX96pcGQ",
  );
  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/redirect',
      theme: appTheme,
      routes: {
        '/redirect': (context) => const RedirectRoute(),
        '/auth': (context) => const AuthRoute(),
        '/home': (context) => const HomeRoute(),
      },
    );
  }
}