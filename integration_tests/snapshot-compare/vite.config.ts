import { defineConfig } from 'vite';
import react from '@vitejs/plugin-react';
import path from 'path';

export default defineConfig({
  plugins: [react()],
  root: './web',
  build: {
    outDir: '../dist',
    emptyOutDir: true,
  },
  server: {
    proxy: {
      '/api': 'http://localhost:3000',
      '/snapshots': 'http://localhost:3000',
      '/temp': 'http://localhost:3000',
      '/fonts': 'http://localhost:3000',
      '/assets': 'http://localhost:3000',
      '/specs': 'http://localhost:3000',
    }
  }
});