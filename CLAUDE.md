# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project summary

Shell-script converter that turns Markdown files into PDF or DOCX. No build system, no package manager, no test suite — the scripts are the artefacts.

## Running the scripts

```bash
# Bash (Linux/macOS or Git Bash on Windows)
./md2pdf.sh README.md                              # single file → PDF
./md2pdf.sh README.md --format docx               # single file → DOCX
./md2pdf.sh ./input ./output --recursive           # directory, recursive
./md2pdf.sh --install                              # auto-install Typst

# PowerShell (Windows)
.\md2pdf.ps1 -InputPath README.md
.\md2pdf.ps1 -InputPath README.md -Format docx
.\md2pdf.ps1 -InputPath ./input -OutputDir ./output -Recursive
.\md2pdf.ps1 -InstallTypst
```

Syntax-check the scripts without running them:

```bash
bash -n md2pdf.sh
pwsh -NonInteractive -Command "[System.Management.Automation.Language.Parser]::ParseFile('$PWD/md2pdf.ps1', [ref]\$null, [ref]\$null)"
```

## Architecture

Both scripts implement the same logic independently — changes to one must be mirrored in the other.

**PDF pipeline** (requires Pandoc ≥ 3.2 + Typst ≥ 0.12.0):
1. `pandoc <input.md> -o <temp>.typ -t typst --standalone` — Markdown → Typst
2. Prepend a GitHub-style Typst template block to the generated `.typ` file
3. `typst compile <temp>.typ <output>.pdf` — Typst → PDF
4. Delete the temp `.typ` file (kept on failure for debugging)

The intermediate `.typ` file is placed **alongside the source markdown** (not in the output directory) so that Typst resolves relative image paths correctly.

**DOCX pipeline** (requires Pandoc only — any recent version):
- `pandoc <input.md> -o <output>.docx` — single step, no Typst involved

The `--format`/`-Format` flag selects the pipeline at runtime; PDF is the default. The Typst dependency check is skipped entirely when `--format docx` is used.

## Key conventions

- The Typst styling template is embedded as a here-doc/here-string directly inside each script — there is no external template file.
- Intermediate Typst files use the naming pattern `._md2pdf_<basename>.typ` and are covered by `.gitignore`.
- `input/` and `output/` directories are git-ignored (contents only); `.gitkeep` files preserve the directory structure in the repository.
- Commit messages use Conventional Commits format with Australian English spelling.
