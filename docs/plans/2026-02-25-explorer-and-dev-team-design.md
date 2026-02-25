# 設計文件：Explorer + Dev-Team Skills

> 日期：2026-02-25
> 狀態：待實作
> 方案：方案 C（explorer 獨立 + dev-team 內嵌 explorer 作為前置步驟）

---

## 1. 概覽

新增兩個 skill 到 touchfish-skills：

| Skill | 定位 | Agent Teams |
|-------|------|-------------|
| **explorer** | 專案偵察工具 | 智慧混合分工（依專案類型） |
| **dev-team** | 多角色開發團隊 | 大團隊流水線（10+ agents） |

兩者獨立運作，dev-team 可在 Phase 0 呼叫 explorer（先後執行，避免巢狀 Teams）。

---

## 2. Explorer（探索者）

### 2.1 觸發條件

- 關鍵字：explore, 探索, 偵察, 專案地圖, project map, codebase, 了解專案, 專案結構, 探索專案, 分析架構

### 2.2 工作流程

```
Phase 0: 偵測專案類型
  ├─ 讀取根目錄結構、build 檔、package.json 等
  ├─ 判定：單體 / 多模組 / monorepo+共用基礎設施
  └─ 向使用者確認判定結果與探索範圍

Phase 1: 組建探索團隊（Agent Teams）
  ├─ 單體 → backend-explorer + frontend-explorer
  ├─ 多模組 → module-a-explorer + module-b-explorer + ...
  ├─ 混合型 → infra-explorer + module-*-explorer
  └─ TeamCreate: "explore-<專案名>"

Phase 2: 並行探索
  各 explorer 獨立分析負責範圍：
  ├─ 目錄結構與檔案分類
  ├─ 技術棧辨識（框架、語言、版本）
  ├─ 關鍵檔案索引（進入點、設定檔、路由）
  ├─ 模組間依賴關係
  └─ 透過 SendMessage 回報發現

Phase 3: 彙整產出
  ├─ Team lead 彙整各 explorer 報告
  ├─ 產出 PROJECT_MAP.md（存放位置由使用者決定）
  ├─ 關閉團隊（TeamDelete）
  └─ 向使用者呈現摘要
```

### 2.3 智慧混合分工

```
偵測邏輯（偽碼）：

if 根目錄有 packages/ 或 modules/ 或多個 build 檔:
    type = "多模組" 或 "monorepo"
    if 有共用 infra/（docker, k8s, ci）:
        type = "混合型"
        agents = [infra-explorer] + [module-N-explorer for each module]
    else:
        agents = [module-N-explorer for each module]
elif 有明確前後端分離（src/main + src/webapp, 或 server/ + client/）:
    type = "單體"
    agents = [backend-explorer, frontend-explorer]
else:
    type = "單體（簡易）"
    agents = [single-explorer]  # 單一 agent 即可
```

### 2.4 PROJECT_MAP.md 結構

```markdown
# 專案地圖：<專案名>
> 產出時間：YYYY-MM-DD | 探索範圍：<根目錄>

## 專案概覽
- 類型：單體 / 多模組 / monorepo
- 主要語言：Java 17, TypeScript 5.x
- 框架：Spring Boot 3.2, Vue 3.4
- 建置工具：Gradle 8.5, Vite 5.x

## 架構概覽
（高層級的模組/層級關係描述）

## 模組清單（多模組時）
| 模組 | 路徑 | 職責 | 關鍵依賴 |
|------|------|------|----------|

## 後端結構
- 進入點：...
- 分層：Controller → Service → Repository
- 關鍵設定檔：...

## 前端結構
- 進入點：...
- 元件結構：...
- 狀態管理：...
- 路由：...

## 基礎設施
- CI/CD：...
- 容器化：...
- 環境設定：...

## 關鍵檔案索引
| 檔案 | 用途 | 備註 |
|------|------|------|
```

---

## 3. Dev-Team（開發團隊）

### 3.1 觸發條件

- 關鍵字：dev-team, 開發團隊, team, 組隊開發, 多角色, 團隊協作, 全流程開發

### 3.2 團隊架構

```
Team Lead (Opus) — 充當 PM
├── explore-leader (Sonnet)
│   ├── explore-1 (Sonnet/Haiku)
│   ├── explore-2 (Sonnet/Haiku)
│   └── ... (動態調整)
├── pg-leader (Sonnet)
│   ├── pg-1 (Sonnet/Haiku) — backend
│   ├── pg-2 (Sonnet/Haiku) — frontend
│   ├── pg-3 (Sonnet/Haiku) — 其他
│   └── ... (動態調整)
└── qa-leader (Sonnet)
    ├── qa-1 (Sonnet/Haiku)
    ├── qa-2 (Sonnet/Haiku)
    └── ... (動態調整)
```

