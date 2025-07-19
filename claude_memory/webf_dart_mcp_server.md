# WebF Dart MCP Server Guide

## Overview
The webf_dart MCP server provides a comprehensive dependency graph analysis system for the WebF codebase. It maintains a graph of code entities (nodes) and their relationships (edges) across multiple programming languages.

## Core Statistics (as of current snapshot)
- **Total Nodes**: 8,244 (representing classes, methods, functions, files, etc.)
- **Total Edges**: 14,570 (representing relationships between entities)
- **Languages Supported**: Dart, C++, JavaScript, TypeScript, Swift, Java, Kotlin
- **Extraction Quality Score**: 75%

## Key MCP Tools Categories

### 1. Search and Navigation
- `mcp__webf_dart__get_node_by_name`: Find nodes by name pattern
- `mcp__webf_dart__get_nodes_by_directory`: Get all nodes in a directory
- `mcp__webf_dart__search_graph`: Advanced search with filters
- `mcp__webf_dart__search_by_pattern`: Structural pattern search (e.g., `class:*Controller`)
- `mcp__webf_dart__find_similar_nodes`: Find nodes similar to a given node

### 2. Dependency Analysis
- `mcp__webf_dart__get_dependencies`: Get what a node depends on
- `mcp__webf_dart__get_dependents`: Get what depends on a node
- `mcp__webf_dart__analyze_impact`: Analyze impact of changes to a file
- `mcp__webf_dart__get_call_chain`: Find function call paths between nodes
- `mcp__webf_dart__analyze_circular_dependencies`: Detect circular dependencies

### 3. Cross-Language Support
- `mcp__webf_dart__get_ffi_bindings`: Get FFI bindings between languages
- `mcp__webf_dart__trace_ffi_call_chain`: Trace calls across language boundaries
- `mcp__webf_dart__analyze_cross_language_dependencies`: Analyze dependencies between languages
- `mcp__webf_dart__analyze_ffi_interfaces`: Analyze FFI struct and function mappings

### 4. Code Quality Analysis
- `mcp__webf_dart__analyze_code_smells`: Detect god classes, feature envy, etc.
- `mcp__webf_dart__suggest_refactoring_candidates`: Identify refactoring opportunities
- `mcp__webf_dart__find_unused_code`: Find dead code
- `mcp__webf_dart__analyze_naming_consistency`: Check naming conventions
- `mcp__webf_dart__analyze_test_coverage`: Map test coverage

### 5. Architecture Analysis
- `mcp__webf_dart__analyze_architectural_layers`: Validate layer boundaries
- `mcp__webf_dart__analyze_coupling_metrics`: Calculate coupling between modules
- `mcp__webf_dart__suggest_module_boundaries`: Recommend better organization
- `mcp__webf_dart__get_module_metrics`: Get comprehensive module metrics

### 6. Performance Analysis
- `mcp__webf_dart__analyze_hot_paths`: Find frequently called code
- `mcp__webf_dart__find_n_plus_one_patterns`: Detect N+1 query patterns
- `mcp__webf_dart__analyze_memory_patterns`: Find potential memory issues

### 7. Type and Inheritance Analysis
- `mcp__webf_dart__get_overrides`: Find method override chains
- `mcp__webf_dart__analyze_inheritance_hierarchy`: Analyze class hierarchies
- `mcp__webf_dart__get_type_relationships`: Find TYPE_OF relationships
- `mcp__webf_dart__search_mixins`: Search for Dart mixins
- `mcp__webf_dart__search_structs`: Search for struct definitions

### 8. Project Insights
- `mcp__webf_dart__get_metrics`: Get overall project metrics
- `mcp__webf_dart__get_extraction_metrics`: Get extraction statistics
- `mcp__webf_dart__validate_extraction`: Validate graph quality
- `mcp__webf_dart__analyze_framework_usage`: Analyze framework usage patterns

## Usage Patterns

### Finding Code
```
# Find a specific class or function
mcp__webf_dart__get_node_by_name(name="WebFController")

# Search with patterns
mcp__webf_dart__search_by_pattern(structural_pattern="class:*Controller")

# Explore a directory
mcp__webf_dart__get_nodes_by_directory(directory="/webf/lib/src/css")
```

### Analyzing Dependencies
```
# Get dependencies of a node
mcp__webf_dart__get_dependencies(node_name="RenderStyle", max_depth=2)

# Analyze impact of changes
mcp__webf_dart__analyze_impact(file_path="/webf/lib/src/css/render_style.dart")

# Find circular dependencies
mcp__webf_dart__analyze_circular_dependencies(granularity="class")
```

### Code Quality
```
# Find code smells
mcp__webf_dart__analyze_code_smells(god_class_threshold=20)

# Suggest refactoring
mcp__webf_dart__suggest_refactoring_candidates(complexity_threshold=10)

# Check naming consistency
mcp__webf_dart__analyze_naming_consistency()
```

## Key Insights

### Most Complex Files
1. `/webf/lib/src/css/render_style.dart` - 206 nodes
2. `/webf/lib/src/rendering/box_model.dart` - 166 nodes
3. `/webf/lib/src/bridge/to_native.dart` - 165 nodes
4. `/webf/lib/src/html/html.dart` - 137 nodes
5. `/webf/lib/src/css/style_declaration.dart` - 124 nodes

### Language Distribution
- **Dart**: 6,681 nodes (81.1%) with highest edge density (18.65 edges/node)
- **JavaScript**: 1,018 nodes (12.3%)
- **C++**: 464 nodes (5.6%)
- **TypeScript**: 81 nodes (1.0%)

### Common Methods
Most frequently called: `add`, `toString`, `assert`, `remove`, `clear`, `contains`, `call`, `hasProperty`

## Important Notes

1. **FFI Analysis**: The system supports FFI analysis but currently shows no active FFI bindings. This might indicate:
   - FFI relationships need explicit extraction
   - The codebase uses a different Dart-C++ communication mechanism
   - The graph needs regeneration with FFI support enabled

2. **Circular Dependencies**: 577 circular dependencies detected, which may need attention

3. **Node Types**: The system tracks various node types including:
   - Classes, Methods, Functions
   - Files, Modules, Packages
   - Virtual nodes (framework components)
   - Structs, Mixins, Interfaces

4. **Extraction Quality**: 75% quality score indicates room for improvement in graph extraction

## Best Practices

1. **Start with search**: Use search tools to find relevant nodes before analysis
2. **Use appropriate depth**: Limit traversal depth to avoid overwhelming results
3. **Check extraction quality**: Validate that the graph accurately represents your code
4. **Combine tools**: Use multiple analysis tools together for comprehensive insights
5. **Monitor metrics**: Regular metric checks help maintain code quality

## Common Use Cases

1. **Understanding a feature**: Find the main class, analyze its dependencies
2. **Refactoring planning**: Identify impact, find circular dependencies, suggest boundaries
3. **Code review**: Check naming consistency, find code smells, analyze complexity
4. **Performance optimization**: Find hot paths, analyze memory patterns
5. **Documentation**: Generate outlines, find incomplete implementations