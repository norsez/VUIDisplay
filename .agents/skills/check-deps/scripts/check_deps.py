#!/usr/bin/env python3
"""Resolve every explicit import in a Processing sketch against core.jar and the sketchbook.

Exits 0 when every import resolves, 1 when any does not, 2 on a usage problem.

This proves the sketch's libraries are installed. It does not compile, preprocess, or
type-check anything. Do not report it as a build.
"""

from __future__ import annotations

import argparse
import json
import os
import re
import sys
import zipfile
from pathlib import Path

# Processing injects these into every sketch. Never reported.
DEFAULT_IMPORT_ROOTS = {"processing", "java", "javax", "com.sun", "sun", "apple"}

# core.jar is found by scanning Processing.app rather than hardcoding a revision path.
PROCESSING_GLOBS = [
    "/Applications/Processing.app/Contents/Java/core/library/core.jar",
    "~/Applications/Processing.app/Contents/Java/core/library/core.jar",
]

SKETCHBOOK_GLOBS = [
    "~/Documents/Processing/libraries",
    "~/Documents/Processing4/libraries",
]

IMPORT_RE = re.compile(r"^\s*import\s+(?:static\s+)?([\w.]+)(?:\.\*)?\s*;", re.MULTILINE)

SKETCH_GLOBS = [
    "~/Library/Preferences/Processing",
    "~/Documents/Processing",
]


def expand(paths: list[str]) -> list[Path]:
    found: list[Path] = []
    for pattern in paths:
        expanded = Path(os.path.expanduser(pattern))
        if expanded.is_file():
            found.append(expanded)
            continue
        # A glob-shaped parent (…/libraries/*/library) needs the wildcard handled by the shell.
        if "*" in pattern:
            base, _, tail = pattern.partition("*")
            root = Path(os.path.expanduser(base))
            if not root.is_dir():
                continue
            suffix = Path(tail.lstrip("/")) if tail else Path()
            found.extend(sorted(root.glob("**/" + str(suffix)) if str(suffix) else root.glob("*/*")))
        elif expanded.is_dir():
            found.append(expanded)
    return found


def find_core_jar() -> Path | None:
    for candidate in expand(PROCESSING_GLOBS):
        if candidate.name == "core.jar":
            return candidate
    # Fall back to a scan of any Processing install that is present.
    for root in ("/Applications/Processing.app", "~/Applications/Processing.app"):
        base = Path(os.path.expanduser(root))
        if not base.is_dir():
            continue
        hits = sorted(base.glob("**/core/library/core.jar"))
        if hits:
            return hits[0]
    return None


def find_sketchbook() -> Path | None:
    for candidate in expand(SKETCHBOOK_GLOBS):
        if candidate.is_dir():
            return candidate
    return None


def package_index(jars: list[Path]) -> dict[str, str]:
    """Map top-level package name -> jar that contains it.

    A library jar declares its own package (controlP5.jar -> controlP5). Some jars also carry
    embedded packages belonging to no separate library (VideoExport.jar -> com.hamoid), so index
    every top-level package each jar holds. That is what stops com.hamoid reading as missing.
    """
    index: dict[str, str] = {}
    for jar in jars:
        try:
            with zipfile.ZipFile(jar) as zf:
                names = zf.namelist()
        except (OSError, zipfile.BadZipFile):
            continue
        roots: set[str] = set()
        pairs: set[str] = set()
        for name in names:
            if not name.endswith(".class"):
                continue
            parts = name.split("/")
            if len(parts) >= 2:
                roots.add(parts[0])
                # Two segments deep is enough to tell com.hamoid from a bare com.
                pairs.add(".".join(parts[:2]))
            elif len(parts) == 1:
                # Default-package class, e.g. for a jar of top-level types.
                roots.add("<default>")
        # First segment drives resolution. Two segments drive the report, so 'com.hamoid'
        # is named rather than a bare 'com'.
        for root in roots:
            index.setdefault(root, jar.name)
        for pair in pairs:
            index.setdefault(pair, jar.name)
    return index


def best_match(root: str, statement: str, index: dict[str, str]) -> tuple[str, str]:
    """Name the most specific package that matched, for a readable report.

    'com' alone is uninformative. 'com.hamoid' tells the owner exactly which jar carries it,
    which is the question they need answered to install the right library.
    """
    # The statement is stored as "<file>: <import>", so anchor on the import, not the line start.
    match = re.search(r"\bimport\s+(?:static\s+)?([\w.]+)\.\*\s*;", statement)
    if match:
        package = match.group(1)
        if package in index:
            return package, index[package]
    return root, index[root]


