#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

INPUT_FILE="main.tex"
THESIS_DIR="$REPO_ROOT/docs/thesis"
ENGINE="auto"
KEEP_INTERMEDIATES=0
CLEAN_ONLY=0

INTERMEDIATE_PATTERNS=(
  "*.aux"
  "*.bbl"
  "*.blg"
  "*.bcf"
  "*.dvi"
  "*.fdb_latexmk"
  "*.fls"
  "*.idx"
  "*.ilg"
  "*.ind"
  "*.lof"
  "*.log"
  "*.lot"
  "*.nav"
  "*.out"
  "*.run.xml"
  "*.snm"
  "*.synctex.gz"
  "*.synctex(busy)"
  "*.toc"
  "*.vrb"
  "*.xdv"
  "*.acn"
  "*.acr"
  "*.alg"
  "*.glg"
  "*.glo"
  "*.gls"
  "*.ist"
  "*.loa"
  "*.lol"
)

usage() {
  cat <<EOF
Usage: $(basename "$0") [OPTIONS]

Compiles the LaTeX thesis inside the thesis directory and cleans intermediate
build artifacts unless --keep-intermediates is passed.

Options:
  --input <file>          Main .tex file relative to --thesis-dir (default: main.tex)
  --thesis-dir <dir>      Path to the LaTeX thesis directory (default: <repo>/docs/thesis)
  --engine <engine>       LaTeX engine: auto|latexmk|tectonic|pdflatex|xelatex|lualatex
                          (default: auto)
  --keep-intermediates    Keep intermediate LaTeX files after compilation
  --clean-only            Only remove intermediate files without compiling
  -h, --help              Show this help message and exit 0

Auto-detection order (--engine auto):
  1. latexmk (only if both latexmk and perl are in PATH)
  2. tectonic
  3. pdflatex
  4. xelatex
  5. lualatex
EOF
}

die() {
  echo "Error: $*" >&2
  exit 1
}

has_cmd() {
  command -v "$1" >/dev/null 2>&1
}

print_install_hints() {
  cat >&2 <<'EOF'
No supported LaTeX engine was found in PATH.

Install one of the following toolchains:
  - Tectonic (recommended, lightweight):
      macOS:   brew install tectonic
      Linux:   https://tectonic-typesetting.github.io/
  - TeX Live (includes pdflatex, xelatex, lualatex, latexmk):
      macOS:   brew install --cask mactex-no-gui
      Linux:   sudo apt install texlive-full   (or texlive-latex-extra)
  - MiKTeX:
      https://miktex.org/download
EOF
}

detect_engine() {
  if has_cmd latexmk && has_cmd perl; then
    echo "latexmk"
  elif has_cmd tectonic; then
    echo "tectonic"
  elif has_cmd pdflatex; then
    echo "pdflatex"
  elif has_cmd xelatex; then
    echo "xelatex"
  elif has_cmd lualatex; then
    echo "lualatex"
  else
    return 1
  fi
}

validate_requested_engine() {
  local eng="$1"
  case "$eng" in
    latexmk)
      if ! has_cmd latexmk; then
        print_install_hints
        die "Requested engine 'latexmk' was not found in PATH."
      fi
      if ! has_cmd perl; then
        die "Requested engine 'latexmk' requires 'perl' in PATH, but perl was not found."
      fi
      ;;
    tectonic|pdflatex|xelatex|lualatex)
      if ! has_cmd "$eng"; then
        print_install_hints
        die "Requested engine '$eng' was not found in PATH."
      fi
      ;;
    *)
      die "Unsupported engine '$eng'. Allowed: auto, latexmk, tectonic, pdflatex, xelatex, lualatex."
      ;;
  esac
}

