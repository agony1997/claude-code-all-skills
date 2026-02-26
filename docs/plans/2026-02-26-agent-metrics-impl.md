# Agent Metrics Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Add per-agent resource tracking (model, duration, tokens, cost, tasks completed) to dev-team, output in DELIVERY_REPORT.

**Architecture:** Hybrid collection — exact data from QA sub-agent Task tool returns, tracked data from TL timestamps for teammates. TL assembles metrics in Phase 6 and writes to Agent Metrics section in delivery report.

**Tech Stack:** Markdown skill files (SKILL.md, prompts, references, docs)

---

### Task 1: Add METRICS REPORTING to worker prompt

**Files:**
- Modify: `plugins/dev-team/skills/dev-team/prompts/worker.md:54`

**Step 1: Add METRICS REPORTING section before the closing backticks**

Insert after line 54 (after the STOP RULE line) and before the closing ``` on line 55:

```
METRICS REPORTING:
- When you receive a shutdown_request, before approving:
  1. TaskList → count tasks where owner=yourself and status=completed
  2. Include in your final SendMessage to TL:
     METRICS: tasks={count} | model=sonnet
- This data is used for the delivery report. Do not skip it.
```

The file should now have METRICS REPORTING as the last section inside the code block.

**Step 2: Verify**

Run: `grep -n "METRICS" plugins/dev-team/skills/dev-team/prompts/worker.md`
Expected: Lines showing METRICS REPORTING section.

**Step 3: Commit**

```bash
git add plugins/dev-team/skills/dev-team/prompts/worker.md
git commit -m "feat(dev-team): add metrics reporting to worker prompt"
```

---

### Task 2: Add METRICS REPORTING to challenger prompt

**Files:**
- Modify: `plugins/dev-team/skills/dev-team/prompts/challenger.md:45`

**Step 1: Add METRICS REPORTING section before the closing backticks**

Insert after line 45 (after the STOP RULE line) and before the closing ``` on line 46:

```
METRICS REPORTING:
- When you receive a shutdown_request, before approving:
  Include in your final SendMessage to TL:
     METRICS: reviews={count of checkpoints you reviewed} | model=sonnet
- This data is used for the delivery report. Do not skip it.
```

**Step 2: Verify**

Run: `grep -n "METRICS" plugins/dev-team/skills/dev-team/prompts/challenger.md`
Expected: Lines showing METRICS REPORTING section.

**Step 3: Commit**

```bash
git add plugins/dev-team/skills/dev-team/prompts/challenger.md
git commit -m "feat(dev-team): add metrics reporting to challenger prompt"
```

---

### Task 3: Add Agent Metrics section to delivery report template

**Files:**
- Modify: `plugins/dev-team/skills/dev-team/references/delivery-report-template.md`

**Step 1: Insert Agent Metrics section after the QA Results table (after line 23)**

Insert after line 23 (after the QA Results table header row `|------|--------|--------|-------|`):

```markdown

## Agent Metrics

### Team Composition

| Agent | Model | Role | Tasks Completed |
|-------|-------|------|-----------------|
| TL | opus | Planner + QA gate | — |
| challenger | sonnet | Devil's advocate | — |
| {worker} | {model} | {role} | {count} |

### Resource Usage

| Agent | Tokens (in/out) | Duration | Est. Cost (USD) | Source |
|-------|-----------------|----------|-----------------|--------|
| TL | — | {duration} | — | tracked |
| challenger | — | {duration} | — | tracked |
| {worker} | — | {duration} | — | tracked |
| QA ({n} reviews) | {in} / {out} | {duration} | ${cost} | exact |
| **Total** | | **{total}** | **~${total}** | |

<!-- Source: "exact" = from Task tool usage return, "tracked" = TL timestamp tracking -->

### Cost Breakdown

| Role | Count | Est. Cost | % of Total |
|------|-------|-----------|------------|
| TL (Opus) | 1 | ${cost} | {pct}% |
| Workers (Sonnet) | {n} | ${cost} | {pct}% |
| Challenger (Sonnet) | 1 | ${cost} | {pct}% |
| QA Sub-agents (Sonnet) | {n} | ${cost} | {pct}% |

<!-- Pricing: Opus in=$15/MTok out=$75/MTok | Sonnet in=$3/MTok out=$15/MTok | Haiku in=$0.80/MTok out=$4/MTok -->
```

**Step 2: Verify the template reads correctly**

Run: `grep -c "Agent Metrics" plugins/dev-team/skills/dev-team/references/delivery-report-template.md`
Expected: 1

**Step 3: Commit**

```bash
git add plugins/dev-team/skills/dev-team/references/delivery-report-template.md
git commit -m "feat(dev-team): add Agent Metrics section to delivery report template"
```

---

### Task 4: Add metrics tracking to SKILL.md

**Files:**
- Modify: `plugins/dev-team/skills/dev-team/SKILL.md`

Three insertion points: Phase 3 (spawn tracking), Phase 4 (QA accumulation), Phase 6 (assembly).

**Step 1: Add spawn timestamp tracking to Phase 3**

After line 143 (the current `6. Update {date}-TRACE.md Worker column...` line), insert:

```
8. **Metrics init**: TL records spawn timestamp for each agent (challenger, workers).
   Maintain internal metrics ledger: `{agent_name: {model, spawn_time, tasks_completed, tokens_in, tokens_out, duration_ms}}`.
   QA sub-agent metrics are accumulated separately as a group.
```

