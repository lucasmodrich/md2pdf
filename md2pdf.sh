#!/bin/bash

# Markdown to PDF Converter with Typst Engine
# Usage: ./convert-md-to-pdf-typst.sh <input_path> [output_dir]

set -e

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Default values
OUTPUT_DIR="./pdf_output"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Function to print colored output
print_color() {
    local color=$1
    shift
    echo -e "${color}$@${NC}"
}

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to install Typst
install_typst() {
    print_color "$CYAN" "Installing Typst..."
    
    local typst_version="v0.12.0"
    local platform=""
    local install_dir="$HOME/.typst"
    
    # Detect platform
    case "$(uname -s)" in
        Linux*)
            platform="x86_64-unknown-linux-musl"
            ;;
        Darwin*)
            if [[ "$(uname -m)" == "arm64" ]]; then
                platform="aarch64-apple-darwin"
            else
                platform="x86_64-apple-darwin"
            fi
            ;;
        MINGW*|MSYS*|CYGWIN*)
            platform="x86_64-pc-windows-msvc"
            ;;
        *)
            print_color "$RED" "Unsupported platform: $(uname -s)"
            return 1
            ;;
    esac
    
    local download_url="https://github.com/typst/typst/releases/download/${typst_version}/typst-${platform}.tar.xz"
    local temp_file="/tmp/typst.tar.xz"
    
    # Download
    print_color "$CYAN" "Downloading Typst ${typst_version}..."
    if ! curl -L -o "$temp_file" "$download_url" 2>/dev/null; then
        print_color "$RED" "Failed to download Typst"
        return 1
    fi
    
    # Create install directory
    mkdir -p "$install_dir"
    
    # Extract
    print_color "$CYAN" "Extracting..."
    tar -xf "$temp_file" -C "$install_dir"
    
    # Add to PATH in shell config
    local shell_rc=""
    if [[ -f "$HOME/.bashrc" ]]; then
        shell_rc="$HOME/.bashrc"
    elif [[ -f "$HOME/.zshrc" ]]; then
        shell_rc="$HOME/.zshrc"
    fi
    
    if [[ -n "$shell_rc" ]]; then
        if ! grep -q "typst" "$shell_rc"; then
            echo "export PATH=\"\$PATH:$install_dir/typst-${platform}\"" >> "$shell_rc"
            print_color "$GREEN" "✓ Typst installed successfully to: $install_dir/typst-${platform}"
            print_color "$YELLOW" "  Please restart your terminal or run: source $shell_rc"
        fi
    fi
    
    # Add to current session PATH
    export PATH="$PATH:$install_dir/typst-${platform}"
    
    rm -f "$temp_file"
    return 0
}

# Function to convert markdown to PDF using Typst
convert_md_to_pdf() {
    local md_file=$1
    local output_file=$2
    
    print_color "$CYAN" "Converting: $md_file"
    
    # Create temporary Typst file
    local typst_file="${output_file%.pdf}.typ"
    
    # Step 1: Convert markdown to Typst
    if ! pandoc "$md_file" -o "$typst_file" -t typst 2>/dev/null; then
        print_color "$RED" "✗ Failed to convert markdown to Typst: $md_file"
        return 1
    fi
    
    # Step 2: Add GitHub styling to the Typst file
    local typst_content=$(cat "$typst_file")
    cat > "$typst_file" << 'TYPST_TEMPLATE'
// GitHub-style formatting
#set page(margin: (x: 2.5cm, y: 2.5cm))
#set text(font: "Liberation Sans", size: 11pt, fill: rgb("#24292e"))
#set par(justify: false, leading: 0.65em)

#show heading.where(level: 1): it => {
  set text(size: 2em, weight: 600)
  block(below: 1em, above: 1.5em)[
    #it.body
    #v(0.3em)
    #line(length: 100%, stroke: 0.5pt + rgb("#eaecef"))
  ]
}

#show heading.where(level: 2): it => {
  set text(size: 1.5em, weight: 600)
  block(below: 1em, above: 1.5em)[
    #it.body
    #v(0.3em)
    #line(length: 100%, stroke: 0.5pt + rgb("#eaecef"))
  ]
}

#show link: set text(fill: rgb("#0366d6"))

#show raw.where(block: false): it => box(
  fill: rgb("#f6f8fa"),
  outset: (x: 3pt, y: 2pt),
  radius: 3pt,
)[#set text(font: "Liberation Mono", size: 0.85em); #it]

#show raw.where(block: true): it => block(
  fill: rgb("#f6f8fa"),
  width: 100%,
  inset: 1em,
  radius: 6pt,
)[#set text(font: "Liberation Mono", size: 0.85em); #it]

#show quote: it => pad(
  left: 1em,
  block(
    width: 100%,
    stroke: (left: 0.25em + rgb("#dfe2e5")),
    inset: (left: 1em, rest: 0.5em)
  )[#set text(fill: rgb("#6a737d")); #it]
)

#let horizontalrule = [
  #v(0.5em)
  #line(length: 100%, stroke: 0.25em + rgb("#e1e4e8"))
  #v(0.5em)
]

TYPST_TEMPLATE
    
    echo "$typst_content" >> "$typst_file"
    
    # Step 3: Compile Typst to PDF
    if typst compile "$typst_file" "$output_file" 2>/dev/null; then
        rm -f "$typst_file"
        print_color "$GREEN" "✓ Created: $output_file"
        return 0
    else
        print_color "$RED" "✗ Failed to compile Typst to PDF: $md_file"
        print_color "$YELLOW" "  Typst file saved at: $typst_file (for debugging)"
        return 1
    fi
}

