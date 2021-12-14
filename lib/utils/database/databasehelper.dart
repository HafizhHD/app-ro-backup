import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper{
  static final _dbname = 'ruangkeluarga.db';
  static final _dbversion = 10;
  static final tableAplikasi = 'AplikasiData';

  DatabaseHelper._privateConstructor();

  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  _initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, _dbname);

    return await openDatabase(path,
        version: _dbversion, onCreate: (Database db, int version) async{
          await db.execute('''
          CREATE TABLE IF NOT EXISTS $tableAplikasi (
            id INTEGER PRIMARY KEY,
            email TEXT,
            idUsage TEXT,
            dataAplikasi TEXT
          )
          ''');
        }, onUpgrade: (Database db, int currentVersion, int newVersion) async {

        });
  }
}