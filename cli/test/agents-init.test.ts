import fs from 'fs';
import os from 'os';
import path from 'path';
import { agentsInitCommand } from '../src/agents';

function readText(filePath: string) {
  return fs.readFileSync(filePath, 'utf-8');
}

describe('webf agents init', () => {
  let tempDir: string;
  let consoleSpy: jest.SpyInstance;

  beforeEach(() => {
    tempDir = fs.mkdtempSync(path.join(os.tmpdir(), 'webf-agents-init-'));
    consoleSpy = jest.spyOn(console, 'log').mockImplementation(() => {});
  });

  afterEach(() => {
    consoleSpy.mockRestore();
    fs.rmSync(tempDir, { recursive: true, force: true });
  });

  it('initializes a new project with skills and CLAUDE.md', async () => {
    await agentsInitCommand(tempDir);

    expect(fs.existsSync(path.join(tempDir, 'CLAUDE.md'))).toBe(true);
    expect(fs.existsSync(path.join(tempDir, '.claude', 'skills', 'webf-quickstart', 'SKILL.md'))).toBe(true);

    const claude = readText(path.join(tempDir, 'CLAUDE.md'));
    expect(claude).toContain('<!-- webf-agents:init start -->');
    expect(claude).toContain('Source: `@openwebf/claude-code-skills@');
    expect(claude).toContain('### Skills');

    const version = readText(path.join(tempDir, '.claude', 'webf-claude-code-skills.version'));
    expect(version).toMatch(/^@openwebf\/claude-code-skills@/);
  });

  it('updates an existing CLAUDE.md without removing existing content', async () => {
    fs.writeFileSync(path.join(tempDir, 'CLAUDE.md'), '# Existing\n\nHello\n', 'utf-8');

    await agentsInitCommand(tempDir);

    const claude = readText(path.join(tempDir, 'CLAUDE.md'));
    expect(claude).toContain('# Existing');
    expect(claude).toContain('Hello');
    expect(claude).toContain('<!-- webf-agents:init start -->');
  });

  it('is idempotent (does not duplicate the injected block)', async () => {
    await agentsInitCommand(tempDir);
    await agentsInitCommand(tempDir);

    const claude = readText(path.join(tempDir, 'CLAUDE.md'));
    const occurrences = claude.split('<!-- webf-agents:init start -->').length - 1;
    expect(occurrences).toBe(1);
  });

  it('backs up modified skill files before overwriting', async () => {
    const skillDir = path.join(tempDir, '.claude', 'skills', 'webf-quickstart');
    fs.mkdirSync(skillDir, { recursive: true });
    fs.writeFileSync(path.join(skillDir, 'SKILL.md'), 'local edits', 'utf-8');

    await agentsInitCommand(tempDir);

    const files = fs.readdirSync(skillDir);
    expect(files.some(f => f.startsWith('SKILL.md.bak.'))).toBe(true);

    const sourceSkill = fs.readFileSync(
      path.join(
        path.dirname(require.resolve('@openwebf/claude-code-skills/package.json')),
        'webf-quickstart',
        'SKILL.md'
      ),
      'utf-8'
    );
    const installedSkill = readText(path.join(skillDir, 'SKILL.md'));
    expect(installedSkill).toBe(sourceSkill);
  });
});
