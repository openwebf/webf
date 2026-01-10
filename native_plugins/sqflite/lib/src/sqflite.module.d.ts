/**
 * Type-safe JavaScript API for the WebF SQFlite module.
 *
 * This interface is used by the WebF CLI (`webf module-codegen`) to generate:
 * - An npm package wrapper that forwards calls to `webf.invokeModuleAsync`
 * - Dart bindings that map module `invoke` calls to strongly-typed methods
 */

/**
 * Options for opening a database.
 */
interface OpenDatabaseOptions {
  /** Database file path. If relative, uses the default database directory. */
  path: string;
  /** Database schema version. Used for migrations. */
  version?: number;
  /** SQL statements to execute when creating a new database. */
  onCreate?: string[];
  /** SQL statements to execute when upgrading the database. */
  onUpgrade?: string[];
  /** Whether to open the database in read-only mode. */
  readOnly?: boolean;
  /** Whether this is an in-memory database. */
  inMemory?: boolean;
}

/**
 * Result from opening a database.
 */
interface OpenDatabaseResult {
  /** "true" on success, "false" on failure. */
  success: string;
  /** Unique database handle ID for subsequent operations. */
  databaseId?: string;
  /** Database file path. */
  path?: string;
  /** Current database version. */
  version?: number;
  /** Error message if operation failed. */
  error?: string;
}

/**
 * Result from closing a database.
 */
interface CloseDatabaseResult {
  /** "true" on success, "false" on failure. */
  success: string;
  /** Error message if operation failed. */
  error?: string;
}

/**
 * Options for query operations.
 */
interface QueryOptions {
  /** Database handle ID. */
  databaseId: string;
  /** Table name to query. */
  table: string;
  /** Columns to select. If not specified, selects all columns. */
  columns?: string[];
  /** WHERE clause (without 'WHERE' keyword). */
  where?: string;
  /** Arguments for WHERE clause placeholders. */
  whereArgs?: (string | number | null)[];
  /** ORDER BY clause (without 'ORDER BY' keyword). */
  orderBy?: string;
  /** Maximum number of rows to return. */
  limit?: number;
  /** Number of rows to skip. */
  offset?: number;
  /** GROUP BY clause (without 'GROUP BY' keyword). */
  groupBy?: string;
  /** HAVING clause (without 'HAVING' keyword). */
  having?: string;
  /** Whether to return distinct rows only. */
  distinct?: boolean;
}

/**
 * Result from query operations.
 */
interface QueryResult {
  /** "true" on success, "false" on failure. */
  success: string;
  /** Array of rows as JSON string. Each row is an object with column names as keys. */
  rows?: string;
  /** Number of rows returned. */
  count?: number;
  /** Error message if operation failed. */
  error?: string;
}

/**
 * Options for insert operations.
 */
interface InsertOptions {
  /** Database handle ID. */
  databaseId: string;
  /** Table name to insert into. */
  table: string;
  /** Values to insert as a JSON object. */
  values: string;
  /** Conflict resolution algorithm. */
  conflictAlgorithm?: 'rollback' | 'abort' | 'fail' | 'ignore' | 'replace';
}

/**
 * Result from insert operations.
 */
interface InsertResult {
  /** "true" on success, "false" on failure. */
  success: string;
  /** Row ID of the inserted row. */
  lastInsertRowId?: number;
  /** Error message if operation failed. */
  error?: string;
}

/**
 * Options for update operations.
 */
interface UpdateOptions {
  /** Database handle ID. */
  databaseId: string;
  /** Table name to update. */
  table: string;
  /** Values to update as a JSON object. */
  values: string;
  /** WHERE clause (without 'WHERE' keyword). */
  where?: string;
  /** Arguments for WHERE clause placeholders. */
  whereArgs?: (string | number | null)[];
  /** Conflict resolution algorithm. */
  conflictAlgorithm?: 'rollback' | 'abort' | 'fail' | 'ignore' | 'replace';
}

