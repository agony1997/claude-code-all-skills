# Explorer + Dev-Team Skills 實作計畫

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** 新增兩個 skill plugin（explorer 和 dev-team）到 touchfish-skills 專案

**Architecture:** 每個 skill 是獨立的 plugin，包含 plugin.json 和 SKILL.md。explorer 用 sub-agents 並行探索 + Opus leader 審視；dev-team 用混合 teammates/sub-agents 的流水線大團隊模式。

**Tech Stack:** Claude Code Skills（SKILL.md YAML frontmatter + Markdown workflow）、Agent Teams API（TeamCreate, SendMessage, Task）

**設計文件：** `docs/plans/2026-02-25-explorer-and-dev-team-design.md`

---

### Task 1: 建立 explorer plugin 目錄結構

**Files:**
- Create: `plugins/explorer/.claude-plugin/plugin.json`

**Step 1: 建立 plugin.json**

```json
{
  "version": "1.0.0",
  "name": "explorer",
  "description": "專案探索者：Opus Leader 指揮 sub-agents 並行探索，交叉比對後產出專案地圖",
  "author": {
    "name": "Custom Skills"
  },
  "skills": [
    "./skills/explorer"
  ]
}
```

**Step 2: 驗證目錄結構**

Run: `ls -la plugins/explorer/.claude-plugin/`
Expected: 看到 plugin.json

**Step 3: Commit**

```bash
git add plugins/explorer/.claude-plugin/plugin.json
git commit -m "chore(explorer): scaffold plugin directory structure"
```

---

### Task 2: 撰寫 explorer SKILL.md

**Files:**
- Create: `plugins/explorer/skills/explorer/SKILL.md`
- Reference: `docs/plans/2026-02-25-explorer-and-dev-team-design.md` Section 2

**Step 1: 撰寫 SKILL.md**

SKILL.md 必須包含以下章節，內容依據設計文件 Section 2：

```markdown
---
name: explorer
description: >
  專案探索者：使用 Opus Leader 指揮多個 sub-agents 並行探索專案結構，
  交叉比對後產出結構化的專案地圖文件（PROJECT_MAP.md）。
  支援單體、多模組、monorepo 等專案類型的智慧偵測與分工。
  使用時機：接手新專案、了解專案架構、產出專案地圖、實作前收集上下文。
  關鍵字：explore, 探索, 偵察, 專案地圖, project map, codebase,
  了解專案, 專案結構, 探索專案, 分析架構, architecture, 架構分析,
  onboarding, 新人導覽, 專案概覽, 技術棧, tech stack。
---
```

SKILL.md 本文結構：

```
# 專案探索者 (Project Explorer)

## 流程

### Phase 0: 偵測專案類型
  - 讀取根目錄結構
  - 判定專案類型（偵測邏輯偽碼，從設計文件 2.3 搬入）
  - AskUserQuestion 確認判定結果與探索範圍

### Phase 1: 派出探索 sub-agents
  - 根據專案類型決定 sub-agent 數量和分工
  - 每個 sub-agent 的 prompt 模板（含探索指引）
  - 所有 sub-agents 用 Task tool 並行派出（model: sonnet）
  - sub-agent 探索清單：
    ├─ 目錄結構與檔案分類
    ├─ 技術棧辨識（框架、語言、版本）
    ├─ 關鍵檔案索引（進入點、設定檔、路由）
    └─ 模組間依賴關係

### Phase 2: 審視與交叉比對
  - 收回所有 sub-agent 報告
  - 審視檢查清單（從設計文件 2.4 搬入）
  - 審視迴圈：
    ├─ 有明確疑問 → 再派 sub-agent 深入探索
    ├─ 有不確定 → AskUserQuestion 詢問使用者 → 再派 sub-agent
    └─ 無疑慮 → 進入 Phase 3

### Phase 3: 彙整產出
  - PROJECT_MAP.md 模板（從設計文件 2.5 搬入）
  - AskUserQuestion 確認存放位置
  - 寫入檔案，向使用者呈現摘要
```

**Step 2: 審閱 SKILL.md**

自行通讀一遍，確認：
- [ ] frontmatter 的 description 和 name 正確
- [ ] 所有 Phase 都有明確的步驟和工具指示
- [ ] sub-agent prompt 模板完整
- [ ] 審視檢查清單完整
- [ ] PROJECT_MAP.md 模板完整
- [ ] 沒有遺漏設計文件中的任何要點

