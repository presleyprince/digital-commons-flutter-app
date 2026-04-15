import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'app_database.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE finance_logs(
            id TEXT PRIMARY KEY,
            user_id TEXT,
            amount REAL,
            description TEXT,
            date INTEGER,
            category INTEGER
          )
        ''');

        await db.execute('''
          CREATE TABLE finance_history(
            id TEXT PRIMARY KEY,
            action TEXT
          )
        ''');

        await db.execute('''
          CREATE TABLE information(
            id TEXT PRIMARY KEY,
            title TEXT,
            image_url TEXT,
            content TEXT,
            created_at INTEGER,
            category TEXT
          )
        ''');

        await db.execute('''
  CREATE TABLE administration_documents (
    id TEXT PRIMARY KEY,
    user_id TEXT NOT NULL,
    type INTEGER NOT NULL,
    custom_type TEXT,
    created_at INTEGER NOT NULL,
    updated_at INTEGER NOT NULL,
    is_synced INTEGER NOT NULL DEFAULT 0,
    is_deleted INTEGER NOT NULL DEFAULT 0,
    deleted_at INTEGER
  )
''');

        await db.execute('''
  CREATE TABLE document_requirements (
    id TEXT PRIMARY KEY,
    document_id TEXT NOT NULL,
    requirement INTEGER NOT NULL,
    FOREIGN KEY (document_id) REFERENCES administration_documents (id) ON DELETE CASCADE
  )
''');

        await db.execute('''
  CREATE TABLE document_images (
    id TEXT PRIMARY KEY,
    document_id TEXT NOT NULL,
    local_path TEXT NOT NULL,
    cloud_url TEXT,
    is_synced INTEGER NOT NULL DEFAULT 0,
    is_deleted INTEGER NOT NULL DEFAULT 0,
    created_at INTEGER NOT NULL,
    deleted_at INTEGER,
    FOREIGN KEY (document_id) REFERENCES administration_documents (id) ON DELETE CASCADE
  )
''');

      await db.execute('''
  CREATE TABLE informations (
    id TEXT PRIMARY KEY,
    title TEXT NOT NULL,
    image_url TEXT,
    content TEXT NOT NULL,
    author TEXT NOT NULL,
    created_at INTEGER NOT NULL,
    updated_at INTEGER NOT NULL,
    is_deleted INTEGER NOT NULL DEFAULT 0,
    deleted_at INTEGER,
    category INTEGER NOT NULL
  )''');

// Create indexes
        await db.execute('''
  CREATE INDEX idx_documents_user_id ON administration_documents(user_id)
''');

        await db.execute('''
  CREATE INDEX idx_images_document_id ON document_images(document_id)
''');

        await db.execute('''
  CREATE INDEX idx_requirements_document_id ON document_requirements(document_id)
''');
      },
    );
  }
}