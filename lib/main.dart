import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:dartmc/dartmc.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mcstatus/screens/server_detail.dart';
import 'package:mcstatus/screens/server_list.dart';
import 'package:mcstatus/somla.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';

void main() async {
  //WidgetsFlutterBinding.ensureInitialized();
  debugPrint("starting");
  runApp(MyApp());
}

class FileStorage {
  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();

    return directory.path;
  }

  Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/servers.json');
  }

  Future<File> _namedFile(String id) async {
    final path = await _localPath;
    return File(join(path, id));
  }

  //Future<File> addServer(Server server) async {
  //  final file = await _localFile;
//
  //  // Write the file
  //  var str = file.readAsString();
  //  //Map<String, dynamic> servers = jsonDecode(await file.readAsString());
  //  // convert to json
  //  // add server to json
  //  // write json back out
//
  //  return file.writeAsString('$counter');
  //}

  Future<File> writeImage(String id, List<int> bytes) async {
    final file = await _namedFile(id);

    // Write the file
    return file.writeAsBytes(bytes);
  }

  Future<Image> readImage(String id) async {
    try {
      final file = await _namedFile(id);

      // Read the file
      final bytes = await file.readAsBytes();

      return Image.memory(bytes);
    } catch (e) {
      // If encountering an error, return 0
      // image: AssetImage('graphics/default.webp') ??
      print(e);
      return Image.asset('graphics/default.webp');
    }
  }
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      //home: MyHomePage(title: 'Flutter Minecraft Server Status Viewer'),
      home: ServerList(),
    );
  }
}