**Step 3: Commit**

```bash
git add plugins/explorer/skills/explorer/SKILL.md
git commit -m "feat(explorer): add project explorer skill with sub-agent parallel exploration"
```

---

### Task 3: 建立 dev-team plugin 目錄結構

**Files:**
- Create: `plugins/dev-team/.claude-plugin/plugin.json`

**Step 1: 建立 plugin.json**

```json
{
  "version": "1.0.0",
  "name": "dev-team",
  "description": "開發團隊：多角色流水線協作（PM/開發者/QA），動態規模，混合 teammates + sub-agents",
  "author": {
    "name": "Custom Skills"
  },
  "skills": [
    "./skills/dev-team"
  ]
}
```

**Step 2: 驗證目錄結構**

Run: `ls -la plugins/dev-team/.claude-plugin/`
Expected: 看到 plugin.json

**Step 3: Commit**

```bash
git add plugins/dev-team/.claude-plugin/plugin.json
git commit -m "chore(dev-team): scaffold plugin directory structure"
```

---

### Task 4: 撰寫 dev-team SKILL.md

**Files:**
- Create: `plugins/dev-team/skills/dev-team/SKILL.md`
- Reference: `docs/plans/2026-02-25-explorer-and-dev-team-design.md` Section 3

**Step 1: 撰寫 SKILL.md**

SKILL.md 必須包含以下章節，內容依據設計文件 Section 3：

```markdown
---
name: dev-team
description: >
  開發團隊：多角色流水線協作，由 Team Lead（Opus）充當 PM，
  指揮 explore-leader、pg-leader、qa-leader（均 Opus）分組運作。
  pg 組 workers 用 teammates（Sonnet）支援互相協調，
  explore/qa 組 workers 用 sub-agents（Sonnet）獨立執行。
  支援動態規模調整、API 契約優先、流水線開發與審查。
  使用時機：需要多角色團隊協作完成功能開發、全流程開發。
  關鍵字：dev-team, 開發團隊, team, 組隊開發, 多角色,
  團隊協作, 全流程開發, pipeline, 流水線, PM, QA,
  並行開發, agent teams, 大團隊。
---
```

SKILL.md 本文結構：

```
# 開發團隊 (Dev Team)

## 團隊架構

（從設計文件 3.2 搬入架構圖）
- Team Lead (Opus) — PM
- explore-leader (Opus) + sub-agents (Sonnet)
- pg-leader (Opus) + teammates (Sonnet)
- qa-leader (Opus) + sub-agents (Sonnet)

## Model 選擇指引

（從設計文件 3.4 搬入表格）

## 流程

### Phase 0: 專案偵察
  - 判斷 explorer skill 是否已安裝
  - 已安裝 → 呼叫 explorer skill（獨立執行，完成後才繼續）
  - 未安裝 → TL 自行簡易掃描

### Phase 1: 需求分析與任務規劃（TL 獨立執行）
  - 閱讀使用者需求
  - 參考 PROJECT_MAP.md
  - TaskCreate 拆分任務 + 定義依賴
  - AskUserQuestion 確認任務清單 + 驗收標準

### Phase 2: API 契約定義（TL 獨立執行）
  - 產出 API_CONTRACT.md 的模板和指引
  - AskUserQuestion 確認契約
  - 契約變更規則

### Phase 3: 組建團隊
  - TeamCreate: "dev-<專案名>-<功能名>"
  - Spawn Leaders（全部 Opus）
  - pg-leader 評估任務量 → spawn pg workers（teammates, Sonnet）
  - 動態規模範例（從設計文件 3.3 搬入）
  - TL 指派高層任務給 Leaders

### Phase 3+4: 流水線開發與審查
  - 流水線運作機制說明（從設計文件搬入）
  - pg-leader 管理開發 workers
  - qa-leader 派 sub-agents 審查已完成任務
  - 問題回饋 → 修正任務 → 重新審查
  - 中途追加 worker 的機制

### Phase 5: 契約一致性驗證
  - qa-leader 的最終檢查清單
  - 不一致 → 回到流水線
  - 一致 → 通過

### Phase 6: 交付
  - TL 彙整交付報告
  - TeamDelete 關閉團隊
  - 不自動 commit/push

## 溝通協議

### 溝通規則
  （從設計文件 3.6 搬入允許/禁止路徑）

### Agent Spawn Prompt 模板
  - Leader prompt 模板（含角色、職責、溝通對象）
  - Worker prompt 模板（含角色、上級、溝通對象）

### Worker 行為準則
  （從設計文件搬入，嵌入每個 Worker 的 spawn prompt）

### 任務指派鏈範例
  （從設計文件 3.6 搬入）
```

