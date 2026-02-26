# Dev-Team v2.0 Design: Task Pool Architecture

Date: 2026-02-26
Status: Approved
Scope: Major architecture rewrite (v1.3.0 → v2.0.0)

## Problem Statement

dev-team v1.3.0 has three core issues:

1. **Leader heterogeneity**: The "manager who doesn't do work" concept (pg-leader) is unnatural for AI agents. AI's instinct is to solve problems, not route them. This causes pg-leader to write code instead of delegating.
2. **QA latency**: The notification chain (worker → pg-leader → TL → qa-leader → sub-agent) creates unnecessary sequential delays.
3. **Simplistic task assignment**: Worker count is determined by raw task count without considering complexity or dependencies.
4. **Worker scope violation**: Workers fix issues outside their assigned scope because AI naturally tries to resolve problems it encounters.

### Root Cause

AI agents don't need human organizational hierarchy. The "manager" role is designed for human attention/energy constraints that don't apply to AI. The value a manager provides (coordination, monitoring, decision-making) can be handled by the task system and a single planning agent.

## Solution: Task Pool Architecture

### Architecture

```
TL (Opus) — Sole planner + quality gate
├── challenger (Sonnet, teammate) — Devil's advocate, persistent
├── worker-1 (Sonnet, teammate) — Self-assigning from task pool
├── worker-2 (Sonnet, teammate) — Self-assigning from task pool
└── worker-N (Sonnet, teammate) — Self-assigning from task pool
```

### Removed Concepts

- **pg-leader**: Entirely removed. No more "manager who doesn't code".
- **qa-leader**: Removed. TL spawns disposable QA sub-agents directly.
- **explore-leader**: Removed. TL uses `explorer` skill or spawns sub-agent directly.
- **Lightweight/Full mode toggle**: Only one mode (evolved Lightweight).

### Retained Concepts

- TL as sole spawn authority
- API Contract-first workflow
- Document tracking system (TRACE, PROCESS_LOG, ISSUES, DELIVERY_REPORT)
- STOP RULE and Communication Discipline
- 6-phase flow (Phase 0-5, content adjusted)

### New Concepts

- **Task Pool**: Workers self-assign from TaskList (pending + unblocked + no owner).
- **File Scope**: Each task specifies allowed/readonly/forbidden files.
- **Challenger role**: Persistent Sonnet teammate that challenges decisions and finds systemic issues.
- **Disposable QA sub-agents**: TL spawns one-off sub-agents for task review (not teammates).
- **Complexity-based worker sizing**: Tasks scored S/M/L, workers allocated by weighted workload.

## Three Parallel Pipelines

| Pipeline | Actor | Parallelism | Trigger |
|----------|-------|-------------|---------|
| Development | Worker × N | Each worker executes independently | Self-assign from TaskList |
| Review | TL → QA sub-agents | Multiple sub-agents can review concurrently | Worker marks task completed |
| Challenge | Challenger | Independent, can raise issues anytime | TL notifies at key checkpoints |

## Worker Self-Assignment Mechanism

```
After completing a task:
1. TaskUpdate → status: completed
2. SendMessage TL: completion report (files, results)
3. TaskList → find next task: status=pending + no blockedBy + no owner
4. TaskUpdate → claim (owner: self)
5. Begin execution
```

Conflict prevention:
- TaskUpdate is atomic — first to claim wins.
- If claimed by someone else: TaskList again, pick next.

## Challenger Role Design

- Core directive: "Your job is to find problems, not confirm everything is fine."
- Scope: Architecture decisions, cross-task consistency, API contract compliance, edge cases.
- Cannot modify code — only raises challenges.
- Structured prefix: `CHALLENGE: {scope} | Issue: {description} | Severity: high/medium/low`
- TL decides whether to accept challenge and create fix tasks.

TL notifies challenger at:
1. Phase 1 complete — review task decomposition + API Contract
2. After each batch of tasks complete — review cross-task consistency
3. Phase 5 (Contract Check) — participate in final verification

