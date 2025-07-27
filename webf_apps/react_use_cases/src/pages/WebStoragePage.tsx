import React, { useState, useEffect } from 'react';
import { WebFListView } from '@openwebf/react-core-ui';
import styles from './WebStoragePage.module.css';

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
      <div className={styles.storageSection}>
        <div className={styles.storageHeader}>
          <div className={styles.storageTitle}>
            {type === 'local' ? 'localStorage' : 'sessionStorage'}
          </div>
          <div className={styles.storageUsage}>
            {usage.count} items • {usage.sizeFormatted}
          </div>
          <button 
            className={styles.clearButton}
            onClick={() => clearStorage(type)}
          >
            Clear All
          </button>
        </div>
        
        <div className={styles.storageTable}>
          {filteredItems.length === 0 ? (
            <div className={styles.emptyState}>
              {items.length === 0 ? 'No items stored' : 'No items match your search'}
            </div>
          ) : (
            filteredItems.map((item, index) => (
              <div key={`${item.key}-${index}`} className={styles.storageRow}>
                <div className={styles.storageKey}>
                  <span className={styles.keyText}>{item.key}</span>
                  <span className={styles.keySize}>{formatBytes(item.size)}</span>
                </div>
                <div className={styles.storageValue}>
                  <pre className={styles.valueText}>{formatValue(item.value)}</pre>
                </div>
                <div className={styles.storageActions}>
                  <button
                    className={styles.removeButton}
                    onClick={() => removeStorageItem(item.key, type)}
                  >
                    Remove
                  </button>
                </div>
              </div>
            ))
          )}
        </div>
      </div>
    );
  };

  return (
    <div id="main">
      <WebFListView className={styles.list}>
        <div className={styles.componentSection}>
          <div className={styles.sectionTitle}>Web Storage API</div>
          <div className={styles.componentBlock}>
            
            {/* Add New Item */}
            <div className={styles.componentItem}>
              <div className={styles.itemLabel}>Add Storage Item</div>
              <div className={styles.itemDesc}>Add key-value pairs to localStorage or sessionStorage</div>
              <div className={styles.addForm}>
                <div className={styles.storageTypeButtons}>
                  <button
                    className={`${styles.typeButton} ${storageType === 'local' ? styles.active : ''}`}
                    onClick={() => setStorageType('local')}
                  >
                    localStorage
                  </button>
                  <button
                    className={`${styles.typeButton} ${storageType === 'session' ? styles.active : ''}`}
                    onClick={() => setStorageType('session')}
                  >
                    sessionStorage
                  </button>
                </div>
                <div className={styles.formRow}>
                  <input
                    type="text"
                    value={newKey}
                    onChange={(e) => setNewKey(e.target.value)}
                    placeholder="Enter key..."
                    className={styles.textInput}
                  />
                  <input
                    type="text"
                    value={newValue}
                    onChange={(e) => setNewValue(e.target.value)}
                    placeholder="Enter value..."
                    className={styles.textInput}
                  />
                </div>
                <div className={styles.formActions}>
                  <button className={styles.actionButton} onClick={addStorageItem}>
                    Add Item
                  </button>
                  <button className={styles.actionButton} onClick={generateSampleData}>
                    Generate Sample Data
                  </button>
                </div>
              </div>
            </div>

            {/* Search */}
            <div className={styles.componentItem}>
              <div className={styles.itemLabel}>Search Storage</div>
              <div className={styles.itemDesc}>Search through stored keys and values in both localStorage and sessionStorage</div>
              <div className={styles.searchContainer}>
                <input
                  type="text"
                  value={searchTerm}
                  onChange={(e) => setSearchTerm(e.target.value)}
                  placeholder="Search keys and values..."
                  className={styles.searchInput}
                />
                {searchTerm && (
                  <div className={styles.searchResults}>
                    <div className={styles.searchSummary}>
                      Found {filterItems(localStorageItems).length} items in localStorage, {filterItems(sessionStorageItems).length} items in sessionStorage
                    </div>
                    <button 
                      className={styles.clearSearchButton}
                      onClick={() => setSearchTerm('')}
                    >
                      Clear Search
                    </button>
                  </div>
                )}
              </div>
            </div>

            {/* Storage Tables */}
            <div className={styles.componentItem}>
              <div className={styles.itemLabel}>Storage Contents</div>
              <div className={styles.itemDesc}>View and manage stored data</div>
              
              {renderStorageTable(localStorageItems, 'local')}
              {renderStorageTable(sessionStorageItems, 'session')}
            </div>

            {/* Storage Info */}
            <div className={styles.componentItem}>
              <div className={styles.itemLabel}>Storage Information</div>
              <div className={styles.itemDesc}>Browser storage capabilities and limits</div>
              <div className={styles.infoGrid}>
                <div className={styles.infoCard}>
                  <div className={styles.infoTitle}>localStorage</div>
                  <div className={styles.infoContent}>
                    <div className={styles.infoStat}>
                      Items: {localStorageItems.length}
                    </div>
                    <div className={styles.infoStat}>
                      Size: {getStorageUsage(localStorageItems).sizeFormatted}
                    </div>
                    <div className={styles.infoDesc}>
                      Persistent storage that survives browser restarts
                    </div>
                  </div>
                </div>
                
                <div className={styles.infoCard}>
                  <div className={styles.infoTitle}>sessionStorage</div>
                  <div className={styles.infoContent}>
                    <div className={styles.infoStat}>
                      Items: {sessionStorageItems.length}
                    </div>
                    <div className={styles.infoStat}>
                      Size: {getStorageUsage(sessionStorageItems).sizeFormatted}
                    </div>
                    <div className={styles.infoDesc}>
                      Temporary storage that clears when tab closes
                    </div>
                  </div>
                </div>
                
                <div className={styles.infoCard}>
                  <div className={styles.infoTitle}>Typical Limits</div>
                  <div className={styles.infoContent}>
                    <div className={styles.infoStat}>
                      localStorage: ~5-10MB
                    </div>
                    <div className={styles.infoStat}>
                      sessionStorage: ~5-10MB
                    </div>
                    <div className={styles.infoDesc}>
                      Varies by browser and available disk space
                    </div>
                  </div>
                </div>
              </div>
            </div>

          </div>
        </div>
      </WebFListView>
    </div>
  );
};