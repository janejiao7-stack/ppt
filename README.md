# PPT 模板替换执行仓库（可复用）

本仓库用于处理「**原始PPT + 目标模板PPT/THMX**」的换模版执行项目，目标是：

- 内容不改（文字/数据/图片本体不改）。
- 版式允许微调。
- 保留切换、对象动画、嵌入视频。
- SmartArt保持可编辑（不转形状）。

## 一次性搭建后，后续项目复用方法

1. 新建一个项目运行目录（run）。
2. 把两个PPT文件放进 run 目录。
3. 填写该 run 的配置文件（字体映射、页数、风险页等）。
4. 按文档执行试点10页 -> 批量处理 -> 终检 -> 交付。

## 快速开始

```bash
bash scripts/start_ppt_migration_run.sh \
  --run-id clientA-20260301 \
  --source-file source.pptx \
  --theme-file theme.thmx
```

执行后会自动生成：

- `runs/<run-id>/input/`：放源文件与模板
- `runs/<run-id>/output/`：交付产物
- `runs/<run-id>/work/`：工作中间文件
- `runs/<run-id>/run-config.yaml`：本次项目配置
- `runs/<run-id>/checklist.md`：执行与验收清单


## 先跑“小样评估”

如果你已上传源PPT和模板文件，可先跑一次结构干跑报告：

```bash
bash scripts/run_ppt_migration_dryrun.sh \
  --run-id trial-001 \
  --source path/to/source.pptx \
  --theme path/to/theme.thmx
```

输出报告：`runs/<run-id>/work/dryrun-report.md`。


## 直接执行（你上传两个PPT后）

```bash
bash scripts/execute_theme_swap_trial.sh \
  --run-id trial-live \
  --source path/to/old.pptx \
  --template path/to/template.pptx
```

输出：

- `runs/<run-id>/output/trial_theme_swapped.pptx`
- `runs/<run-id>/work/theme-swap-report.md`

> 该命令会先做“安全试跑”：仅替换主题XML（`theme1.xml`），尽量保留原始内容、动画、视频结构，便于你先看效果再微调。


## 自动扫描并执行（无需手填路径）

如果你已把两个文件放在仓库目录（任意子目录），可直接运行：

```bash
bash scripts/execute_uploaded_trial.sh run-001
```

会在项目内生成：

- `runs/run-001/work/execution-report.md`
- 若检测到输入并执行成功，还会生成 `runs/run-001/output/trial_theme_swapped.pptx`


## 配置 GitHub origin（首次同步必做）

如果本地仓库还没有 `origin`，先执行：

```bash
bash scripts/configure_origin.sh https://github.com/janejiao7-stack/ppt.git main
```

执行后可验证：

```bash
git remote -v
git fetch origin --prune
```

## 文档索引

- `PPT换模版执行SOP.md`：详细执行流程（操作级）。
- `PPT换模版代执行说明.md`：边界、交付、验收说明。
- `GitHub执行与复用手册.md`：如何在GitHub长期复用与协作。

## 说明

本仓库当前提供的是**可复用流程与执行骨架**。如需实际产出目标PPT，请先将源PPT和模板文件加入对应 run 的 `input/` 目录，再按清单执行。