**Step 2: Add QA usage accumulation to Phase 4**

In Phase 4 step 3 (around line 167), after sub-step c (`QA sub-agent reviews and returns structured result.`), insert a new sub-step:

```
   d. Extract `<usage>` from QA sub-agent return (total_tokens, duration_ms). Accumulate into QA metrics ledger.
```

**Step 3: Update Phase 6 to assemble metrics**

Replace the current Phase 6 content (lines 195-201) with:

```
### Phase 6: Delivery

1. Finalize `{date}-TRACE.md` Summary counts.

2. **Assemble Agent Metrics**:
   a. Send shutdown_request to challenger + all workers. Each responds with `METRICS:` line.
   b. Parse METRICS from each agent's final message (tasks completed, model).
   c. Calculate duration per agent: shutdown_time - spawn_time.
   d. QA sub-agents: use accumulated exact token/duration data from Phase 4.
   e. Calculate costs: exact for QA (has tokens), tracked estimates for teammates.
      Pricing: Opus in=$15/MTok out=$75/MTok | Sonnet in=$3/MTok out=$15/MTok.

3. Read `references/delivery-report-template.md` → write `{date}-DELIVERY_REPORT.md` to output dir.
   Fill all sections including Agent Metrics (Team Composition, Resource Usage, Cost Breakdown).

4. Present to user: list all 5 output files with paths.
5. Confirm all teammates closed → TeamDelete.
6. Do NOT auto-commit/push. User decides.
```

**Step 4: Verify no syntax issues**

Run: `wc -l plugins/dev-team/skills/dev-team/SKILL.md`
Expected: ~215-225 lines (was 202, added ~15-20 lines).

**Step 5: Commit**

```bash
git add plugins/dev-team/skills/dev-team/SKILL.md
git commit -m "feat(dev-team): add metrics tracking to Phase 3/4/6 in SKILL.md"
```

---

### Task 5: Update GUIDE.zh-TW.md

**Files:**
- Modify: `plugins/dev-team/docs/GUIDE.zh-TW.md`

**Step 1: Update version**

Change line 3 from:
```
> 版本：2.0.0 | 最後更新：2026-02-26
```
to:
```
> 版本：2.1.0 | 最後更新：2026-02-26
```

**Step 2: Add Agent Metrics to the 產出文件 section**

After line 170 (the DELIVERY_REPORT.md description), insert:

```

**Agent Metrics（包含在 DELIVERY_REPORT.md 中）** — Phase 6 自動產出：
- **Team Composition**：每個 agent 的模型、角色、完成任務數
- **Resource Usage**：耗用時間、token 用量（QA 為精確值，其他為追蹤值）、估算成本
- **Cost Breakdown**：按角色分組的成本佔比
- QA sub-agent 的資料來自 Task tool 回傳（`Source: exact`），其他來自 TL 時間戳追蹤（`Source: tracked`）
```

**Step 3: Add FAQ entry**

After the last FAQ entry (line 253), add:

```

**Q: Agent Metrics 的資料精確嗎？**
A: QA sub-agent 的 token 和耗時是精確的（來自 Task tool 回傳）。Workers 和 challenger 的耗時是從 spawn 到 shutdown 的牆鐘時間，token 用量無法精確取得。報告中的 `Source` 欄會標示 `exact` 或 `tracked`。
```

**Step 4: Update file structure section**

At line 213, change `← 插件元資料 (v2.0.0)` to `← 插件元資料 (v2.1.0)`.

**Step 5: Verify**

Run: `grep -c "Agent Metrics\|2.1.0" plugins/dev-team/docs/GUIDE.zh-TW.md`
Expected: 3 or more matches.

**Step 6: Commit**

```bash
git add plugins/dev-team/docs/GUIDE.zh-TW.md
git commit -m "docs(dev-team): document Agent Metrics feature in GUIDE.zh-TW.md"
```

---

### Task 6: Bump plugin.json to v2.1.0

**Files:**
- Modify: `plugins/dev-team/.claude-plugin/plugin.json`

**Step 1: Update version**

Change `"version": "2.0.0"` to `"version": "2.1.0"`.

**Step 2: Commit**

```bash
git add plugins/dev-team/.claude-plugin/plugin.json
git commit -m "chore(dev-team): bump version to 2.1.0"
```

---

### Task 7: Final verification

**Step 1: Verify metrics keywords present in all modified files**

```bash
grep -l "METRICS\|metrics\|Agent Metrics" plugins/dev-team/skills/dev-team/SKILL.md plugins/dev-team/skills/dev-team/prompts/worker.md plugins/dev-team/skills/dev-team/prompts/challenger.md plugins/dev-team/skills/dev-team/references/delivery-report-template.md plugins/dev-team/docs/GUIDE.zh-TW.md
```
Expected: All 5 files listed.

**Step 2: Verify version consistency**

```bash
grep "version\|版本" plugins/dev-team/.claude-plugin/plugin.json plugins/dev-team/docs/GUIDE.zh-TW.md | head -3
```
Expected: All show 2.1.0.

**Step 3: Git log**

```bash
git log --oneline -8
```
Expected: 6 new commits for tasks 1-6.
