import React, { useState, useEffect, useCallback } from 'react';
import { WebFListView } from '@openwebf/react-core-ui';
import { WebFSQFlite } from '@openwebf/webf-sqflite';

interface User {
  id: number;
  name: string;
  email: string;
  created_at: string;
}

interface Task {
  id: number;
  user_id: number;
  title: string;
  completed: number;
}

export const WebFSQFlitePage: React.FC = () => {
  const [databaseId, setDatabaseId] = useState<string | null>(null);
  const [dbPath, setDbPath] = useState<string>('');
  const [users, setUsers] = useState<User[]>([]);
  const [tasks, setTasks] = useState<Task[]>([]);
  const [logs, setLogs] = useState<string[]>([]);
  const [isProcessing, setIsProcessing] = useState<{[key: string]: boolean}>({});
  const [newUserName, setNewUserName] = useState('');
  const [newUserEmail, setNewUserEmail] = useState('');
  const [newTaskTitle, setNewTaskTitle] = useState('');
  const [selectedUserId, setSelectedUserId] = useState<number | null>(null);

  const addLog = useCallback((message: string) => {
    const timestamp = new Date().toLocaleTimeString();
    setLogs(prev => [`[${timestamp}] ${message}`, ...prev.slice(0, 49)]);
  }, []);

  useEffect(() => {
    initializeDatabase();
    return () => {
      if (databaseId) {
        WebFSQFlite.closeDatabase(databaseId).catch(console.error);
      }
    };
  }, []);

  const initializeDatabase = async () => {
    if (!WebFSQFlite.isAvailable()) {
      addLog('WebFSQFlite is not available. Make sure the module is registered.');
      return;
    }

    setIsProcessing(prev => ({ ...prev, init: true }));
    try {
      const pathResult = await WebFSQFlite.getDatabasesPath();
      if (pathResult.success === 'true') {
        setDbPath(pathResult.path || '');
        addLog(`Databases path: ${pathResult.path}`);
      }

      const result = await WebFSQFlite.openDatabase({
        path: 'webf_demo.db',
        version: 1,
        onCreate: [
          `CREATE TABLE IF NOT EXISTS users (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            email TEXT UNIQUE,
            created_at TEXT DEFAULT CURRENT_TIMESTAMP
          )`,
          `CREATE TABLE IF NOT EXISTS tasks (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            user_id INTEGER,
            title TEXT NOT NULL,
            completed INTEGER DEFAULT 0,
            FOREIGN KEY (user_id) REFERENCES users(id)
          )`
        ]
      });

      if (result.success === 'true') {
        setDatabaseId(result.databaseId || null);
        addLog(`Database opened successfully! ID: ${result.databaseId}`);
        addLog(`Database version: ${result.version}`);
        await loadUsers(result.databaseId!);
        await loadTasks(result.databaseId!);
      } else {
        addLog(`Failed to open database: ${result.error}`);
      }
    } catch (error) {
      addLog(`Error initializing database: ${error}`);
    } finally {
      setIsProcessing(prev => ({ ...prev, init: false }));
    }
  };

  const loadUsers = async (dbId: string) => {
    try {
      const result = await WebFSQFlite.query({
        databaseId: dbId,
        table: 'users',
        orderBy: 'id DESC'
      });

      if (result.success === 'true' && result.rows) {
        const parsedUsers = JSON.parse(result.rows) as User[];
        setUsers(parsedUsers);
        addLog(`Loaded ${parsedUsers.length} users`);
      }
    } catch (error) {
      addLog(`Error loading users: ${error}`);
    }
  };

  const loadTasks = async (dbId: string) => {
    try {
      const result = await WebFSQFlite.query({
        databaseId: dbId,
        table: 'tasks',
        orderBy: 'id DESC'
      });

      if (result.success === 'true' && result.rows) {
        const parsedTasks = JSON.parse(result.rows) as Task[];
        setTasks(parsedTasks);
        addLog(`Loaded ${parsedTasks.length} tasks`);
      }
    } catch (error) {
      addLog(`Error loading tasks: ${error}`);
    }
  };

  const addUser = async () => {
    if (!databaseId || !newUserName.trim()) {
      addLog('Please enter a user name');
      return;
    }

    setIsProcessing(prev => ({ ...prev, addUser: true }));
    try {
      const result = await WebFSQFlite.insert({
        databaseId,
        table: 'users',
        values: JSON.stringify({
          name: newUserName.trim(),
          email: newUserEmail.trim() || `${newUserName.toLowerCase().replace(/\s+/g, '.')}@example.com`
        })
      });

      if (result.success === 'true') {
        addLog(`User added with ID: ${result.lastInsertRowId}`);
        setNewUserName('');
        setNewUserEmail('');
        await loadUsers(databaseId);
      } else {
        addLog(`Failed to add user: ${result.error}`);
      }
    } catch (error) {
      addLog(`Error adding user: ${error}`);
    } finally {
      setIsProcessing(prev => ({ ...prev, addUser: false }));
    }
  };

  const addTask = async () => {
    if (!databaseId || !newTaskTitle.trim() || !selectedUserId) {
      addLog('Please enter a task title and select a user');
      return;
    }

    setIsProcessing(prev => ({ ...prev, addTask: true }));
    try {
      const result = await WebFSQFlite.insert({
        databaseId,
        table: 'tasks',
        values: JSON.stringify({
          user_id: selectedUserId,
          title: newTaskTitle.trim(),
          completed: 0
        })
      });

      if (result.success === 'true') {
        addLog(`Task added with ID: ${result.lastInsertRowId}`);
        setNewTaskTitle('');
        await loadTasks(databaseId);
      } else {
        addLog(`Failed to add task: ${result.error}`);
      }
    } catch (error) {
      addLog(`Error adding task: ${error}`);
    } finally {
      setIsProcessing(prev => ({ ...prev, addTask: false }));
    }
  };

  const toggleTaskCompleted = async (taskId: number, currentStatus: number) => {
    if (!databaseId) return;

    try {
      const result = await WebFSQFlite.update({
        databaseId,
        table: 'tasks',
        values: JSON.stringify({ completed: currentStatus === 0 ? 1 : 0 }),
        where: 'id = ?',
        whereArgs: [taskId]
      });

      if (result.success === 'true') {
        addLog(`Task ${taskId} toggled. Rows affected: ${result.rowsAffected}`);
        await loadTasks(databaseId);
      } else {
        addLog(`Failed to update task: ${result.error}`);
      }
    } catch (error) {
      addLog(`Error updating task: ${error}`);
    }
  };

  const deleteUser = async (userId: number) => {
    if (!databaseId) return;

    setIsProcessing(prev => ({ ...prev, [`deleteUser_${userId}`]: true }));
    try {
      const result = await WebFSQFlite.transaction({
        databaseId,
        operations: JSON.stringify([
          {
            type: 'delete',
            table: 'tasks',
            where: 'user_id = ?',
            whereArgs: [userId]
          },
          {
            type: 'delete',
            table: 'users',
            where: 'id = ?',
            whereArgs: [userId]
          }
        ])
      });

      if (result.success === 'true') {
        const results = JSON.parse(result.results || '[]');
        addLog(`User ${userId} and related tasks deleted. Transaction results: ${JSON.stringify(results)}`);
        await loadUsers(databaseId);
        await loadTasks(databaseId);
      } else {
        addLog(`Failed to delete user: ${result.error}`);
      }
    } catch (error) {
      addLog(`Error deleting user: ${error}`);
    } finally {
      setIsProcessing(prev => ({ ...prev, [`deleteUser_${userId}`]: false }));
    }
  };

  const runRawQuery = async () => {
    if (!databaseId) return;

    setIsProcessing(prev => ({ ...prev, rawQuery: true }));
    try {
      const result = await WebFSQFlite.rawQuery({
        databaseId,
        sql: `
          SELECT u.name, u.email, COUNT(t.id) as task_count,
                 SUM(CASE WHEN t.completed = 1 THEN 1 ELSE 0 END) as completed_count
          FROM users u
          LEFT JOIN tasks t ON u.id = t.user_id
          GROUP BY u.id
          ORDER BY task_count DESC
        `
      });

      if (result.success === 'true') {
        addLog(`Raw query result (${result.count} rows):`);
        addLog(result.rows || '[]');
      } else {
        addLog(`Raw query failed: ${result.error}`);
      }
    } catch (error) {
      addLog(`Error running raw query: ${error}`);
    } finally {
      setIsProcessing(prev => ({ ...prev, rawQuery: false }));
    }
  };

  const runBatchInsert = async () => {
    if (!databaseId) return;

    setIsProcessing(prev => ({ ...prev, batch: true }));
    try {
      const batchUsers = [
        { name: 'Alice', email: 'alice@example.com' },
        { name: 'Bob', email: 'bob@example.com' },
        { name: 'Charlie', email: 'charlie@example.com' }
      ];

      const result = await WebFSQFlite.batch({
        databaseId,
        operations: JSON.stringify(
          batchUsers.map(user => ({
            type: 'insert',
            table: 'users',
            values: user,
            conflictAlgorithm: 'ignore'
          }))
        ),
        noResult: false
      });

      if (result.success === 'true') {
        addLog(`Batch insert completed. Results: ${result.results}`);
        await loadUsers(databaseId);
      } else {
        addLog(`Batch insert failed: ${result.error}`);
      }
    } catch (error) {
      addLog(`Error in batch insert: ${error}`);
    } finally {
      setIsProcessing(prev => ({ ...prev, batch: false }));
    }
  };

  const clearAllData = async () => {
    if (!databaseId) return;

    setIsProcessing(prev => ({ ...prev, clear: true }));
    try {
      const result = await WebFSQFlite.transaction({
        databaseId,
        operations: JSON.stringify([
          { type: 'delete', table: 'tasks' },
          { type: 'delete', table: 'users' }
        ])
      });

      if (result.success === 'true') {
        addLog('All data cleared successfully');
        setUsers([]);
        setTasks([]);
      } else {
        addLog(`Failed to clear data: ${result.error}`);
      }
    } catch (error) {
      addLog(`Error clearing data: ${error}`);
    } finally {
      setIsProcessing(prev => ({ ...prev, clear: false }));
    }
  };

  return (
    <div id="main">
      <WebFListView className="flex-1 p-0 m-0">
        <div className="p-5 bg-gray-100 dark:bg-gray-900 min-h-screen max-w-4xl mx-auto">
          <h1 className="text-2xl font-bold text-gray-800 dark:text-white mb-6 text-center">
            WebF SQFlite Module
          </h1>

          {/* Database Status */}
          <div className="bg-white dark:bg-gray-800 rounded-xl p-6 shadow-md border border-gray-200 dark:border-gray-700 mb-6">
            <h2 className="text-lg font-semibold text-gray-800 dark:text-white mb-2">Database Status</h2>
            <p className="text-sm text-gray-600 dark:text-gray-400 mb-4">
              SQLite database for persistent local storage
            </p>
            <div className="bg-gray-50 dark:bg-gray-700 rounded-lg p-4 border border-gray-200 dark:border-gray-600">
              <div className="mb-3">
                <span className="font-semibold text-gray-700 dark:text-gray-300">Status: </span>
                <span className={databaseId ? 'text-green-600' : 'text-red-600'}>
                  {databaseId ? 'Connected' : 'Disconnected'}
                </span>
              </div>
              {dbPath && (
                <div className="text-xs text-gray-500 dark:text-gray-400 mb-3 break-all">
                  <span className="font-semibold">Path:</span> {dbPath}
                </div>
              )}
              {!databaseId && (
                <button
                  className={`px-4 py-2 rounded-lg text-white font-medium transition-all ${
                    isProcessing.init
                      ? 'bg-yellow-500 animate-pulse'
                      : 'bg-blue-500 hover:bg-blue-600'
                  }`}
                  onClick={initializeDatabase}
                  disabled={isProcessing.init}
                >
                  {isProcessing.init ? 'Connecting...' : 'Connect Database'}
                </button>
              )}
            </div>
          </div>

          {/* Add User */}
          <div className="bg-white dark:bg-gray-800 rounded-xl p-6 shadow-md border border-gray-200 dark:border-gray-700 mb-6">
            <h2 className="text-lg font-semibold text-gray-800 dark:text-white mb-2">Add User</h2>
            <p className="text-sm text-gray-600 dark:text-gray-400 mb-4">
              Insert a new user into the database
            </p>
            <div className="bg-gray-50 dark:bg-gray-700 rounded-lg p-4 border border-gray-200 dark:border-gray-600">
              <input
                type="text"
                placeholder="Name"
                value={newUserName}
                onChange={(e) => setNewUserName(e.target.value)}
                className="w-full px-3 py-2 rounded-lg border border-gray-300 dark:border-gray-600 bg-white dark:bg-gray-800 text-gray-800 dark:text-white mb-2 focus:outline-none focus:ring-2 focus:ring-blue-500"
              />
              <input
                type="email"
                placeholder="Email (optional)"
                value={newUserEmail}
                onChange={(e) => setNewUserEmail(e.target.value)}
                className="w-full px-3 py-2 rounded-lg border border-gray-300 dark:border-gray-600 bg-white dark:bg-gray-800 text-gray-800 dark:text-white mb-3 focus:outline-none focus:ring-2 focus:ring-blue-500"
              />
              <button
                className={`px-4 py-2 rounded-lg text-white font-medium transition-all ${
                  isProcessing.addUser || !databaseId
                    ? 'bg-gray-400 cursor-not-allowed'
                    : 'bg-blue-500 hover:bg-blue-600'
                }`}
                onClick={addUser}
                disabled={isProcessing.addUser || !databaseId}
              >
                {isProcessing.addUser ? 'Adding...' : 'Add User'}
              </button>
            </div>
          </div>

          {/* Users List */}
          <div className="bg-white dark:bg-gray-800 rounded-xl p-6 shadow-md border border-gray-200 dark:border-gray-700 mb-6">
            <h2 className="text-lg font-semibold text-gray-800 dark:text-white mb-2">
              Users ({users.length})
            </h2>
            <p className="text-sm text-gray-600 dark:text-gray-400 mb-4">
              Click to select, delete to remove with related tasks
            </p>
            <div className="bg-gray-50 dark:bg-gray-700 rounded-lg p-4 border border-gray-200 dark:border-gray-600">
              {users.length === 0 ? (
                <div className="text-gray-500 text-center py-5">
                  No users yet. Add one above!
                </div>
              ) : (
                <div className="max-h-48 overflow-y-auto space-y-2">
                  {users.map(user => (
                    <div
                      key={user.id}
                      className={`flex items-center justify-between p-3 rounded-lg cursor-pointer transition-all ${
                        selectedUserId === user.id
                          ? 'bg-blue-100 dark:bg-blue-900 border-2 border-blue-500'
                          : 'bg-white dark:bg-gray-800 border border-gray-200 dark:border-gray-600 hover:bg-gray-100 dark:hover:bg-gray-700'
                      }`}
                      onClick={() => setSelectedUserId(user.id)}
                    >
                      <div>
                        <div className="font-semibold text-gray-800 dark:text-white">{user.name}</div>
                        <div className="text-xs text-gray-500 dark:text-gray-400">{user.email}</div>
                      </div>
                      <button
                        onClick={(e) => { e.stopPropagation(); deleteUser(user.id); }}
                        disabled={isProcessing[`deleteUser_${user.id}`]}
                        className="px-3 py-1 bg-red-500 hover:bg-red-600 text-white text-xs rounded-md transition-colors disabled:opacity-50"
                      >
                        {isProcessing[`deleteUser_${user.id}`] ? '...' : 'Delete'}
                      </button>
                    </div>
                  ))}
                </div>
              )}
            </div>
          </div>

          {/* Add Task */}
          <div className="bg-white dark:bg-gray-800 rounded-xl p-6 shadow-md border border-gray-200 dark:border-gray-700 mb-6">
            <h2 className="text-lg font-semibold text-gray-800 dark:text-white mb-2">Add Task</h2>
            <p className="text-sm text-gray-600 dark:text-gray-400 mb-4">
              Add a task for the selected user
            </p>
            <div className="bg-gray-50 dark:bg-gray-700 rounded-lg p-4 border border-gray-200 dark:border-gray-600">
              <input
                type="text"
                placeholder="Task title"
                value={newTaskTitle}
                onChange={(e) => setNewTaskTitle(e.target.value)}
                className="w-full px-3 py-2 rounded-lg border border-gray-300 dark:border-gray-600 bg-white dark:bg-gray-800 text-gray-800 dark:text-white mb-3 focus:outline-none focus:ring-2 focus:ring-blue-500"
              />
              {selectedUserId ? (
                <div className="text-sm text-gray-600 dark:text-gray-400 mb-3">
                  Adding task for: <span className="font-semibold">{users.find(u => u.id === selectedUserId)?.name}</span>
                </div>
              ) : (
                <div className="text-sm text-yellow-600 dark:text-yellow-400 mb-3">
                  Select a user above first
                </div>
              )}
              <button
                className={`px-4 py-2 rounded-lg text-white font-medium transition-all ${
                  isProcessing.addTask || !databaseId || !selectedUserId
                    ? 'bg-gray-400 cursor-not-allowed'
                    : 'bg-blue-500 hover:bg-blue-600'
                }`}
                onClick={addTask}
                disabled={isProcessing.addTask || !databaseId || !selectedUserId}
              >
                {isProcessing.addTask ? 'Adding...' : 'Add Task'}
              </button>
            </div>
          </div>

          {/* Tasks List */}
          <div className="bg-white dark:bg-gray-800 rounded-xl p-6 shadow-md border border-gray-200 dark:border-gray-700 mb-6">
            <h2 className="text-lg font-semibold text-gray-800 dark:text-white mb-2">
              Tasks ({tasks.length})
            </h2>
            <p className="text-sm text-gray-600 dark:text-gray-400 mb-4">
              Click to toggle completion status
            </p>
            <div className="bg-gray-50 dark:bg-gray-700 rounded-lg p-4 border border-gray-200 dark:border-gray-600">
              {tasks.length === 0 ? (
                <div className="text-gray-500 text-center py-5">
                  No tasks yet. Add one above!
                </div>
              ) : (
                <div className="max-h-48 overflow-y-auto space-y-2">
                  {tasks.map(task => {
                    const user = users.find(u => u.id === task.user_id);
                    return (
                      <div
                        key={task.id}
                        className={`flex items-center p-3 rounded-lg cursor-pointer transition-all ${
                          task.completed
                            ? 'bg-green-100 dark:bg-green-900'
                            : 'bg-white dark:bg-gray-800'
                        } border border-gray-200 dark:border-gray-600 hover:shadow-md`}
                        onClick={() => toggleTaskCompleted(task.id, task.completed)}
                      >
                        <div className={`w-5 h-5 rounded border-2 mr-3 flex items-center justify-center ${
                          task.completed
                            ? 'bg-blue-500 border-blue-500'
                            : 'bg-white border-blue-500'
                        }`}>
                          {task.completed ? (
                            <span className="text-white text-xs">&#10003;</span>
                          ) : null}
                        </div>
                        <div className="flex-1">
                          <div className={`${task.completed ? 'line-through text-gray-500' : 'text-gray-800 dark:text-white'}`}>
                            {task.title}
                          </div>
                          <div className="text-xs text-gray-400">
                            Assigned to: {user?.name || 'Unknown'}
                          </div>
                        </div>
                      </div>
                    );
                  })}
                </div>
              )}
            </div>
          </div>

          {/* Advanced Operations */}
          <div className="bg-white dark:bg-gray-800 rounded-xl p-6 shadow-md border border-gray-200 dark:border-gray-700 mb-6">
            <h2 className="text-lg font-semibold text-gray-800 dark:text-white mb-2">Advanced Operations</h2>
            <p className="text-sm text-gray-600 dark:text-gray-400 mb-4">
              Raw queries, batch operations, and data management
            </p>
            <div className="bg-gray-50 dark:bg-gray-700 rounded-lg p-4 border border-gray-200 dark:border-gray-600">
              <div className="flex flex-wrap gap-2">
                <button
                  className={`px-4 py-2 rounded-lg text-white font-medium transition-all ${
                    isProcessing.rawQuery || !databaseId
                      ? 'bg-gray-400 cursor-not-allowed'
                      : 'bg-blue-500 hover:bg-blue-600'
                  }`}
                  onClick={runRawQuery}
                  disabled={isProcessing.rawQuery || !databaseId}
                >
                  {isProcessing.rawQuery ? 'Querying...' : 'Run Stats Query'}
                </button>
                <button
                  className={`px-4 py-2 rounded-lg text-white font-medium transition-all ${
                    isProcessing.batch || !databaseId
                      ? 'bg-gray-400 cursor-not-allowed'
                      : 'bg-gray-600 hover:bg-gray-700'
                  }`}
                  onClick={runBatchInsert}
                  disabled={isProcessing.batch || !databaseId}
                >
                  {isProcessing.batch ? 'Inserting...' : 'Batch Insert Demo'}
                </button>
                <button
                  className={`px-4 py-2 rounded-lg text-white font-medium transition-all ${
                    isProcessing.clear || !databaseId
                      ? 'bg-gray-400 cursor-not-allowed'
                      : 'bg-red-500 hover:bg-red-600'
                  }`}
                  onClick={clearAllData}
                  disabled={isProcessing.clear || !databaseId}
                >
                  {isProcessing.clear ? 'Clearing...' : 'Clear All Data'}
                </button>
              </div>
            </div>
          </div>

          {/* Logs */}
          <div className="bg-white dark:bg-gray-800 rounded-xl p-6 shadow-md border border-gray-200 dark:border-gray-700 mb-6">
            <h2 className="text-lg font-semibold text-gray-800 dark:text-white mb-2">Operation Logs</h2>
            <p className="text-sm text-gray-600 dark:text-gray-400 mb-4">
              Real-time database operation logs
            </p>
            <div className="bg-gray-900 rounded-lg p-3 border border-gray-700 max-h-72 overflow-y-auto font-mono text-xs text-gray-300">
              {logs.length === 0 ? (
                <div className="text-gray-500">No logs yet...</div>
              ) : (
                logs.map((log, index) => (
                  <div key={index} className="mb-1 break-all">
                    {log}
                  </div>
                ))
              )}
            </div>
          </div>
        </div>
      </WebFListView>
    </div>
  );
};
