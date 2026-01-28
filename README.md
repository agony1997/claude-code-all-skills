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

將 **tools** 放在 User scope（全域可用），**技術棧**放在 Project scope（按專案需求啟用）。

#### User scope — 全域工具

編輯 `~/.claude/settings.json`：

```jsonc
{
  "enabledPlugins": {
    "all-skills": true        // 安裝 marketplace
  },
  "enabledSkills": {
    // 全域啟用所有 tools_ 插件
    "tools_api-docs": true,
    "tools_business-report": true,
    "tools_chart-generator": true,
    "tools_excel-converter": true,
    "tools_markdown-converter": true,
    "tools_pdf-processor": true,
    "tools_tech-presentation": true,
    "tools_word-processor": true
  }
}
```

#### Project scope — 按專案啟用技術棧

在專案根目錄建立 `.claude/settings.json`：

**範例 A：Java 個人開發（Spring Boot + PostgreSQL + Quasar）**

```jsonc
{
  "enabledSkills": {
    "core_system-design": true,
    "core_ddd-delivery": true,
    "core_microservices": true,
    "core_spring-boot": true,
    "core_testing-review": true,
    "db_schema-design": true,
    "db_postgresql": true,
    "db_redis": true,
    "frontend_vue": true,
    "frontend_quasar": true,
    "frontend_typescript": true,
    "devops_git": true,
    "devops_docker": true,
    "devops_cicd": true
  }
}
```

**範例 B：Java 公司開發（Quarkus + MSSQL + Quasar）**

```jsonc
{
  "enabledSkills": {
    "core_pg-standards": true,
    "core_quarkus": true,
    "core_testing-review": true,
    "db_mssql": true,
    "frontend_vue": true,
    "frontend_quasar": true,
    "frontend_typescript": true,
    "devops_git": true
  }
}
```

### 設定層級

```
User scope（~/.claude/settings.json）
  └─ tools_ 全域可用，任何專案皆可使用文件工具

Project scope（<project>/.claude/settings.json）
  └─ core_ / db_ / frontend_ / devops_ 按技術棧啟用
```

這樣每個專案只載入需要的技術棧技能，不會被無關插件干擾，同時文件工具在任何地方都可使用。
