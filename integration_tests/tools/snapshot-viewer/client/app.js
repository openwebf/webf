class SnapshotViewer {
  constructor() {
    this.snapshots = [];
    this.currentIndex = -1;
    this.currentSnapshot = null;
    this.init();
  }

  init() {
    this.setupEventListeners();
    this.loadSnapshots();
    this.setupKeyboardShortcuts();
  }

  setupEventListeners() {
    // Navigation buttons
    document.getElementById('prev-btn').addEventListener('click', () => this.navigatePrevious());
    document.getElementById('next-btn').addEventListener('click', () => this.navigateNext());

    // Action buttons
    document.getElementById('accept-current').addEventListener('click', () => this.acceptCurrent());
    document.getElementById('keep-original').addEventListener('click', () => this.keepOriginal());

    // Bulk actions
    document.getElementById('accept-all-current').addEventListener('click', () => this.acceptAllCurrent());
    document.getElementById('keep-all-original').addEventListener('click', () => this.keepAllOriginal());

    // Rescan button
    document.getElementById('rescan-btn').addEventListener('click', () => this.rescanSnapshots());
  }

  setupKeyboardShortcuts() {
    document.addEventListener('keydown', (e) => {
      // Check if any input is focused
      if (document.activeElement.tagName === 'INPUT') return;

      switch(e.key) {
        case 'ArrowLeft':
          if (e.metaKey || e.ctrlKey) {
            e.preventDefault();
            this.navigatePrevious();
          }
          break;
        case 'ArrowRight':
          if (e.metaKey || e.ctrlKey) {
            e.preventDefault();
            this.navigateNext();
          }
          break;
        case 'Enter':
          if (e.metaKey || e.ctrlKey) {
            e.preventDefault();
            this.acceptCurrent();
          }
          break;
        case 'Escape':
          e.preventDefault();
          this.keepOriginal();
          break;
        case 'a':
          if (e.altKey) {
            e.preventDefault();
            this.acceptAllCurrent();
          }
          break;
        case 'r':
          if (e.altKey) {
            e.preventDefault();
            this.keepAllOriginal();
          }
          break;
      }
    });
  }

  async loadSnapshots() {
    try {
      const response = await fetch('/api/snapshots');
      const data = await response.json();
      
      this.snapshots = data.snapshots;
      this.updateSnapshotList();
      this.updateSnapshotCount();

      // Auto-select first snapshot if available
      if (this.snapshots.length > 0) {
        this.selectSnapshot(0);
      }
    } catch (error) {
      this.showToast('Failed to load snapshots', 'error');
      console.error('Failed to load snapshots:', error);
    }
  }

  updateSnapshotList() {
    const listElement = document.getElementById('snapshot-list');
    listElement.innerHTML = '';

    if (this.snapshots.length === 0) {
      listElement.innerHTML = '<div class="empty-state">No failed snapshots found! 🎉</div>';
      document.getElementById('snapshot-viewer').style.display = 'none';
      document.getElementById('empty-state').style.display = 'flex';
      return;
    }

    this.snapshots.forEach((snapshot, index) => {
      const item = document.createElement('div');
      item.className = 'snapshot-item';
      item.dataset.index = index;
      
      item.innerHTML = `
        <div class="snapshot-item-name">${snapshot.name}</div>
        ${snapshot.path ? `<div class="snapshot-item-path">${snapshot.path}</div>` : ''}
      `;

      item.addEventListener('click', () => this.selectSnapshot(index));
      listElement.appendChild(item);
    });
  }

  updateSnapshotCount() {
    const count = this.snapshots.length;
    const text = count === 0 ? 'No failed snapshots' : 
                 count === 1 ? '1 failed snapshot' : 
                 `${count} failed snapshots`;
    document.getElementById('snapshot-count').textContent = text;
  }

  selectSnapshot(index) {
    if (index < 0 || index >= this.snapshots.length) return;

    this.currentIndex = index;
    this.currentSnapshot = this.snapshots[index];

    // Update list selection
    document.querySelectorAll('.snapshot-item').forEach((item, i) => {
      item.classList.toggle('active', i === index);
    });

    // Show viewer
    document.getElementById('empty-state').style.display = 'none';
    document.getElementById('snapshot-viewer').style.display = 'flex';

    // Update viewer content
    this.updateViewer();
  }

  updateViewer() {
    const snapshot = this.currentSnapshot;
    
    // Update header
    document.getElementById('current-snapshot-name').textContent = snapshot.name;
    document.getElementById('snapshot-index').textContent = 
      `${this.currentIndex + 1} / ${this.snapshots.length}`;

    // Update navigation buttons
    document.getElementById('prev-btn').disabled = this.currentIndex === 0;
    document.getElementById('next-btn').disabled = this.currentIndex === this.snapshots.length - 1;

    // Update images
    const baseUrl = window.location.origin;
    document.getElementById('original-image').src = `${baseUrl}/${snapshot.original}`;
    document.getElementById('current-image').src = `${baseUrl}/${snapshot.current}`;
    document.getElementById('diff-image').src = `${baseUrl}/${snapshot.diff}`;
  }

  navigatePrevious() {
    if (this.currentIndex > 0) {
      this.selectSnapshot(this.currentIndex - 1);
    }
  }

  navigateNext() {
    if (this.currentIndex < this.snapshots.length - 1) {
      this.selectSnapshot(this.currentIndex + 1);
    }
  }

  async acceptCurrent() {
    if (!this.currentSnapshot) return;

    try {
      const response = await fetch('/api/snapshots/update', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          name: this.currentSnapshot.name,
          useCurrentVersion: true
        })
      });

      const data = await response.json();
      
      if (data.success) {
        this.showToast('Snapshot updated (current version accepted)', 'success');
        this.removeCurrentSnapshot();
      } else {
        this.showToast('Failed to update snapshot', 'error');
      }
    } catch (error) {
      this.showToast('Failed to update snapshot', 'error');
      console.error('Failed to update snapshot:', error);
    }
  }

  async keepOriginal() {
    if (!this.currentSnapshot) return;

    try {
      const response = await fetch('/api/snapshots/update', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          name: this.currentSnapshot.name,
          useCurrentVersion: false
        })
      });

      const data = await response.json();
      
      if (data.success) {
        this.showToast('Snapshot updated (original version kept)', 'success');
        this.removeCurrentSnapshot();
      } else {
        this.showToast('Failed to update snapshot', 'error');
      }
    } catch (error) {
      this.showToast('Failed to update snapshot', 'error');
      console.error('Failed to update snapshot:', error);
    }
  }

  removeCurrentSnapshot() {
    // Remove from array
    this.snapshots.splice(this.currentIndex, 1);
    
    // Update UI
    this.updateSnapshotList();
    this.updateSnapshotCount();

    // Select next snapshot
    if (this.snapshots.length > 0) {
      const newIndex = Math.min(this.currentIndex, this.snapshots.length - 1);
      this.selectSnapshot(newIndex);
    } else {
      // No more snapshots
      document.getElementById('snapshot-viewer').style.display = 'none';
      document.getElementById('empty-state').style.display = 'flex';
      document.getElementById('empty-state').innerHTML = 
        '<p>🎉 All snapshots have been reviewed!</p>';
    }
  }

  async acceptAllCurrent() {
    if (this.snapshots.length === 0) return;

    const confirmed = confirm(`Accept all ${this.snapshots.length} current snapshot(s)?`);
    if (!confirmed) return;

    try {
      const response = await fetch('/api/snapshots/update-all', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ useCurrentVersion: true })
      });

      const data = await response.json();
      
      if (data.success > 0) {
        this.showToast(`Updated ${data.success} snapshot(s) with current versions`, 'success');
        this.loadSnapshots();
      } else {
        this.showToast('Failed to update snapshots', 'error');
      }
    } catch (error) {
      this.showToast('Failed to update snapshots', 'error');
      console.error('Failed to update snapshots:', error);
    }
  }

  async keepAllOriginal() {
    if (this.snapshots.length === 0) return;

    const confirmed = confirm(`Keep all ${this.snapshots.length} original snapshot(s)?`);
    if (!confirmed) return;

    try {
      const response = await fetch('/api/snapshots/update-all', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ useCurrentVersion: false })
      });

      const data = await response.json();
      
      if (data.success > 0) {
        this.showToast(`Kept ${data.success} original snapshot(s)`, 'success');
        this.loadSnapshots();
      } else {
        this.showToast('Failed to update snapshots', 'error');
      }
    } catch (error) {
      this.showToast('Failed to update snapshots', 'error');
      console.error('Failed to update snapshots:', error);
    }
  }

  async rescanSnapshots() {
    try {
      const response = await fetch('/api/snapshots/rescan', {
        method: 'POST'
      });

      const data = await response.json();
      this.snapshots = data.snapshots;
      this.updateSnapshotList();
      this.updateSnapshotCount();
      
      this.showToast(`Found ${data.total} failed snapshot(s)`, 'success');
      
      if (this.snapshots.length > 0) {
        this.selectSnapshot(0);
      }
    } catch (error) {
      this.showToast('Failed to rescan snapshots', 'error');
      console.error('Failed to rescan:', error);
    }
  }

  showToast(message, type = 'info') {
    const toast = document.getElementById('toast');
    toast.textContent = message;
    toast.className = `toast ${type}`;
    
    // Show toast
    setTimeout(() => toast.classList.add('show'), 10);
    
    // Hide after 3 seconds
    setTimeout(() => {
      toast.classList.remove('show');
    }, 3000);
  }
}

// Initialize app when DOM is ready
document.addEventListener('DOMContentLoaded', () => {
  new SnapshotViewer();
});