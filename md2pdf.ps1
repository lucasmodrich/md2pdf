#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Convert markdown files to PDF using Typst engine with GitHub styling.

.DESCRIPTION
    This script converts one or more markdown files to PDF format using pandoc with Typst as the PDF engine.
    Typst provides excellent Unicode support, modern typography, and fast compilation.

.PARAMETER InputPath
    Path to a markdown file or directory containing markdown files.

.PARAMETER OutputDir
    Directory where PDF files will be saved. Defaults to './output'.

.PARAMETER Recursive
    If specified and InputPath is a directory, process markdown files in subdirectories.

.PARAMETER InstallTypst
    If specified, downloads and installs Typst if not already installed.

.EXAMPLE
    .\md2pdf.ps1 -InputPath "README.md"
    Convert a single markdown file to PDF.

.EXAMPLE
    .\md2pdf.ps1 -InputPath "./docs" -Recursive
    Convert all markdown files in the docs directory and subdirectories.

.EXAMPLE
    .\md2pdf.ps1 -InstallTypst
    Install Typst before converting documents.
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory=$false, Position=0)]
    [string]$InputPath,
    
    [Parameter(Mandatory=$false)]
    [string]$OutputDir = "./output",
    
    [Parameter(Mandatory=$false)]
    [switch]$Recursive,
    
    [Parameter(Mandatory=$false)]
    [switch]$InstallTypst
)

# Set error action preference
$ErrorActionPreference = "Stop"

# Function to check if a command exists
function Test-CommandExists {
    param([string]$Command)
    try {
        $null = Get-Command $Command -ErrorAction Stop
        return $true
    }
    catch {
        return $false
    }
}

# Function to install Typst
function Install-Typst {
    Write-Host "Installing Typst..." -ForegroundColor Cyan
    
    $typstVersion = "v0.12.0"
    $arch = if ([System.Runtime.InteropServices.RuntimeInformation]::ProcessArchitecture -eq [System.Runtime.InteropServices.Architecture]::Arm64) { "aarch64" } else { "x86_64" }
    $platform = if ($IsWindows -or $env:OS -match "Windows") { "$arch-pc-windows-msvc" }
                elseif ($IsMacOS) { "$arch-apple-darwin" }
                elseif ($IsLinux) { "$arch-unknown-linux-musl" }
                else { "$arch-pc-windows-msvc" }
    
    $downloadUrl = "https://github.com/typst/typst/releases/download/$typstVersion/typst-$platform.zip"
    $tempZip = Join-Path $env:TEMP "typst.zip"
    $installDir = Join-Path $HOME ".typst"
    
    try {
        # Download Typst
        Write-Host "Downloading Typst $typstVersion..." -ForegroundColor Cyan
        Invoke-WebRequest -Uri $downloadUrl -OutFile $tempZip -UseBasicParsing
        
        # Create install directory
        if (-not (Test-Path $installDir)) {
            New-Item -ItemType Directory -Path $installDir -Force | Out-Null
        }
        
        # Extract
        Write-Host "Extracting..." -ForegroundColor Cyan
        Expand-Archive -Path $tempZip -DestinationPath $installDir -Force
        
        # Add to PATH
        $typstBin = Join-Path $installDir "typst-$platform"
        $currentPath = [Environment]::GetEnvironmentVariable("Path", "User")
        if ($currentPath -notlike "*$typstBin*") {
            [Environment]::SetEnvironmentVariable("Path", "$currentPath;$typstBin", "User")
            $env:Path = "$env:Path;$typstBin"
        }
        
        Write-Host "✓ Typst installed successfully to: $typstBin" -ForegroundColor Green
        Write-Host "  Please restart your terminal for PATH changes to take effect." -ForegroundColor Yellow
        
        Remove-Item $tempZip -Force
        return $true
    }
    catch {
        Write-Host "✗ Failed to install Typst: $_" -ForegroundColor Red
        return $false
    }
}

