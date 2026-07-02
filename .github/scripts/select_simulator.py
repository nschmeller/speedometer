import glob
import os
import re
import subprocess
import sys


def destinations(xcode):
    try:
        listing = subprocess.run(
            [
                "xcodebuild",
                "-showdestinations",
                "-project",
                "Speedometer.xcodeproj",
                "-scheme",
                "Speedometer",
            ],
            capture_output=True,
            text=True,
            timeout=120,
            env={**os.environ, "DEVELOPER_DIR": f"{xcode}/Contents/Developer"},
        )
    except subprocess.TimeoutExpired:
        return []
    if listing.returncode != 0:
        return []
    eligible = listing.stdout.split("Ineligible destinations")[0]
    candidates = []
    for chunk in re.findall(r"\{([^}]*)\}", eligible):
        fields = dict(
            part.strip().split(":", 1) for part in chunk.split(",") if ":" in part
        )
        if (
            fields.get("platform") != "iOS Simulator"
            or "OS" not in fields
            or not fields.get("name", "").startswith("iPhone")
        ):
            continue
        version = tuple(int(part) for part in fields["OS"].split("."))
        candidates.append((version, fields["name"], fields["id"]))
    return candidates


def xcode_version(path):
    return tuple(int(part) for part in re.findall(r"\d+", os.path.basename(path)))


def main():
    xcodes = sorted(glob.glob("/Applications/Xcode_*.app"), key=xcode_version, reverse=True)
    if not xcodes:
        sys.exit("No Xcode installations found")
    for xcode in xcodes:
        candidates = destinations(xcode)
        if not candidates:
            print(f"{xcode}: no eligible iPhone simulator destination", file=sys.stderr)
            continue
        newest = max(version for version, _, _ in candidates)
        version, name, identifier = min(c for c in candidates if c[0] == newest)
        os_version = ".".join(str(part) for part in version)
        print(f"Selected {xcode} with {name} (iOS {os_version})", file=sys.stderr)
        print(f"developer_dir={xcode}/Contents/Developer")
        print(f"destination=platform=iOS Simulator,id={identifier}")
        return
    sys.exit("No Xcode installation has an eligible iPhone simulator destination")


if __name__ == "__main__":
    main()
