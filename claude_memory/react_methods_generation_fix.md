# React Methods Generation Fix

## Problem
The WebF CLI was not generating methods from TypeScript `Methods` interfaces (e.g., `WebFListViewMethods`) in React components. The methods were being parsed correctly by the analyzer but not included in the generated React components.

## Root Cause
In `cli/src/react.ts`, the Methods interfaces were being filtered out from the "others" list but were not included in the dependencies generation. The dependencies only included "others" and type aliases, but not the Methods interfaces themselves.

## Solution
Updated `cli/src/react.ts` to include Methods interfaces in the dependencies generation:

```typescript
const dependencies = [
  typeAliasDeclarations,
  // Include Methods interfaces as dependencies
  methods.map(object => {
    const methodDeclarations = object.methods.map(method => {
      return `  ${generateMethodDeclaration(method)}`;
    }).join('\n');

    return `interface ${object.name} {
${methodDeclarations}
}`;
  }).join('\n\n'),
  others.map(object => {
    // ... existing code for other interfaces
  }).join('\n\n')
].filter(Boolean).join('\n\n');
```

Also updated the template calls to pass the methods object:
- Added `methods: component.methods` to the template parameters in both single and multiple component generation

## Template Updates
The React component template (`cli/templates/react.component.tsx.tpl`) was updated to use `methods?.methods` instead of `properties?.methods`:

```typescript
export interface <%= className %>Element extends WebFElementWithMethods<{
  <% _.forEach(methods?.methods, function(method, index) { %>
  <%= generateMethodDeclaration(method) %>
  <% }); %>
}> {}
```

## Result
After these changes, the WebF CLI now correctly generates:
1. The Methods interface with all method declarations
2. The Element interface that extends WebFElementWithMethods with the proper method signatures

Example output for WebFListView:
```typescript
interface WebFListViewMethods {
  finishRefresh(result: string): void;
  finishLoad(result: string): void;
  resetHeader(): void;
  resetFooter(): void;
}

export interface WebFListViewElement extends WebFElementWithMethods<{
  finishRefresh(result: string): void;
  finishLoad(result: string): void;
  resetHeader(): void;
  resetFooter(): void;
}> {}
```

## Testing
To test the fix:
1. Build the CLI: `npm run build`
2. Run code generation: `webf codegen <output-dir> --flutter-package-src=<path> --framework=react`
3. Check that Methods interfaces are properly generated in the React components

## Related Files
- `/cli/src/react.ts` - Main React generator that needed the fix
- `/cli/templates/react.component.tsx.tpl` - Template that uses the methods
- `/webf/lib/src/html/listview.d.ts` - Example TypeScript definition with Methods interface