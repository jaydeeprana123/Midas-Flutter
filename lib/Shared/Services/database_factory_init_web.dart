import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';

/// Web stores SQLite data in IndexedDB via sqflite_common_ffi_web.
/// Uses the no-web-worker factory so only sqlite3.wasm is required in /web.
Future<void> initializeAppDatabase() async {
  databaseFactory = databaseFactoryFfiWebNoWebWorker;
}
