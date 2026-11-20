<#
.SYNOPSIS
Compiles the LaTeX thesis and optionally cleans intermediate build files.

.DESCRIPTION
Builds the LaTeX document located in the thesis directory (default: docs\thesis)
using an automatically detected or explicitly selected TeX engine. By default,
intermediate files are removed recursively after a successful build; on failure,
the .log file is preserved and its trailing lines are displayed for debugging.

Compatible with both Windows PowerShell 5.1 and PowerShell 7+ (pwsh).

.PARAMETER InputFile
Main .tex file to compile, relative to ThesisDir. Defaults to "main.tex".

.PARAMETER ThesisDir
Path to the directory containing the LaTeX thesis sources.
Defaults to "<repo-root>\docs\thesis".

.PARAMETER Engine
LaTeX engine to use: auto, latexmk, tectonic, pdflatex, xelatex, or lualatex.
Defaults to "auto", which checks in order:
1) latexmk (only if perl is also in PATH)
2) tectonic
3) pdflatex
4) xelatex
5) lualatex

.PARAMETER KeepIntermediates
Keep intermediate LaTeX files after successful compilation.

.PARAMETER CleanOnly
Only delete intermediate LaTeX files inside ThesisDir without compiling.

.PARAMETER Help
Display usage help and exit with code 0.

.EXAMPLE
.\scripts\build-thesis.ps1
Compiles main.tex in docs\thesis with the auto-detected engine and cleans intermediates.

.EXAMPLE
.\scripts\build-thesis.ps1 -KeepIntermediates
Compiles main.tex and preserves .aux, .log, .bbl, and other intermediate files.

.EXAMPLE
.\scripts\build-thesis.ps1 -CleanOnly
Deletes intermediate LaTeX files in docs\thesis without compiling.

.EXAMPLE
.\scripts\build-thesis.ps1 -Engine tectonic -InputFile main.tex
Forces compilation using Tectonic.
#>
[CmdletBinding()]
param(
    [string]$InputFile = "main.tex",
    [string]$ThesisDir = "",
    [ValidateSet("auto", "latexmk", "tectonic", "pdflatex", "xelatex", "lualatex")]
    [string]$Engine = "auto",
    [switch]$KeepIntermediates,
    [switch]$CleanOnly,
    [switch]$Help
)

$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

if ($Help) {
    $scriptPath = $MyInvocation.MyCommand.Path
    if ($scriptPath -and (Test-Path -LiteralPath $scriptPath)) {
        Get-Help -Full $scriptPath
    }
    else {
        Write-Output "Usage: build-thesis.ps1 [-InputFile <file>] [-ThesisDir <dir>] [-Engine <auto|latexmk|tectonic|pdflatex|xelatex|lualatex>] [-KeepIntermediates] [-CleanOnly] [-Help]"
    }
    exit 0
}

$IntermediateSuffixes = @(
    ".aux",
    ".bbl",
    ".blg",
    ".bcf",
    ".dvi",
    ".fdb_latexmk",
    ".fls",
    ".idx",
    ".ilg",
    ".ind",
    ".lof",
    ".log",
    ".lot",
    ".nav",
    ".out",
    ".run.xml",
    ".snm",
    ".synctex.gz",
    ".synctex(busy)",
    ".toc",
    ".vrb",
    ".xdv",
    ".acn",
    ".acr",
    ".alg",
    ".glg",
    ".glo",
    ".gls",
    ".ist",
    ".loa",
    ".lol"
)

function Test-CommandExists {
    param([Parameter(Mandatory = $true)][string]$Name)
    return [bool](Get-Command -Name $Name -ErrorAction SilentlyContinue)
}

function Write-InstallHints {
    Write-Host "No supported LaTeX engine was found in PATH." -ForegroundColor Red
    Write-Host ""
    Write-Host "Install one of the following toolchains:"
    Write-Host "  - Tectonic (recommended, lightweight): winget install Tectonic.Tectonic  (or brew install tectonic)"
    Write-Host "  - MiKTeX:                              https://miktex.org/download"
    Write-Host "  - TeX Live:                            https://tug.org/texlive/"
}

function Resolve-AutoEngine {
    if ((Test-CommandExists -Name "latexmk") -and (Test-CommandExists -Name "perl")) {
        return "latexmk"
    }
    foreach ($candidate in @("tectonic", "pdflatex", "xelatex", "lualatex")) {
        if (Test-CommandExists -Name $candidate) {
            return $candidate
        }
    }
    return $null
}

function Remove-IntermediateFiles {
    param([Parameter(Mandatory = $true)][string]$TargetDir)

    $removed = 0
    $files = @(Get-ChildItem -LiteralPath $TargetDir -Recurse -File)
    foreach ($file in $files) {
        $shouldRemove = $false
        foreach ($suffix in $IntermediateSuffixes) {
            if ($file.Name.EndsWith($suffix, [System.StringComparison]::OrdinalIgnoreCase)) {
                $shouldRemove = $true
                break
            }
        }
        if ($shouldRemove) {
            Remove-Item -LiteralPath $file.FullName -Force
            $removed++
        }
    }
    return $removed
}

