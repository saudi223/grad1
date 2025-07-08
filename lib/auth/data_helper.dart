import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final _dbName = 'profile.db';
  static final _dbVersion = 1;

  static Future<Database> initDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _dbName);

    return openDatabase(
      path,
      version: _dbVersion,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE profiles (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT,
            blood_type TEXT,
            weight TEXT,
            height TEXT,
            phone1 TEXT,
            phone2 TEXT,
            camera_ip TEXT,
            profile_image TEXT
          )
        ''');
      },
    );
  }
}