# Function to convert a single markdown file to PDF using Typst
function Convert-MarkdownToPdf {
    param(
        [string]$MarkdownFile,
        [string]$OutputFile
    )
    
    Write-Host "Converting: $MarkdownFile" -ForegroundColor Cyan
    
    # Build pandoc command - generate Typst first, then compile
    # Place the .typ file next to the source markdown so Typst resolves relative
    # paths (images, includes) against the correct directory.
    $typstBaseName = [System.IO.Path]::GetFileNameWithoutExtension($OutputFile)
    $sourceDir = Split-Path $MarkdownFile -Parent
    $typstFile = Join-Path $sourceDir "._md2pdf_$typstBaseName.typ"
    
    try {
        # Step 1: Convert markdown to Typst (--standalone preserves YAML front matter)
        $pandocOutput = & pandoc $MarkdownFile -o $typstFile -t typst --standalone 2>&1
        
        if ($LASTEXITCODE -ne 0) {
            Write-Host "✗ Failed to convert markdown to Typst: $MarkdownFile" -ForegroundColor Red
            if ($pandocOutput) { Write-Host ($pandocOutput -join "`n") -ForegroundColor Red }
            return $false
        }
        
        # Step 2: Add GitHub styling to the Typst file
        $typstContent = Get-Content $typstFile -Raw
        $styledTypst = @"
// GitHub-style formatting
#set page(margin: (x: 2.5cm, y: 2.5cm))
#set text(font: ("Segoe UI", "Arial", "Helvetica", "DejaVu Sans"), size: 11pt, fill: rgb("#24292e"))
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
)[#set text(font: ("Consolas", "Menlo", "DejaVu Sans Mono", "Courier New"), size: 0.85em); #it]

#show raw.where(block: true): it => block(
  fill: rgb("#f6f8fa"),
  width: 100%,
  inset: 1em,
  radius: 6pt,
)[#set text(font: ("Consolas", "Menlo", "DejaVu Sans Mono", "Courier New"), size: 0.85em); #it]

#show quote: it => pad(
  left: 1em,
  block(
    width: 100%,
    stroke: (left: 0.25em + rgb("#dfe2e5")),
    inset: (left: 1em, rest: 0.5em)
  )[#set text(fill: rgb("#6a737d")); #it]
)

$typstContent
"@
        
        Set-Content -Path $typstFile -Value $styledTypst -Encoding UTF8
        
        # Step 3: Compile Typst to PDF
        $typstOutput = & typst compile $typstFile $OutputFile 2>&1
        
        if ($LASTEXITCODE -eq 0) {
            # Clean up intermediate Typst file
            Remove-Item $typstFile -Force -ErrorAction SilentlyContinue
            Write-Host "✓ Created: $OutputFile" -ForegroundColor Green
            return $true
        }
        else {
            Write-Host "✗ Failed to compile Typst to PDF: $MarkdownFile" -ForegroundColor Red
            if ($typstOutput) { Write-Host ($typstOutput -join "`n") -ForegroundColor Red }
            Write-Host "  Typst file saved at: $typstFile (for debugging)" -ForegroundColor Yellow
            return $false
        }
    }
    catch {
        Write-Host "✗ Failed to convert: $MarkdownFile" -ForegroundColor Red
        Write-Host "  Error: $_" -ForegroundColor Red
        return $false
    }
}

# Main script execution
Write-Host "=== Markdown to PDF Converter (Typst Engine) ===" -ForegroundColor Yellow
Write-Host ""

# Handle InstallTypst flag
if ($InstallTypst) {
    if (Install-Typst) {
        Write-Host ""
        Write-Host "Typst has been installed. Please restart your terminal and run the script again." -ForegroundColor Yellow
        exit 0
    }
    exit 1
}

# Validate that InputPath is provided
if (-not $InputPath) {
    Write-Host "ERROR: InputPath parameter is required" -ForegroundColor Red
    Write-Host ""
    Write-Host "Usage: .\md2pdf.ps1 -InputPath <path>" -ForegroundColor Yellow
    Write-Host "Use -InstallTypst flag to install Typst first" -ForegroundColor Yellow
    exit 1
}

