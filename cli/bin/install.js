#!/usr/bin/env node

const { mkdir, cp, access, readdir } = require('node:fs/promises');
const { join } = require('node:path');
const { homedir } = require('node:os');

const ASSETS_DIR = join(__dirname, '..', 'assets');
const TARGET_DIR = join(homedir(), '.claude', 'skills', 'godomaster');

const GREEN = '\x1b[32m';
const YELLOW = '\x1b[33m';
const CYAN = '\x1b[36m';
const RESET = '\x1b[0m';

const IS_SILENT = process.argv.includes('--silent') || process.argv.includes('-s');

function log(msg) {
  if (!IS_SILENT) console.log(msg);
}

function success(msg) {
  console.log(`${GREEN}✓${RESET} ${msg}`);
}

function warn(msg) {
  console.log(`${YELLOW}⚠${RESET} ${msg}`);
}

function info(msg) {
  console.log(`${CYAN}ℹ${RESET} ${msg}`);
}

async function exists(path) {
  try { await access(path); return true; } catch { return false; }
}

async function main() {
  const isDryRun = process.argv.includes('--dry-run');

  if (!IS_SILENT) {
    console.log(`
${GREEN}╔══════════════════════════════════════════╗
║   GodoMaster — Installer                  ║
║   Godot 4.x Game Development Intelligence ║
╚══════════════════════════════════════════╝${RESET}
`);
  }

  // Check assets
  const assetsExist = await exists(ASSETS_DIR);
  if (!assetsExist) {
    if (!IS_SILENT) {
      warn('Assets not found. If installed via npm, this is expected — the skill is bundled with the package.');
      info('For manual install, clone the repository and run: node cli/bin/install.js');
    }
    return;
  }

  // Check if already installed
  const alreadyInstalled = await exists(TARGET_DIR);
  if (alreadyInstalled) {
    const forceFlag = process.argv.includes('--force') || process.argv.includes('-f');
    if (!forceFlag) {
      info(`Already installed at: ${TARGET_DIR}`);
      info('Use --force to reinstall.');
      return;
    }
  }

  if (isDryRun) {
    info(`[DRY RUN] Would install to: ${TARGET_DIR}`);
    return;
  }

  // Create target directory
  await mkdir(TARGET_DIR, { recursive: true });
  log('');

  // Copy SKILL.md
  const skillSrc = join(ASSETS_DIR, 'SKILL.md');
  if (await exists(skillSrc)) {
    await cp(skillSrc, join(TARGET_DIR, 'SKILL.md'));
    success('Installed: SKILL.md');
  }

  // Copy references
  const refSrc = join(ASSETS_DIR, 'references');
  const refDst = join(TARGET_DIR, 'references');
  if (await exists(refSrc)) {
    await cp(refSrc, refDst, { recursive: true });
    const refs = await readdir(refDst);
    success(`Installed: references/ (${refs.length} files)`);
  }

  // Copy READMEs
  for (const readmeName of ['README.md', 'README.zh-cn.md']) {
    const readmeSrc = join(ASSETS_DIR, readmeName);
    if (await exists(readmeSrc)) {
      await cp(readmeSrc, join(TARGET_DIR, readmeName));
      success(`Installed: ${readmeName}`);
    }
  }

  log('');
  success(`GodoMaster installed to: ${TARGET_DIR}`);
  log('');
  info('Usage: Type /godomaster in Claude Code, or mention any Godot topic.');
  info('Topics: GDScript, scene, tilemap, shader, physics, animation, etc.');
  log('');
}

main().catch((err) => {
  console.error(`\x1b[31m✗ Error: ${err.message}\x1b[0m`);
  process.exit(1);
});
