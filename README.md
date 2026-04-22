# md2pdf

Convert Markdown files to beautifully formatted PDFs or editable Word documents (DOCX) using Pandoc and the Typst typesetting engine.

## Overview

`md2pdf` provides cross-platform scripts for converting Markdown documents to PDF or DOCX format. The scripts use [Pandoc](https://pandoc.org/) for Markdown parsing, with [Typst](https://typst.app/) as the PDF rendering engine for GitHub-inspired PDF output. DOCX output is handled directly by Pandoc and does not require Typst.

### Why Typst (for PDF)?

- ✓ Native Unicode and emoji support (✓ ✗ 😀 🎉)
- ✓ Modern typography and layout capabilities
- ✓ Fast compilation times
- ✓ No LaTeX dependencies required
- ✓ Active development and community support

## Features

- **Cross-platform**: Works on Windows (PowerShell), Linux, and macOS (Bash), including ARM64
- **Multiple output formats**: Export to PDF (GitHub-styled) or DOCX (editable Word document)
- **Batch conversion**: Process entire directories of Markdown files
- **Recursive processing**: Scan subdirectories for Markdown files
- **GitHub styling**: Professional, GitHub-themed PDF output
- **Front matter**: YAML front matter (`title`, `author`, `date`) is rendered in the output
- **Relative assets**: Images and includes are resolved relative to the source file
- **Auto-install**: Built-in Typst installation functionality
- **Flexible output**: Specify custom output directories

## Dependencies

### PDF output

1. **Pandoc** (v3.2 or higher)
   - Universal document converter
   - v3.2+ is required for Typst output format support

2. **Typst** (v0.12.0 recommended)
   - Modern typesetting engine
   - Can be auto-installed by the scripts

### DOCX output

1. **Pandoc** (any recent version)
   - Handles Markdown to DOCX conversion directly
   - Typst is **not** required

### Optional

- **PowerShell 7+** (for Windows users preferring cross-platform PowerShell)
- **Bash 4+** (pre-installed on most Linux/macOS systems)

## Installation

### 1. Install Pandoc

#### Windows
```powershell
# Using Chocolatey
choco install pandoc

# Or using winget
winget install JohnMacFarlane.Pandoc

# Or download installer from https://pandoc.org/installing.html
```

#### macOS
```bash
# Using Homebrew
brew install pandoc

# Or using MacPorts
sudo port install pandoc
```

#### Linux
```bash
# Ubuntu/Debian
sudo apt-get install pandoc

# Fedora
sudo dnf install pandoc

# Arch Linux
sudo pacman -S pandoc
```

### 2. Install Typst

#### Option A: Auto-install using the scripts

**Windows (PowerShell):**
```powershell
.\md2pdf.ps1 -InstallTypst
```

**Linux/macOS (Bash):**
```bash
chmod +x md2pdf.sh
./md2pdf.sh --install
```

After auto-installation, restart your terminal for PATH changes to take effect.

#### Option B: Manual installation

**Windows:**
```powershell
# Using Chocolatey
choco install typst

# Or using winget
winget install Typst.Typst
```

**macOS:**
```bash
# Using Homebrew
brew install typst
```

**Linux:**
```bash
# Using package manager (if available)
# Ubuntu 23.10+
sudo apt install typst

# Or download from GitHub releases
wget https://github.com/typst/typst/releases/download/v0.12.0/typst-x86_64-unknown-linux-musl.tar.xz
tar -xf typst-x86_64-unknown-linux-musl.tar.xz
sudo mv typst-x86_64-unknown-linux-musl/typst /usr/local/bin/
```

### 3. Clone or Download This Repository

```bash
git clone https://github.com/lucasmodrich/md2pdf.git
cd md2pdf
```

## Usage

### Windows (PowerShell)

#### Convert a single file to PDF
```powershell
.\md2pdf.ps1 -InputPath "README.md"
```

#### Convert a single file to DOCX
```powershell
.\md2pdf.ps1 -InputPath "README.md" -Format docx
```

#### Convert all Markdown files in a directory
```powershell
.\md2pdf.ps1 -InputPath "./docs"
```

#### Convert recursively with custom output directory
```powershell
.\md2pdf.ps1 -InputPath "./docs" -OutputPath "./output" -Recursive
```

#### Convert recursively to DOCX
```powershell
.\md2pdf.ps1 -InputPath "./docs" -Format docx -Recursive
```

#### Install Typst (required for PDF output)
```powershell
.\md2pdf.ps1 -InstallTypst
```

### Linux/macOS (Bash)

#### Make the script executable (first time only)
```bash
chmod +x md2pdf.sh
```

#### Convert a single file to PDF
```bash
./md2pdf.sh README.md
```

#### Convert a single file to DOCX
```bash
./md2pdf.sh README.md --format docx
```

#### Convert all Markdown files in a directory
```bash
./md2pdf.sh ./docs
```

#### Convert recursively with custom output directory
```bash
./md2pdf.sh ./docs --output-path ./output --recursive
```

#### Convert recursively to DOCX
```bash
./md2pdf.sh ./docs --output-path ./output --format docx --recursive
```

#### Install Typst (required for PDF output)
```bash
./md2pdf.sh --install
```

#### Show help
```bash
./md2pdf.sh --help
```

## Command-Line Options

### PowerShell Script (md2pdf.ps1)

| Parameter | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| `-InputPath` | String | Yes* | - | Path to a Markdown file or directory |
| `-OutputPath` | String | No | `./output` | Directory for output files |
| `-Format` | String | No | `pdf` | Output format: `pdf` or `docx` |
| `-Recursive` | Switch | No | `false` | Process subdirectories recursively |
| `-InstallTypst` | Switch | No | `false` | Download and install Typst |

*Not required when using `-InstallTypst`

### Bash Script (md2pdf.sh)

| Option | Type | Required | Default | Description |
|--------|------|----------|---------|-------------|
| `<input_path>` | Positional | Yes* | - | Path to a Markdown file or directory |
| `-o, --output-path` | Flag | No | `./output` | Directory for output files |
| `-f, --format` | Flag | No | `pdf` | Output format: `pdf` or `docx` |
| `-r, --recursive` | Flag | No | `false` | Process subdirectories recursively |
| `-i, --install` | Flag | No | `false` | Download and install Typst |
| `-h, --help` | Flag | No | `false` | Show help message |

*Not required when using `--install`

## Output Format

### PDF

PDFs are rendered with GitHub-style formatting via Typst:

- **Typography**: Cross-platform font priority list — `Segoe UI` / `Arial` / `Helvetica` / `DejaVu Sans`
- **Monospace**: `Consolas` / `Menlo` / `DejaVu Sans Mono` / `Courier New`
- **Headings**: Bold with horizontal rules for H1 and H2
- **Code blocks**: Monospace font with light grey background
- **Inline code**: Monospace font with light background
- **Links**: Blue, GitHub-style hyperlinks
- **Quotes**: Left border with grey text
- **Page margins**: 2.5cm on all sides

### DOCX

DOCX files are produced directly by Pandoc using its default Word styles. The output is clean and fully editable in Microsoft Word or any compatible application. YAML front matter (`title`, `author`, `date`) is preserved as document metadata.

## Examples

### Example 1: Convert documentation directory to PDF
```powershell
# Windows
.\md2pdf.ps1 -InputPath "./docs" -Recursive

# Linux/macOS
./md2pdf.sh ./docs -r
```

### Example 2: Convert documentation directory to DOCX
```powershell
# Windows
.\md2pdf.ps1 -InputPath "./docs" -Format docx -Recursive

# Linux/macOS
./md2pdf.sh ./docs --format docx --recursive
```

### Example 3: Convert to specific output location
```powershell
# Windows
.\md2pdf.ps1 -InputPath "project-notes.md" -OutputPath "C:\exports"

# Linux/macOS
./md2pdf.sh project-notes.md --output-path ~/exports
```

### Example 4: Batch convert — output layout
Output files are saved to `./output` by default with the appropriate extension:
```
output/
├── README.pdf          # --format pdf (default)
├── CONTRIBUTING.pdf
└── CHANGELOG.pdf

output/
├── README.docx         # --format docx
├── CONTRIBUTING.docx
└── CHANGELOG.docx
```

## Troubleshooting

### "pandoc is not installed or not in PATH"
- Install Pandoc using the instructions above
- Verify installation: `pandoc --version`
- Restart your terminal after installation

### "Typst is not installed or not in PATH"
- Run the script with `-InstallTypst` or `--install` flag
- Or manually install Typst from https://github.com/typst/typst/releases
- Restart your terminal after installation

### Conversion fails with font errors
The scripts use a cross-platform font priority list. Typst picks the first font it finds installed on the system:

- **Body text**: Segoe UI → Arial → Helvetica → DejaVu Sans
- **Monospace**: Consolas → Menlo → DejaVu Sans Mono → Courier New

At least one font from each list is present on all mainstream operating systems. Font warnings in the output are non-fatal — Typst substitutes the next available font automatically.

### Permission denied (Linux/macOS)
```bash
chmod +x md2pdf.sh
```

### Images not appearing in the PDF
Image paths must be relative to the source `.md` file. The scripts write the intermediate Typst file alongside the source markdown so all relative paths resolve correctly:

```markdown
![Logo](images/logo.png)
```

The above works as long as `images/logo.png` exists next to the Markdown file.

### PowerShell execution policy error (Windows)
```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

## Project Structure

```
md2pdf/
├── md2pdf.ps1          # PowerShell script for Windows
├── md2pdf.sh           # Bash script for Linux/macOS
├── README.md           # This file
├── LICENSE             # Project licence
├── input/              # Place source Markdown files here
└── output/             # Generated PDFs saved here by default
```

## Contributing

Contributions are welcome! Please feel free to submit issues, feature requests, or pull requests.

## License

This project is licensed under the terms specified in the [LICENSE](LICENSE) file.

## Credits

- [Pandoc](https://pandoc.org/) - Universal document converter by John MacFarlane
- [Typst](https://typst.app/) - Modern typesetting system
- GitHub for design inspiration

## Related Projects

- [pandoc](https://github.com/jgm/pandoc) - Universal markup converter
- [typst](https://github.com/typst/typst) - A new markup-based typesetting system
- [markdown-pdf](https://github.com/yzane/vscode-markdown-pdf) - VS Code extension for Markdown to PDF

---

**Made with ❤️ for the Markdown community**
