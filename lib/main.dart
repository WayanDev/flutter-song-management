import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import 'screens/song_list_screen.dart';
import 'services/storage_service.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Manajemen Lagu',
      theme: ThemeData(useMaterial3: true),
      home: const SplashGate(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class SplashGate extends StatefulWidget {
  const SplashGate({super.key});

  @override
  State<SplashGate> createState() => _SplashGateState();
}

class _SplashGateState extends State<SplashGate> {
  final storage = StorageService();

  @override
  void initState() {
    super.initState();
    _go();
  }

  Future<void> _go() async {
    final loggedIn = await storage.isLoggedIn();
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => loggedIn ? const SongListScreen() : const LoginScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