### 3.3 動態規模調整

- Worker 數量由 TL 或小組長根據任務量動態決定
- 中途可追加 Worker（如發現需要額外處理 i18n → spawn pg-4）
- 小型功能可減少至最低配置（每組 1 worker）

### 3.4 Model 選擇指引

| 層級 | 預設 Model | 說明 |
|------|-----------|------|
| Team Lead | Opus | 決策品質要高：需求分析、契約定義、全局協調 |
| Leader 層 | Sonnet | 需要判斷力：任務拆分、Worker 管理、跨組協調 |
| Worker 層 | 依任務決定 | Haiku：套版、簡單 CRUD、設定檔、樣式調整 |
| | | Sonnet：複雜商業邏輯、架構決策、安全性相關 |

由 Leader 在 spawn Worker 時透過 `model` 參數指定。

### 3.5 工作流程

```
Phase 0: 專案偵察
  ├─ 若已安裝 explorer skill：
  │   ├─ 呼叫 explorer skill
  │   ├─ explorer 建立自己的 Team → 並行探索 → 產出 PROJECT_MAP.md → TeamDelete
  │   └─ explorer team 完整走完並關閉後，才進入 Phase 1
  ├─ 若未安裝 explorer：
  │   └─ TL 自行做簡易專案掃描
  └─ 確認專案地圖

Phase 1: 需求分析與任務規劃（TL 獨立執行）
  ├─ 閱讀使用者需求
  ├─ 參考 PROJECT_MAP.md 了解專案現況
  ├─ 拆分為具體任務（TaskCreate）
  ├─ 定義任務依賴（blockedBy / blocks）
  └─ 向使用者確認任務清單 + 驗收標準

Phase 2: API 契約定義（TL 獨立執行）
  ├─ 根據需求產出 API_CONTRACT.md
  │   ├─ 每個端點：Method, Path, Request, Response, 狀態碼
  │   ├─ 共用型別定義
  │   └─ 錯誤回傳格式
  ├─ 向使用者確認契約
  └─ 契約變更必須經過 TL

Phase 3: 組建團隊（TeamCreate）
  ├─ TeamCreate: "dev-<專案名>-<功能名>"
  ├─ Spawn Leaders: explore-leader, pg-leader, qa-leader
  ├─ 各 Leader 評估任務量後 spawn 適當數量的 Worker
  ├─ TL 將高層任務指派給各 Leader
  └─ 各 Leader 拆分並指派給 Worker

Phase 3+4: 流水線開發與審查（合併執行）
  ┌─ 流水線運作 ────────────────────────────┐
  │                                          │
  │  pg-leader 指派任務給 pg-1, pg-2...      │
  │                                          │
  │  pg-1 完成 Task A                        │
  │    → TaskUpdate completed                │
  │    → pg-leader 通知 qa-leader            │
  │    → qa-leader 指派 qa-1 審查 Task A     │
  │    → pg-1 繼續 Task B                    │
  │                                          │
  │  pg-2 完成 Task C                        │
  │    → qa-leader 指派 qa-2 審查 Task C     │
  │    → pg-2 繼續 Task D                    │
  │                                          │
  │  qa-1 審查 Task A 發現問題               │
  │    → 建立修正任務                        │
  │    → qa-leader 通知 pg-leader            │
  │    → pg-leader 指派 pg-1 修正            │
  │    → qa-1 繼續審查其他任務               │
  │                                          │
  │  中途追加：                               │
  │    pg-leader: "需要額外處理 i18n"         │
  │    → spawn pg-4 (Haiku)                  │
  │                                          │
  └──────────────────────────────────────────┘

Phase 5: 契約一致性驗證
  ├─ qa-leader 做最終的前後端對接檢查：
  │   ├─ 後端實際 API 是否符合契約？
  │   ├─ 前端呼叫是否符合契約？
  │   ├─ Request/Response 格式是否對齊？
  │   └─ 錯誤處理是否一致？
  ├─ 不一致 → 回到流水線修正
  └─ 一致 → 通過

Phase 6: 交付
  ├─ TL 彙整交付報告：
  │   ├─ 完成了什麼
  │   ├─ 修改的檔案清單
  │   ├─ QA 審查結果
  │   └─ 待注意事項
  ├─ 關閉團隊（TeamDelete）
  ├─ 向使用者呈現報告
  └─ （不自動 commit/push，交由使用者決定）
```

### 3.6 溝通協議

#### 溝通規則

