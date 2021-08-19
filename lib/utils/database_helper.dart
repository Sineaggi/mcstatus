import 'package:flutter/material.dart';
import 'package:mcstatus/models/server.dart';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  // singletons fucking suck
  static DatabaseHelper? _databaseHelper;
  static Database? _database;

  DatabaseHelper._createInstance();

  factory DatabaseHelper() {
    if (_databaseHelper == null) {
      _databaseHelper = DatabaseHelper._createInstance();
    }
    return _databaseHelper!; // this is a great language
  }

  Future<Database> get database async {
    if (_database == null) {
      _database = await initializeDatabase();
    }
    return _database!; // holy fuckshit we're doing this again
  }

  Future<Database> initializeDatabase() async {
    debugPrint('initializing database!');
    //.debugPrint('initializing database!');
    return openDatabase(
      join(await getDatabasesPath(), 'servers.db'),
      onCreate: (db, version) {
        debugPrint('initializing database create tabl');
        //switch version {

        //}
        return db.execute(
            'CREATE TABLE server(id INTEGER PRIMARY KEY, name TEXT, address TEXT, image TEXT)');
      },
      version: 1,
    );
  }

  Future<int> insertServer(Server server) async {
    final db = await database;

    return await db.insert(
      'server',
      server.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  //Future<Server> server(int id) async {
  //  final db = await database;
  //
  //  await db.query('servers', );
  //}

  Future<List<Server>> servers() async {
    final db = await database;

    final kola = await db.rawQuery("SELECT name FROM sqlite_master WHERE type='table'");
    debugPrint('$kola');

    final List<Map<String, dynamic>> maps = await db.query('server');

    return List.generate(maps.length, (i) {
      return Server(
        id: maps[i]['id'],
        name: maps[i]['name'],
        address: maps[i]['address'],
        image: maps[i]['image'],
      );
    });
  }

  Future<int> updateServer(Server server) async {
    final db = await database;

    return await db.update(
      'server',
      server.toMap(),
      where: 'id = ?',
      whereArgs: [server.id],
    );
  }

  Future<int> deleteServer(int id) async {
    final db = await database;

    return await db.delete(
      'server',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
