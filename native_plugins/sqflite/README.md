# webf_sqflite

WebF native plugin for SQLite database operations. This plugin wraps the [sqflite](https://pub.dev/packages/sqflite) Flutter package to provide persistent local storage with SQL queries, transactions, and batch operations for WebF applications.

## Features

- Open, close, and delete databases
- Execute raw SQL queries (SELECT, INSERT, UPDATE, DELETE)
- Helper methods for common operations (query, insert, update, delete)
- Batch operations for improved performance
- Transaction support for atomicity
- In-memory database support
- Database version management and migrations

## Installation

### Flutter Side

Add the dependency to your Flutter app's `pubspec.yaml`:

```yaml
dependencies:
  webf: ^0.24.0
  webf_sqflite: ^1.0.0
```

Register the module in your `main.dart`:

```dart
import 'package:webf/webf.dart';
import 'package:webf_sqflite/webf_sqflite.dart';

void main() {
  WebFControllerManager.instance.initialize(WebFControllerManagerConfig(
    maxAliveInstances: 2,
    maxAttachedInstances: 1,
  ));

  // Register SQFlite module
  WebF.defineModule((context) => SQFliteModule(context));

  runApp(MyApp());
}
```

### JavaScript Side

Install the npm package:

```bash
npm install @openwebf/webf-sqflite
```

## Usage

### Basic Example

```typescript
import { WebFSQFlite } from '@openwebf/webf-sqflite';

async function example() {
  // Open a database with initial schema
  const openResult = await WebFSQFlite.openDatabase({
    path: 'my_app.db',
    version: 1,
    onCreate: [
      `CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        email TEXT UNIQUE,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP
      )`,
      `CREATE TABLE posts (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER,
        title TEXT,
        content TEXT,
        FOREIGN KEY (user_id) REFERENCES users(id)
      )`
    ]
  });

  if (openResult.success !== 'true') {
    console.error('Failed to open database:', openResult.error);
    return;
  }

  const dbId = openResult.databaseId!;

  // Insert a user
  const insertResult = await WebFSQFlite.insert({
    databaseId: dbId,
    table: 'users',
    values: JSON.stringify({
      name: 'John Doe',
      email: 'john@example.com'
    })
  });

  console.log('Inserted user with ID:', insertResult.lastInsertRowId);

  // Query all users
  const queryResult = await WebFSQFlite.query({
    databaseId: dbId,
    table: 'users',
    orderBy: 'name ASC'
  });

  if (queryResult.success === 'true') {
    const users = JSON.parse(queryResult.rows!);
    console.log('Users:', users);
  }

  // Close database when done
  await WebFSQFlite.closeDatabase(dbId);
}
```

### Raw SQL Queries

```typescript
// Raw SELECT query
const result = await WebFSQFlite.rawQuery({
  databaseId: dbId,
  sql: 'SELECT * FROM users WHERE email LIKE ?',
  arguments: ['%@example.com']
});

// Raw INSERT
const insertResult = await WebFSQFlite.rawInsert({
  databaseId: dbId,
  sql: 'INSERT INTO users (name, email) VALUES (?, ?)',
  arguments: ['Jane Doe', 'jane@example.com']
});

// Raw UPDATE
const updateResult = await WebFSQFlite.rawUpdate({
  databaseId: dbId,
  sql: 'UPDATE users SET name = ? WHERE id = ?',
  arguments: ['Jane Smith', 1]
});

// Raw DELETE
const deleteResult = await WebFSQFlite.rawDelete({
  databaseId: dbId,
  sql: 'DELETE FROM users WHERE id = ?',
  arguments: [1]
});

// Execute DDL statements
await WebFSQFlite.execute({
  databaseId: dbId,
  sql: 'CREATE INDEX idx_users_email ON users(email)'
});
```

### Batch Operations

Batch operations reduce communication overhead and improve performance:

```typescript
const batchResult = await WebFSQFlite.batch({
  databaseId: dbId,
  operations: JSON.stringify([
    {
      type: 'insert',
      table: 'users',
      values: { name: 'User 1', email: 'user1@example.com' }
    },
    {
      type: 'insert',
      table: 'users',
      values: { name: 'User 2', email: 'user2@example.com' }
    },
    {
      type: 'insert',
      table: 'users',
      values: { name: 'User 3', email: 'user3@example.com' }
    }
  ]),
  noResult: false
});

if (batchResult.success === 'true') {
  const results = JSON.parse(batchResult.results!);
  console.log('Batch results:', results);
}
```

