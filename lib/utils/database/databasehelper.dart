import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper{
  static final _dbname = 'ruangortuasia.db';
  static final _dbversion = 13;
  static final tableAplikasi = 'AplikasiDataORTUASIA';

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
            dataAplikasi TEXT,
            kunciLayar TEXT,
            modekunciLayar TEXT
          )
          ''');
        }, onUpgrade: (Database db, int currentVersion, int newVersion) async {
          if (currentVersion > 10 && currentVersion < 12) {
            ['''ALTER TABLE $tableAplikasi ADD COLUMN kunciLayar TEXT''',].forEach((script) async => await db.execute(script));
          }
          if (currentVersion > 12) {
            ['''ALTER TABLE $tableAplikasi ADD COLUMN modekunciLayar TEXT''',].forEach((script) async => await db.execute(script));
          }
        });
  }

  var migration5_6 = [
    '''
          ALTER TABLE $tableAplikasi ADD COLUMN kunciLayar TEXT
          ''',
  ];
}