#!/usr/bin/env node
// Sync the published skill into the npm payload. Source of truth: .claude/skills/godomaster/

const { readFile, writeFile, mkdir } = require('node:fs/promises');
const { join } = require('node:path');

const ROOT = join(__dirname, '..');
const SKILL = join(ROOT, '.claude', 'skills', 'godomaster');
const ASSETS = join(ROOT, 'cli', 'assets');

async function copy(from, to) {
  await mkdir(join(to, '..'), { recursive: true });
  await writeFile(to, await readFile(from));
}

async function main() {
  const refs = [];
  for (const f of (await readFile(join(SKILL, 'SKILL.md'), 'utf8')).matchAll(/`(references\/[^`]+\.md)`/g)) {
    refs.push(f[1]);
  }

  const plan = [
    [join(SKILL, 'SKILL.md'), 'SKILL.md'],
    ...refs.map((r) => [join(SKILL, r), r]),
    // Root README.md is the Chinese one; README.zh-cn.md is an alias the npm page links to.
    [join(ROOT, 'README.md'), 'README.md'],
    [join(ROOT, 'README.md'), 'README.zh-cn.md'],
    [join(ROOT, 'README.en.md'), 'README.en.md'],
  ];

  for (const [src, dst] of plan) {
    await copy(src, join(ASSETS, dst));
  }

  console.log(`Synced SKILL.md + ${refs.length} references + 3 READMEs into cli/assets/`);
}

main().catch((err) => {
  console.error(`sync failed: ${err.message}`);
  process.exit(1);
});
