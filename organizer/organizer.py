import argparse
import hashlib
import json
import os
import shutil
import tempfile
from collections import defaultdict
from datetime import datetime
from pathlib import Path

from PIL import Image, ExifTags

CATEGORIES = {
    "Photos": {".jpg", ".jpeg", ".png", ".heic", ".webp", ".gif", ".dng"},
    "Videos": {".mp4", ".mov", ".avi", ".mkv", ".webm", ".3gp"},
    "Documents": {".pdf", ".doc", ".docx", ".txt", ".rtf", ".odt"},
    "Spreadsheets": {".xlsx", ".xls", ".csv", ".ods"},
    "Presentations": {".ppt", ".pptx", ".odp"},
    "Projects": {".py", ".js", ".ts", ".html", ".css", ".java", ".json", ".sql"},
    "Archives": {".zip", ".rar", ".7z", ".tar", ".gz"},
    "Audio": {".mp3", ".wav", ".flac", ".m4a", ".aac"},
}
PROTECTED_FOLDERS = {".venv", "config", "reports", "tests", ".git"}
TEMP_PREFIX, TEMP_SUFFIX = ".ark_", ".tmp"


def is_reparse_point(path):
    """Treat symlinks and Windows junctions as unsafe traversal points."""
    try:
        attributes = path.stat(follow_symlinks=False).st_file_attributes
    except (AttributeError, FileNotFoundError, OSError):
        return path.is_symlink()
    return path.is_symlink() or bool(attributes & 0x400)


def assert_no_reparse_points(path, label):
    current = Path(path.anchor)
    for part in path.parts[1:]:
        current /= part
        if current.exists() and is_reparse_point(current):
            raise SystemExit(f"{label} contains a symlink or junction: {current}")


def classify(path):
    if "screenshot" in path.name.lower() or "screen_shot" in path.name.lower():
        return "Screenshots"
    return next((category for category, extensions in CATEGORIES.items()
                 if path.suffix.lower() in extensions), "Other")


def file_hash(path):
    sha = hashlib.sha256()
    with path.open("rb") as file:
        for chunk in iter(lambda: file.read(1024 * 1024), b""):
            sha.update(chunk)
    return sha.hexdigest()


def capture_date(path):
    if path.suffix.lower() in {".jpg", ".jpeg", ".webp", ".png"}:
        try:
            with Image.open(path) as image:
                for tag, value in image.getexif().items():
                    if ExifTags.TAGS.get(tag) == "DateTimeOriginal":
                        return datetime.strptime(str(value), "%Y:%m:%d %H:%M:%S")
        except (OSError, ValueError, TypeError):
            pass
    return None


def destination_for(path, category):
    if category in {"Photos", "Videos", "Screenshots"}:
        date = capture_date(path)
        return (Path(category) / str(date.year) / f"{date.month:02d}" / path.name
                if date else Path(category) / "Undated" / path.name)
    return Path(category) / path.name


def scan_folder(source):
    files = []
    for path in source.rglob("*"):
        if is_reparse_point(path) or not path.is_file():
            continue
        if any(part.lower() in PROTECTED_FOLDERS for part in path.relative_to(source).parts):
            continue
        files.append(path)
    return sorted(files)


def analyze(source, destination):
    hashes, targets, results = defaultdict(list), defaultdict(list), []
    for path in scan_folder(source):
        category, relative_destination, digest = classify(path), None, file_hash(path)
        relative_destination = destination_for(path, category)
        target = destination / relative_destination
        action = ("SKIP_ALREADY_COPIED" if target.is_file() and file_hash(target) == digest
                  else "SKIP_EXISTS_DIFFERENT" if target.exists() else "PREVIEW_ONLY")
        hashes[digest].append(str(path))
        targets[str(relative_destination).lower()].append(str(path))
        results.append({"source": str(path), "category": category, "destination": str(relative_destination),
                        "size_bytes": path.stat().st_size, "sha256": digest, "action": action})
    duplicates = [paths for paths in hashes.values() if len(paths) > 1]
    conflicts = {name: paths for name, paths in targets.items() if len(paths) > 1}
    duplicate_sources = {path for group in duplicates for path in group}
    conflict_sources = {path for group in conflicts.values() for path in group}
    for item in results:
        if item["action"] == "PREVIEW_ONLY":
            item["action"] = ("SKIP_CONFLICT" if item["source"] in conflict_sources else
                              "SKIP_DUPLICATE" if item["source"] in duplicate_sources else "PREVIEW_ONLY")
    return {"generated_at": datetime.now().isoformat(), "source_directory": str(source),
            "destination_directory": str(destination), "total_files": len(results),
            "duplicate_groups": duplicates, "destination_conflicts": conflicts, "files": results, "mode": "DRY_RUN"}


