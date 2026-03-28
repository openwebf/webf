# Shadcn Component Migration Plan

## Goal

Replace the old `use_cases` shadcn showcase with a docs-aligned React + Tailwind implementation modeled after [shadcn/ui Components](https://ui.shadcn.com/docs/components), while keeping the older `@openwebf/react-shadcn-ui` routes available only as deprecated references.

## Current Status

### Done in this branch

1. Replaced the primary `/shadcn-showcase` entry with a docs-style showcase implemented in local `src/components/ui/*`.
2. Added a lightweight local component layer for the first migration set:
   - `button`
   - `card`
   - `input`
   - `field`
   - `badge`
   - `dialog`
   - `dropdown-menu`
   - `table`
3. Marked the existing `/shadcn/*` legacy pages as `Deprecated` in route titles and exposed them only as legacy links from the new showcase.

## Why this direction

1. It follows the current shadcn/ui composition model directly inside `use_cases`.
2. It avoids coupling the migration to `webf_shadcn_ui` parity work.
3. It lets us audit WebF CSS/runtime gaps using real docs-style examples first, then push only the necessary pieces into lower layers.

## Next Phases

### Phase 2: Expand the local shadcn set

Add the next batch of docs-aligned components in `src/components/ui/*`:

1. `select`
2. `tabs`
3. `accordion`
4. `popover`
5. `calendar`
6. `textarea`
7. `separator`
8. `skeleton`

### Phase 3: Route-by-route migration

For each existing legacy route:

1. Rebuild the page with local docs-style components.
2. Keep the old route path if the new page is compatible.
3. Move any incompatible legacy implementation behind a clearly named fallback page.

### Phase 4: WebF capability audit

Audit the shadcn-heavy CSS/runtime requirements against WebF:

1. Overlay stacking and focus management for dialogs, dropdowns, popovers.
2. Sticky headers/footers in long scroll containers.
3. Official docs layout patterns using Grid, responsive breakpoints, and viewport units.
4. Pointer/keyboard event consistency for menu-style components.
5. Any remaining animation or filter-related gaps.

## Validation Checklist

1. `/shadcn-showcase` is the only recommended shadcn entry.
2. Legacy routes render but are clearly labeled deprecated.
3. The new local `components/ui/*` work without adding new runtime dependencies.
4. The migrated showcase stays within WebF-supported CSS features.
