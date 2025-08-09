// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'screens/login.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await dotenv.load(fileName: "assets/.env");
    await Supabase.initialize(
      url: dotenv.env['SUPABASE_URL']!,
      anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
    );
    final supabase = Supabase.instance.client;
    final testResponse = await supabase.from('orders').select('order_id').limit(1);
    print('Supabase initialized with URL: ${dotenv.env['SUPABASE_URL']}');
    print('Test query result: $testResponse');
  } catch (e) {
    print('Supabase initialization error: $e');
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hotel Admin Dashboard',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        brightness: Brightness.light,
        fontFamily: 'Roboto',
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.blueGrey,
        useMaterial3: true,
      ),
      themeMode: ThemeMode.system,
      home: const LoginScreen(),
    );
  }
}