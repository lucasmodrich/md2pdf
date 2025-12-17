# md2pdf

Convert Markdown files to beautifully formatted PDFs with GitHub-style styling using the Typst typesetting engine.

## Overview

`md2pdf` provides cross-platform scripts for converting Markdown documents to PDF format. The scripts use [Pandoc](https://pandoc.org/) for Markdown parsing and [Typst](https://typst.app/) as the PDF rendering engine, producing clean, professional PDFs with GitHub-inspired formatting.

### Why Typst?

- ✓ Native Unicode and emoji support (✓ ✗ 😀 🎉)
- ✓ Modern typography and layout capabilities
- ✓ Fast compilation times
- ✓ No LaTeX dependencies required
- ✓ Active development and community support

## Features

- **Cross-platform**: Works on Windows (PowerShell), Linux, and macOS (Bash)
- **Batch conversion**: Process entire directories of Markdown files
- **Recursive processing**: Scan subdirectories for Markdown files
- **GitHub styling**: Professional, GitHub-themed PDF output
- **Auto-install**: Built-in Typst installation functionality
- **Flexible output**: Specify custom output directories

## Dependencies

### Required

1. **Pandoc** (v2.0 or higher)
   - Universal document converter
   - Required for Markdown to Typst conversion

2. **Typst** (v0.12.0 recommended)
   - Modern typesetting engine
   - Can be auto-installed by the scripts

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

#### Convert a single file
```powershell
.\md2pdf.ps1 -InputPath "README.md"
```

#### Convert all Markdown files in a directory
```powershell
.\md2pdf.ps1 -InputPath "./docs"
```

#### Convert recursively with custom output directory
```powershell
.\md2pdf.ps1 -InputPath "./docs" -OutputDir "./output" -Recursive
```

#### Check if Typst is installed
```powershell
.\md2pdf.ps1 -InstallTypst
```

### Linux/macOS (Bash)

#### Make the script executable (first time only)
```bash
chmod +x md2pdf.sh
```

#### Convert a single file
```bash
./md2pdf.sh README.md
```

#### Convert all Markdown files in a directory
```bash
./md2pdf.sh ./docs
```

#### Convert recursively with custom output directory
```bash
./md2pdf.sh ./docs ./output --recursive
```

#### Install Typst
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
| `-OutputDir` | String | No | `./pdf_output` | Directory for PDF output |
| `-Recursive` | Switch | No | `false` | Process subdirectories recursively |
| `-InstallTypst` | Switch | No | `false` | Download and install Typst |

*Not required when using `-InstallTypst`

### Bash Script (md2pdf.sh)

| Option | Type | Required | Default | Description |
|--------|------|----------|---------|-------------|
| `<input_path>` | Positional | Yes* | - | Path to a Markdown file or directory |
| `[output_dir]` | Positional | No | `./pdf_output` | Directory for PDF output |
| `-r, --recursive` | Flag | No | `false` | Process subdirectories recursively |
| `-i, --install` | Flag | No | `false` | Download and install Typst |
| `-h, --help` | Flag | No | `false` | Show help message |

*Not required when using `--install`

## Output Format

The scripts generate PDFs with GitHub-style formatting:

- **Typography**: Clean, readable fonts (Segoe UI/Liberation Sans)
- **Headings**: Bold with horizontal rules for H1 and H2
- **Code blocks**: Syntax highlighting with gray background
- **Inline code**: Monospace font with light background
- **Links**: Blue, GitHub-style hyperlinks
- **Quotes**: Left border with gray text
- **Page margins**: 2.5cm on all sides

## Examples

### Example 1: Convert documentation directory
```powershell
# Windows
.\md2pdf.ps1 -InputPath "./docs" -Recursive

# Linux/macOS
./md2pdf.sh -r ./docs
```

### Example 2: Convert to specific output location
```powershell
# Windows
.\md2pdf.ps1 -InputPath "project-notes.md" -OutputDir "C:\exports"

# Linux/macOS
./md2pdf.sh project-notes.md ~/exports
```

### Example 3: Batch convert with custom styling
The scripts automatically apply GitHub styling. Output PDFs will be saved to `./pdf_output` by default:
```
pdf_output/
├── README.pdf
├── CONTRIBUTING.pdf
└── CHANGELOG.pdf
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
The scripts use system fonts:
- **Windows**: Segoe UI, Consolas
- **Linux/macOS**: Liberation Sans, Liberation Mono

If fonts are missing, install them or modify the font settings in the script's Typst template.

### Permission denied (Linux/macOS)
```bash
chmod +x md2pdf.sh
```

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
├── LICENSE             # Project license
├── docs/               # Documentation directory
└── pdf_output/         # Default output directory (created automatically)
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
