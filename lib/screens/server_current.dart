import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:dartmc/dartmc.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mcstatus/somla.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
    });
  }

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Invoke "debug painting" (press "p" in the console, choose the
          // "Toggle Debug Paint" action from the Flutter Inspector in Android
          // Studio, or the "Toggle Debug Paint" command in Visual Studio Code)
          // to see the wireframe for each widget.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextField(
              onChanged: _updateMinecraftServer,
            ),
            //Text(
            //  'You have pushed the button this many times:',
            //),
            FutureBuilder<PingResponse>(
              future: pingResponse,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  var data = snapshot.data!;
                  Image image;
                  var favicon = data.favicon;
                  if (favicon != null) {
                    var bytes = UriData.parse(favicon).contentAsBytes();
                    image = Image.memory(
                      bytes,
                      scale: 0.5,
                      isAntiAlias: false,
                      filterQuality: FilterQuality.none,
                    );
                  } else {
                    image = Image(image: AssetImage('graphics/default.webp'));
                    //image = Image.asset('images/lake.jpg');
                  }

                  return Column(children: [
                    Text(
                      '''Server description: ${data.description}
Server latency: ${data.latency} ms
Server players (${data.players.online}/${data.players.max})
Server version ${data.version.name}''',
                      style: TextStyle(
                          fontFamily: Platform.isIOS ? "Courier" : "monospace",
                          fontSize: 16),
                    ),
                    image
                  ]);

                  return Text(
                    '''
                  Server description: ${data.description}
                  Server latency: ${data.latency} ms
                  Server players (${data.players.online}/${data.players.max})
                  Server j ${data.favicon}
                  ''',
                    style: TextStyle(
                      fontFeatures: [FontFeature.tabularFigures()],
                    ),
                  );
                  return Text(
                      "Current latency: ${snapshot.data!.latency} ms\nhi");
                } else if (snapshot.hasError) {
                  return Text('${snapshot.error}');
                }

                // By default, show a loading spinner.
                return const CircularProgressIndicator();
              },
            ),
            //Text(
            //  '$_counter',
            //  style: Theme.of(context).textTheme.headline4,
            //),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                content: Stack(
                  children: <Widget>[
                    Form(
                      key: _formKey,
                      child: Column(
                        children: <Widget>[
                          Text("Server Name"),
                          TextFormField(
                            initialValue: 'Minecraft Server',
                            // The validator receives the text that the user has entered.
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter some text';
                              }
                              return null;
                            },
                          ),
                          Text("Server Address"),
                          TextFormField(
                            // The validator receives the text that the user has entered.
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter some text';
                              }
                              return null;
                            },
                          ),
                          ElevatedButton(
                            onPressed: () {
                              // Validate returns true if the form is valid, or false otherwise.
                              if (_formKey.currentState!.validate()) {

                                // todo: save this new server to db, even before getting the status.


                                // If the form is valid, display a snackbar. In the real world,
                                // you'd often call a server or save the information in a database.
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Processing Data')),
                                );
                              }
                            },
                            child: const Text('Submit'),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              );
            },
          );
        },
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  late Future<PingResponse> pingResponse;

  @override
  void initState() {
    super.initState();
    refreshServers();
  }

  void refreshServers() {
    pingResponse = Somla.getStatus();
  }

  void _updateMinecraftServer(String value) {
    pingResponse = Somla.getStatus(address: value);
  }
}
