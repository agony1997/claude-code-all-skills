# all-skills

Claude Code 技能插件 Marketplace，共 5 個工作流型插件。

> **設計原則**：只保留有明確工作流的技能。純領域知識（Spring Boot、PostgreSQL、Vue.js 等）交給 Claude 本身的能力，流程方法論（TDD、brainstorming、debugging）交給 superpowers 等外部插件。

## 插件清單

| 插件 | 類型 | 說明 |
|------|------|------|
| `core_ddd-delivery` | 方法論 | DDD 端到端交付：Event Storming → SA → SD → 實作規劃 |
| `devops_git` | 操作流程 | Git Commit、PR、分支策略、版本發布 + 團隊規範 |
| `standards-reviewer` | 審查流程 | 專案規範審查員：根據專案載入對應規範，執行合規審查 |
| `spec-to-md` | 轉換流程 | 規格文件 → 結構化 AI Coding 實作文件 |
| `md-to-code` | 實作流程 | 實作文件 → 程式碼（並行 Agent Teams） |

## 搭配的外部插件

| 插件 | 來源 | 涵蓋 |
|------|------|------|
| superpowers | obra/superpowers-marketplace | brainstorming、TDD、debugging、code review、plan |
| document-skills | anthropic-agent-skills | docx、pptx、pdf、xlsx 文件處理 |
| claude-developer-platform | anthropic-agent-skills | Claude API 開發指南 |

## 使用方式

### 安裝

```bash
claude /plugin add ./path/to/all-skills
```

### 建議配置

將 **devops_git** 放在 User scope（全域可用），其餘按專案需求啟用。

#### User scope — 全域工具

`~/.claude/settings.json`（對應 `examples/global-settings.json`）：

```jsonc
{
  "enabledPlugins": {
    "all-skills": true,
    "devops_git@all-skills": true
  }
}
```

#### Project scope — 按專案啟用

`<project>/.claude/settings.json`（對應 `examples/project-settings.json`）：

```jsonc
{
  "enabledPlugins": {
    "all-skills": true,
    "core_ddd-delivery@all-skills": true,
    "standards-reviewer@all-skills": true,
    "spec-to-md@all-skills": true,
    "md-to-code@all-skills": true
  }
}
```

### 目錄結構

```
all-skills/
├── README.md
├── plugins/
│   ├── core_ddd-delivery/        # DDD 方法論
│   ├── devops_git/               # Git 控管流程
│   ├── standards-reviewer/       # 規範審查員（支援多專案規範）
│   ├── spec-to-md/               # 規格 → 實作文件
│   └── md-to-code/               # 實作文件 → 程式碼
├── docs/plans/                   # 設計與計畫文件
└── examples/                     # 設定檔範例
    ├── global-settings.json
    └── project-settings.json
```
