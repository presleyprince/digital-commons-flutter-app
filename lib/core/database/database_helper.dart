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
      version: 3,
      onCreate: (db, version) async {
        await _createTables(db);
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await _createPlotTables(db);
        }
        if (oldVersion < 3) {
          await _createPlotFormTables(db);
        }
      },
    );
  }

  Future<void> _createTables(Database db) async {
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
      )
    ''');

    await db.execute('''
      CREATE INDEX idx_documents_user_id ON administration_documents(user_id)
    ''');

    await db.execute('''
      CREATE INDEX idx_images_document_id ON document_images(document_id)
    ''');

    await db.execute('''
      CREATE INDEX idx_requirements_document_id ON document_requirements(document_id)
    ''');

    await _createPlotTables(db);
    await _createPlotFormTables(db);
  }

  Future<void> _createPlotTables(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS saved_plots (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        area_square_meters REAL NOT NULL,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL,
        is_synced INTEGER NOT NULL DEFAULT 0,
        source TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS saved_plot_points (
        plot_id TEXT NOT NULL,
        point_order INTEGER NOT NULL,
        latitude REAL NOT NULL,
        longitude REAL NOT NULL,
        accuracy REAL NOT NULL,
        recorded_at INTEGER NOT NULL,
        PRIMARY KEY (plot_id, point_order),
        FOREIGN KEY (plot_id) REFERENCES saved_plots (id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE INDEX IF NOT EXISTS idx_saved_plot_points_plot_id
      ON saved_plot_points(plot_id)
    ''');
  }

  Future<void> _createPlotFormTables(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS plot_forms (
        plot_id TEXT PRIMARY KEY,
        owner_name TEXT NOT NULL,
        owner_address TEXT NOT NULL,
        ownership_start_date TEXT NOT NULL,
        previous_owner TEXT NOT NULL,
        ownership_through TEXT NOT NULL,
        is_same_as_owner INTEGER NOT NULL DEFAULT 0,
        operator_name TEXT NOT NULL,
        operator_address TEXT NOT NULL,
        lease_period TEXT NOT NULL,
        type_of_seaweed TEXT NOT NULL,
        planting_cycle TEXT NOT NULL,
        production_capacity TEXT NOT NULL,
        adjacent_plot_owners TEXT NOT NULL,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL,
        is_synced INTEGER NOT NULL DEFAULT 0,
        FOREIGN KEY (plot_id) REFERENCES saved_plots (id) ON DELETE CASCADE
      )
    ''');
  }
}