### Transactions

Transactions ensure all operations succeed or all are rolled back:

```typescript
const txResult = await WebFSQFlite.transaction({
  databaseId: dbId,
  operations: JSON.stringify([
    {
      type: 'insert',
      table: 'users',
      values: { name: 'New User', email: 'new@example.com' }
    },
    {
      type: 'insert',
      table: 'posts',
      values: { user_id: 1, title: 'First Post', content: 'Hello World!' }
    },
    {
      type: 'query',
      table: 'users',
      where: 'email = ?',
      whereArgs: ['new@example.com']
    }
  ])
});

if (txResult.success === 'true') {
  const results = JSON.parse(txResult.results!);
  console.log('Transaction results:', results);
} else {
  console.error('Transaction failed (rolled back):', txResult.error);
}
```

### Database Management

```typescript
// Get default databases path
const pathResult = await WebFSQFlite.getDatabasesPath();
console.log('Databases path:', pathResult.path);

// Check if database exists
const existsResult = await WebFSQFlite.databaseExists('my_app.db');
console.log('Database exists:', existsResult.exists === 'true');

// Delete a database
const deleteResult = await WebFSQFlite.deleteDatabase('old_database.db');

// Open in-memory database
const memoryDb = await WebFSQFlite.openDatabase({
  path: 'memory_db',
  inMemory: true,
  onCreate: ['CREATE TABLE cache (key TEXT PRIMARY KEY, value TEXT)']
});

// Open read-only database
const readOnlyDb = await WebFSQFlite.openDatabase({
  path: 'existing.db',
  readOnly: true
});
```

### Query with Filters

```typescript
const result = await WebFSQFlite.query({
  databaseId: dbId,
  table: 'users',
  columns: ['id', 'name', 'email'],
  where: 'name LIKE ? AND created_at > ?',
  whereArgs: ['%John%', '2024-01-01'],
  orderBy: 'name ASC',
  limit: 10,
  offset: 0,
  distinct: true
});
```

### Update with Conflict Resolution

```typescript
const result = await WebFSQFlite.insert({
  databaseId: dbId,
  table: 'users',
  values: JSON.stringify({
    id: 1,
    name: 'Updated Name',
    email: 'updated@example.com'
  }),
  conflictAlgorithm: 'replace' // 'rollback' | 'abort' | 'fail' | 'ignore' | 'replace'
});
```

## API Reference

### Database Management

| Method | Description |
|--------|-------------|
| `getDatabasesPath()` | Get the default databases directory path |
| `openDatabase(options)` | Open or create a database |
| `closeDatabase(databaseId)` | Close a database connection |
| `deleteDatabase(path)` | Delete a database file |
| `databaseExists(path)` | Check if a database file exists |

### CRUD Operations

| Method | Description |
|--------|-------------|
| `query(options)` | Query rows from a table |
| `insert(options)` | Insert a row into a table |
| `update(options)` | Update rows in a table |
| `delete(options)` | Delete rows from a table |

### Raw SQL Operations

| Method | Description |
|--------|-------------|
| `rawQuery(options)` | Execute a raw SELECT query |
| `rawInsert(options)` | Execute a raw INSERT statement |
| `rawUpdate(options)` | Execute a raw UPDATE statement |
| `rawDelete(options)` | Execute a raw DELETE statement |
| `execute(options)` | Execute any SQL statement (DDL, etc.) |

### Batch & Transaction

| Method | Description |
|--------|-------------|
| `batch(options)` | Execute multiple operations in a batch |
| `transaction(options)` | Execute operations in a transaction |

## Platform Support

| Platform | Support |
|----------|---------|
| Android | Yes |
| iOS | Yes |
| macOS | Yes |
| Linux | Via sqflite_common_ffi |
| Windows | Via sqflite_common_ffi |

## License

MIT License - see the [LICENSE](LICENSE) file for details.

## Related

- [sqflite](https://pub.dev/packages/sqflite) - The underlying SQLite plugin
- [WebF Documentation](https://openwebf.com/en/docs)
- [WebF Native Plugins](https://openwebf.com/en/native-plugins)
