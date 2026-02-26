# 變更紀錄

此檔案將記錄本專案的所有重大變更。

格式基於 [Keep a Changelog](https://keepachangelog.com/zh-CN/1.0.0/)，
並且本專案遵循 [語意化版本 (Semantic Versioning)](https://semver.org/lang/zh-TW/)。

## [未發布]

## [2026-02-26] - 統一架構 v1.1.0

### 變更
- **統一架構 (Unified Architecture)**：所有 7 個插件已重構為統一架構：
    - **英文 SKILL.md**：AI 始終載入，採用簡潔指令風格 (terse directive style)。
    - **references/ + prompts/**：按需載入 (Glob + Read 模式)，減少 Context 佔用。
    - **docs/GUIDE.zh-TW.md**：新增繁體中文人類使用指南。
- **插件版本更新**：
    - `ddd-core` 更新至 1.1.0
    - `git-nanny` 更新至 1.1.0
    - `reviewer` 更新至 1.1.0
    - `spec-to-md` 更新至 1.1.0
    - `md-to-code` 更新至 1.1.0
    - `explorer` 更新至 1.1.0
    - `dev-team` 更新至 2.1.0

### 新增
- **效能優化**：
    - 7 個 SKILL.md 總行數從約 3,055 行減少至約 912 行 (-70%)。
    - 引入按需載入機制，現在共有 18 個按需載入檔案。
    - 為每個插件新增獨立的 `GUIDE.zh-TW.md` 使用指南。

## [1.0.0] - 初始發布

### 新增
- TouchFish-Skills 插件組初始發布。
- 包含插件：`ddd-core`, `git-nanny`, `reviewer`, `spec-to-md`, `md-to-code`, `explorer`, `dev-team`。
