import fs from 'fs';
import os from 'os';
import path from 'path';
import yaml from 'yaml';

type SkillInfo = {
  directoryName: string;
  name: string;
  description?: string;
  skillFileRelativePath: string;
  referenceRelativePaths: string[];
};

type CopyStats = {
  filesWritten: number;
  filesUnchanged: number;
  backupsCreated: number;
};

const WEBF_AGENTS_BLOCK_START = '<!-- webf-agents:init start -->';
const WEBF_AGENTS_BLOCK_END = '<!-- webf-agents:init end -->';

function ensureDirSync(dirPath: string) {
  fs.mkdirSync(dirPath, { recursive: true });
}

function readFileIfExists(filePath: string): Buffer | null {
  try {
    return fs.readFileSync(filePath);
  } catch (error: any) {
    if (error?.code === 'ENOENT') return null;
    throw error;
  }
}

function backupFileSync(filePath: string) {
  const timestamp = new Date()
    .toISOString()
    .replace(/[:.]/g, '')
    .replace('T', '')
    .replace('Z', 'Z');
  const backupPath = `${filePath}.bak.${timestamp}`;
  fs.copyFileSync(filePath, backupPath);
  return backupPath;
}

function copyFileWithBackupSync(srcPath: string, destPath: string) {
  const src = fs.readFileSync(srcPath);
  const dest = readFileIfExists(destPath);

  if (dest && Buffer.compare(src, dest) === 0) return { changed: false, backupPath: null as string | null };

  ensureDirSync(path.dirname(destPath));
  let backupPath: string | null = null;
  if (dest) {
    backupPath = backupFileSync(destPath);
  }
  fs.writeFileSync(destPath, src);
  return { changed: true, backupPath };
}

function copyDirRecursiveSync(srcDir: string, destDir: string, stats: CopyStats) {
  ensureDirSync(destDir);
  const entries = fs.readdirSync(srcDir, { withFileTypes: true });
  for (const entry of entries) {
    const srcPath = path.join(srcDir, entry.name);
    const destPath = path.join(destDir, entry.name);
    if (entry.isDirectory()) {
      copyDirRecursiveSync(srcPath, destPath, stats);
      continue;
    }
    if (entry.isFile()) {
      const { changed, backupPath } = copyFileWithBackupSync(srcPath, destPath);
      if (changed) stats.filesWritten += 1;
      else stats.filesUnchanged += 1;
      if (backupPath) stats.backupsCreated += 1;
    }
  }
}

function listFilesRecursiveSync(dirPath: string): string[] {
  const out: string[] = [];
  const entries = fs.readdirSync(dirPath, { withFileTypes: true });
  for (const entry of entries) {
    const entryPath = path.join(dirPath, entry.name);
    if (entry.isDirectory()) {
      out.push(...listFilesRecursiveSync(entryPath));
      continue;
    }
    if (entry.isFile()) out.push(entryPath);
  }
  return out;
}

function toPosixRelativePath(fromDir: string, absolutePath: string) {
  const rel = path.relative(fromDir, absolutePath);
  return rel.split(path.sep).join('/');
}

function parseSkillFrontmatter(skillMd: string): { name?: string; description?: string } {
  const trimmed = skillMd.trimStart();
  if (!trimmed.startsWith('---')) return {};
  const endIndex = trimmed.indexOf('\n---', 3);
  if (endIndex === -1) return {};
  const fm = trimmed.slice(3, endIndex).trim();
  try {
    const parsed = yaml.parse(fm) ?? {};
    return { name: parsed?.name, description: parsed?.description };
  } catch {
    return {};
  }
}

function updateOrAppendMarkedBlock(existing: string, newBlock: string): { content: string; action: 'replaced' | 'appended' } {
  const startIndex = existing.indexOf(WEBF_AGENTS_BLOCK_START);
  const endIndex = existing.indexOf(WEBF_AGENTS_BLOCK_END);

  if (startIndex !== -1 && endIndex !== -1 && endIndex > startIndex) {
    const before = existing.slice(0, startIndex).trimEnd();
    const after = existing.slice(endIndex + WEBF_AGENTS_BLOCK_END.length).trimStart();
    const next = [before, newBlock.trim(), after].filter(Boolean).join('\n\n');
    return { content: next + '\n', action: 'replaced' };
  }

  const content = existing.trimEnd();
  return { content: (content ? content + '\n\n' : '') + newBlock.trim() + '\n', action: 'appended' };
}

function buildClaudeBlock(sourcePackageName: string, sourcePackageVersion: string, skills: SkillInfo[]) {
  const lines: string[] = [];
  lines.push(WEBF_AGENTS_BLOCK_START);
  lines.push('## WebF Claude Code Skills');
  lines.push('');
  lines.push(`Source: \`${sourcePackageName}@${sourcePackageVersion}\``);
  lines.push('');
  lines.push('### Skills');
  for (const skill of skills) {
    const desc = skill.description ? ` — ${skill.description}` : '';
    lines.push(`- \`${skill.name}\`${desc} (\`${skill.skillFileRelativePath}\`)`);
  }

  const anyReferences = skills.some(s => s.referenceRelativePaths.length > 0);
  if (anyReferences) {
    lines.push('');
    lines.push('### References');
    for (const skill of skills) {
      if (skill.referenceRelativePaths.length === 0) continue;
      const refs = skill.referenceRelativePaths.map(r => `\`${r}\``).join(', ');
      lines.push(`- \`${skill.name}\`: ${refs}`);
    }
  }

  lines.push(WEBF_AGENTS_BLOCK_END);
  return lines.join('\n');
}

