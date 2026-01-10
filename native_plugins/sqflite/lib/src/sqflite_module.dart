import 'dart:async';
import 'dart:convert';

import 'package:sqflite/sqflite.dart' as sqflite;
import 'package:webf/module.dart';
import 'sq_flite_module_bindings_generated.dart';

/// WebF module for SQLite database operations.
///
/// This module provides functionality to:
/// - Open, close, and delete databases
/// - Execute raw SQL queries (SELECT, INSERT, UPDATE, DELETE)
/// - Use helper methods for common operations
/// - Execute batch operations for performance
/// - Execute transactions for atomicity
///
/// Example usage in Flutter:
/// ```dart
/// // Register module globally (in main function)
/// WebF.defineModule((context) => SQFliteModule(context));
/// ```
///
/// Example usage in JavaScript:
/// ```javascript
/// import { WebFSQFlite } from '@openwebf/webf-sqflite';
///
/// // Open a database
/// const result = await WebFSQFlite.openDatabase({
///   path: 'my_database.db',
///   version: 1,
///   onCreate: ['CREATE TABLE users (id INTEGER PRIMARY KEY, name TEXT)']
/// });
///
/// if (result.success === 'true') {
///   const dbId = result.databaseId;
///
///   // Insert data
///   await WebFSQFlite.insert({
///     databaseId: dbId,
///     table: 'users',
///     values: JSON.stringify({ name: 'John' })
///   });
///
///   // Query data
///   const queryResult = await WebFSQFlite.query({
///     databaseId: dbId,
///     table: 'users'
///   });
///
///   if (queryResult.success === 'true') {
///     const rows = JSON.parse(queryResult.rows);
///     console.log('Users:', rows);
///   }
/// }
/// ```
class SQFliteModule extends SQFliteModuleBindings {
  SQFliteModule(super.moduleManager);

  /// Active database connections keyed by unique ID.
  final Map<String, sqflite.Database> _databases = {};

  /// Counter for generating unique database IDs.
  int _databaseIdCounter = 0;

  @override
  void dispose() {
    // Close all open databases
    for (final db in _databases.values) {
      db.close();
    }
    _databases.clear();
  }

  /// Generate a unique database ID.
  String _generateDatabaseId() {
    _databaseIdCounter++;
    return 'db_${DateTime.now().millisecondsSinceEpoch}_$_databaseIdCounter';
  }

  /// Get a database by ID, throws if not found.
  sqflite.Database _getDatabase(String? databaseId) {
    if (databaseId == null || !_databases.containsKey(databaseId)) {
      throw Exception('Database not found: $databaseId');
    }
    return _databases[databaseId]!;
  }

  /// Convert conflict algorithm string to sqflite enum.
  sqflite.ConflictAlgorithm? _parseConflictAlgorithm(String? algorithm) {
    if (algorithm == null) return null;
    switch (algorithm.toLowerCase()) {
      case 'rollback':
        return sqflite.ConflictAlgorithm.rollback;
      case 'abort':
        return sqflite.ConflictAlgorithm.abort;
      case 'fail':
        return sqflite.ConflictAlgorithm.fail;
      case 'ignore':
        return sqflite.ConflictAlgorithm.ignore;
      case 'replace':
        return sqflite.ConflictAlgorithm.replace;
      default:
        return null;
    }
  }

  // ============================================================================
  // Database Management
  // ============================================================================

  @override
  Future<DatabasesPathResult> getDatabasesPath() async {
    try {
      final path = await sqflite.getDatabasesPath();
      return DatabasesPathResult(
        success: 'true',
        path: path,
      );
    } catch (e) {
      return DatabasesPathResult(
        success: 'false',
        error: e.toString(),
      );
    }
  }