/**
 * Result from update operations.
 */
interface UpdateResult {
  /** "true" on success, "false" on failure. */
  success: string;
  /** Number of rows affected. */
  rowsAffected?: number;
  /** Error message if operation failed. */
  error?: string;
}

/**
 * Options for delete operations.
 */
interface DeleteOptions {
  /** Database handle ID. */
  databaseId: string;
  /** Table name to delete from. */
  table: string;
  /** WHERE clause (without 'WHERE' keyword). */
  where?: string;
  /** Arguments for WHERE clause placeholders. */
  whereArgs?: (string | number | null)[];
}

/**
 * Result from delete operations.
 */
interface DeleteResult {
  /** "true" on success, "false" on failure. */
  success: string;
  /** Number of rows deleted. */
  rowsAffected?: number;
  /** Error message if operation failed. */
  error?: string;
}

/**
 * Options for raw SQL operations.
 */
interface RawSqlOptions {
  /** Database handle ID. */
  databaseId: string;
  /** SQL statement to execute. */
  sql: string;
  /** Arguments for SQL placeholders. */
  arguments?: (string | number | null)[];
}

/**
 * Result from raw query operations.
 */
interface RawQueryResult {
  /** "true" on success, "false" on failure. */
  success: string;
  /** Array of rows as JSON string. */
  rows?: string;
  /** Number of rows returned. */
  count?: number;
  /** Error message if operation failed. */
  error?: string;
}

/**
 * Result from raw insert operations.
 */
interface RawInsertResult {
  /** "true" on success, "false" on failure. */
  success: string;
  /** Row ID of the inserted row. */
  lastInsertRowId?: number;
  /** Error message if operation failed. */
  error?: string;
}

/**
 * Result from raw update/delete operations.
 */
interface RawUpdateResult {
  /** "true" on success, "false" on failure. */
  success: string;
  /** Number of rows affected. */
  rowsAffected?: number;
  /** Error message if operation failed. */
  error?: string;
}

/**
 * Result from execute operations.
 */
interface ExecuteResult {
  /** "true" on success, "false" on failure. */
  success: string;
  /** Error message if operation failed. */
  error?: string;
}

/**
 * Options for batch operations.
 */
interface BatchOptions {
  /** Database handle ID. */
  databaseId: string;
  /** Array of batch operations as JSON string. */
  operations: string;
  /** Whether to continue on error. */
  continueOnError?: boolean;
  /** Whether to skip returning results for performance. */
  noResult?: boolean;
}

/**
 * Result from batch operations.
 */
interface BatchResult {
  /** "true" on success, "false" on failure. */
  success: string;
  /** Results from each operation as JSON string. */
  results?: string;
  /** Error message if operation failed. */
  error?: string;
}

/**
 * Options for transaction operations.
 */
interface TransactionOptions {
  /** Database handle ID. */
  databaseId: string;
  /** Array of SQL operations to execute in transaction as JSON string. */
  operations: string;
}

/**
 * Result from transaction operations.
 */
interface TransactionResult {
  /** "true" on success, "false" on failure. */
  success: string;
  /** Results from each operation as JSON string. */
  results?: string;
  /** Error message if operation failed. */
  error?: string;
}

/**
 * Result from getDatabasesPath operation.
 */
interface DatabasesPathResult {
  /** "true" on success, "false" on failure. */
  success: string;
  /** The default databases directory path. */
  path?: string;
  /** Error message if operation failed. */
  error?: string;
}

/**
 * Result from deleteDatabase operation.
 */
interface DeleteDatabaseResult {
  /** "true" on success, "false" on failure. */
  success: string;
  /** Error message if operation failed. */
  error?: string;
}

/**
 * Result from databaseExists operation.
 */
interface DatabaseExistsResult {
  /** "true" on success, "false" on failure. */
  success: string;
  /** "true" if database exists, "false" otherwise. */
  exists?: string;
  /** Error message if operation failed. */
  error?: string;
}

