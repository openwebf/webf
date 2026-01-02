import fs from 'fs';
import path from 'path';

describe('Templates', () => {
  it('react tsconfig template pins React type resolution to root @types', () => {
    const templatePath = path.resolve(__dirname, '../templates/react.tsconfig.json.tpl');
    const template = fs.readFileSync(templatePath, 'utf8');

    expect(template).toContain('"baseUrl": "."');
    expect(template).toContain('"paths"');
    expect(template).toContain('"react": ["./node_modules/@types/react/index.d.ts"]');
    expect(template).toContain('"react-dom": ["./node_modules/@types/react-dom/index.d.ts"]');
    expect(template).toContain('"react/jsx-runtime": ["./node_modules/@types/react/jsx-runtime.d.ts"]');
    expect(template).toContain('"react/jsx-dev-runtime": ["./node_modules/@types/react/jsx-dev-runtime.d.ts"]');
  });
});

