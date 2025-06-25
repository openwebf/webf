import resolve from '@rollup/plugin-node-resolve';
import commonjs from '@rollup/plugin-commonjs';
import typescript from '@rollup/plugin-typescript';
import dts from 'rollup-plugin-dts';
import path from 'path';

const external = ['react', 'react-dom'];

export default [
  {
    input: 'src/index.ts',
    output: [
      {
        file: 'dist/index.js',
        format: 'cjs',
        sourcemap: true,
        globals: {
          react: 'React',
          'react-dom': 'ReactDOM'
        }
      },
      {
        file: 'dist/index.esm.js',
        format: 'esm',
        sourcemap: true,
        globals: {
          react: 'React',
          'react-dom': 'ReactDOM'
        }
      },
    ],
    external: (id) => {
      // Mark react and react-dom as external
      if (external.includes(id)) return true;
      // Also mark any react submodules as external
      if (id.startsWith('react/') || id.startsWith('react-dom/')) return true;
      return false;
    },
    plugins: [
      resolve({
        // Don't bundle react/react-dom
        resolveOnly: (module) => !external.includes(module)
      }),
      commonjs(),
      typescript({ tsconfig: './tsconfig.json' }),
    ],
  },
  {
    input: 'dist/index.d.ts',
    output: [{ file: 'dist/index.d.ts', format: 'es' }],
    plugins: [dts()],
  },
];