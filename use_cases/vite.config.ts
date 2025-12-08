import { defineConfig } from 'vite';
import react from '@vitejs/plugin-react-swc';

// https://vitejs.dev/config/
export default defineConfig(({ mode }) => ({
  plugins: [react()],
  publicDir: 'public',
  build: {
    // Keep CRA-compatible output folder name
    outDir: 'build',
    emptyOutDir: true,
  },
  define: {
    // Provide NODE_ENV for libs expecting it
    'process.env.NODE_ENV': JSON.stringify(
      mode === 'production' ? 'production' : 'development'
    ),
  },
}));