def explicit_imports(pde_files: list[Path]) -> dict[str, list[str]]:
    found: dict[str, list[str]] = {}
    for pde in pde_files:
        try:
            text = pde.read_text(encoding="utf-8", errors="replace")
        except OSError:
            continue
        for match in IMPORT_RE.finditer(text):
            statement = match.group(0).strip()
            root = match.group(1).split(".")[0]
            found.setdefault(root, []).append(f"{pde.name}: {statement}")
    return found


def main() -> int:
    parser = argparse.ArgumentParser(
        description="Resolve a Processing sketch's imports against core.jar and the sketchbook."
    )
    parser.add_argument("--sketch", default=".", help="sketch folder (default: current directory)")
    parser.add_argument("--json", action="store_true", help="emit JSON instead of text")
    args = parser.parse_args()

    sketch = Path(args.sketch).expanduser().resolve()
    if not sketch.is_dir():
        print(f"error: not a directory: {sketch}", file=sys.stderr)
        return 2

    pde_files = sorted(sketch.glob("*.pde"))
    if not pde_files:
        print(f"error: no .pde files in {sketch}", file=sys.stderr)
        return 2

    main_tab = sketch / f"{sketch.name}.pde"
    name_note = None
    if not main_tab.exists():
        name_note = (
            f"the sketch folder is '{sketch.name}' but '{main_tab.name}' does not exist; "
            "the Processing IDE will not open this sketch"
        )

    core = find_core_jar()
    sketchbook = find_sketchbook()
    jars: list[Path] = []
    if core:
        jars.append(core)
    if sketchbook:
        for library_dir in sorted(sketchbook.glob("*/library")):
            jars.extend(sorted(library_dir.glob("*.jar")))

    index = package_index(jars)

    imports = explicit_imports(pde_files)
    unresolved: dict[str, list[str]] = {}
    resolved: dict[str, tuple[str, str]] = {}
    default_root_hits: list[str] = []

    for root, statements in sorted(imports.items()):
        if root in DEFAULT_IMPORT_ROOTS:
            default_root_hits.append(root)
            continue
        if root in index:
            resolved[root] = best_match(root, statements[0], index)
        else:
            unresolved[root] = statements

    if args.json:
        print(json.dumps({
            "sketch": str(sketch),
            "pde_files": len(pde_files),
            "core_jar": str(core) if core else None,
            "sketchbook": str(sketchbook) if sketchbook else None,
            "library_jars": len(jars),
            "resolved": resolved,
            "default_import_roots": sorted(default_root_hits),
            "unresolved": unresolved,
            "main_tab_note": name_note,
            "proves": "libraries present on this machine",
            "does_not_prove": "the sketch compiles, or that its code type-checks",
        }, indent=2, sort_keys=True))
        return 1 if unresolved or name_note else 0

    print(f"sketch        {sketch}")
    print(f"tabs          {len(pde_files)} .pde files")
    print(f"core.jar      {core if core else 'NOT FOUND'}")
    print(f"sketchbook    {sketchbook if sketchbook else 'NOT FOUND'}")
    print(f"jars indexed  {len(jars)}")

    if name_note:
        print(f"\nMAIN TAB      {name_note}")

    print(f"\nresolved {len(resolved)} import(s):")
    for root in sorted(resolved):
        package, jar = resolved[root]
        print(f"  {package:<28} {jar}")

    if default_root_hits:
        print(f"\ndefault Processing imports, resolved by rule: {', '.join(sorted(default_root_hits))}")

    if unresolved:
        print(f"\nUNRESOLVED {len(unresolved)} import(s):")
        for root in sorted(unresolved):
            print(f"  {root}")
            for statement in unresolved[root]:
                print(f"    {statement}")
        print(
            "\nThese libraries are not installed in the sketchbook. Install them through the "
            "Processing\nContributions Manager (Sketch > Manage Libraries). Do not install them by "
            "script — a jar\nwithout library.properties is invisible to the IDE."
        )
    else:
        print("\nall explicit imports resolve")

    print("\nnote: this does not compile the sketch and does not type-check it.")
    return 1 if unresolved or name_note else 0


if __name__ == "__main__":
    sys.exit(main())