---
description: MCP-first cross-validated code intelligence across dependency graphs
argument-hint: [query] [optional:scope] [optional:mode] [optional:server=<name>] [optional:prompt=<name>]
allowed-tools: Bash(rg:*), Bash(git grep:*), Bash(git ls-files:*), Bash(git rev-parse:*)
---

# MCP-first code search and analysis (cross-validated)

Use this command to answer code/navigation/impact questions by prioritizing MCP server tools over default editor tooling, then cross-validating with text/LSP search to increase precision and recall.

Inputs
- Query: `$ARGUMENTS`
- Optional scope hint (directory/module/package)
- Optional mode: `search | navigate | impact | arch`
- Optional server: `server=<name>` (normalized MCP server name from `/mcp`)
- Optional prompt: `prompt=<name>` (specific MCP tool/prompt to prefer)

Execution protocol
1) Discover and prioritize MCP tools
   - If `server=<name>` is provided, restrict MCP calls to that server; otherwise, iterate through all connected servers exposing dependency graph tools and prefer those indexing libraries/packages referenced by this workspace.
   - Prefer these tools (by intent):
     - Search/navigation: `search_graph`, `get_node_by_name`, `find_references`, `find_definition`, `get_dependencies`, `get_dependents`, `get_call_chain`
     - Impact/quality: `analyze_impact`, `analyze_code_smells`, `analyze_circular_dependencies`, `analyze_architectural_layers`, `get_module_metrics`, `analyze_external_dependencies`
     - Similarity/patterns: `find_similar_nodes`, `find_similar_implementations`, `search_by_pattern`
   - Use narrow scope if provided; otherwise start broad, then refine by directories/languages as indicated by early results.
   - If `prompt=<name>` is provided, prefer calling that MCP tool/prompt first when applicable.

2) Cross-validate with default/editor tools
   - Use IDE symbol search/LSP capabilities to corroborate MCP findings (definitions, references, symbols).
   - Run a conservative ripgrep for the query and any top MCP-derived identifiers to catch non-indexed text:
     - !`rg -n --hidden --no-ignore -S "$ARGUMENTS" | head -200`
   - If the query looks like a symbol/path, also search likely variants (case, suffix/prefix, interface/impl patterns) inferred from MCP results.

3) Merge, rank, and reconcile
   - Deduplicate by canonical node/file identity; prefer MCP graph semantics over plain-text hits.
   - Rank by:
     - Direct MCP matches (exact node/file) > MCP structural proximity (deps/dependents/call chains) > editor/LSP > raw text hits.
   - Flag disagreements (present in text-only, absent in MCP) as potential extraction gaps or dead code.

4) Produce decision-ready output
   - Summary: 1–3 bullets with the most relevant findings and next action.
   - Evidence (MCP): key nodes, relationships, call chains, impact sets, and metrics.
   - Evidence (default): LSP/grep confirmations and any unique findings not in MCP.
   - Cross-validation: overlaps, conflicts, and confidence score.
   - If mode=impact, include affected files/modules and suggested test focus; if mode=arch, include layer/cycle findings.

Heuristics
- Prefer MCP graph relationships over text proximity when signals conflict.
- When MCP tools return no results, expand scope and switch to text-first, then attempt to map text hits back to MCP nodes.
- For library/package queries not in the local workspace, query MCP servers that index those artifacts first; only then fall back to local search.

Response format (concise)
- Summary
- Findings (ranked list with brief rationale)
- Cross-validation (MCP vs default)
- Next steps

Notes
- This command assumes MCP prompts/tools are available via connected servers and will be invoked before editor defaults.
- Keep output focused; surface only the top-most actionable results, link deeper evidence on demand.

Examples
- `/Q "retry policy backoff" scope=shared/utils mode=search server=depgraph-mcp`
- `/Q "transitive deps of FooService" mode=navigate server=depgraph-mcp prompt=get_dependencies`
- To discover server names and prompts exposed by MCP servers, use `/mcp` and look for commands like `/mcp__<server-name>__<prompt-name>`.

