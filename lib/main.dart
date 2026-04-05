import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:squeez_game/Screens/Menu/menu.dart';
import 'package:squeez_game/services/audio_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  // Initialise audio engine
  await AudioService().init();
  // Start BGM immediately (mute state will be synced when screens load)
  unawaited(AudioService().playBgm());
  runApp(const MyApp());
}

// Convenience helper so we don't need to import async everywhere
// ignore: unused_element
void unawaited(Future<void> future) {}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Squeeze Can',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      home: const MenuPage(),
    );
  }
}
