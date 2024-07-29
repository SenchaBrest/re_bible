import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class BibleDatabase {
  static final BibleDatabase instance = BibleDatabase._init();

  static Database? _database;

  BibleDatabase._init();

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDB('bible.SQLite3');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, "demo_$filePath.db");

    final exists = await databaseExists(path);

    if (!exists) {
      if (kDebugMode) {
        print("Creating new copy from asset");
      }

      try {
        await Directory(dirname(path)).create(recursive: true);
      } catch (_) {}

      ByteData data = await rootBundle.load(url.join("assets", filePath));
      List<int> bytes =
      data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);

      await File(path).writeAsBytes(bytes, flush: true);
    } else {
      if (kDebugMode) {
        print("Opening existing database");
      }
    }

    return await openDatabase(path, readOnly: true);
  }

  Future<List<Map<String, dynamic>>> getBooks() async {
    final db = await instance.database;

    final result = await db.query('books');
    return result;
  }

  Future<List<Map<String, dynamic>>> getChapters(int bookNumber) async {
    final db = await instance.database;

    final result = await db.query(
      'verses',
      columns: ['chapter'],
      where: 'book_number = ?',
      whereArgs: [bookNumber],
      distinct: true,
    );
    return result;
  }

  Future<List<Map<String, dynamic>>> getVerses(int bookNumber, int chapter) async {
    final db = await instance.database;

    final result = await db.query(
      'verses',
      where: 'book_number = ? AND chapter = ?',
      whereArgs: [bookNumber, chapter],
    );
    return result;
  }

  Future<List<Map<String, dynamic>>> getVersesForBook(int bookNumber) async {
    final db = await instance.database;

    final result = await db.query(
      'verses',
      where: 'book_number = ?',
      whereArgs: [bookNumber],
    );
    return result;
  }

  Future close() async {
    final db = await instance.database;

    db.close();
  }
}
