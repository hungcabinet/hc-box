#!/usr/bin/env python3
"""Generate surgical hungcabinet android patches against clients/android.

Run from the repository root (or anywhere):
  python patches/hungcabinet/android/generate_patches.py

Requires a clean clients/android checkout matching the intended base.
"""

from __future__ import annotations

import difflib
import pathlib
import re

HERE = pathlib.Path(__file__).resolve().parent
ROOT = HERE.parents[2]
ANDROID = ROOT / "clients/android"
PATCHES_DIR = HERE / "patches"


def unified(rel: str, old: str, new: str) -> str:
    diff = difflib.unified_diff(
        old.splitlines(keepends=True),
        new.splitlines(keepends=True),
        fromfile=f"a/{rel}",
        tofile=f"b/{rel}",
        lineterm="\n",
        n=3,
    )
    text = "".join(diff)
    if not text.endswith("\n"):
        text += "\n"
    return text


def ensure_nl(text: str) -> str:
    return text if text.endswith("\n") else text + "\n"


def edit_build(text: str) -> str:
    text2, n = re.subn(
        r'applicationId\s*=\s*"[^"]+"',
        'applicationId = "com.hungcabinet.box"',
        text,
        count=1,
    )
    assert n == 1, "applicationId not found"
    return text2


def edit_app_settings(text: str) -> str:
    text2, n = re.subn(
        r'\n(\s*)"fdroid"\s+to\s+stringResource\(R\.string\.update_source_fdroid\),\s*\n',
        "\n",
        text,
        count=1,
    )
    assert n == 1, "fdroid update source line not found"
    return text2


def edit_settings(text: str) -> str:
    text2, n = re.subn(
        r"https://github.com/SagerNet/sing-box-for-android",
        "https://github.com/hungcabinet/hc-box",
        text,
        count=1,
    )
    assert n == 1, "SagerNet android github URL not found"
    return text2


def edit_vendor(text: str) -> str:
    text2, n = re.subn(
        r"override val updateSources = listOf\(UpdateSource\.GITHUB,\s*UpdateSource\.FDROID\)",
        "override val updateSources = listOf(UpdateSource.GITHUB)",
        text,
        count=1,
    )
    assert n == 1, "updateSources line not found"
    return text2


def edit_github(text: str) -> str:
    text2, n = re.subn(
        r"https://api\.github\.com/repos/SagerNet/sing-box/releases",
        "https://api.github.com/repos/hungcabinet/hc-box/releases",
        text,
        count=1,
    )
    assert n == 1, "SagerNet releases URL not found"
    return text2


ITEMS = [
    ("0001-application-id.patch", "app/build.gradle.kts", edit_build),
    (
        "0002-remove-fdroid-update-source.patch",
        "app/src/main/java/io/nekohasekai/sfa/compose/screen/settings/AppSettingsScreen.kt",
        edit_app_settings,
    ),
    (
        "0003-settings-github-url.patch",
        "app/src/main/java/io/nekohasekai/sfa/compose/screen/settings/SettingsScreen.kt",
        edit_settings,
    ),
    (
        "0004-vendor-github-only.patch",
        "app/src/other/java/io/nekohasekai/sfa/vendor/Vendor.kt",
        edit_vendor,
    ),
    (
        "0005-github-releases-url.patch",
        "app/src/github/java/io/nekohasekai/sfa/vendor/GitHubUpdateChecker.kt",
        edit_github,
    ),
]


def main() -> None:
    if not ANDROID.is_dir():
        raise SystemExit(f"missing {ANDROID}")

    PATCHES_DIR.mkdir(parents=True, exist_ok=True)
    for old in PATCHES_DIR.glob("*.patch"):
        old.unlink()

    for name, rel, editor in ITEMS:
        src = ANDROID / rel
        old = ensure_nl(src.read_text(encoding="utf-8"))
        new = ensure_nl(editor(old))
        patch = unified(rel, old, new)
        if not patch.strip():
            raise SystemExit(f"empty patch for {rel}")
        out = PATCHES_DIR / name
        out.write_text(patch, encoding="utf-8", newline="\n")
        print(f"wrote {out.relative_to(ROOT)} ({len(patch.splitlines())} lines)")

    print("DONE")


if __name__ == "__main__":
    main()