  @override
  Future<OpenDatabaseResult> openDatabase(OpenDatabaseOptions? options) async {
    try {
      if (options == null || options.path == null) {
        return OpenDatabaseResult(
          success: 'false',
          error: 'Database path is required',
        );
      }

      String dbPath = options.path!;

      // Handle in-memory database
      if (options.inMemory == true) {
        dbPath = ':memory:';
      } else if (!dbPath.startsWith('/')) {
        // If relative path, prepend default databases directory
        final basePath = await sqflite.getDatabasesPath();
        dbPath = '$basePath/$dbPath';
      }

      final version = (options.version?.toInt()) ?? 1;
      final readOnly = options.readOnly ?? false;

      sqflite.Database db;

      if (readOnly) {
        db = await sqflite.openReadOnlyDatabase(dbPath);
      } else {
        db = await sqflite.openDatabase(
          dbPath,
          version: version,
          onCreate: (database, version) async {
            if (options.onCreate != null) {
              for (final sql in options.onCreate!) {
                if (sql != null && sql.isNotEmpty) {
                  await database.execute(sql);
                }
              }
            }
          },
          onUpgrade: (database, oldVersion, newVersion) async {
            if (options.onUpgrade != null) {
              for (final sql in options.onUpgrade!) {
                if (sql != null && sql.isNotEmpty) {
                  await database.execute(sql);
                }
              }
            }
          },
        );
      }

      final databaseId = _generateDatabaseId();
      _databases[databaseId] = db;

      return OpenDatabaseResult(
        success: 'true',
        databaseId: databaseId,
        path: db.path,
        version: await db.getVersion(),
      );
    } catch (e) {
      return OpenDatabaseResult(
        success: 'false',
        error: e.toString(),
      );
    }
  }

  @override
  Future<CloseDatabaseResult> closeDatabase(dynamic databaseId) async {
    try {
      final dbId = databaseId?.toString();
      if (dbId == null || !_databases.containsKey(dbId)) {
        return CloseDatabaseResult(
          success: 'false',
          error: 'Database not found: $databaseId',
        );
      }

      final db = _databases.remove(dbId)!;
      await db.close();

      return CloseDatabaseResult(success: 'true');
    } catch (e) {
      return CloseDatabaseResult(
        success: 'false',
        error: e.toString(),
      );
    }
  }

  @override
  Future<DeleteDatabaseResult> deleteDatabase(dynamic path) async {
    try {
      final dbPath = path?.toString();
      if (dbPath == null) {
        return DeleteDatabaseResult(
          success: 'false',
          error: 'Database path is required',
        );
      }

      String fullPath = dbPath;
      if (!dbPath.startsWith('/')) {
        final basePath = await sqflite.getDatabasesPath();
        fullPath = '$basePath/$dbPath';
      }

      await sqflite.deleteDatabase(fullPath);

      return DeleteDatabaseResult(success: 'true');
    } catch (e) {
      return DeleteDatabaseResult(
        success: 'false',
        error: e.toString(),
      );
    }
  }

  @override
  Future<DatabaseExistsResult> databaseExists(dynamic path) async {
    try {
      final dbPath = path?.toString();
      if (dbPath == null) {
        return DatabaseExistsResult(
          success: 'false',
          error: 'Database path is required',
        );
      }

      String fullPath = dbPath;
      if (!dbPath.startsWith('/')) {
        final basePath = await sqflite.getDatabasesPath();
        fullPath = '$basePath/$dbPath';
      }

      final exists = await sqflite.databaseExists(fullPath);

      return DatabaseExistsResult(
        success: 'true',
        exists: exists ? 'true' : 'false',
      );
    } catch (e) {
      return DatabaseExistsResult(
        success: 'false',
        error: e.toString(),
      );
    }
  }

  // ============================================================================
  // Helper Methods (Abstracted SQL)
  // ============================================================================

  @override
  Future<QueryResult> query(QueryOptions? options) async {
    try {
      if (options == null) {
        return QueryResult(
          success: 'false',
          error: 'Query options are required',
        );
      }

      final db = _getDatabase(options.databaseId);

      if (options.table == null) {
        return QueryResult(
          success: 'false',
          error: 'Table name is required',
        );
      }

      // Convert columns from dynamic to List<String>? if needed
      List<String>? columns;
      if (options.columns != null) {
        columns = (options.columns as List).map((e) => e.toString()).toList();
      }

      final rows = await db.query(
        options.table!,
        distinct: options.distinct ?? false,
        columns: columns,
        where: options.where,
        whereArgs: options.whereArgs,
        groupBy: options.groupBy,
        having: options.having,
        orderBy: options.orderBy,
        limit: options.limit?.toInt(),
        offset: options.offset?.toInt(),
      );

      return QueryResult(
        success: 'true',
        rows: jsonEncode(rows),
        count: rows.length,
      );
    } catch (e) {
      return QueryResult(
        success: 'false',
        error: e.toString(),
      );
    }
  }

