import 'package:flutter/material.dart';
import 'package:dunno_hack/extensions.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class HomeScreen extends StatelessWidget {
  static const _githubUrl = "https://github.com/mensly/dunnohack";
  static const _openTdbUrl = "https://opentdb.com";

  const HomeScreen({Key? key}) : super(key: key);

  void _openGitHub() async {
    await launch(_githubUrl);
  }

  void _openOpenTdb() async {
    await launch(_openTdbUrl);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(context.appTitle),
        ),
        floatingActionButton: FloatingActionButton.extended(
          icon: const Icon(FontAwesomeIcons.githubAlt),
          label: const Text("Fork me on GitHub"),
          onPressed: () => _openGitHub(),
        ),
        body: Center(
          child: Column(
            children: [
              const Padding(
                padding: EdgeInsets.all(32.0),
                child: Text(
                  "Play trivia by yourself or with friends using questions from Open Trivia Database",
                  textScaleFactor: 2,
                  textAlign: TextAlign.center,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: MaterialButton(
                  onPressed: () => Navigator.of(context).pushNamed("/host"),
                  color: context.theme.primaryColor,
                  textColor: Colors.white,
                  child: const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text("Host Game", textScaleFactor: 3),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: MaterialButton(
                  onPressed: () => Navigator.of(context).pushNamed("/player"),
                  color: context.theme.primaryColor,
                  textColor: Colors.white,
                  child: const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text("Join Game", textScaleFactor: 3),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: MaterialButton(
                  onPressed: () => _openOpenTdb(),
                  color: context.theme.primaryColor,
                  textColor: Colors.white,
                  child: const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text("Open Trivia Database", textScaleFactor: 1),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: MaterialButton(
                  onPressed: () => Navigator.of(context).pushNamed("/game"),
                  color: context.theme.primaryColor,
                  textColor: Colors.white,
                  child: const Padding(
                    padding: EdgeInsets.all(8.0),
                    child:
                        Text("Single Player\n(Deprecated)", textScaleFactor: 1),
                  ),
                ),
              ),
            ],
          ),
        ));
  }
}
