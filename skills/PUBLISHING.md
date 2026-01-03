# Publishing Guide

This guide explains how to publish `@openwebf/claude-code-skills` to npm.

## Prerequisites

1. You need an npm account with access to the `@openwebf` organization
2. You need to be logged in: `npm login`

## Pre-publish Checklist

Before publishing, ensure:

- [ ] All skill files are up to date
- [ ] Version number is incremented in `package.json`
- [ ] README.md is current
- [ ] LICENSE file is present
- [ ] All tests pass (if any)
- [ ] Documentation URLs are correct

## Publishing Steps

### 1. Navigate to skills directory

```bash
cd /Users/andycall/workspace/webf/skills
```

### 2. Test the package locally

```bash
# See what files will be included
npm pack --dry-run

# Create a tarball to inspect
npm pack
```

### 3. Publish to npm

For first-time publish:

```bash
npm publish --access public
```

For subsequent updates:

```bash
# Update version first
npm version patch  # or minor, or major

# Then publish
npm publish
```

## Version Management

Follow semantic versioning:

- **Patch** (`1.0.x`): Bug fixes, typo corrections, minor updates
- **Minor** (`1.x.0`): New skills added, non-breaking changes
- **Major** (`x.0.0`): Breaking changes to skill structure

Examples:

```bash
npm version patch  # 1.0.0 -> 1.0.1
npm version minor  # 1.0.1 -> 1.1.0
npm version major  # 1.1.0 -> 2.0.0
```

## Verifying Publication

After publishing:

1. Check on npm: https://www.npmjs.com/package/@openwebf/claude-code-skills
2. Test installation:
   ```bash
   npm install -g @openwebf/claude-code-skills
   ```

## Unpublishing (Emergency Only)

Only unpublish if there's a critical issue within 72 hours:

```bash
npm unpublish @openwebf/claude-code-skills@<version>
```

**Note**: After 72 hours, you cannot unpublish. Only deprecate:

```bash
npm deprecate @openwebf/claude-code-skills@<version> "Reason for deprecation"
```

## CI/CD (Future)

Consider setting up automated publishing via GitHub Actions:

```yaml
# .github/workflows/publish.yml
name: Publish to npm
on:
  release:
    types: [created]
jobs:
  publish:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: actions/setup-node@v3
        with:
          node-version: '18'
          registry-url: 'https://registry.npmjs.org'
      - run: npm publish --access public
        env:
          NODE_AUTH_TOKEN: ${{ secrets.NPM_TOKEN }}
```

## Troubleshooting

### "You do not have permission to publish"

- Ensure you're logged in: `npm whoami`
- Check organization access: Contact @openwebf admin

### "Cannot publish over existing version"

- Increment version: `npm version patch`
- Or publish with new version: `npm publish --tag next`

### "Package name too similar to existing package"

- Verify the exact package name: `@openwebf/claude-code-skills`
- Ensure you're using the scoped name with `@openwebf/`

## Support

For issues related to publishing:
- npm support: https://www.npmjs.com/support
- WebF team: https://github.com/openwebf/webf/issues