#!/bin/sh
# Open a Processing sketch in the IDE and report whether the sketch process started.
#
# Does NOT press Run. Does NOT compile. Opening the editor is not running the sketch.
# Exits 0 when the IDE process is up, 1 when it is not.
set -eu

usage() {
  cat <<'EOF'
usage: run.sh [--status] [sketch-dir]

  --status      report only, open nothing
  sketch-dir    the sketch folder (default: current directory)
EOF
}

status_only=0
sketch=""

while [ $# -gt 0 ]; do
  case "$1" in
    --status) status_only=1 ;;
    -h|--help) usage; exit 0 ;;
    -*) echo "unknown option: $1" >&2; usage >&2; exit 2 ;;
    *) sketch="$1" ;;
  esac
  shift
done

[ -n "$sketch" ] || sketch="."

# macOS translocates the IDE, so match the class not the path.
ide_pid() {
  pgrep -f "Processing.app/Contents/MacOS/Processing" 2>/dev/null | head -1
}

sketch_pid() {
  pgrep -f "processing.core.PApplet" 2>/dev/null | head -1
}

sketch_path_of() {
  ps -o args= -p "$1" 2>/dev/null | tr ' ' '\n' \
    | sed -n 's/^--sketch-path=//p' | head -1
}

report() {
  ide=$(ide_pid || true)
  sk=$(sketch_pid || true)

  printf 'IDE      %s\n' "${ide:-not running}"
  if [ -n "$ide" ]; then
    printf '         %s\n' "$(ps -o args= -p "$ide" 2>/dev/null | tr ' ' '\n' | head -1)"
  fi

  printf 'sketch   %s\n' "${sk:-not running}"
  if [ -n "$sk" ]; then
    printf '         path %s\n' "$(sketch_path_of "$sk" || echo unknown)"
  else
    printf '         no sketch process. Nothing is running. Run is a human button.\n'
  fi
}

if [ "$status_only" -eq 1 ]; then
  report
  [ -n "$(ide_pid || true)" ]
  exit $?
fi

if [ ! -d "$sketch" ]; then
  echo "not a directory: $sketch" >&2
  exit 1
fi

sketch=$(cd "$sketch" && pwd)

name=$(basename "$sketch")
main_tab="$sketch/$name.pde"

if [ ! -f "$main_tab" ]; then
  printf 'MAIN TAB MISMATCH\n'
  printf '  the sketch folder is named "%s" but %s does not exist.\n' "$name" "$name.pde"
  printf '  the Processing IDE will not open this sketch. Rename the folder or the main tab so\n'
  printf '  they match. Renaming is the owner'"'"'s call, not this skill'"'"'s.\n'
  exit 1
fi

tabs=$(find "$sketch" -maxdepth 1 -name '*.pde' | wc -l | tr -d ' ')

if [ ! -d "$sketch/data" ]; then
  printf 'DATA     no data/ folder. loadFont and loadImage will fail at startup.\n'
fi

printf 'sketch   %s (%s tabs)\n' "$sketch" "$tabs"

open -a Processing "$sketch"
sleep 3

if ide_pid >/dev/null 2>&1; then
  printf 'IDE      open. Press Run to compile and launch.\n'
  printf '        Nothing has been compiled and nothing is running.\n'
  printf '        /check-deps resolves the libraries first if this is a fresh machine.\n'
  report
  exit 0
fi

printf 'IDE      failed to open\n'
exit 1