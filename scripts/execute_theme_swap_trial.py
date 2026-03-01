#!/usr/bin/env python3
"""Execute a safe theme swap trial for PPTX files.

Strategy: keep source deck content intact and only replace theme1.xml
using a template PPTX/THMX theme payload.
"""
from __future__ import annotations

import argparse
import datetime as dt
from pathlib import Path
import zipfile


def read_theme_xml(template_file: Path) -> bytes:
    if not zipfile.is_zipfile(template_file):
        raise SystemExit(f"Template is not a valid Office package: {template_file}")
    with zipfile.ZipFile(template_file) as zf:
        names = set(zf.namelist())
        candidates = [
            "ppt/theme/theme1.xml",  # pptx template
            "theme/theme/theme1.xml",  # thmx commonly uses /theme/
            "theme1.xml",
        ]
        for c in candidates:
            if c in names:
                return zf.read(c)
    raise SystemExit("Could not find theme1.xml in template package")


def theme_swap(source_file: Path, template_file: Path, output_file: Path) -> dict:
    if not zipfile.is_zipfile(source_file):
        raise SystemExit(f"Source is not a valid PPTX package: {source_file}")

    theme_xml = read_theme_xml(template_file)

    replaced = False
    output_file.parent.mkdir(parents=True, exist_ok=True)

    with zipfile.ZipFile(source_file) as src, zipfile.ZipFile(output_file, "w", compression=zipfile.ZIP_DEFLATED) as out:
        names = src.namelist()
        for name in names:
            data = src.read(name)
            if name == "ppt/theme/theme1.xml":
                data = theme_xml
                replaced = True
            out.writestr(name, data)

        if not replaced:
            out.writestr("ppt/theme/theme1.xml", theme_xml)

    return {
        "source": str(source_file),
        "template": str(template_file),
        "output": str(output_file),
        "replaced_existing_theme": replaced,
    }


def write_report(report_file: Path, result: dict) -> None:
    now = dt.datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    lines = [
        "# 主题替换试跑报告",
        "",
        f"- 时间：{now}",
        f"- 源文件：`{result['source']}`",
        f"- 模板文件：`{result['template']}`",
        f"- 输出文件：`{result['output']}`",
        f"- 是否覆盖原主题：{result['replaced_existing_theme']}",
        "",
        "## 说明",
        "",
        "- 本次为安全试跑：仅替换 `ppt/theme/theme1.xml`，不改文字/图片/视频资源。",
        "- 动画、切换、视频对象结构保持源文件不变。",
        "- 如需进一步贴合模板版式，仍建议在 PowerPoint 中执行版式微调。",
    ]
    report_file.parent.mkdir(parents=True, exist_ok=True)
    report_file.write_text("\n".join(lines), encoding="utf-8")


def main() -> int:
    p = argparse.ArgumentParser()
    p.add_argument("--source", required=True)
    p.add_argument("--template", required=True)
    p.add_argument("--output", required=True)
    p.add_argument("--report", required=True)
    args = p.parse_args()

    result = theme_swap(Path(args.source), Path(args.template), Path(args.output))
    write_report(Path(args.report), result)
    print(f"Created: {result['output']}")
    print(f"Report: {args.report}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