# Check if pandoc is installed
if (-not (Test-CommandExists "pandoc")) {
    Write-Host "ERROR: pandoc is not installed or not in PATH" -ForegroundColor Red
    Write-Host "Please install pandoc from: https://pandoc.org/installing.html" -ForegroundColor Yellow
    exit 1
}

# Check minimum pandoc version (3.2 introduced -t typst)
$pandocVersionRaw = (pandoc --version | Select-Object -First 1) -replace "pandoc ", ""
$pandocVersionParsed = [version]($pandocVersionRaw -replace "-.*", "")
if ($pandocVersionParsed -lt [version]"3.2") {
    Write-Host "ERROR: pandoc $pandocVersionRaw is too old. Version 3.2 or higher is required for Typst output." -ForegroundColor Red
    Write-Host "Please upgrade pandoc from: https://pandoc.org/installing.html" -ForegroundColor Yellow
    exit 1
}

# Check if Typst is installed
if (-not (Test-CommandExists "typst")) {
    Write-Host "ERROR: Typst is not installed or not in PATH" -ForegroundColor Red
    Write-Host ""
    Write-Host "To install Typst, run:" -ForegroundColor Yellow
    Write-Host "  .\md2pdf.ps1 -InstallTypst" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Or install manually from: https://github.com/typst/typst/releases" -ForegroundColor Yellow
    exit 1
}

# Show versions
$typstVersionFull = (typst --version) -replace "typst ", "" -replace " \(.*\)", ""
Write-Host "Using pandoc $pandocVersionRaw with Typst $typstVersionFull" -ForegroundColor Cyan
Write-Host ""

# Create output directory if it doesn't exist
if (-not (Test-Path $OutputDir)) {
    New-Item -ItemType Directory -Path $OutputDir | Out-Null
    Write-Host "Created output directory: $OutputDir" -ForegroundColor Green
}

# Get markdown files to process
$markdownFiles = @()

if (Test-Path $InputPath -PathType Container) {
    # Directory input
    Write-Host "Searching for markdown files in: $InputPath" -ForegroundColor Cyan
    
    if ($Recursive) {
        $markdownFiles = Get-ChildItem -Path $InputPath -Filter "*.md" -Recurse -File
    }
    else {
        $markdownFiles = Get-ChildItem -Path $InputPath -Filter "*.md" -File
    }
}
elseif (Test-Path $InputPath -PathType Leaf) {
    # Single file input
    if ($InputPath -match '\.md$') {
        $markdownFiles = @(Get-Item $InputPath)
    }
    else {
        Write-Host "ERROR: Input file is not a markdown file (.md)" -ForegroundColor Red
        exit 1
    }
}
else {
    Write-Host "ERROR: Input path not found: $InputPath" -ForegroundColor Red
    exit 1
}

if ($markdownFiles.Count -eq 0) {
    Write-Host "No markdown files found." -ForegroundColor Yellow
    exit 0
}

Write-Host "Found $($markdownFiles.Count) markdown file(s)" -ForegroundColor Cyan
Write-Host ""

# Process each markdown file
$successCount = 0
$failCount = 0

foreach ($mdFile in $markdownFiles) {
    # Generate output filename
    $pdfFileName = [System.IO.Path]::GetFileNameWithoutExtension($mdFile.Name) + ".pdf"
    $pdfPath = Join-Path $OutputDir $pdfFileName
    
    # Convert
    if (Convert-MarkdownToPdf -MarkdownFile $mdFile.FullName -OutputFile $pdfPath) {
        $successCount++
    }
    else {
        $failCount++
    }
}

# Summary
Write-Host ""
Write-Host "=== Conversion Complete ===" -ForegroundColor Yellow
Write-Host "Successful: $successCount" -ForegroundColor Green
Write-Host "Failed: $failCount" -ForegroundColor $(if ($failCount -gt 0) { "Red" } else { "Gray" })
Write-Host "Output directory: $OutputDir" -ForegroundColor Cyan
