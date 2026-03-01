#!/usr/bin/env python3
"""Create a dry-run analysis report for source/template PPT files.

This does NOT rewrite slides. It inspects pptx/thmx structure and generates
an execution-ready report to estimate migration effort/risk.
"""
from __future__ import annotations

import argparse
import datetime as dt
from pathlib import Path
import re
import zipfile


def _is_zip(path: Path) -> bool:
    return zipfile.is_zipfile(path)


def _count_files(zf: zipfile.ZipFile, pattern: str) -> int:
    rgx = re.compile(pattern)
    return sum(1 for n in zf.namelist() if rgx.search(n))


def analyze_pptx(path: Path) -> dict:
    if not _is_zip(path):
        raise ValueError(f"Not a valid Office zip container: {path}")

    with zipfile.ZipFile(path) as zf:
        names = zf.namelist()
        slide_count = _count_files(zf, r"^ppt/slides/slide\d+\.xml$")
        video_count = _count_files(zf, r"^ppt/media/.*\.(mp4|mov|wmv|avi|m4v)$")
        image_count = _count_files(zf, r"^ppt/media/.*\.(png|jpg|jpeg|gif|bmp|tif|tiff|webp|emf|wmf)$")
        chart_count = _count_files(zf, r"^ppt/charts/chart\d+\.xml$")

        smartart_count = 0
        for n in names:
            if n.startswith("ppt/slides/") and n.endswith(".xml"):
                data = zf.read(n)
                if b"dgm" in data or b"diagram" in data:
                    smartart_count += 1

        has_transitions = False
        has_animations = False
        for n in names:
            if n.startswith("ppt/slides/") and n.endswith(".xml"):
                data = zf.read(n)
                if b"<p:transition" in data:
                    has_transitions = True
                if b"<p:timing" in data or b"<p:anim" in data:
                    has_animations = True
                if has_transitions and has_animations:
                    break

        return {
            "file": str(path),
            "slides": slide_count,
            "embedded_videos": video_count,
            "images": image_count,
            "charts": chart_count,
            "smartart_like_slides": smartart_count,
            "has_transitions": has_transitions,
            "has_animations": has_animations,
        }


def write_report(report_path: Path, run_id: str, source_stats: dict, theme_file: Path) -> None:
    report_path.parent.mkdir(parents=True, exist_ok=True)
    now = dt.datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    lines = [
        f"# PPT迁移干跑报告（{run_id}）",
        "",
        f"- 生成时间：{now}",
        f"- 源文件：`{source_stats['file']}`",
        f"- 模板文件：`{theme_file}`",
        "",
        "## 源PPT结构扫描",
        "",
        f"- 幻灯片数：**{source_stats['slides']}**",
        f"- 嵌入视频数：**{source_stats['embedded_videos']}**",
        f"- 图片资源数：{source_stats['images']}",
        f"- 图表资源数：{source_stats['charts']}",
        f"- SmartArt疑似页数：{source_stats['smartart_like_slides']}",
        f"- 检测到切换：{source_stats['has_transitions']}",
        f"- 检测到动画：{source_stats['has_animations']}",
        "",
        "## 执行建议（本次可先做小样）",
        "",
        "1. 先抽10页做试点（覆盖视频页/SmartArt页/复杂动画页）。",
        "2. 试点通过后按15~20页分批处理，逐批质检。",
        "3. 最终全量放映检查视频、动画与切换。",
        "",
        "## 注意",
        "",
        "- 当前为结构干跑分析，不会自动改写PPT内容。",
        "- 真正换版执行仍需在PowerPoint环境进行，以确保动画/视频完全保真。",
    ]
    report_path.write_text("\n".join(lines), encoding="utf-8")


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--run-id", required=True)
    parser.add_argument("--source", required=True)
    parser.add_argument("--theme", required=True)
    args = parser.parse_args()

    source = Path(args.source)
    theme = Path(args.theme)

    if not source.exists():
        raise SystemExit(f"Source file not found: {source}")
    if not theme.exists():
        raise SystemExit(f"Theme file not found: {theme}")

    source_stats = analyze_pptx(source)

    out = Path("runs") / args.run_id / "work" / "dryrun-report.md"
    write_report(out, args.run_id, source_stats, theme)
    print(f"Dry-run report generated: {out}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
