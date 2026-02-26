# Agent Metrics Feature Design

Date: 2026-02-26
Status: Approved
Scope: Feature addition to dev-team v2.0 (v2.1.0)

## Problem Statement

dev-team v2.0 produces 5 tracking documents but none capture resource consumption. Users need visibility into:
- Cost per execution (which roles are most expensive)
- Efficiency analysis (time and token usage per role)
- Task throughput per agent

## Solution: Hybrid Metrics Collection

Combine exact data (from sub-agent returns) with tracked data (from TL timestamps and task counts) to produce an Agent Metrics section in the delivery report.

### Data Sources

| Role | Data Source | Fields | Accuracy |
|------|-----------|--------|----------|
| QA sub-agents | Task tool `<usage>` return | `total_tokens`, `duration_ms`, `tool_uses` | Exact |
| Workers | TL timestamp tracking + TaskList | wall-clock duration, task count, model | Tracked |
| Challenger | TL timestamp tracking | wall-clock duration, model | Tracked |
| TL | Self-tracking at Phase 6 | total session duration | Tracked |

### Worker/Challenger Self-Report

Add to worker.md and challenger.md prompts:

```
METRICS REPORTING:
- When you receive a shutdown_request, before responding:
  1. Count: how many tasks you completed (TaskList, filter owner=yourself, status=completed)
  2. Report in your final message to TL:
     METRICS: tasks={count} | model={your model}
- This data is used for the delivery report.
```

### TL Tracking Mechanism

TL tracks metrics throughout execution:
1. **Spawn time**: record timestamp when each agent is spawned
2. **QA sub-agent returns**: extract and accumulate `total_tokens`, `duration_ms` from each Task tool return
3. **Task completion**: count per worker from TaskList at Phase 6
4. **Shutdown time**: record timestamp when each agent confirms shutdown
5. **Duration**: calculated as (shutdown_time - spawn_time) per agent

### Cost Calculation

TL applies known pricing at Phase 6:

```
Opus:   input $15/MTok, output $75/MTok
Sonnet: input $3/MTok,  output $15/MTok
Haiku:  input $0.80/MTok, output $4/MTok
```

- QA sub-agents: exact cost (has precise token data)
- Workers/Challenger/TL: marked as "estimated" (no per-agent token breakdown available)

## Output Format

Integrated into DELIVERY_REPORT.md as `## Agent Metrics` section (after `## QA Results`):

### Team Composition Table

```markdown
| Agent | Model | Role | Tasks Completed |
|-------|-------|------|-----------------|
```

### Resource Usage Table

```markdown
| Agent | Tokens (in/out) | Duration | Est. Cost (USD) | Source |
|-------|-----------------|----------|-----------------|--------|
```

- `Source` column: `exact` (from Task tool return) or `tracked` (TL timestamps)
- QA sub-agents row aggregates all reviews
- Duration from PROCESS_LOG timestamps

### Cost Breakdown Table

```markdown
| Role | Count | Est. Cost | % of Total |
|------|-------|-----------|------------|
```

## Implementation Changes

### Files to Modify

1. **SKILL.md**: Add metrics tracking instructions to Phase 3 (spawn tracking), Phase 4 (QA accumulation), Phase 6 (metrics assembly)
2. **prompts/worker.md**: Add METRICS REPORTING section
3. **prompts/challenger.md**: Add METRICS REPORTING section
4. **references/delivery-report-template.md**: Add Agent Metrics section template
5. **docs/GUIDE.zh-TW.md**: Document the metrics feature

### Files NOT Modified

- references/trace-template.md (no change)
- references/api-contract-template.md (no change)
- references/process-log-template.md (no change — timestamps already captured)
- references/issues-template.md (no change)
- references/qa-review-template.md (no change)

## Version

v2.1.0 — Feature addition (non-breaking).
