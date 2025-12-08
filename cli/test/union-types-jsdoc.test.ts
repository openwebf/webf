import { analyzer, clearCaches, UnionTypeCollector, ParameterType } from '../src/analyzer';
import { generateReactComponent } from '../src/react';
import { IDLBlob } from '../src/IDLBlob';
import { ClassObject } from '../src/declaration';

describe('Union Types and JSDoc Preservation', () => {
  beforeEach(() => {
    clearCaches();
  });

  test('should generate union types with quoted string literals and preserve JSDoc @default tags', () => {
    // Create test TypeScript content with union types and JSDoc
    const testContent = `
/**
 * Table cell component
 */
interface WebFTableCellProperties {
  /**
   * Text alignment
   * @default "left"
   */
  align?: 'left' | 'center' | 'right';
  
  /**
   * Cell type (header or data)
   * @default "data"
   */
  type?: 'header' | 'data';
  
  /**
   * Column span
   * @default 1
   */
  colspan?: number;
}

interface WebFTableCellEvents {
  /**
   * Cell click event
   */
  click: CustomEvent<{row: number, column: number, value: any}>;
}
`;

    // Create IDL blob
    const blob = new IDLBlob('test.d.ts', 'dist', 'table_cell', 'implement');
    blob.raw = testContent;
    
    // Analyze the content
    const definedPropertyCollector = {
      properties: new Set<string>(),
      files: new Set<string>(),
      interfaces: new Set<string>()
    };
    const unionTypeCollector: UnionTypeCollector = { types: new Set<ParameterType[]>() };
    
    analyzer(blob, definedPropertyCollector, unionTypeCollector);
    
    // Generate React component
    const reactCode = generateReactComponent(blob);
    
    // Test 1: Check that union types are properly quoted
    expect(reactCode).toContain("align?: 'left' | 'center' | 'right';");
    expect(reactCode).toContain("type?: 'header' | 'data';");
    
    // Test 2: Check that JSDoc is preserved with @default tags
    expect(reactCode).toMatch(/\*\s+Text alignment[\s\S]*?\*\s+@default "left"/);
    expect(reactCode).toMatch(/\*\s+Cell type \(header or data\)[\s\S]*?\*\s+@default "data"/);
    
    // Test 3: Check that the generated interface has the correct structure
    expect(reactCode).toContain('export interface WebFTableCellProps {');
    expect(reactCode).toContain('colspan?: number;');
    
    // Test 4: Verify the component is created with correct props
    expect(reactCode).toContain("attributeProps: [");
    expect(reactCode).toContain("'align',");
    expect(reactCode).toContain("'type',");
    expect(reactCode).toContain("'colspan',");
  });

  test('should handle complex union types', () => {
    const testContent = `
interface TestProperties {
  /**
   * Size property
   * @default "medium"
   */
  size?: 'small' | 'medium' | 'large' | 'xl';
  
  /**
   * Status
   * @default "pending"
   */
  status?: 'pending' | 'active' | 'completed' | 'failed';
}
`;

    const blob = new IDLBlob('test.d.ts', 'dist', 'test', 'implement');
    blob.raw = testContent;
    
    const definedPropertyCollector = {
      properties: new Set<string>(),
      files: new Set<string>(),
      interfaces: new Set<string>()
    };
    const unionTypeCollector: UnionTypeCollector = { types: new Set<ParameterType[]>() };
    
    analyzer(blob, definedPropertyCollector, unionTypeCollector);
    const reactCode = generateReactComponent(blob);
    
    // Check complex union types
    expect(reactCode).toContain("size?: 'small' | 'medium' | 'large' | 'xl';");
    expect(reactCode).toContain("status?: 'pending' | 'active' | 'completed' | 'failed';");
  });

  test('should handle mixed type properties alongside union types', () => {
    const testContent = `
interface MixedProperties {
  /**
   * String union type
   * @default "auto"
   */
  mode?: 'auto' | 'manual' | 'disabled';
  
  /**
   * Regular string
   */
  name?: string;
  
  /**
   * Number property
   * @default 42
   */
  count?: number;
  
  /**
   * Boolean property
   * @default true
   */
  enabled?: boolean;
}
`;

    const blob = new IDLBlob('test.d.ts', 'dist', 'mixed', 'implement');
    blob.raw = testContent;
    
    const definedPropertyCollector = {
      properties: new Set<string>(),
      files: new Set<string>(),
      interfaces: new Set<string>()
    };
    const unionTypeCollector: UnionTypeCollector = { types: new Set<ParameterType[]>() };
    
    analyzer(blob, definedPropertyCollector, unionTypeCollector);
    const reactCode = generateReactComponent(blob);
    
    // Check that different types are handled correctly
    expect(reactCode).toContain("mode?: 'auto' | 'manual' | 'disabled';");
    expect(reactCode).toContain("name?: string;");
    expect(reactCode).toContain("count?: number;");
    expect(reactCode).toContain("enabled?: boolean;");
    
    // Check JSDoc preservation
    expect(reactCode).toMatch(/\*\s+String union type[\s\S]*?\*\s+@default "auto"/);
    expect(reactCode).toMatch(/\*\s+Number property[\s\S]*?\*\s+@default 42/);
    expect(reactCode).toMatch(/\*\s+Boolean property[\s\S]*?\*\s+@default true/);
  });
});