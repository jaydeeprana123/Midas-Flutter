import 'package:midas/Material/Models/add_material_tagging_request.dart';
import 'package:midas/Material/Models/material_by_inward_type_model.dart';
import 'package:midas/Material/Models/material_tagging_detail_model.dart';
import 'package:midas/Material/Models/pending_material_assign_tag_model.dart';
import 'package:midas/Material/Models/pending_material_link_location_model.dart';
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
      version: 3,
      onCreate: (db, version) async {
        await _createTables(db);
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute('''
            CREATE TABLE IF NOT EXISTS pending_material_link_location (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              location_code TEXT NOT NULL,
              detail_ids_json TEXT NOT NULL,
              tag_code TEXT,
              created_at TEXT,
              status TEXT NOT NULL DEFAULT 'pending'
            )
          ''');
        }
        if (oldVersion < 3) {
          await db.execute('''
            CREATE TABLE IF NOT EXISTS material_by_inward_type (
              inward_type_id INTEGER NOT NULL,
              material_row_id INTEGER NOT NULL,
              material_id INTEGER NOT NULL,
              material_name TEXT,
              code TEXT,
              uom TEXT,
              uo_mid INTEGER,
              quantity REAL,
              tagged_quantity REAL,
              remarks TEXT,
              PRIMARY KEY (inward_type_id, material_row_id)
            )
          ''');
          await db.execute('''
            CREATE TABLE IF NOT EXISTS pending_material_assign_tag (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              request_json TEXT NOT NULL,
              tag_code TEXT,
              created_at TEXT,
              status TEXT NOT NULL DEFAULT 'pending'
            )
          ''');
        }
      },
    );
  }

  Future<void> _createTables(Database db) async {
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
        await db.execute('''
          CREATE TABLE pending_material_link_location (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            location_code TEXT NOT NULL,
            detail_ids_json TEXT NOT NULL,
            tag_code TEXT,
            created_at TEXT,
            status TEXT NOT NULL DEFAULT 'pending'
          )
        ''');
        await db.execute('''
          CREATE TABLE material_by_inward_type (
            inward_type_id INTEGER NOT NULL,
            material_row_id INTEGER NOT NULL,
            material_id INTEGER NOT NULL,
            material_name TEXT,
            code TEXT,
            uom TEXT,
            uo_mid INTEGER,
            quantity REAL,
            tagged_quantity REAL,
            remarks TEXT,
            PRIMARY KEY (inward_type_id, material_row_id)
          )
        ''');
        await db.execute('''
          CREATE TABLE pending_material_assign_tag (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            request_json TEXT NOT NULL,
            tag_code TEXT,
            created_at TEXT,
            status TEXT NOT NULL DEFAULT 'pending'
          )
        ''');
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

  Future<int> insertPendingLinkLocation(
    PendingMaterialLinkLocationModel record,
  ) async {
    final db = await database;
    return db.insert('pending_material_link_location', record.toSqliteMap());
  }

  Future<List<PendingMaterialLinkLocationModel>>
      getPendingLinkLocations() async {
    final db = await database;
    final rows = await db.query(
      'pending_material_link_location',
      where: 'status = ?',
      whereArgs: ['pending'],
      orderBy: 'id ASC',
    );
    return rows.map(PendingMaterialLinkLocationModel.fromSqlite).toList();
  }

  Future<void> markPendingLinkLocationSynced(int id) async {
    final db = await database;
    await db.delete(
      'pending_material_link_location',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Replaces cached materials for one source id only; other source ids remain.
  Future<void> replaceMaterialsForSourceId(
    int inwardTypeId,
    List<MaterialByInwardTypeModel> items,
  ) async {
    final db = await database;
    final batch = db.batch();
    batch.delete(
      'material_by_inward_type',
      where: 'inward_type_id = ?',
      whereArgs: [inwardTypeId],
    );
    for (final item in items) {
      batch.insert(
        'material_by_inward_type',
        item.toSqliteMap(inwardTypeId),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    await batch.commit(noResult: true);
  }

  Future<List<MaterialByInwardTypeModel>> getMaterialsBySourceId(
    int inwardTypeId,
  ) async {
    final db = await database;
    final rows = await db.query(
      'material_by_inward_type',
      where: 'inward_type_id = ?',
      whereArgs: [inwardTypeId],
      orderBy: 'material_name COLLATE NOCASE ASC',
    );
    return rows.map(MaterialByInwardTypeModel.fromSqlite).toList();
  }

  Future<bool> hasPendingAssignTag(AddMaterialTaggingRequest request) async {
    final tag = request.materialTagingDetails.isEmpty
        ? null
        : request.materialTagingDetails.first.tagCode.trim().toLowerCase();
    if (tag == null || tag.isEmpty) return false;

    final pending = await getPendingAssignTags();
    for (final record in pending) {
      final existingTag = record.tagCode?.trim().toLowerCase();
      if (record.request.inwardTypeId == request.inwardTypeId &&
          record.request.materialId == request.materialId &&
          existingTag == tag) {
        return true;
      }
    }
    return false;
  }

  Future<int> insertPendingAssignTag(PendingMaterialAssignTagModel record) async {
    final db = await database;
    return db.insert('pending_material_assign_tag', record.toSqliteMap());
  }

  Future<List<PendingMaterialAssignTagModel>> getPendingAssignTags() async {
    final db = await database;
    final rows = await db.query(
      'pending_material_assign_tag',
      where: 'status = ?',
      whereArgs: ['pending'],
      orderBy: 'id ASC',
    );
    return rows.map(PendingMaterialAssignTagModel.fromSqlite).toList();
  }

  Future<void> markPendingAssignTagSynced(int id) async {
    final db = await database;
    await db.delete(
      'pending_material_assign_tag',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