def find_interrupted_copies(destination):
    return [] if not destination.exists() else [str(path) for path in destination.rglob(f"{TEMP_PREFIX}*{TEMP_SUFFIX}")
            if path.is_file() and not is_reparse_point(path)]


def write_report(report, result):
    """Atomically replace the report after each completed file."""
    report.parent.mkdir(parents=True, exist_ok=True)
    with tempfile.NamedTemporaryFile("w", encoding="utf-8", dir=report.parent, prefix=".ark_report_", suffix=".tmp", delete=False) as temp:
        temp_path = Path(temp.name)
        json.dump(result, temp, indent=2)
        temp.flush()
        os.fsync(temp.fileno())
    try:
        os.replace(temp_path, report)
    finally:
        temp_path.unlink(missing_ok=True)


def copy_safely(source, destination, expected_hash):
    """Verified temp copy followed by no-overwrite publish; originals are untouched."""
    assert_no_reparse_points(destination.parent, "Destination")
    destination.parent.mkdir(parents=True, exist_ok=True)
    assert_no_reparse_points(destination.parent, "Destination")
    temp_path = None
    try:
        if file_hash(source) != expected_hash:
            return "SKIP_CHANGED"
        with tempfile.NamedTemporaryFile("wb", dir=destination.parent, prefix=TEMP_PREFIX, suffix=TEMP_SUFFIX, delete=False) as temp:
            temp_path = Path(temp.name)
            with source.open("rb") as src:
                shutil.copyfileobj(src, temp)
            temp.flush()
            os.fsync(temp.fileno())
        if file_hash(source) != expected_hash or file_hash(temp_path) != expected_hash:
            return "SKIP_CHANGED"
        # On Windows, rename refuses to replace an existing destination. Because
        # the temporary file is in the same directory, this is an atomic publish.
        os.rename(temp_path, destination)
        return "COPIED"
    except FileExistsError:
        return "SKIP_EXISTS"
    finally:
        if temp_path is not None:
            temp_path.unlink(missing_ok=True)


def validate_paths(source, destination, report):
    for path, label in ((source, "Source"), (destination, "Destination"), (report, "Report")):
        if path == Path(path.anchor):
            raise SystemExit(f"{label} cannot be a drive root.")
        assert_no_reparse_points(path, label)
    if not source.is_dir():
        raise SystemExit(f"Source directory does not exist: {source}")
    if source == destination or source.is_relative_to(destination) or destination.is_relative_to(source):
        raise SystemExit("Source and destination must be separate, non-overlapping directories.")
    if report.is_relative_to(source) or report.is_relative_to(destination):
        raise SystemExit("Keep the report outside the source and destination directories.")


def main():
    parser = argparse.ArgumentParser(description="ARK Smart Organizer")
    parser.add_argument("--source", required=True)
    parser.add_argument("--report", required=True)
    parser.add_argument("--destination", required=True)
    parser.add_argument("--apply", action="store_true", help="Copy verified files; never delete originals.")
    args = parser.parse_args()
    source, destination, report = (Path(value).resolve() for value in (args.source, args.destination, args.report))
    validate_paths(source, destination, report)
    result = analyze(source, destination)
    result["interrupted_copies"] = find_interrupted_copies(destination)
    if args.apply and result["interrupted_copies"]:
        result["mode"] = "BLOCKED_INTERRUPTED_COPY"
        write_report(report, result)
        raise SystemExit("SAFETY STOP: Interrupted temporary copies were found. Review them before retrying.")
    if args.apply:
        result["mode"] = "COPY"
        write_report(report, result)
        for item in result["files"]:
            if item["action"] != "PREVIEW_ONLY":
                continue
            try:
                item["action"] = copy_safely(Path(item["source"]), destination / item["destination"], item["sha256"])
            except OSError as error:
                item["action"] = f"ERROR: {error}"
            write_report(report, result)
    else:
        write_report(report, result)
    print("ARK Smart Organizer")
    print(f"Mode: {result['mode']}")
    print(f"Files scanned: {result['total_files']}")
    print(f"Duplicate groups: {len(result['duplicate_groups'])}")
    print(f"Destination conflicts: {len(result['destination_conflicts'])}")
    print(f"Report: {report}")
    print("Copy operation complete. Original files were not deleted." if args.apply else "Dry run only. No files were copied or moved.")


if __name__ == "__main__":
    main()
