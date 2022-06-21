import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:simple_notes/model/note.dart';

class DBProvider {
  DBProvider._();
  static final DBProvider db = DBProvider._();

  static late Database _database;

  String notesTable = 'Notes';
  String columnId = 'id';
  String columnText = 'text';

  Future<Database> get database async {
    //if (_database != null) return _database;

    _database = await _initDB();
    return _database;
  }

  Future<Database> _initDB() async {
    Directory dir = await getApplicationDocumentsDirectory();
    String path = '${dir.path}Note.db';
    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  // Note
  // Id | Text
  // 0    ..
  // 1    ..

  void _createDB(Database db, int version) async {
    await db.execute(
      'CREATE TABLE $notesTable($columnId INTEGER PRIMARY KEY AUTOINCREMENT, $columnText TEXT)',
    );
  }

  // READ
  Future<List<Note>> getNotes() async {
    Database db = await database;
    final List<Map<String, dynamic>> notesMapList =
    await db.query(notesTable);
    final List<Note> notesList = [];
    for (var noteMap in notesMapList) {
      notesList.add(Note.fromMap(noteMap));
    }

    return notesList;
  }

  // INSERT
  Future<Note> insertNote(Note note) async {
    Database db = await database;
    note.id = await db.insert(notesTable, note.toMap());
    return note;
  }

  // UPDATE
  Future<int> updateNote(Note note) async {
    Database db = await database;
    return await db.update(
      notesTable,
      note.toMap(),
      where: '$columnId = ?',
      whereArgs: [note.id],
    );
  }

  // DELETE
  Future<int> deleteStudent(int? id) async {
    Database db = await database;
    return await db.delete(
      notesTable,
      where: '$columnId = ?',
      whereArgs: [id],
    );
  }
}