import 'package:dunno_hack/ui/game.dart';
import 'package:dunno_hack/ui/home.dart';
import 'package:dunno_hack/ui/host.dart';
import 'package:dunno_hack/ui/remotegame.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final Future<FirebaseApp> _initialization = Firebase.initializeApp();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _initialization,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return MaterialApp(
            title: 'Dunno Hack',
            theme: ThemeData(
              primarySwatch: Colors.teal,
            ),
            initialRoute: '/',
            routes: {
              // When navigating to the "/" route, build the FirstScreen widget.
              '/': (context) => const HomeScreen(),
              '/game': (context) => const GameScreen(),
              '/host': (context) => const HostScreen(),
              '/player': (context) => const RemoteGameScreen(),
            },
          );
        }
        return const Center(child: CircularProgressIndicator());
      },
    );

  }
}
