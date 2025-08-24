const express = require('express');
const path = require('path');
const fs = require('fs');
const glob = require('glob');
const chalk = require('chalk');

class SnapshotViewerServer {
  constructor(snapshotDir, port) {
    this.snapshotDir = snapshotDir;
    this.port = port;
    this.app = express();
    this.failedImages = [];
    this.setupMiddleware();
    this.setupRoutes();
    this.scanFailedImages();
  }

  setupMiddleware() {
    this.app.use(express.json());
    this.app.use(express.static(this.snapshotDir));
    this.app.use('/viewer', express.static(path.join(__dirname, 'client')));
  }

  scanFailedImages() {
    const pattern = path.join(this.snapshotDir, '**/*.current.png');
    const files = glob.sync(pattern, { nodir: true });
    
    this.failedImages = files.map(file => {
      const relativePath = path.relative(this.snapshotDir, file);
      const baseName = relativePath.replace('.current.png', '');
      return {
        name: baseName,
        current: `${baseName}.current.png`,
        original: `${baseName}.png`,
        diff: `${baseName}.diff.png`,
        path: path.dirname(relativePath)
      };
    });

    console.log(chalk.cyan(`Found ${this.failedImages.length} failed snapshot(s)`));
  }

  updateSnapshot(name, useCurrentVersion) {
    const basePath = path.join(this.snapshotDir, name);
    const currentPath = `${basePath}.current.png`;
    const originalPath = `${basePath}.png`;
    const diffPath = `${basePath}.diff.png`;

    try {
      if (useCurrentVersion) {
        // Accept current version as new baseline
        if (fs.existsSync(currentPath)) {
          fs.copyFileSync(currentPath, originalPath);
          console.log(chalk.green(`✓ Updated snapshot: ${name}.png (using current version)`));
        }
      } else {
        // Keep original version
        console.log(chalk.yellow(`✓ Kept original snapshot: ${name}.png`));
      }

      // Clean up temporary files
      if (fs.existsSync(currentPath)) fs.unlinkSync(currentPath);
      if (fs.existsSync(diffPath)) fs.unlinkSync(diffPath);

      // Remove from failed list
      this.failedImages = this.failedImages.filter(img => img.name !== name);
      
      return { success: true };
    } catch (error) {
      console.error(chalk.red(`Failed to update snapshot: ${error.message}`));
      return { success: false, error: error.message };
    }
  }

  setupRoutes() {
    // Redirect root to viewer
    this.app.get('/', (req, res) => {
      res.redirect('/viewer');
    });

    // API: Get failed images list
    this.app.get('/api/snapshots', (req, res) => {
      this.scanFailedImages(); // Rescan on each request
      res.json({
        total: this.failedImages.length,
        snapshots: this.failedImages
      });
    });

    // API: Update snapshot
    this.app.post('/api/snapshots/update', (req, res) => {
      const { name, useCurrentVersion } = req.body;
      
      if (!name) {
        return res.status(400).json({ error: 'Snapshot name required' });
      }

      const result = this.updateSnapshot(name, useCurrentVersion);
      
      if (result.success) {
        res.json({ 
          success: true, 
          remaining: this.failedImages.length 
        });
      } else {
        res.status(500).json({ 
          success: false, 
          error: result.error 
        });
      }
    });

    // API: Update all snapshots
    this.app.post('/api/snapshots/update-all', (req, res) => {
      const { useCurrentVersion } = req.body;
      const results = [];
      const toUpdate = [...this.failedImages];

      for (const img of toUpdate) {
        const result = this.updateSnapshot(img.name, useCurrentVersion);
        results.push({ name: img.name, ...result });
      }

      const successCount = results.filter(r => r.success).length;
      const failCount = results.filter(r => !r.success).length;

      res.json({
        total: results.length,
        success: successCount,
        failed: failCount,
        results
      });
    });

    // API: Rescan snapshots
    this.app.post('/api/snapshots/rescan', (req, res) => {
      this.scanFailedImages();
      res.json({
        total: this.failedImages.length,
        snapshots: this.failedImages
      });
    });
  }

  start() {
    this.app.listen(this.port, () => {
      console.log(chalk.green(`\n🖼️  WebF Snapshot Viewer`));
      console.log(chalk.cyan(`   Server running at: http://localhost:${this.port}/viewer`));
      console.log(chalk.cyan(`   Snapshot directory: ${this.snapshotDir}`));
      console.log(chalk.gray(`   Press Ctrl+C to stop\n`));
    });
  }
}

module.exports = { SnapshotViewerServer };