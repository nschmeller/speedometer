import re
import subprocess
import sys


def main():
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
        check=True,
    )
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
    if not candidates:
        sys.exit(f"No eligible iPhone simulator destination in:\n{listing.stdout}")
    newest = max(version for version, _, _ in candidates)
    version, name, identifier = min(c for c in candidates if c[0] == newest)
    os_version = ".".join(str(part) for part in version)
    print(f"Selected: {name} (iOS {os_version})", file=sys.stderr)
    print(f"platform=iOS Simulator,id={identifier}")


if __name__ == "__main__":
    main()
