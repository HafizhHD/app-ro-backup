import 'package:ruangkeluarga/utils/database/databasehelper.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite/sqlite_api.dart';

class AplikasiDB{

  AplikasiDB._privateConstructor();
  static final AplikasiDB instance = AplikasiDB._privateConstructor();

  static Database? _database;
  Future<Database> get database async {
    if(_database != null) return _database!;
    _database = await  DatabaseHelper.instance.database;
    return _database!;
  }

  Future<int> insertData(Map<String, dynamic> row) async {
    Database db = await instance.database;
    return await db.insert(DatabaseHelper.tableAplikasi, row, conflictAlgorithm: ConflictAlgorithm.replace,);
  }

  Future<Map<String, dynamic>?> queryAllRowsAplikasi() async {
    Database db = await instance.database;
    var result = await db.query(DatabaseHelper.tableAplikasi, limit: 1);
    if(result.length>0){
      return result[0];
    }
    return null;
  }

  Future<Map<String, dynamic>?> queryRowsAplikasi() async {
    Database db = await instance.database;
    var result = await db.query(DatabaseHelper.tableAplikasi, limit: 1);
    if(result.length>0){
      return result[0];
    }
    return null;
  }

  Future<bool> checkDataAplikasi() async {
    Map<String, dynamic> cust = new Map();
    try {
      cust = (await queryAllRowsAplikasi())!;
    } catch (e) {
      return false;
    }
    return (cust['email'] == null)? false : true;
  }

  Future<int> deleteAllData() async {
    Database db = await instance.database;
    return await db.delete(DatabaseHelper.tableAplikasi);
  }
}