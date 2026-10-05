import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import '../models/sign_history.dart';

class DatabaseHelper {
  DatabaseHelper._();
  static final DatabaseHelper instance = DatabaseHelper._();
  static Database? _database;

  Future<Database> get database async => _database ??= await _openDatabase();

  Future<Database> _openDatabase() async {
    final directory = await getApplicationDocumentsDirectory();
    final path = p.join(directory.path, 'driveflow.db');
    return openDatabase(path, version: 1, onCreate: (db, version) async {
      await db.execute('''
        CREATE TABLE sign_history (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          sign_name TEXT NOT NULL,
          scanned_at TEXT NOT NULL,
          image_path TEXT NOT NULL
        )
      ''');
    });
  }

  Future<int> insertSignHistory(SignHistory history) async {
    final db = await database;
    return db.insert('sign_history', history.toMap());
  }

  Future<List<SignHistory>> getSignHistory() async {
    final db = await database;
    final rows = await db.query('sign_history', orderBy: 'scanned_at DESC');
    return rows.map(SignHistory.fromMap).toList();
  }

  Future<int> deleteSignHistory(int id) async {
    final db = await database;
    return db.delete('sign_history', where: 'id = ?', whereArgs: [id]);
  }
}
