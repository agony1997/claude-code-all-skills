# all-skills

Claude Code 技能插件 Marketplace，共 26 個插件，依前綴分為 5 大類。

## 插件清單

### core_ — 核心開發（7）

| 插件 | 說明 |
|------|------|
| `core_system-design` | 系統架構設計：技術選型、架構模式、NFR、整潔架構/六邊形架構 |
| `core_microservices` | 微服務架構模式，服務拆分、API Gateway、分散式事務 |
| `core_ddd-delivery` | DDD 端到端交付：理論 → Event Storming → SA → SD → 實作規劃 |
| `core_spring-boot` | Spring Boot 開發：REST API、自動配置、JPA/資料存取、效能優化 |
| `core_quarkus` | Quarkus 雲原生 Java 開發 |
| `core_testing-review` | 品質保證：TDD、測試策略、程式碼審查、重構 |
| `core_pg-standards` | PG 紀律遵規，規格書與程式碼風格 |

### db_ — 資料庫（5）

| 插件 | 說明 |
|------|------|
| `db_schema-design` | DDD 導向資料庫設計，聚合邊界→表結構、DDL、Flyway |
| `db_postgresql` | PostgreSQL 進階：JSONB、全文搜尋、分區表、窗口函數 |
| `db_mysql` | MySQL 索引優化、查詢優化、複製架構 |
| `db_mssql` | SQL Server T-SQL 與效能調校 |
| `db_redis` | Redis 快取策略、分散式鎖、Cluster |

### frontend_ — 前端（3）

| 插件 | 說明 |
|------|------|
| `frontend_vue` | Vue 2/3 Composition API、Vue Router、Pinia |
| `frontend_quasar` | Quasar Framework Vue 3 多平台應用 |
| `frontend_typescript` | TypeScript 泛型、進階型別、工具型別 |

### devops_ — DevOps（3）

| 插件 | 說明 |
|------|------|
| `devops_docker` | Docker 容器化、Dockerfile、Docker Compose |
| `devops_cicd` | CI/CD GitHub Actions、GitLab CI、Jenkins |
| `devops_git` | Git Commit、PR、分支策略、版本發布 |

### tools_ — 文件工具（8）

| 插件 | 說明 |
|------|------|
| `tools_api-docs` | API 文檔 OpenAPI 3.0/Swagger |
| `tools_business-report` | 商業報告：週報、月報、季報 |
| `tools_chart-generator` | 圖表生成 Mermaid/PlantUML |
| `tools_excel-converter` | Excel/CSV/JSON 格式互轉 |
| `tools_markdown-converter` | Markdown ↔ HTML/PDF/DOCX |
| `tools_pdf-processor` | PDF 合併、分割、提取、浮水印 |
| `tools_tech-presentation` | 技術簡報 PowerPoint 生成 |
| `tools_word-processor` | Word 文檔建立與編輯 |

## 使用方式

### 安裝

```bash
claude /plugin add ./path/to/all-skills
```

### 建議配置

將 **devops_git + tools** 放在 User scope（全域可用），**技術棧**放在 Project scope（按專案需求啟用）。

插件在 `enabledPlugins` 中的 key 格式為 `插件名@marketplace名`，例如 `devops_git@all-skills`。

#### User scope — 全域工具

透過 `/plugin` 安裝 marketplace 後，在 User scope 啟用 `devops_git` 和所有 `tools_` 插件。

`~/.claude/settings.json`：

```jsonc
{
  "enabledPlugins": {
    "all-skills": true,                          // marketplace
    "devops_git@all-skills": true,                // Git 全域可用
    "tools_api-docs@all-skills": true,
    "tools_business-report@all-skills": true,
    "tools_chart-generator@all-skills": true,
    "tools_excel-converter@all-skills": true,
    "tools_markdown-converter@all-skills": true,
    "tools_pdf-processor@all-skills": true,
    "tools_tech-presentation@all-skills": true,
    "tools_word-processor@all-skills": true
  }
}
```

#### Project scope — 按專案啟用技術棧

在專案根目錄建立 `.claude/settings.json`，只啟用該專案需要的技術棧插件：

**範例 A：Java 個人開發（Spring Boot + PostgreSQL + Quasar）**

```jsonc
{
  "enabledPlugins": {
    "core_system-design@all-skills": true,
    "core_ddd-delivery@all-skills": true,
    "core_microservices@all-skills": true,
    "core_spring-boot@all-skills": true,
    "core_testing-review@all-skills": true,
    "db_schema-design@all-skills": true,
    "db_postgresql@all-skills": true,
    "db_redis@all-skills": true,
    "frontend_vue@all-skills": true,
    "frontend_quasar@all-skills": true,
    "frontend_typescript@all-skills": true,
    "devops_docker@all-skills": true,
    "devops_cicd@all-skills": true
  }
}
```

**範例 B：Java 公司開發（Quarkus + MSSQL + Quasar）**

```jsonc
{
  "enabledPlugins": {
    "core_pg-standards@all-skills": true,
    "core_quarkus@all-skills": true,
    "core_testing-review@all-skills": true,
    "db_mssql@all-skills": true,
    "frontend_vue@all-skills": true,
    "frontend_quasar@all-skills": true,
    "frontend_typescript@all-skills": true
  }
}
```

### 覆蓋 User scope 設定

如果某個插件在 User scope 已啟用，但特定專案不需要，可以在 Project scope 中設為 `false` 覆蓋：

```jsonc
// <project>/.claude/settings.json
{
  "enabledPlugins": {
    "tools_business-report@all-skills": false    // 此專案停用商業報告
  }
}
```

不寫的插件會繼承 User scope 的值。

### 設定層級

```
User scope（~/.claude/settings.json）
  └─ devops_git + tools_ 全域可用，所有專案繼承

Project scope（<project>/.claude/settings.json）
  ├─ core_ / db_ / frontend_ / devops_(docker, cicd) 按技術棧啟用
  └─ 可用 false 覆蓋 User scope 中不需要的插件
```