```
允許的溝通路徑：
  ✅ TL ↔ explore-leader, pg-leader, qa-leader
  ✅ explore-leader ↔ explore-1, explore-2, ...
  ✅ pg-leader ↔ pg-1, pg-2, pg-3, ...
  ✅ qa-leader ↔ qa-1, qa-2, ...
  ✅ pg-leader ↔ qa-leader（跨組協調）

禁止的溝通路徑：
  ❌ TL → pg-1（不越級指揮）
  ❌ explore-1 → qa-2（不跨組直接溝通）
  ❌ pg-1 → pg-2（同組 worker 透過 leader 協調）
```

#### 每個 Agent 的 Spawn Prompt 必須包含

```
你是 <角色名稱>，隸屬於 <組名>。
- 你的上級：<leader 名稱>（只接受他的指令）
- 你的同事：<同組 worker 列表>（透過 leader 協調）
- 你能直接溝通的對象：<允許清單>
- 不在上述名單的人，不要 SendMessage
```

#### 任務指派鏈

```
TL 建立高層任務：
  "實作員工請假功能 - 後端"  → owner: pg-leader
  "實作員工請假功能 - 前端"  → owner: pg-leader
  "探索專案現況"            → owner: explore-leader

pg-leader 拆分並指派：
  "實作 LeaveRequest Entity" → owner: pg-1
  "實作請假 API endpoints"   → owner: pg-1
  "實作請假表單元件"         → owner: pg-2
  "實作請假列表頁面"         → owner: pg-2

qa-leader 領取已完成任務：
  "審查 LeaveRequest Entity" → owner: qa-1
  "審查請假 API endpoints"   → owner: qa-1
  "審查請假表單元件"         → owner: qa-2
```

### 3.7 效率對比

```
原設計（順序 Phase）：
TL ████████░░░░░░░░░░░░░░░░████
BE ░░░░░░░░████████░░░░░░░░░░░░
FE ░░░░░░░░████████░░░░░░░░░░░░
QA ░░░░░░░░░░░░░░░░████████░░░░
                              總時間 ████████████████████████████

流水線（大團隊重疊）：
TL  ████████░░░░░░░░░░░░████
PG-L ░░░░░░░████████████░░░░
PG-1 ░░░░░░░░████████████░░░
PG-2 ░░░░░░░░████████████░░░
QA-L ░░░░░░░░░░██████████░░░
QA-1 ░░░░░░░░░░░█████████░░░
                        總時間 ████████████████████████

████ = 工作    ░ = 等待/監控
```

---

## 4. 與現有 Skills 的關係

| | 關係 |
|---|---|
| **explorer ↔ 現有 5 skill** | 獨立，產出物（PROJECT_MAP.md）可被任何 skill 參考 |
| **dev-team ↔ 現有 5 skill** | 獨立運作，不依賴也不取代 |
| **dev-team ↔ explorer** | 軟依賴：Phase 0 可呼叫 explorer（先後執行），未安裝時自行掃描 |
| **explorer ↔ explorer** | 不可巢狀：dev-team 呼叫 explorer 時，explorer team 跑完才建 dev-team |

---

## 5. 成本估算

### 單次中型功能開發（8 個開發任務 + 審查）

| 配置 | Agent 數 | 預估 Input | 預估 Output | 混合模型成本 |
|------|---------|-----------|-------------|-------------|
| 精簡版（前次設計） | 3 | ~200K | ~60K | ~$1.0 |
| 大團隊 | 8-10 | ~400K | ~120K | ~$1.5 |

### Model 定價參考

| Model | Input | Output |
|-------|-------|--------|
| Opus | $15/M | $75/M |
| Sonnet | $3/M | $15/M |
| Haiku | $0.25/M | $1.25/M |

---

## 6. Plugin 結構

```
plugins/
├── explorer/
│   ├── .claude-plugin/
│   │   └── plugin.json
│   └── skills/
│       └── explorer/
│           └── SKILL.md
└── dev-team/
    ├── .claude-plugin/
    │   └── plugin.json
    └── skills/
        └── dev-team/
            └── SKILL.md
```

marketplace.json 新增：
```json
{
  "name": "explorer",
  "source": "./plugins/explorer",
  "description": "專案探索者：Agent Teams 並行探索專案結構，產出專案地圖文件",
  "tags": ["explore", "project-map", "codebase", "architecture", "agent-teams"]
},
{
  "name": "dev-team",
  "source": "./plugins/dev-team",
  "description": "開發團隊：多角色流水線協作（PM/開發者/QA），大團隊並行開發與審查",
  "tags": ["team", "agent-teams", "pipeline", "pm", "qa", "development"]
}
```
