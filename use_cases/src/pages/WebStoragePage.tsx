import React, { useState, useEffect } from 'react';
import { WebFListView } from '@openwebf/react-core-ui';

interface StorageItem {
  key: string;
  value: string;
  size: number;
  timestamp: string;
}

export const WebStoragePage: React.FC = () => {
  const [localStorageItems, setLocalStorageItems] = useState<StorageItem[]>([]);
  const [sessionStorageItems, setSessionStorageItems] = useState<StorageItem[]>([]);
  const [newKey, setNewKey] = useState('');
  const [newValue, setNewValue] = useState('');
  const [storageType, setStorageType] = useState<'local' | 'session'>('local');
  const [searchTerm, setSearchTerm] = useState('');

  const loadStorageItems = () => {
    // Load localStorage items
    const localItems: StorageItem[] = [];
    for (let i = 0; i < localStorage.length; i++) {
      const key = localStorage.key(i);
      if (key) {
        const value = localStorage.getItem(key) || '';
        localItems.push({
          key,
          value,
          size: new Blob([value]).size,
          timestamp: new Date().toLocaleString()
        });
      }
    }
    setLocalStorageItems(localItems);

    // Load sessionStorage items
    const sessionItems: StorageItem[] = [];
    for (let i = 0; i < sessionStorage.length; i++) {
      const key = sessionStorage.key(i);
      if (key) {
        const value = sessionStorage.getItem(key) || '';
        sessionItems.push({
          key,
          value,
          size: new Blob([value]).size,
          timestamp: new Date().toLocaleString()
        });
      }
    }
    setSessionStorageItems(sessionItems);
  };

  useEffect(() => {
    loadStorageItems();
  }, []);

  const addStorageItem = () => {
    console.log('addStorageItem', newKey, newValue);
    if (!newKey.trim() || !newValue.trim()) return;

    const storage = storageType === 'local' ? localStorage : sessionStorage;
    storage.setItem(newKey.trim(), newValue);
    
    setNewKey('');
    setNewValue('');
    loadStorageItems();
  };

  const removeStorageItem = (key: string, type: 'local' | 'session') => {
    const storage = type === 'local' ? localStorage : sessionStorage;
    storage.removeItem(key);
    loadStorageItems();
  };

  const clearStorage = (type: 'local' | 'session') => {
    const storage = type === 'local' ? localStorage : sessionStorage;
    storage.clear();
    loadStorageItems();
  };


  const generateSampleData = () => {
    const samples = [
      { key: 'user_preferences', value: '{"theme":"dark","language":"en","notifications":true}' },
      { key: 'cart_items', value: '[{"id":1,"name":"Laptop","price":999},{"id":2,"name":"Mouse","price":25}]' },
      { key: 'last_visited', value: new Date().toISOString() },
      { key: 'app_version', value: '1.2.3' },
      { key: 'feature_flags', value: '{"newUI":true,"betaFeatures":false,"analytics":true}' }
    ];

    const storage = storageType === 'local' ? localStorage : sessionStorage;
    samples.forEach(({ key, value }) => {
      storage.setItem(key, value);
    });
    loadStorageItems();
  };

  const getStorageUsage = (items: StorageItem[]) => {
    const totalSize = items.reduce((sum, item) => sum + item.size, 0);
    return {
      count: items.length,
      size: totalSize,
      sizeFormatted: formatBytes(totalSize)
    };
  };

  const formatBytes = (bytes: number) => {
    if (bytes === 0) return '0 B';
    const k = 1024;
    const sizes = ['B', 'KB', 'MB', 'GB'];
    const i = Math.floor(Math.log(bytes) / Math.log(k));
    return parseFloat((bytes / Math.pow(k, i)).toFixed(2)) + ' ' + sizes[i];
  };

  const filterItems = (items: StorageItem[]) => {
    if (!searchTerm) return items;
    return items.filter(item => 
      item.key.toLowerCase().includes(searchTerm.toLowerCase()) ||
      item.value.toLowerCase().includes(searchTerm.toLowerCase())
    );
  };

  const formatValue = (value: string) => {
    try {
      const parsed = JSON.parse(value);
      return JSON.stringify(parsed, null, 2);
    } catch {
      return value;
    }
  };

  const renderStorageTable = (items: StorageItem[], type: 'local' | 'session') => {
    const filteredItems = filterItems(items);
    const usage = getStorageUsage(items);

    return (
      <div className="mt-4">
        <div className="flex items-center gap-2 mb-2">
          <div className="text-base font-medium text-fg-primary">
            {type === 'local' ? 'localStorage' : 'sessionStorage'}
          </div>
          <div className="text-sm text-fg-secondary">{usage.count} items • {usage.sizeFormatted}</div>
          <button className="ml-auto px-3 py-1.5 rounded border border-line hover:bg-surface-hover" onClick={() => clearStorage(type)}>Clear All</button>
        </div>
        <div className="space-y-2">
          {filteredItems.length === 0 ? (
            <div className="text-sm text-fg-secondary border border-dashed border-line rounded p-3">
              {items.length === 0 ? 'No items stored' : 'No items match your search'}
            </div>
          ) : (
            filteredItems.map((item, index) => (
              <div key={`${item.key}-${index}`} className="border border-line rounded p-3 bg-surface">
                <div className="flex items-center gap-2 mb-2">
                  <span className="font-medium text-fg-primary break-all">{item.key}</span>
                  <span className="text-xs text-fg-secondary">{formatBytes(item.size)}</span>
                  <button className="ml-auto px-2 py-1 rounded border border-line hover:bg-surface-hover" onClick={() => removeStorageItem(item.key, type)}>Remove</button>
                </div>
                <pre className="text-sm bg-surface rounded border border-line p-2 overflow-auto">{formatValue(item.value)}</pre>
              </div>
            ))
          )}
        </div>
      </div>
    );
  };

  return (
    <div id="main" className="min-h-screen w-full bg-surface">
      <WebFListView className="w-full px-3 md:px-6 max-w-4xl mx-auto py-6">
          <h1 className="text-2xl font-semibold text-fg-primary mb-4">Web Storage API</h1>
          <div className="flex flex-col gap-6">
            
            {/* Add New Item */}
            <div className="bg-surface-secondary border border-line rounded-xl p-4">
              <div className="text-lg font-medium text-fg-primary">Add Storage Item</div>
              <div className="text-sm text-fg-secondary mb-3">Add key-value pairs to localStorage or sessionStorage</div>
              <div className="space-y-3">
                <div className="flex gap-2 flex-wrap">
                  <button className={`px-3 py-1.5 rounded border border-line ${storageType === 'local' ? 'bg-black text-white' : 'hover:bg-surface-hover'}`} onClick={() => setStorageType('local')}>localStorage</button>
                  <button className={`px-3 py-1.5 rounded border border-line ${storageType === 'session' ? 'bg-black text-white' : 'hover:bg-surface-hover'}`} onClick={() => setStorageType('session')}>sessionStorage</button>
                </div>
                <div className="flex gap-2 flex-wrap">
                  <input type="text" value={newKey} onChange={(e) => setNewKey(e.target.value)} placeholder="Enter key..." className="rounded border border-line px-3 py-2 bg-surface flex-1 min-w-[200px]" />
                  <input type="text" value={newValue} onChange={(e) => setNewValue(e.target.value)} placeholder="Enter value..." className="rounded border border-line px-3 py-2 bg-surface flex-1 min-w-[200px]" />
                </div>
                <div className="flex gap-2 flex-wrap">
                  <button className="px-3 py-2 rounded border border-line hover:bg-surface-hover" onClick={addStorageItem}>Add Item</button>
                  <button className="px-3 py-2 rounded border border-line hover:bg-surface-hover" onClick={generateSampleData}>Generate Sample Data</button>
                </div>
              </div>
            </div>

            {/* Search */}
            <div className="bg-surface-secondary border border-line rounded-xl p-4">
              <div className="text-lg font-medium text-fg-primary">Search Storage</div>
              <div className="text-sm text-fg-secondary mb-3">Search through stored keys and values in both localStorage and sessionStorage</div>
              <div>
                <input type="text" value={searchTerm} onChange={(e) => setSearchTerm(e.target.value)} placeholder="Search keys and values..." className="w-full rounded border border-line px-3 py-2 bg-surface" />
                {searchTerm && (
                  <div className="flex items-center justify-between text-sm text-fg-secondary mt-2">
                    <div>Found {filterItems(localStorageItems).length} items in localStorage, {filterItems(sessionStorageItems).length} items in sessionStorage</div>
                    <button className="px-3 py-1.5 rounded border border-line hover:bg-surface-hover" onClick={() => setSearchTerm('')}>Clear Search</button>
                  </div>
                )}
              </div>
            </div>

            {/* Storage Tables */}
            <div className="bg-surface-secondary border border-line rounded-xl p-4">
              <div className="text-lg font-medium text-fg-primary">Storage Contents</div>
              <div className="text-sm text-fg-secondary mb-2">View and manage stored data</div>
              {renderStorageTable(localStorageItems, 'local')}
              {renderStorageTable(sessionStorageItems, 'session')}
            </div>

            {/* Storage Info */}
            <div className="bg-surface-secondary border border-line rounded-xl p-4">
              <div className="text-lg font-medium text-fg-primary">Storage Information</div>
              <div className="text-sm text-fg-secondary mb-3">Browser storage capabilities and limits</div>
              <div className="grid grid-cols-1 md:grid-cols-3 gap-3">
                <div className="border border-line rounded p-3 bg-surface">
                  <div className="font-medium mb-2">localStorage</div>
                  <div className="text-sm">Items: {localStorageItems.length}</div>
                  <div className="text-sm">Size: {getStorageUsage(localStorageItems).sizeFormatted}</div>
                  <div className="text-sm text-fg-secondary mt-1">Persistent storage that survives browser restarts</div>
                </div>
                <div className="border border-line rounded p-3 bg-surface">
                  <div className="font-medium mb-2">sessionStorage</div>
                  <div className="text-sm">Items: {sessionStorageItems.length}</div>
                  <div className="text-sm">Size: {getStorageUsage(sessionStorageItems).sizeFormatted}</div>
                  <div className="text-sm text-fg-secondary mt-1">Temporary storage that clears when tab closes</div>
                </div>
                <div className="border border-line rounded p-3 bg-surface">
                  <div className="font-medium mb-2">Typical Limits</div>
                  <div className="text-sm">localStorage: ~5-10MB</div>
                  <div className="text-sm">sessionStorage: ~5-10MB</div>
                  <div className="text-sm text-fg-secondary mt-1">Varies by browser and available disk space</div>
                </div>
              </div>
            </div>

          </div>
      </WebFListView>
    </div>
  );
};