**Step 2: 審閱 SKILL.md**

自行通讀一遍，確認：
- [ ] frontmatter 的 description 和 name 正確
- [ ] 團隊架構圖清楚
- [ ] 所有 Phase 都有明確步驟和工具指示
- [ ] 溝通協議完整（允許/禁止路徑、prompt 模板）
- [ ] Worker 行為準則完整嵌入
- [ ] 動態規模範例清楚
- [ ] 流水線機制說明清楚
- [ ] API 契約模板完整
- [ ] 沒有遺漏設計文件中的任何要點

**Step 3: Commit**

```bash
git add plugins/dev-team/skills/dev-team/SKILL.md
git commit -m "feat(dev-team): add dev team skill with pipeline pattern and mixed agents"
```

---

### Task 5: 更新 marketplace.json

**Files:**
- Modify: `.claude-plugin/marketplace.json`

**Step 1: 在 plugins 陣列末尾新增兩個 plugin**

在 md-to-code 之後加入：

```json
,
{
  "name": "explorer",
  "source": "./plugins/explorer",
  "description": "專案探索者：Opus Leader 指揮 sub-agents 並行探索，交叉比對後產出專案地圖",
  "tags": ["explore", "project-map", "codebase", "architecture", "agent-teams"]
},
{
  "name": "dev-team",
  "source": "./plugins/dev-team",
  "description": "開發團隊：多角色流水線協作（PM/開發者/QA），動態規模，混合 teammates + sub-agents",
  "tags": ["team", "agent-teams", "pipeline", "pm", "qa", "development"]
}
```

**Step 2: 更新 marketplace.json 的 description 和 version**

- description: `"摸魚技能集：7 個工作流型 Claude Code 插件"`（從 5 改為 7）
- version: `"5.0.0"`（新增 2 個 plugin 屬於 MAJOR 變更）

**Step 3: 驗證 JSON 格式**

Run: `python -c "import json; json.load(open('.claude-plugin/marketplace.json'))"`
Expected: 無報錯

**Step 4: Commit**

```bash
git add .claude-plugin/marketplace.json
git commit -m "feat(marketplace): add explorer and dev-team plugins, bump to v5.0.0"
```

---

### Task 6: 最終驗證

**Step 1: 驗證所有 plugin 目錄結構完整**

Run: `find plugins/ -name "*.md" -o -name "*.json" | sort`

Expected: 看到 7 個 plugin 的完整結構，包含：
```
plugins/explorer/.claude-plugin/plugin.json
plugins/explorer/skills/explorer/SKILL.md
plugins/dev-team/.claude-plugin/plugin.json
plugins/dev-team/skills/dev-team/SKILL.md
```

**Step 2: 驗證 marketplace.json 列出 7 個 plugins**

Run: `python -c "import json; data=json.load(open('.claude-plugin/marketplace.json')); print(len(data['plugins']), 'plugins'); [print(f'  - {p[\"name\"]}') for p in data['plugins']]"`

Expected:
```
7 plugins
  - ddd-core
  - git-nanny
  - reviewer
  - spec-to-md
  - md-to-code
  - explorer
  - dev-team
```

**Step 3: 確認 git 狀態乾淨**

Run: `git status && git log --oneline -6`

Expected: working tree clean，看到 Task 1-5 的 5 個 commits

---

## 注意事項

- SKILL.md 是純 Markdown 工作流文件，**不是程式碼**，所以不適用 TDD
- 撰寫 SKILL.md 時，務必對照設計文件逐條搬入，不要遺漏
- 每個 Phase 都必須有明確的工具呼叫指示（Task, TeamCreate, SendMessage, AskUserQuestion 等）
- 保持與現有 5 個 skill 的風格一致（繁體中文、YAML frontmatter 含關鍵字）
- explorer 和 dev-team 都是獨立 plugin，互不依賴（dev-team 對 explorer 是軟依賴）