function Invoke-NativeChecked {
    param(
        [Parameter(Mandatory = $true)][string]$Command,
        [Parameter(Mandatory = $true)][string[]]$Arguments
    )

    & $Command @Arguments
    if ($LASTEXITCODE -ne 0) {
        throw "Command '$Command $($Arguments -join ' ')' failed with exit code $LASTEXITCODE."
    }
}

if ([string]::IsNullOrWhiteSpace($ThesisDir)) {
    $ThesisDir = Join-Path (Split-Path -Parent $PSScriptRoot) (Join-Path "docs" "thesis")
}

if (-not (Test-Path -LiteralPath $ThesisDir -PathType Container)) {
    Write-Error "Thesis directory does not exist: $ThesisDir"
    exit 1
}

$resolvedThesisDir = (Resolve-Path -LiteralPath $ThesisDir).Path

if ($CleanOnly) {
    $removedCount = Remove-IntermediateFiles -TargetDir $resolvedThesisDir
    Write-Host "Cleanup complete in '$resolvedThesisDir': removed $removedCount intermediate file(s)."
    exit 0
}

$inputFullPath = Join-Path $resolvedThesisDir $InputFile
if (-not (Test-Path -LiteralPath $inputFullPath -PathType Leaf)) {
    Write-Error "Input file not found: $inputFullPath"
    exit 1
}

$selectedEngine = $Engine
if ($selectedEngine -eq "auto") {
    $selectedEngine = Resolve-AutoEngine
    if (-not $selectedEngine) {
        Write-InstallHints
        exit 1
    }
}
else {
    if (-not (Test-CommandExists -Name $selectedEngine)) {
        Write-InstallHints
        Write-Error "Requested engine '$selectedEngine' was not found in PATH."
        exit 1
    }
    if (($selectedEngine -eq "latexmk") -and (-not (Test-CommandExists -Name "perl"))) {
        Write-Error "Requested engine 'latexmk' requires 'perl' in PATH, but perl was not found."
        exit 1
    }
}

$jobName = [System.IO.Path]::GetFileNameWithoutExtension($InputFile)
$logPath = Join-Path $resolvedThesisDir "$jobName.log"
$pdfPath = Join-Path $resolvedThesisDir "$jobName.pdf"

Write-Host "Building thesis..."
Write-Host "  Thesis dir : $resolvedThesisDir"
Write-Host "  Input file : $InputFile"
Write-Host "  Engine     : $selectedEngine"

$buildFailed = $false
$failureMessage = ""

Push-Location -LiteralPath $resolvedThesisDir
try {
    switch ($selectedEngine) {
        "latexmk" {
            Invoke-NativeChecked -Command "latexmk" -Arguments @("-pdf", "-interaction=nonstopmode", "-halt-on-error", $InputFile)
        }
        "tectonic" {
            if ($KeepIntermediates) {
                Invoke-NativeChecked -Command "tectonic" -Arguments @("-k", "--keep-logs", "--outdir", ".", $InputFile)
            }
            else {
                Invoke-NativeChecked -Command "tectonic" -Arguments @("--outdir", ".", $InputFile)
            }
        }
        { $_ -in @("pdflatex", "xelatex", "lualatex") } {
            $texArgs = @("-interaction=nonstopmode", "-halt-on-error", $InputFile)
            Invoke-NativeChecked -Command $selectedEngine -Arguments $texArgs

            $auxPath = Join-Path $resolvedThesisDir "$jobName.aux"
            if ((Test-Path -LiteralPath $auxPath -PathType Leaf) -and (Test-CommandExists -Name "bibtex")) {
                $auxContent = Get-Content -LiteralPath $auxPath -Raw
                if ($auxContent -and $auxContent.Contains("\bibdata")) {
                    Invoke-NativeChecked -Command "bibtex" -Arguments @($jobName)
                }
            }

            Invoke-NativeChecked -Command $selectedEngine -Arguments $texArgs
            Invoke-NativeChecked -Command $selectedEngine -Arguments $texArgs
        }
    }
}
catch {
    $buildFailed = $true
    $failureMessage = $_.Exception.Message
}
finally {
    Pop-Location
}

if ($buildFailed) {
    Write-Host "Compilation failed: $failureMessage" -ForegroundColor Red
    if (Test-Path -LiteralPath $logPath -PathType Leaf) {
        Write-Host "Last 40 lines of '$logPath' (preserved for debugging):" -ForegroundColor Yellow
        Get-Content -LiteralPath $logPath -Tail 40
    }
    else {
        Write-Host "No log file found at '$logPath'." -ForegroundColor Yellow
    }
    exit 1
}

if ($KeepIntermediates) {
    $cleanupSummary = "kept intermediate files (-KeepIntermediates)"
}
else {
    $removedCount = Remove-IntermediateFiles -TargetDir $resolvedThesisDir
    $cleanupSummary = "removed $removedCount intermediate file(s)"
}

Write-Host "Build succeeded." -ForegroundColor Green
Write-Host "  Output PDF : $pdfPath"
Write-Host "  Cleanup    : $cleanupSummary"