/**
 * Public WebF SQFlite module interface.
 *
 * Methods here map 1:1 to the underlying Dart `SQFliteModule.invoke` methods.
 *
 * Module name: "SQFlite"
 */
interface WebFSQFlite {
  // ============================================================================
  // Database Management
  // ============================================================================

  /**
   * Get the default databases directory path.
   *
   * @returns Promise with the path result.
   */
  getDatabasesPath(): Promise<DatabasesPathResult>;

  /**
   * Open or create a database.
   *
   * @param options Database open options.
   * @returns Promise with the database handle result.
   */
  openDatabase(options: OpenDatabaseOptions): Promise<OpenDatabaseResult>;

  /**
   * Close a database connection.
   *
   * @param databaseId Database handle ID to close.
   * @returns Promise with the close result.
   */
  closeDatabase(databaseId: string): Promise<CloseDatabaseResult>;

  /**
   * Delete a database file.
   *
   * @param path Path to the database file to delete.
   * @returns Promise with the delete result.
   */
  deleteDatabase(path: string): Promise<DeleteDatabaseResult>;

  /**
   * Check if a database file exists.
   *
   * @param path Path to the database file to check.
   * @returns Promise with the exists result.
   */
  databaseExists(path: string): Promise<DatabaseExistsResult>;

  // ============================================================================
  // Helper Methods (Abstracted SQL)
  // ============================================================================

  /**
   * Query rows from a table.
   *
   * @param options Query options.
   * @returns Promise with the query result.
   */
  query(options: QueryOptions): Promise<QueryResult>;

  /**
   * Insert a row into a table.
   *
   * @param options Insert options.
   * @returns Promise with the insert result.
   */
  insert(options: InsertOptions): Promise<InsertResult>;

  /**
   * Update rows in a table.
   *
   * @param options Update options.
   * @returns Promise with the update result.
   */
  update(options: UpdateOptions): Promise<UpdateResult>;

  /**
   * Delete rows from a table.
   *
   * @param options Delete options.
   * @returns Promise with the delete result.
   */
  delete(options: DeleteOptions): Promise<DeleteResult>;

  // ============================================================================
  // Raw SQL Operations
  // ============================================================================

  /**
   * Execute a raw SELECT query.
   *
   * @param options Raw SQL options.
   * @returns Promise with the query result.
   */
  rawQuery(options: RawSqlOptions): Promise<RawQueryResult>;

  /**
   * Execute a raw INSERT statement.
   *
   * @param options Raw SQL options.
   * @returns Promise with the insert result.
   */
  rawInsert(options: RawSqlOptions): Promise<RawInsertResult>;

  /**
   * Execute a raw UPDATE statement.
   *
   * @param options Raw SQL options.
   * @returns Promise with the update result.
   */
  rawUpdate(options: RawSqlOptions): Promise<RawUpdateResult>;

  /**
   * Execute a raw DELETE statement.
   *
   * @param options Raw SQL options.
   * @returns Promise with the delete result.
   */
  rawDelete(options: RawSqlOptions): Promise<RawUpdateResult>;

  /**
   * Execute a raw SQL statement (DDL, etc.).
   *
   * @param options Raw SQL options.
   * @returns Promise with the execute result.
   */
  execute(options: RawSqlOptions): Promise<ExecuteResult>;

  // ============================================================================
  // Batch Operations
  // ============================================================================

  /**
   * Execute multiple operations in a batch.
   *
   * Batching reduces communication overhead and improves performance.
   *
   * @param options Batch options with array of operations.
   * @returns Promise with the batch result.
   */
  batch(options: BatchOptions): Promise<BatchResult>;

  // ============================================================================
  // Transaction Operations
  // ============================================================================

  /**
   * Execute multiple operations in a transaction.
   *
   * All operations succeed or all are rolled back.
   *
   * @param options Transaction options with array of operations.
   * @returns Promise with the transaction result.
   */
  transaction(options: TransactionOptions): Promise<TransactionResult>;
}
