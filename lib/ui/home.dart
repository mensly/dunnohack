import 'package:flutter/material.dart';
import 'package:dunno_hack/extensions.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.appTitle),
      ),
      body: Center(
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.all(32.0),
              child: Text("Play trivia by yourself or with friends using questions from Open Trivia Database",
                textScaleFactor: 2,
                textAlign: TextAlign.center,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: MaterialButton(
                onPressed: () {
                  Navigator.of(context).pushNamed("/game");
                },
                color: context.theme.primaryColor,
                textColor: Colors.white,
                child: const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text("Single Player", textScaleFactor: 3),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: MaterialButton(
                onPressed: () {
                  Navigator.of(context).pushNamed("/host");
                },
                color: context.theme.primaryColor,
                textColor: Colors.white,
                child: const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text("Host Game", textScaleFactor: 3),
                ),
              ),
            )
          ],
        ),
      )
    );
  }
}
