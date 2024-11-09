import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
// import 'package:sqflite_porter/sqflite_porter.dart' show dbImportSql;

class Storage {
  static final String _initialDBPath = 'assets/cfg/init.sql';
  static final _dbFile = "finance.db";
  static Storage _instance;
  static Database _database;

  Storage._init();

  static get instance {
    if (_instance == null) {
      _instance = Storage._init();
    }
    return _instance;
  }

  Future<Database> getDatabase() async {
    if (_database == null) {
      var dbDirectory = await getApplicationDocumentsDirectory();
      String dbPath = join(dbDirectory.path, _dbFile);
      _database = await openDatabase(dbPath,
          version: 2,
          onCreate: _onDBCreate,
          onUpgrade: _onDBUpgrade,
          onDowngrade: _onDBDowngrade);
    }
    return _database;
  }

  Future _onDBCreate(Database db, int oldVersion) async {
    String sqlFile = await rootBundle.loadString(_initialDBPath);
    List<String> sqlCommands = sqlFile.split("; ");
    // await dbImportSql(db, sqlCommands);
    for (String command in sqlCommands) {
      await db.execute(command);
    }
  }

  Future _onDBUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < newVersion) {
      print("database upgrade");
      String sqlFile = await rootBundle.loadString(_initialDBPath);
      List<String> sqlCommands = sqlFile.split("; ");
      // await dbImportSql(db, sqlCommands);
      for (String command in sqlCommands) {
        await db.execute(command);
      }
    }
  }

  Future _onDBDowngrade(Database db, int oldVersion, int newVersion) async {}
}
