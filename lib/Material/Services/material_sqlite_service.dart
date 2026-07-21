import 'package:midas/Material/Models/material_tagging_detail_model.dart';
import 'package:midas/Material/Models/pending_material_unassign_model.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

class MaterialSqliteService {
  Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _open();
    return _db!;
  }

  Future<Database> _open() async {
    final dbPath = await getDatabasesPath();
    return openDatabase(
      p.join(dbPath, 'midas_material.db'),
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE material_tag_details (
            tag_code TEXT PRIMARY KEY,
            detail_id INTEGER NOT NULL,
            material_tagging_id INTEGER,
            material_id INTEGER,
            material_name TEXT,
            material_code TEXT,
            location TEXT,
            raw_json TEXT,
            updated_at TEXT
          )
        ''');
        await db.execute('''
          CREATE TABLE pending_material_unassign (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            detail_ids_json TEXT NOT NULL,
            tag_code TEXT,
            created_at TEXT,
            status TEXT NOT NULL DEFAULT 'pending'
          )
        ''');
      },
    );
  }

  Future<void> upsertMaterialTagDetails(
    List<MaterialTaggingDetailModel> items,
  ) async {
    if (items.isEmpty) return;
    final db = await database;
    final batch = db.batch();
    for (final item in items) {
      batch.insert(
        'material_tag_details',
        item.toSqliteMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    await batch.commit(noResult: true);
  }

  Future<MaterialTaggingDetailModel?> getMaterialTagDetailsByTagCode(
    String tagCode,
  ) async {
    final db = await database;
    final rows = await db.query(
      'material_tag_details',
      where: 'LOWER(tag_code) = ?',
      whereArgs: [tagCode.trim().toLowerCase()],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return MaterialTaggingDetailModel.fromSqlite(rows.first);
  }

  Future<void> deleteMaterialTagDetailsByTagCode(String tagCode) async {
    final db = await database;
    await db.delete(
      'material_tag_details',
      where: 'LOWER(tag_code) = ?',
      whereArgs: [tagCode.trim().toLowerCase()],
    );
  }

  Future<int> insertPendingUnassign(PendingMaterialUnassignModel record) async {
    final db = await database;
    return db.insert('pending_material_unassign', record.toSqliteMap());
  }

  Future<List<PendingMaterialUnassignModel>> getPendingUnassigns() async {
    final db = await database;
    final rows = await db.query(
      'pending_material_unassign',
      where: "status = ?",
      whereArgs: ['pending'],
      orderBy: 'id ASC',
    );
    return rows.map(PendingMaterialUnassignModel.fromSqlite).toList();
  }

  Future<void> markPendingUnassignSynced(int id) async {
    final db = await database;
    await db.delete(
      'pending_material_unassign',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
