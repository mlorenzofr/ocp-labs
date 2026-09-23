#!/usr/bin/env python3
"""Check latest container component versions and ansible/ansible-lint compatibility."""

from __future__ import annotations

import json
import os
import re
import sys
import urllib.error
import urllib.request
from dataclasses import dataclass
from pathlib import Path


def reexec_in_venv() -> None:
    venv_python = Path(__file__).resolve().parent / ".venv" / "bin" / "python"
    if not venv_python.is_file():
        return
    if Path(sys.executable).resolve() == venv_python.resolve():
        return
    os.execv(str(venv_python), [str(venv_python), *sys.argv])


reexec_in_venv()

from packaging.requirements import Requirement
from packaging.version import Version


@dataclass(frozen=True)
class ComponentVersions:
    alpine: str
    ansible: str
    ansible_lint: str
    community_general: str
    kubectl: str


@dataclass
class CompatibilityResult:
    label: str
    compatible: bool
    compatibility: dict[str, object] | None
    error: str | None


@dataclass
class ValidationResult:
    label: str
    failures: int
    compatibility: CompatibilityResult


def containerfile_path() -> Path:
    return Path(__file__).resolve().parent.parent / "container" / "Containerfile"


def fetch_json(url: str) -> dict:
    try:
        with urllib.request.urlopen(url, timeout=30) as response:
            return json.load(response)
    except urllib.error.URLError as exc:
        raise SystemExit(f"Failed to fetch {url}: {exc}") from exc


def read_containerfile(containerfile: Path) -> ComponentVersions:
    if not containerfile.is_file():
        raise SystemExit(f"Containerfile not found: {containerfile}")

    content = containerfile.read_text(encoding="utf-8")
    patterns = {
        "alpine": r"^FROM alpine:(\S+)",
        "ansible": r"^ENV ANSIBLE_VERSION (\S+)",
        "ansible_lint": r"^ENV ANSIBLE_LINT_VERSION (\S+)",
        "community_general": r"^ENV ANSIBLE_COMM_GENERAL_VERSION (\S+)",
        "kubectl": r"^ENV KUBECTL_VERSION (\S+)",
    }

    values: dict[str, str] = {}
    for key, pattern in patterns.items():
        match = re.search(pattern, content, flags=re.MULTILINE)
        if not match:
            raise SystemExit(f"Could not parse {key} from {containerfile}")
        values[key] = match.group(1)

    return ComponentVersions(**values)


def latest_alpine_version() -> str:
    page = 1
    tags: list[str] = []

    while True:
        payload = fetch_json(
            f"https://hub.docker.com/v2/repositories/library/alpine/tags?page_size=100&page={page}"
        )
        tags.extend(
            item["name"]
            for item in payload.get("results", [])
            if re.fullmatch(r"3\.\d+", item.get("name", ""))
        )
        if payload.get("next") is None:
            break
        page += 1

    if not tags:
        raise SystemExit("Could not determine latest Alpine version")

    return sorted(tags, key=lambda tag: [int(part) for part in tag.split(".")])[-1]


def latest_pypi_version(package: str) -> str:
    payload = fetch_json(f"https://pypi.org/pypi/{package}/json")
    return payload["info"]["version"]


def latest_community_general_version() -> str:
    payload = fetch_json(
        "https://galaxy.ansible.com/api/v3/plugin/ansible/content/published/"
        "collections/index/community/general/versions/?limit=1"
    )
    return payload["data"][0]["version"]


def latest_kubectl_version() -> str:
    with urllib.request.urlopen("https://dl.k8s.io/release/stable.txt", timeout=30) as response:
        version = response.read().decode("utf-8").strip()
    return version.removeprefix("v")


def fetch_latest_versions() -> ComponentVersions:
    return ComponentVersions(
        alpine=latest_alpine_version(),
        ansible=latest_pypi_version("ansible"),
        ansible_lint=latest_pypi_version("ansible-lint"),
        community_general=latest_community_general_version(),
        kubectl=latest_kubectl_version(),
    )


def alpine_tag_exists(version: str) -> bool:
    try:
        payload = fetch_json(f"https://hub.docker.com/v2/repositories/library/alpine/tags/{version}")
    except SystemExit:
        return False
    return payload.get("name") == version


def pypi_package_exists(package: str, version: str) -> bool:
    try:
        payload = fetch_json(f"https://pypi.org/pypi/{package}/{version}/json")
    except SystemExit:
        return False
    return payload.get("info", {}).get("version") == version


def galaxy_collection_exists(version: str) -> bool:
    try:
        payload = fetch_json(
            "https://galaxy.ansible.com/api/v3/plugin/ansible/content/published/"
            f"collections/index/community/general/versions/?version={version}"
        )
    except SystemExit:
        return False
    return any(item.get("version") == version for item in payload.get("data", []))


def kubectl_artifact_exists(version: str) -> bool:
    url = f"https://dl.k8s.io/release/v{version}/bin/linux/amd64/kubectl"
    request = urllib.request.Request(url, method="HEAD")
    try:
        with urllib.request.urlopen(request, timeout=30):
            return True
    except urllib.error.HTTPError:
        return False
    except urllib.error.URLError:
        return False


def fetch_requires_dist(package: str, version: str) -> list[str]:
    payload = fetch_json(f"https://pypi.org/pypi/{package}/{version}/json")
    requires_dist = payload["info"].get("requires_dist") or []
    return [item for item in requires_dist if item]


