import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static const String databaseName = 'notes.db';
  static const int databaseVersion = 1;

  static const String tableName = 'notes';

  static Future<Database> getDatabase() async {
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, databaseName);

    return openDatabase(
      path,
      version: databaseVersion,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE $tableName (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT NOT NULL,
            description TEXT
          )
        ''');
      },
    );
  }

  static Future<int> insertNote(Map<String, dynamic> note) async {
    final db = await getDatabase();

    return await db.insert(tableName, note);
  }

  static Future<List<Map<String, dynamic>>> getNotes() async {
    final db = await getDatabase();

    return await db.query(tableName);
  }

  static Future<int> updateNote(int id, Map<String, dynamic> note) async {
    final db = await getDatabase();

    return await db.update(tableName, note, where: 'id = ?', whereArgs: [id]);
  }

  static Future<int> deleteNote(int id) async {
    final db = await getDatabase();

    return await db.delete(tableName, where: 'id = ?', whereArgs: [id]);
  }
}