function resolveSkillsPackageRoot() {
  const packageJsonPath = require.resolve('@openwebf/claude-code-skills/package.json');
  const packageRoot = path.dirname(packageJsonPath);
  const packageJson = JSON.parse(fs.readFileSync(packageJsonPath, 'utf-8'));
  return {
    packageRoot,
    packageName: packageJson?.name ?? '@openwebf/claude-code-skills',
    packageVersion: packageJson?.version ?? 'unknown',
  };
}

function listSkillDirectories(skillsPackageRoot: string) {
  const entries = fs.readdirSync(skillsPackageRoot, { withFileTypes: true });
  const dirs = entries
    .filter(e => e.isDirectory())
    .map(e => e.name)
    .filter(name => fs.existsSync(path.join(skillsPackageRoot, name, 'SKILL.md')))
    .sort();
  return dirs;
}

function collectSkillInfo(projectRoot: string, skillsDir: string, skillDirectoryName: string): SkillInfo {
  const skillDirAbs = path.join(skillsDir, skillDirectoryName);
  const skillMdAbs = path.join(skillDirAbs, 'SKILL.md');
  const skillMd = fs.readFileSync(skillMdAbs, 'utf-8');
  const fm = parseSkillFrontmatter(skillMd);

  const referenceRelativePaths: string[] = [];
  const files = listFilesRecursiveSync(skillDirAbs);
  for (const fileAbs of files) {
    if (path.basename(fileAbs) === 'SKILL.md') continue;
    referenceRelativePaths.push(toPosixRelativePath(projectRoot, fileAbs));
  }
  referenceRelativePaths.sort();

  return {
    directoryName: skillDirectoryName,
    name: fm.name ?? skillDirectoryName,
    description: fm.description,
    skillFileRelativePath: toPosixRelativePath(projectRoot, skillMdAbs),
    referenceRelativePaths,
  };
}

async function agentsInitCommand(projectDir: string): Promise<void> {
  const startedAt = Date.now();
  const resolvedProjectDir = path.resolve(process.cwd(), projectDir || '.');
  const claudeMdPath = path.join(resolvedProjectDir, 'CLAUDE.md');
  const claudeDir = path.join(resolvedProjectDir, '.claude');
  const projectSkillsDir = path.join(claudeDir, 'skills');

  const hasClaudeMd = fs.existsSync(claudeMdPath);
  const hasClaudeDir = fs.existsSync(claudeDir);

  const isNewProject = !hasClaudeMd && !hasClaudeDir;

  console.log('webf agents init');
  console.log(`Project: ${resolvedProjectDir}`);
  if (isNewProject) {
    console.log('Detected: no CLAUDE.md and no .claude/ (new project)');
  } else {
    console.log(`Detected: CLAUDE.md=${hasClaudeMd ? 'yes' : 'no'}, .claude/=${hasClaudeDir ? 'yes' : 'no'} (existing project)`);
  }

  const { packageRoot, packageName, packageVersion } = resolveSkillsPackageRoot();
  const skillDirectories = listSkillDirectories(packageRoot);

  if (skillDirectories.length === 0) {
    throw new Error(`No skills found in ${packageName} (resolved at ${packageRoot}).`);
  }

  console.log(`Skills source: ${packageName}@${packageVersion}`);
  console.log(`Skills destination: ${toPosixRelativePath(resolvedProjectDir, projectSkillsDir)}`);

  ensureDirSync(projectSkillsDir);

  const copyStats: CopyStats = { filesWritten: 0, filesUnchanged: 0, backupsCreated: 0 };
  for (const skillDirName of skillDirectories) {
    const srcSkillDir = path.join(packageRoot, skillDirName);
    const destSkillDir = path.join(projectSkillsDir, skillDirName);

    copyDirRecursiveSync(srcSkillDir, destSkillDir, copyStats);
  }

  const installedSkills = skillDirectories.map(skillDirName =>
    collectSkillInfo(resolvedProjectDir, projectSkillsDir, skillDirName)
  );

  const block = buildClaudeBlock(packageName, packageVersion, installedSkills);

  if (isNewProject) {
    const initial = ['# Claude Code', '', block, ''].join('\n');
    fs.writeFileSync(claudeMdPath, initial, 'utf-8');
    console.log(`Created ${toPosixRelativePath(resolvedProjectDir, claudeMdPath)}`);
  } else {
    const existing = readFileIfExists(claudeMdPath)?.toString('utf-8') ?? '';
    const { content, action } = updateOrAppendMarkedBlock(existing, block);
    fs.writeFileSync(claudeMdPath, content, 'utf-8');
    console.log(`${action === 'replaced' ? 'Updated' : 'Appended'} WebF skills block in ${toPosixRelativePath(resolvedProjectDir, claudeMdPath)}`);
  }

  const versionFilePath = path.join(claudeDir, 'webf-claude-code-skills.version');
  fs.writeFileSync(versionFilePath, `${packageName}@${packageVersion}${os.EOL}`, 'utf-8');
  console.log(`Wrote ${toPosixRelativePath(resolvedProjectDir, versionFilePath)}`);

  console.log(
    `Installed ${installedSkills.length} skills (${copyStats.filesWritten} files written, ${copyStats.filesUnchanged} unchanged, ${copyStats.backupsCreated} backups) in ${Date.now() - startedAt}ms`
  );
}

export { agentsInitCommand };