  @override
  Future<InsertResult> insert(InsertOptions? options) async {
    try {
      if (options == null) {
        return InsertResult(
          success: 'false',
          error: 'Insert options are required',
        );
      }

      final db = _getDatabase(options.databaseId);

      if (options.table == null) {
        return InsertResult(
          success: 'false',
          error: 'Table name is required',
        );
      }

      if (options.values == null) {
        return InsertResult(
          success: 'false',
          error: 'Values are required',
        );
      }

      final values = jsonDecode(options.values!) as Map<String, dynamic>;
      final conflictAlgorithm = _parseConflictAlgorithm(options.conflictAlgorithm);

      final rowId = await db.insert(
        options.table!,
        values,
        conflictAlgorithm: conflictAlgorithm,
      );

      return InsertResult(
        success: 'true',
        lastInsertRowId: rowId,
      );
    } catch (e) {
      return InsertResult(
        success: 'false',
        error: e.toString(),
      );
    }
  }

  @override
  Future<UpdateResult> update(UpdateOptions? options) async {
    try {
      if (options == null) {
        return UpdateResult(
          success: 'false',
          error: 'Update options are required',
        );
      }

      final db = _getDatabase(options.databaseId);

      if (options.table == null) {
        return UpdateResult(
          success: 'false',
          error: 'Table name is required',
        );
      }

      if (options.values == null) {
        return UpdateResult(
          success: 'false',
          error: 'Values are required',
        );
      }

      final values = jsonDecode(options.values!) as Map<String, dynamic>;
      final conflictAlgorithm = _parseConflictAlgorithm(options.conflictAlgorithm);

      final count = await db.update(
        options.table!,
        values,
        where: options.where,
        whereArgs: options.whereArgs,
        conflictAlgorithm: conflictAlgorithm,
      );

      return UpdateResult(
        success: 'true',
        rowsAffected: count,
      );
    } catch (e) {
      return UpdateResult(
        success: 'false',
        error: e.toString(),
      );
    }
  }

  @override
  Future<DeleteResult> delete(DeleteOptions? options) async {
    try {
      if (options == null) {
        return DeleteResult(
          success: 'false',
          error: 'Delete options are required',
        );
      }

      final db = _getDatabase(options.databaseId);

      if (options.table == null) {
        return DeleteResult(
          success: 'false',
          error: 'Table name is required',
        );
      }

      final count = await db.delete(
        options.table!,
        where: options.where,
        whereArgs: options.whereArgs,
      );

      return DeleteResult(
        success: 'true',
        rowsAffected: count,
      );
    } catch (e) {
      return DeleteResult(
        success: 'false',
        error: e.toString(),
      );
    }
  }

  // ============================================================================
  // Raw SQL Operations
  // ============================================================================

  @override
  Future<RawQueryResult> rawQuery(RawSqlOptions? options) async {
    try {
      if (options == null) {
        return RawQueryResult(
          success: 'false',
          error: 'Raw SQL options are required',
        );
      }

      final db = _getDatabase(options.databaseId);

      if (options.sql == null) {
        return RawQueryResult(
          success: 'false',
          error: 'SQL statement is required',
        );
      }

      final rows = await db.rawQuery(options.sql!, options.arguments);

      return RawQueryResult(
        success: 'true',
        rows: jsonEncode(rows),
        count: rows.length,
      );
    } catch (e) {
      return RawQueryResult(
        success: 'false',
        error: e.toString(),
      );
    }
  }

  @override
  Future<RawInsertResult> rawInsert(RawSqlOptions? options) async {
    try {
      if (options == null) {
        return RawInsertResult(
          success: 'false',
          error: 'Raw SQL options are required',
        );
      }

      final db = _getDatabase(options.databaseId);

      if (options.sql == null) {
        return RawInsertResult(
          success: 'false',
          error: 'SQL statement is required',
        );
      }

      final rowId = await db.rawInsert(options.sql!, options.arguments);

      return RawInsertResult(
        success: 'true',
        lastInsertRowId: rowId,
      );
    } catch (e) {
      return RawInsertResult(
        success: 'false',
        error: e.toString(),
      );
    }
  }

