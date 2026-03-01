# GitHub执行与复用手册（面向后续多项目复用）

> 适用场景：你把“原始PPT + 模板文件”放到GitHub仓库后，希望我按同一套方法反复执行，最后你只做少量微调。

## 1. 推荐仓库结构

```text
.
├── README.md
├── PPT换模版执行SOP.md
├── PPT换模版代执行说明.md
├── GitHub执行与复用手册.md
├── scripts/
│   └── start_ppt_migration_run.sh
├── templates/
│   ├── run-config.template.yaml
│   └── checklist.template.md
└── runs/
    └── <run-id>/
        ├── input/
        ├── work/
        ├── output/
        ├── run-config.yaml
        └── checklist.md
```

## 2. 你每次只需要做的事情

1. 提交两个文件到某个 run：
   - `runs/<run-id>/input/source.pptx`
   - `runs/<run-id>/input/theme.thmx`（或 `theme.pptx`）
2. 填写 `runs/<run-id>/run-config.yaml` 的关键字段：
   - 中文目标字体
   - 英文目标字体
   - SmartArt页码
   - 视频页码
   - 复杂动画页码
3. 在 issue/消息里告诉我 run-id，我就按该 run 执行。

## 3. 我执行时的标准流程

- 阶段A：10页试点（先确认视觉方向）
- 阶段B：全量分批（每批15~20页）
- 阶段C：风险页专项（SmartArt/视频/动画）
- 阶段D：终检与交付（双份PPT + 交付说明）

## 4. 复用建议（避免后续返工）

- 字体策略固化：在 `templates/run-config.template.yaml` 里固定默认字体。
- 验收统一：所有项目都复用 `checklist.template.md`。
- 版本管理：每次交付打 tag（如 `delivery-clientA-20260301-v1`）。
- 大文件管理：建议启用 Git LFS 存储PPT与视频。

## 5. 你提到的“以后类似需求复用资料”如何落地

建议把这四类资料长期保留在仓库：

1. SOP（操作路径级）
2. 代执行说明（边界与验收）
3. run 配置模板（参数化）
4. checklist 模板（质检与交付）

这样每次只换输入文件和配置，就能复用同一流程。