Challenger may also proactively TaskList to monitor progress.

## Phase Flow Changes

| Phase | v1.3.0 | v2.0 | Key Diff |
|-------|--------|------|----------|
| 0: Recon | TL or explore-leader | TL uses `explorer` skill or sub-agent | Remove explore-leader |
| 1: Planning | TL solo | TL solo + file_scope + complexity scoring | More precise task definitions |
| 2: API Contract | TL solo | TL solo → notify challenger to review | Challenger first intervention |
| 3: Assembly | Spawn pg/qa/explore leaders + workers | Spawn challenger + workers | Simpler |
| 4: Dev & Review | Hierarchical notification chain | Task pool + TL spawns QA sub-agents | Core change |
| 5: Contract Check | qa-leader does it | TL spawns sub-agent + challenger participates | Remove qa-leader |
| 6: Delivery | Same | Same (5 output files) | No change |

## Phase 4 Detailed Flow

```
1. Workers self-assign tasks, develop in parallel
2. Worker completes → TaskUpdate completed → SendMessage TL
3. TL receives completion:
   a. Update TRACE → done
   b. Log PROCESS_LOG
   c. Spawn QA sub-agent (disposable) to review
4. QA sub-agent returns structured result:
   - PASS → TL updates TRACE → qa-pass, logs PROCESS_LOG
   - FAIL → TL updates TRACE → qa-fail, logs ISSUES, creates fix task (back to pool)
5. Challenger reviews cross-task consistency after each batch
6. Worker self-assigns next task after completing current one
```

## File Scope Mechanism

Each task description includes:

```
## File Scope
- ALLOWED: src/modules/user/*.java, src/modules/user/*.vue
- READONLY: src/shared/types.ts, src/config/api.ts
- FORBIDDEN: anything else

If you need to modify files outside your scope, STOP and SendMessage TL.
```

Worker prompt enforcement:

```
SCOPE ENFORCEMENT:
- Before editing ANY file, check if it's in your task's File Scope.
- ALLOWED: edit freely.
- READONLY: can read, CANNOT modify. If changes needed, SendMessage TL.
- Everything else: FORBIDDEN.
- If you discover a bug outside your scope: report it, don't fix it.
```

## Worker Count Decision (Improved)

```
1. TL scores each task: S(1pt) / M(2pt) / L(3pt)
2. Target: 3-5 points per worker
3. Additional considerations:
   - Frontend + backend → at least one of each
   - Interdependent tasks → assign to same worker
   - Upper limit: 5 workers max
```

## Edge Cases

| Scenario | Handling |
|----------|----------|
| Two workers need same file | TL assigns to same worker or sets blockedBy |
| Worker finishes all claimable tasks | SendMessage TL, wait for blocked tasks to unblock |
| Challenger finds critical issue | TL decides whether to pause dev pipeline, creates fix task |
| QA sub-agent finds cross-task issue | TL creates new task in pool with file_scope |
| Task pool empty but blocked tasks remain | Workers idle, TL monitors and coordinates unblocking |
| Worker finds task too complex | SendMessage TL, TL splits task or reassigns |

## Prompt File Changes

| File | Action |
|------|--------|
| `prompts/pg-leader.md` | **Delete** |
| `prompts/qa-leader.md` | **Delete** |
| `prompts/explore-leader.md` | **Delete** |
| `prompts/worker.md` | **Rewrite** (add self-assignment + file_scope) |
| `prompts/challenger.md` | **New** |
| `references/qa-review-template.md` | **New** (structured review template for QA sub-agents) |

## SKILL.md Changes

Complete rewrite of SKILL.md to reflect:
- New architecture (TL + challenger + workers)
- Removed leader concepts
- Updated Phase Flow
- New Communication Rules (flattened)
- Task pool mechanism
- Challenger notification protocol

## Version

v2.0.0 — Major architecture rewrite.
