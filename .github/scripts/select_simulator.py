import json
import subprocess
import sys


def main():
    listing = subprocess.run(
        ["xcrun", "simctl", "list", "devices", "available", "--json"],
        capture_output=True,
        text=True,
        check=True,
    )
    candidates = []
    for runtime, devices in json.loads(listing.stdout)["devices"].items():
        suffix = runtime.rsplit(".", 1)[-1]
        if not suffix.startswith("iOS-"):
            continue
        version = tuple(int(part) for part in suffix.removeprefix("iOS-").split("-"))
        candidates += [
            (version, device["name"])
            for device in devices
            if device["name"].startswith("iPhone")
        ]
    if not candidates:
        sys.exit("No available iPhone simulator found")
    newest = max(version for version, _ in candidates)
    name = min(name for version, name in candidates if version == newest)
    os_version = ".".join(str(part) for part in newest)
    print(f"platform=iOS Simulator,name={name},OS={os_version}")


if __name__ == "__main__":
    main()
