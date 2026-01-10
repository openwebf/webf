/// WebF SQFlite module for SQLite database operations.
///
/// This module provides functionality to:
/// - Open, close, and delete databases
/// - Execute raw SQL queries (SELECT, INSERT, UPDATE, DELETE)
/// - Use helper methods for common operations (query, insert, update, delete)
/// - Execute batch operations for improved performance
/// - Execute transactions for atomicity
///
/// ## Flutter Setup
///
/// Register the module globally in your main function:
///
/// ```dart
/// import 'package:webf/webf.dart';
/// import 'package:webf_sqflite/webf_sqflite.dart';
///
/// void main() {
///   WebFControllerManager.instance.initialize(WebFControllerManagerConfig(
///     maxAliveInstances: 2,
///     maxAttachedInstances: 1,
///   ));
///
///   // Register SQFlite module
///   WebF.defineModule((context) => SQFliteModule(context));
///
///   runApp(MyApp());
/// }
/// ```
///
/// ## JavaScript Usage with npm Package (Recommended)
///
/// Install the npm package:
///
/// ```bash
/// npm install @openwebf/webf-sqflite
/// ```
///
/// Use in your JavaScript/TypeScript code:
///
/// ```javascript
/// import { WebFSQFlite } from '@openwebf/webf-sqflite';
///
/// // Open a database
/// const result = await WebFSQFlite.openDatabase({
///   path: 'my_database.db',
///   version: 1,
///   onCreate: [
///     'CREATE TABLE users (id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT, email TEXT)'
///   ]
/// });
///
/// if (result.success === 'true') {
///   const dbId = result.databaseId;
///
///   // Insert a user
///   const insertResult = await WebFSQFlite.insert({
///     databaseId: dbId,
///     table: 'users',
///     values: JSON.stringify({ name: 'John Doe', email: 'john@example.com' })
///   });
///
///   // Query all users
///   const queryResult = await WebFSQFlite.query({
///     databaseId: dbId,
///     table: 'users'
///   });
///
///   if (queryResult.success === 'true') {
///     const users = JSON.parse(queryResult.rows);
///     console.log('Users:', users);
///   }
///
///   // Close the database when done
///   await WebFSQFlite.closeDatabase(dbId);
/// }
/// ```
///
/// ## Direct Module Invocation (Legacy)
///
/// ```javascript
/// const result = await webf.invokeModuleAsync('SQFlite', 'openDatabase', {
///   path: 'my_database.db',
///   version: 1
/// });
/// ```
library webf_sqflite;

export 'src/sqflite_module.dart';