def ansible_core_spec(requires_dist: list[str], ansible_version: str) -> str:
    for item in requires_dist:
        if item.startswith("ansible-core"):
            return item.split(";", 1)[0].strip()
    raise ValueError(f"ansible {ansible_version} does not declare an ansible-core requirement")


def ansible_lint_core_specs(requires_dist: list[str], lint_version: str) -> list[str]:
    specs = [
        item.split(";", 1)[0].strip()
        for item in requires_dist
        if item.startswith("ansible-core")
    ]
    if not specs:
        raise ValueError(f"ansible-lint {lint_version} does not declare an ansible-core requirement")
    return specs


def parse_core_version(requirement: Requirement) -> str:
    version_match = re.search(r"(\d+\.\d+\.\d+)", str(requirement))
    if not version_match:
        raise ValueError(f"Could not parse ansible-core version from {requirement}")
    return version_match.group(1)


def check_ansible_compatibility(ansible_version: str, ansible_lint_version: str) -> dict[str, object]:
    ansible_requires = fetch_requires_dist("ansible", ansible_version)
    lint_requires = fetch_requires_dist("ansible-lint", ansible_lint_version)

    ansible_core_req = Requirement(ansible_core_spec(ansible_requires, ansible_version))
    lint_core_reqs = [Requirement(spec) for spec in ansible_lint_core_specs(lint_requires, ansible_lint_version)]

    ansible_core_version = parse_core_version(ansible_core_req)
    core_version = Version(ansible_core_version)

    for req in lint_core_reqs:
        if core_version not in req.specifier:
            raise ValueError(
                "ansible-core "
                f"{ansible_core_version} from ansible {ansible_version} does not satisfy "
                f"ansible-lint {ansible_lint_version} requirement ({req})"
            )

    compat_reqs = [
        str(Requirement(item.split(";", 1)[0].strip()))
        for item in lint_requires
        if item.startswith("ansible-compat")
    ]

    return {
        "ansible_core_version": ansible_core_version,
        "ansible_core_requirement": str(ansible_core_req),
        "ansible_lint_core_requirements": [str(req) for req in lint_core_reqs],
        "ansible_compat_requirements": compat_reqs,
    }


def validate_component_set(label: str, versions: ComponentVersions) -> ValidationResult:
    failures = 0

    checks = [
        alpine_tag_exists(versions.alpine),
        pypi_package_exists("ansible", versions.ansible),
        pypi_package_exists("ansible-lint", versions.ansible_lint),
        galaxy_collection_exists(versions.community_general),
        kubectl_artifact_exists(versions.kubectl),
    ]
    failures += sum(1 for ok in checks if not ok)

    compatibility_result: CompatibilityResult
    try:
        compatibility = check_ansible_compatibility(versions.ansible, versions.ansible_lint)
        compatibility_result = CompatibilityResult(
            label=label,
            compatible=True,
            compatibility=compatibility,
            error=None,
        )
    except ValueError as exc:
        failures += 1
        compatibility_result = CompatibilityResult(
            label=label,
            compatible=False,
            compatibility=None,
            error=str(exc),
        )

    return ValidationResult(
        label=label,
        failures=failures,
        compatibility=compatibility_result,
    )


def print_version_table(containerfile: Path, pinned: ComponentVersions, latest: ComponentVersions) -> None:
    print()
    print(f"Containerfile: {containerfile}")
    print()
    print(f"{'Component':<20} {'Pinned':<15} {'Latest':<15} Status")
    print(f"{'---------':<20} {'------':<15} {'-------':<15} ------")

    rows = [
        ("alpine", pinned.alpine, latest.alpine),
        ("ansible", pinned.ansible, latest.ansible),
        ("ansible-lint", pinned.ansible_lint, latest.ansible_lint),
        ("community.general", pinned.community_general, latest.community_general),
        ("kubectl", pinned.kubectl, latest.kubectl),
    ]

    for name, current, newest in rows:
        status = "updated" if current == newest else "update available"
        print(f"{name:<20} {current:<15} {newest:<15} {status}")


def print_compatibility(result: CompatibilityResult) -> None:
    print()
    print(f"=== {result.label} ===")

    if result.compatible and result.compatibility:
        print("[ok] ansible/ansible-lint ansible-core requirements are compatible")
        print(f"     ansible-core: {result.compatibility['ansible_core_version']}")
        print(f"     ansible requires: {result.compatibility['ansible_core_requirement']}")
        lint_reqs = ", ".join(result.compatibility["ansible_lint_core_requirements"])
        print(f"     ansible-lint requires: {lint_reqs}")
        return

    print("[FAIL] ansible/ansible-lint ansible-core requirements are incompatible")
    if result.error:
        print(f"     {result.error}")


def main() -> int:
    containerfile = containerfile_path()
    pinned = read_containerfile(containerfile)

    print("Fetching latest component versions...")
    latest = fetch_latest_versions()

    results = [
        validate_component_set("Pinned versions", pinned),
        validate_component_set("Latest versions", latest),
    ]
    total_failures = sum(result.failures for result in results)

    print_version_table(containerfile, pinned, latest)
    for result in results:
        print_compatibility(result.compatibility)

    print()
    if total_failures == 0:
        print("All checks passed.")
    else:
        print(f"{total_failures} check group(s) failed.")

    return 1 if total_failures else 0


if __name__ == "__main__":
    sys.exit(main())