  @override
  Future<RawUpdateResult> rawUpdate(RawSqlOptions? options) async {
    try {
      if (options == null) {
        return RawUpdateResult(
          success: 'false',
          error: 'Raw SQL options are required',
        );
      }

      final db = _getDatabase(options.databaseId);

      if (options.sql == null) {
        return RawUpdateResult(
          success: 'false',
          error: 'SQL statement is required',
        );
      }

      final count = await db.rawUpdate(options.sql!, options.arguments);

      return RawUpdateResult(
        success: 'true',
        rowsAffected: count,
      );
    } catch (e) {
      return RawUpdateResult(
        success: 'false',
        error: e.toString(),
      );
    }
  }

  @override
  Future<RawUpdateResult> rawDelete(RawSqlOptions? options) async {
    try {
      if (options == null) {
        return RawUpdateResult(
          success: 'false',
          error: 'Raw SQL options are required',
        );
      }

      final db = _getDatabase(options.databaseId);

      if (options.sql == null) {
        return RawUpdateResult(
          success: 'false',
          error: 'SQL statement is required',
        );
      }

      final count = await db.rawDelete(options.sql!, options.arguments);

      return RawUpdateResult(
        success: 'true',
        rowsAffected: count,
      );
    } catch (e) {
      return RawUpdateResult(
        success: 'false',
        error: e.toString(),
      );
    }
  }

  @override
  Future<ExecuteResult> execute(RawSqlOptions? options) async {
    try {
      if (options == null) {
        return ExecuteResult(
          success: 'false',
          error: 'Raw SQL options are required',
        );
      }

      final db = _getDatabase(options.databaseId);

      if (options.sql == null) {
        return ExecuteResult(
          success: 'false',
          error: 'SQL statement is required',
        );
      }

      await db.execute(options.sql!, options.arguments);

      return ExecuteResult(success: 'true');
    } catch (e) {
      return ExecuteResult(
        success: 'false',
        error: e.toString(),
      );
    }
  }

  // ============================================================================
  // Batch Operations
  // ============================================================================

  @override
  Future<BatchResult> batch(BatchOptions? options) async {
    try {
      if (options == null) {
        return BatchResult(
          success: 'false',
          error: 'Batch options are required',
        );
      }

      final db = _getDatabase(options.databaseId);

      if (options.operations == null) {
        return BatchResult(
          success: 'false',
          error: 'Operations are required',
        );
      }

      final operations = jsonDecode(options.operations!) as List<dynamic>;
      final batch = db.batch();

      for (final op in operations) {
        final operation = op as Map<String, dynamic>;
        final type = operation['type'] as String?;

        switch (type) {
          case 'insert':
            batch.insert(
              operation['table'] as String,
              operation['values'] as Map<String, dynamic>,
              conflictAlgorithm: _parseConflictAlgorithm(operation['conflictAlgorithm'] as String?),
            );
            break;
          case 'update':
            batch.update(
              operation['table'] as String,
              operation['values'] as Map<String, dynamic>,
              where: operation['where'] as String?,
              whereArgs: (operation['whereArgs'] as List?)?.cast<dynamic>(),
              conflictAlgorithm: _parseConflictAlgorithm(operation['conflictAlgorithm'] as String?),
            );
            break;
          case 'delete':
            batch.delete(
              operation['table'] as String,
              where: operation['where'] as String?,
              whereArgs: (operation['whereArgs'] as List?)?.cast<dynamic>(),
            );
            break;
          case 'execute':
            batch.execute(
              operation['sql'] as String,
              (operation['arguments'] as List?)?.cast<dynamic>(),
            );
            break;
          case 'rawInsert':
            batch.rawInsert(
              operation['sql'] as String,
              (operation['arguments'] as List?)?.cast<dynamic>(),
            );
            break;
          case 'rawUpdate':
            batch.rawUpdate(
              operation['sql'] as String,
              (operation['arguments'] as List?)?.cast<dynamic>(),
            );
            break;
          case 'rawDelete':
            batch.rawDelete(
              operation['sql'] as String,
              (operation['arguments'] as List?)?.cast<dynamic>(),
            );
            break;
          default:
            throw Exception('Unknown batch operation type: $type');
        }
      }

      final noResult = options.noResult ?? false;
      final continueOnError = options.continueOnError ?? false;

      final results = await batch.commit(
        noResult: noResult,
        continueOnError: continueOnError,
      );

      return BatchResult(
        success: 'true',
        results: noResult ? null : jsonEncode(results),
      );
    } catch (e) {
      return BatchResult(
        success: 'false',
        error: e.toString(),
      );
    }
  }