# Show usage
show_usage() {
    cat << EOF
Markdown to PDF Converter with Typst Engine

Usage: $0 <input_path> [output_dir] [options]

Arguments:
    input_path      Path to a markdown file or directory containing markdown files
    output_dir      Directory where PDF files will be saved (default: ./pdf_output)

Options:
    -r, --recursive Process subdirectories recursively
    -i, --install   Install Typst before converting
    -h, --help      Show this help message

Examples:
    $0 README.md
    $0 ./docs ./output
    $0 -r ./docs
    $0 --install

Why Typst?
    - Native Unicode and emoji support (✓ ✗ 😀 🎉)
    - Modern typography and layout
    - Fast compilation
    - No external dependencies
    - Active development
EOF
    exit 0
}

# Main script
main() {
    print_color "$YELLOW" "=== Markdown to PDF Converter (Typst Engine) ==="
    echo ""
    
    # Check for help flag
    if [[ "$1" == "-h" ]] || [[ "$1" == "--help" ]]; then
        show_usage
    fi
    
    # Check for install flag
    if [[ "$1" == "-i" ]] || [[ "$1" == "--install" ]]; then
        if install_typst; then
            print_color "$GREEN" "Installation complete!"
            print_color "$YELLOW" "Please restart your terminal and run the script again."
        else
            print_color "$RED" "Installation failed"
            exit 1
        fi
        exit 0
    fi
    
    # Check dependencies
    if ! command_exists pandoc; then
        print_color "$RED" "ERROR: pandoc is not installed or not in PATH"
        print_color "$YELLOW" "Please install pandoc: https://pandoc.org/installing.html"
        exit 1
    fi
    
    if ! command_exists typst; then
        print_color "$RED" "ERROR: Typst is not installed or not in PATH"
        echo ""
        print_color "$YELLOW" "To install Typst, run:"
        print_color "$CYAN" "  $0 --install"
        echo ""
        print_color "$YELLOW" "Or install manually from: https://github.com/typst/typst/releases"
        exit 1
    fi
    
    # Show versions
    local pandoc_version=$(pandoc --version | head -n1 | cut -d' ' -f2)
    local typst_version=$(typst --version | cut -d' ' -f2)
    print_color "$CYAN" "Using pandoc $pandoc_version with Typst $typstversion"
    echo ""
    
    # Parse arguments
    local recursive=0
    local input_path=""
    
    while [[ $# -gt 0 ]]; do
        case $1 in
            -r|--recursive)
                recursive=1
                shift
                ;;
            *)
                if [[ -z "$input_path" ]]; then
                    input_path=$1
                elif [[ "$OUTPUT_DIR" == "./pdf_output" ]]; then
                    OUTPUT_DIR=$1
                fi
                shift
                ;;
        esac
    done
    
    # Validate input path
    if [[ -z "$input_path" ]]; then
        print_color "$RED" "ERROR: No input path specified"
        echo ""
        show_usage
    fi
    
    if [[ ! -e "$input_path" ]]; then
        print_color "$RED" "ERROR: Input path not found: $input_path"
        exit 1
    fi
    
    # Create output directory
    mkdir -p "$OUTPUT_DIR"
    print_color "$GREEN" "Output directory: $OUTPUT_DIR"
    echo ""
    
    # Find markdown files
    local md_files=()
    
    if [[ -f "$input_path" ]]; then
        # Single file
        if [[ "$input_path" == *.md ]]; then
            md_files=("$input_path")
        else
            print_color "$RED" "ERROR: Input file is not a markdown file (.md)"
            exit 1
        fi
    elif [[ -d "$input_path" ]]; then
        # Directory
        print_color "$CYAN" "Searching for markdown files in: $input_path"
        
        if [[ $recursive -eq 1 ]]; then
            while IFS= read -r -d '' file; do
                md_files+=("$file")
            done < <(find "$input_path" -type f -name "*.md" -print0)
        else
            while IFS= read -r -d '' file; do
                md_files+=("$file")
            done < <(find "$input_path" -maxdepth 1 -type f -name "*.md" -print0)
        fi
    fi
    
    if [[ ${#md_files[@]} -eq 0 ]]; then
        print_color "$YELLOW" "No markdown files found."
        exit 0
    fi
    
    print_color "$CYAN" "Found ${#md_files[@]} markdown file(s)"
    echo ""
    
    # Convert files
    local success_count=0
    local fail_count=0
    
    for md_file in "${md_files[@]}"; do
        local base_name=$(basename "$md_file" .md)
        local pdf_file="${OUTPUT_DIR}/${base_name}.pdf"
        
        if convert_md_to_pdf "$md_file" "$pdf_file"; then
            ((success_count++))
        else
            ((fail_count++))
        fi
    done
    
    # Summary
    echo ""
    print_color "$YELLOW" "=== Conversion Complete ==="
    print_color "$GREEN" "Successful: $success_count"
    if [[ $fail_count -gt 0 ]]; then
        print_color "$RED" "Failed: $fail_count"
    else
        print_color "$CYAN" "Failed: $fail_count"
    fi
    print_color "$CYAN" "Output directory: $OUTPUT_DIR"
}

# Run main function
main "$@"
