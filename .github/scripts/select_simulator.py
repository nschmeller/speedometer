import glob
import os
import re
import subprocess
import sys

FIELD = re.compile(r"\b(platform|OS|name|id|error):([^,}]+)")


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
            timeout=300,
            env={**os.environ, "DEVELOPER_DIR": f"{xcode}/Contents/Developer"},
        )
    except subprocess.TimeoutExpired:
        print(f"{xcode}: xcodebuild -showdestinations timed out", file=sys.stderr)
        return []
    if listing.returncode != 0:
        print(f"{xcode}: xcodebuild failed:\n{listing.stderr.strip()}", file=sys.stderr)
        return []
    eligible = listing.stdout.split("Ineligible destinations")[0]
    candidates = []
    for chunk in re.findall(r"\{([^}]*)\}", eligible):
        fields = {key: value.strip() for key, value in FIELD.findall(chunk)}
        if (
            fields.get("platform") != "iOS Simulator"
            or "error" in fields
            or "OS" not in fields
            or not fields.get("name", "").startswith("iPhone")
        ):
            continue
        version = tuple(int(part) for part in fields["OS"].split("."))
        candidates.append((version, fields["name"], fields["id"]))
    return candidates


def is_stable(path):
    return re.fullmatch(r"Xcode_[\d.]+\.app", os.path.basename(path)) is not None


def xcode_version(path):
    return tuple(int(part) for part in re.findall(r"\d+", os.path.basename(path)))


def main():
    installed = glob.glob("/Applications/Xcode_*.app")
    if not installed:
        sys.exit("No Xcode installations found")
    stable = [xcode for xcode in installed if is_stable(xcode)]
    prerelease = [xcode for xcode in installed if not is_stable(xcode)]
    ordered = sorted(stable, key=xcode_version, reverse=True) + sorted(
        prerelease, key=xcode_version, reverse=True
    )
    for xcode in ordered:
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