  // ============================================================================
  // Transaction Operations
  // ============================================================================

  @override
  Future<TransactionResult> transaction(TransactionOptions? options) async {
    try {
      if (options == null) {
        return TransactionResult(
          success: 'false',
          error: 'Transaction options are required',
        );
      }

      final db = _getDatabase(options.databaseId);

      if (options.operations == null) {
        return TransactionResult(
          success: 'false',
          error: 'Operations are required',
        );
      }

      final operations = jsonDecode(options.operations!) as List<dynamic>;
      final results = <dynamic>[];

      await db.transaction((txn) async {
        for (final op in operations) {
          final operation = op as Map<String, dynamic>;
          final type = operation['type'] as String?;

          switch (type) {
            case 'insert':
              final rowId = await txn.insert(
                operation['table'] as String,
                operation['values'] as Map<String, dynamic>,
                conflictAlgorithm: _parseConflictAlgorithm(operation['conflictAlgorithm'] as String?),
              );
              results.add({'type': 'insert', 'lastInsertRowId': rowId});
              break;
            case 'update':
              final count = await txn.update(
                operation['table'] as String,
                operation['values'] as Map<String, dynamic>,
                where: operation['where'] as String?,
                whereArgs: (operation['whereArgs'] as List?)?.cast<dynamic>(),
                conflictAlgorithm: _parseConflictAlgorithm(operation['conflictAlgorithm'] as String?),
              );
              results.add({'type': 'update', 'rowsAffected': count});
              break;
            case 'delete':
              final count = await txn.delete(
                operation['table'] as String,
                where: operation['where'] as String?,
                whereArgs: (operation['whereArgs'] as List?)?.cast<dynamic>(),
              );
              results.add({'type': 'delete', 'rowsAffected': count});
              break;
            case 'query':
              final rows = await txn.query(
                operation['table'] as String,
                columns: (operation['columns'] as List?)?.cast<String>(),
                where: operation['where'] as String?,
                whereArgs: (operation['whereArgs'] as List?)?.cast<dynamic>(),
                orderBy: operation['orderBy'] as String?,
                limit: operation['limit'] as int?,
                offset: operation['offset'] as int?,
              );
              results.add({'type': 'query', 'rows': rows, 'count': rows.length});
              break;
            case 'rawQuery':
              final rows = await txn.rawQuery(
                operation['sql'] as String,
                (operation['arguments'] as List?)?.cast<dynamic>(),
              );
              results.add({'type': 'rawQuery', 'rows': rows, 'count': rows.length});
              break;
            case 'rawInsert':
              final rowId = await txn.rawInsert(
                operation['sql'] as String,
                (operation['arguments'] as List?)?.cast<dynamic>(),
              );
              results.add({'type': 'rawInsert', 'lastInsertRowId': rowId});
              break;
            case 'rawUpdate':
              final count = await txn.rawUpdate(
                operation['sql'] as String,
                (operation['arguments'] as List?)?.cast<dynamic>(),
              );
              results.add({'type': 'rawUpdate', 'rowsAffected': count});
              break;
            case 'rawDelete':
              final count = await txn.rawDelete(
                operation['sql'] as String,
                (operation['arguments'] as List?)?.cast<dynamic>(),
              );
              results.add({'type': 'rawDelete', 'rowsAffected': count});
              break;
            case 'execute':
              await txn.execute(
                operation['sql'] as String,
                (operation['arguments'] as List?)?.cast<dynamic>(),
              );
              results.add({'type': 'execute', 'success': true});
              break;
            default:
              throw Exception('Unknown transaction operation type: $type');
          }
        }
      });

      return TransactionResult(
        success: 'true',
        results: jsonEncode(results),
      );
    } catch (e) {
      return TransactionResult(
        success: 'false',
        error: e.toString(),
      );
    }
  }
}