clean_intermediates() {
  local target_dir="$1"
  local find_args=()
  local pattern
  local count=0
  local file

  for pattern in "${INTERMEDIATE_PATTERNS[@]}"; do
    if [[ ${#find_args[@]} -gt 0 ]]; then
      find_args+=("-o")
    fi
    find_args+=("-name" "$pattern")
  done

  while IFS= read -r -d '' file; do
    rm -f -- "$file"
    count=$((count + 1))
  done < <(find "$target_dir" -type f \( "${find_args[@]}" \) -print0)

  echo "$count"
}

run_tex_compiler() {
  local eng="$1"
  local input_file="$2"
  local jobname="$3"

  case "$eng" in
    latexmk)
      latexmk -pdf -interaction=nonstopmode -halt-on-error "$input_file" || return $?
      ;;
    tectonic)
      if [[ "$KEEP_INTERMEDIATES" -eq 1 ]]; then
        tectonic -k --keep-logs --outdir . "$input_file" || return $?
      else
        tectonic --outdir . "$input_file" || return $?
      fi
      ;;
    pdflatex|xelatex|lualatex)
      "$eng" -interaction=nonstopmode -halt-on-error "$input_file" || return $?
      if [[ -f "${jobname}.aux" ]] && grep -q '\\bibdata' "${jobname}.aux" && has_cmd bibtex; then
        bibtex "$jobname" || return $?
      fi
      "$eng" -interaction=nonstopmode -halt-on-error "$input_file" || return $?
      "$eng" -interaction=nonstopmode -halt-on-error "$input_file" || return $?
      ;;
    *)
      echo "Unsupported engine: $eng" >&2
      return 1
      ;;
  esac
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --input)
      [[ $# -ge 2 ]] || die "Missing value for --input"
      INPUT_FILE="$2"
      shift 2
      ;;
    --thesis-dir)
      [[ $# -ge 2 ]] || die "Missing value for --thesis-dir"
      THESIS_DIR="$2"
      shift 2
      ;;
    --engine)
      [[ $# -ge 2 ]] || die "Missing value for --engine"
      ENGINE="$2"
      shift 2
      ;;
    --keep-intermediates)
      KEEP_INTERMEDIATES=1
      shift
      ;;
    --clean-only)
      CLEAN_ONLY=1
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      die "Unknown option: $1 (use --help for usage)"
      ;;
  esac
done

case "$ENGINE" in
  auto|latexmk|tectonic|pdflatex|xelatex|lualatex) ;;
  *)
    die "Invalid --engine '$ENGINE'. Allowed: auto, latexmk, tectonic, pdflatex, xelatex, lualatex."
    ;;
esac

[[ -d "$THESIS_DIR" ]] || die "Thesis directory does not exist: $THESIS_DIR"
THESIS_DIR="$(cd "$THESIS_DIR" && pwd)"

if [[ "$CLEAN_ONLY" -eq 1 ]]; then
  removed_count="$(clean_intermediates "$THESIS_DIR")"
  echo "Cleanup complete in '$THESIS_DIR': removed $removed_count intermediate file(s)."
  exit 0
fi

[[ -f "$THESIS_DIR/$INPUT_FILE" ]] || die "Input file not found: $THESIS_DIR/$INPUT_FILE"

if [[ "$ENGINE" == "auto" ]]; then
  if ! SELECTED_ENGINE="$(detect_engine)"; then
    print_install_hints
    exit 1
  fi
else
  validate_requested_engine "$ENGINE"
  SELECTED_ENGINE="$ENGINE"
fi

JOBNAME="$(basename "${INPUT_FILE%.tex}")"
LOG_FILE="$THESIS_DIR/${JOBNAME}.log"
PDF_FILE="$THESIS_DIR/${JOBNAME}.pdf"

echo "Building thesis..."
echo "  Thesis dir : $THESIS_DIR"
echo "  Input file : $INPUT_FILE"
echo "  Engine     : $SELECTED_ENGINE"

build_status=0
(
  cd "$THESIS_DIR"
  run_tex_compiler "$SELECTED_ENGINE" "$INPUT_FILE" "$JOBNAME"
) || build_status=$?

if [[ "$build_status" -ne 0 ]]; then
  echo "Compilation failed with exit code $build_status." >&2
  if [[ -f "$LOG_FILE" ]]; then
    echo "Last 40 lines of '$LOG_FILE' (preserved for debugging):" >&2
    tail -n 40 "$LOG_FILE" >&2 || true
  else
    echo "No log file found at '$LOG_FILE'." >&2
  fi
  exit "$build_status"
fi

if [[ "$KEEP_INTERMEDIATES" -eq 1 ]]; then
  cleanup_summary="kept intermediate files (--keep-intermediates)"
else
  removed_count="$(clean_intermediates "$THESIS_DIR")"
  cleanup_summary="removed $removed_count intermediate file(s)"
fi

echo "Build succeeded."
echo "  Output PDF : $PDF_FILE"
echo "  Cleanup    : $cleanup_summary"
