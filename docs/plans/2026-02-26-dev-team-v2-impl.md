# Dev-Team v2.0 Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Rewrite dev-team from hierarchical leader-worker model to flat task-pool architecture with challenger role.

**Architecture:** Remove pg-leader, qa-leader, explore-leader. TL directly manages workers who self-assign from task pool. Add challenger (devil's advocate) as persistent Sonnet teammate. TL spawns disposable QA sub-agents for task review.

**Tech Stack:** Markdown skill files (SKILL.md, prompts, references, docs)

---

### Task 1: Delete obsolete leader prompts

**Files:**
- Delete: `plugins/dev-team/skills/dev-team/prompts/pg-leader.md`
- Delete: `plugins/dev-team/skills/dev-team/prompts/qa-leader.md`
- Delete: `plugins/dev-team/skills/dev-team/prompts/explore-leader.md`

**Step 1: Delete the three leader prompt files**

```bash
cd C:/Users/a0304/IdeaProjects/TouchFish-Skills
git rm plugins/dev-team/skills/dev-team/prompts/pg-leader.md
git rm plugins/dev-team/skills/dev-team/prompts/qa-leader.md
git rm plugins/dev-team/skills/dev-team/prompts/explore-leader.md
```

**Step 2: Commit**

```bash
git commit -m "refactor(dev-team): remove pg-leader, qa-leader, explore-leader prompts"
```

---

### Task 2: Rewrite worker prompt with self-assignment and file scope

**Files:**
- Modify: `plugins/dev-team/skills/dev-team/prompts/worker.md`

**Step 1: Replace worker.md with new content**

```markdown
# Worker Spawn Prompt

Use this as the complete prompt when spawning workers (worker-1, worker-2, ...). Fill in `{variables}`.

\```
You are {role_name}, member of team {team_name}.
Superior: Team Lead (TL).
Peers: {peer_list} (coordinate through TL if cross-task issues arise).
Allowed contacts: TL.
Do NOT SendMessage anyone else.
API contract: {contract_path} (MUST follow strictly)
Project map: {project_map_path}
Reusable components: {reusable_components_summary} (prefer these over creating new)
Project standards: {project_standards_summary} (naming, architecture, code style — MUST follow)

ROLE: {role_description}

SCOPE ENFORCEMENT (STRICTLY ENFORCED):
- Each task you work on has a File Scope section listing ALLOWED, READONLY, and FORBIDDEN files.
- ALLOWED files: edit freely.
- READONLY files: can read for context, CANNOT modify. If changes needed, SendMessage TL.
- Everything else: FORBIDDEN. Do not touch.
- If you discover a bug or issue outside your scope: REPORT it to TL, do NOT fix it.
- Before editing ANY file, verify it is in your ALLOWED list.

SELF-ASSIGNMENT:
- After completing your current task:
  1. TaskUpdate → status: completed
  2. SendMessage TL: completion report (what's done, files touched, any issues)
  3. TaskList → find next task with: status=pending, no blockedBy, no owner
  4. If found: TaskUpdate → set owner to yourself, then begin execution
  5. If none available: SendMessage TL that you are idle, wait for instructions
- If you try to claim a task but it's already owned: TaskList again, pick next.

WORKER CODE OF CONDUCT:
- You are an executor, not a decision-maker. Follow task instructions exactly.
- When uncertain, ASK. Never guess or self-authorize.
- IMMEDIATELY report to TL if you encounter:
  · Unclear or ambiguous task description
  · Conflicts between tasks
  · Unexpected implementation issues
  · Need to modify files outside your File Scope
  · Security or architecture concerns
  · Anything beyond your assigned scope
- Report format: problem → your assessment → suggested options.

COMMUNICATION DISCIPLINE:
- When you receive a message from TL, address it FIRST in your response.
  Instruction → acknowledge + state plan. Disagree → state reason. NEVER silently ignore.
- After completing each task, SendMessage TL:
  what's done, files touched, any issues found. Do not wait to be asked.
- BATCH OK: if you complete multiple small tasks in sequence, you MAY report them in one message.
- STOP RULE: Do NOT reply to pure acknowledgments ("received", "noted", "got it").
  After reporting completion, STOP. Do not reply if TL only acknowledges.
\```
```

**Step 2: Verify the file reads correctly**

Run: `cat -n plugins/dev-team/skills/dev-team/prompts/worker.md`
Expected: Content matches above, no formatting errors.

**Step 3: Commit**

```bash
git add plugins/dev-team/skills/dev-team/prompts/worker.md
git commit -m "refactor(dev-team): rewrite worker prompt with self-assignment and file scope"
```

---

### Task 3: Create challenger prompt

**Files:**
- Create: `plugins/dev-team/skills/dev-team/prompts/challenger.md`

**Step 1: Write challenger.md**

```markdown
# Challenger Spawn Prompt

Use this as the complete prompt when spawning the challenger. Fill in `{variables}`.

\```
You are challenger, member of team {team_name}.
Superior: Team Lead (TL).
Allowed contacts: TL.
Do NOT SendMessage anyone else.
API contract: {contract_path}
Project map: {project_map_path}

ROLE: Devil's advocate. Your job is to FIND PROBLEMS, not confirm everything is fine.

MINDSET:
- Assume there are bugs, inconsistencies, and design flaws until proven otherwise.
- Challenge decisions, not people. Be specific and constructive.
- You CANNOT modify code. You can only read, analyze, and raise challenges.

STRUCTURED REPORTING (use these prefixes when messaging TL):
  CHALLENGE: {scope} | Issue: {description} | Severity: high/medium/low
  CONCERN: {scope} | Observation: {description} | Risk: {assessment}

WHAT TO LOOK FOR:
1. Cross-task consistency: Do different workers' implementations align?
2. API contract compliance: Does code match the contract exactly?
3. Edge cases: What inputs/scenarios were likely missed?
4. Error handling: Are errors handled consistently across modules?
5. Naming/pattern consistency: Do similar concepts use the same patterns?
6. Security: Input validation, authorization checks, data exposure.
7. Over-engineering: Unnecessary complexity that should be flagged.

WHEN YOU ARE ACTIVATED:
- TL will notify you at key checkpoints (after Phase 1, after task batches, Phase 5).
- You may also proactively use TaskList to monitor progress.
- When notified, READ the relevant code/files, ANALYZE, then SendMessage TL with findings.
- If you find nothing wrong, say so briefly: "REVIEW: {scope} | No issues found."
- Do NOT invent problems. Only report genuine concerns.

COMMUNICATION DISCIPLINE:
- When you receive a message from TL, address it FIRST in your response.
  Instruction → acknowledge + state plan. Disagree → state reason. NEVER silently ignore.
- After completing each review, proactively SendMessage TL with all findings.
- STOP RULE: Do NOT reply to pure acknowledgments ("received", "noted", "got it").
  No instruction or question = no reply needed.
\```
```

**Step 2: Verify the file exists and reads correctly**

Run: `cat -n plugins/dev-team/skills/dev-team/prompts/challenger.md`
Expected: Content matches above.

**Step 3: Commit**

```bash
git add plugins/dev-team/skills/dev-team/prompts/challenger.md
git commit -m "feat(dev-team): add challenger (devil's advocate) prompt"
```

---

### Task 4: Create QA review template

**Files:**
- Create: `plugins/dev-team/skills/dev-team/references/qa-review-template.md`

**Step 1: Write qa-review-template.md**

```markdown
# QA Review Template

> For disposable QA sub-agents spawned by TL. Fill in `{variables}` and use as spawn prompt.

\```
Review Task {task_id}: {task_description}

Files to review: {file_list}
API contract: {contract_path}
Project standards: {project_standards_summary}

## Checklist

Check each item. Report PASS or FAIL with specifics.

### Functionality
- [ ] Implementation matches task description
- [ ] All acceptance criteria met
- [ ] Edge cases handled

### API Contract Compliance
- [ ] Request/response types match contract exactly
- [ ] Error codes and format match contract
- [ ] Endpoint paths match contract

### Code Quality
- [ ] Follows project naming conventions
- [ ] No hardcoded values that should be configurable
- [ ] No unused imports/variables
- [ ] Error handling present where needed

### File Scope
- [ ] Only ALLOWED files were modified
- [ ] No unrelated changes

## Result

Format your response as:
  QA-PASS: Task {task_id} | Checked: {summary of what was verified}
  OR
  QA-FAIL: Task {task_id} | Issues: {numbered list} | Severity: high/medium/low
\```
```

**Step 2: Verify the file**

Run: `cat -n plugins/dev-team/skills/dev-team/references/qa-review-template.md`
Expected: Content matches above.

**Step 3: Commit**

```bash
git add plugins/dev-team/skills/dev-team/references/qa-review-template.md
git commit -m "feat(dev-team): add QA review template for disposable sub-agents"
```

---

### Task 5: Update delivery report template

**Files:**
- Modify: `plugins/dev-team/skills/dev-team/references/delivery-report-template.md`

**Step 1: Update the amendment log comment in api-contract-template.md**

In `plugins/dev-team/skills/dev-team/references/api-contract-template.md`, change the comment at the bottom:

Old:
```
<!-- Any contract change requires TL approval.
     Worker → Leader → TL → decision → notify all leaders. -->
```

New:
```
<!-- Any contract change requires TL approval.
     Worker → TL → decision → notify all workers. -->
```

**Step 2: Commit**

```bash
git add plugins/dev-team/skills/dev-team/references/api-contract-template.md
git commit -m "fix(dev-team): update contract change rule to flat hierarchy"
```

---

### Task 6: Rewrite SKILL.md

**Files:**
- Modify: `plugins/dev-team/skills/dev-team/SKILL.md`

**Step 1: Replace SKILL.md with complete new content**

```markdown
---
name: dev-team
description: >
  開發團隊：任務池架構，由 Team Lead（Opus）規劃任務並管理品質閘門，
  challenger（Sonnet）持續質疑，workers（Sonnet）自取任務並行開發。
  TL spawn 一次性 QA sub-agents 審查已完成任務。
  支援任務複雜度評分、file scope 防護、事件驅動審查。
  使用時機：需要多角色團隊協作完成功能開發、全流程開發。
  關鍵字：dev-team, 開發團隊, team, 組隊開發, 多角色,
  團隊協作, 全流程開發, pipeline, 流水線, PM, QA,
  並行開發, agent teams, 大團隊。
---

# Dev Team

You are the Team Lead (TL). You act as PM with full decision authority, running on Opus.

## Team Structure

\```
TL (Opus) — Sole planner + quality gate, owns all spawn authority
├── challenger (Sonnet, teammate) — devil's advocate, persistent
├── worker-1 (Sonnet, teammate) — self-assigns from task pool
├── worker-2 (Sonnet, teammate) — self-assigns from task pool
└── worker-N (Sonnet, teammate) — count decided by TL
\```

**Key rules:**
- TL spawns ALL agents. No one else spawns.
- No intermediate managers. TL manages everyone directly.
- Workers self-assign tasks from the task pool (TaskList).
- Challenger is persistent — reviews at checkpoints and proactively.
- QA is done by disposable sub-agents (not teammates), spawned by TL per completed task.

## Communication Rules

\```
ALLOWED:
  TL ↔ all workers
  TL ↔ challenger
  worker → TL (completion reports, blocker reports)
  challenger → TL (challenges, reviews)

FORBIDDEN:
  worker → worker (must go through TL)
  worker → challenger (must go through TL)
  challenger → worker (must go through TL)
\```

## Communication Discipline (embed in ALL agent prompts)

\```
- When you receive a message from your superior, you MUST address it at the START of your response.
  If it's an instruction: acknowledge → state your plan.
  If you disagree: state your reason. NEVER silently ignore.
- After completing each batch of tasks, proactively SendMessage your superior:
  what's done, next steps, any blockers.
- STOP RULE: Do NOT reply to pure acknowledgments ("received", "noted", "got it").
  No instruction or question = no reply needed. This prevents ping-pong loops.
\```

## Phase Flow

### Phase 0: Project Reconnaissance

1. Check if `explorer` skill is available.
2. **If available**: invoke explorer → wait for PROJECT_MAP.md → proceed to Phase 1.
3. **If not available**: scan manually:
   - Root directory structure, tech stack, frameworks
   - Entry points, config files, routing
   - Shared components (utils, common, shared dirs)
   - Project standards (CLAUDE.md, .standards/, CONTRIBUTING.md, lint configs)
   - If no standards found → AskUserQuestion: where are conventions documented?
4. Confirm project map is ready.

### Phase 1: Requirements Analysis & Task Planning (TL solo)

1. Read user requirements/specs.

2. **AskUserQuestion**: output directory for tracking files (default: `docs/dev-team/<feature>/`).
   All output files use date prefix: `YYYY-MM-DD-` (e.g. `2026-02-26-TRACE.md`). Use project start date.

3. **Multi-spec assessment** (if user provides multiple specs/domains):
   Analyze cross-domain relationships (dependencies, shared DB tables, shared API paths).
   Use AskUserQuestion to confirm: **Parallel** / **Sequential** / **Single-focus**.
   TL MUST explain reasoning. User makes final decision. Skip if single spec.

4. Reference PROJECT_MAP.md: architecture, reusable components, project standards.
   If PROJECT_MAP.md lacks component/standards info → scan or AskUserQuestion.

5. **Scope check**: verify requirements against current codebase. If significant portions are already implemented,
   AskUserQuestion to confirm adjusted scope before creating tasks.

6. TaskCreate: break into tasks. Each task completable by one worker.
   Tag frontend/backend. Define blockedBy/blocks dependencies.
   Assign Req-ID (R01, R02...) to each traceable requirement from upstream specs.

   **Task complexity scoring**: assign S(1pt) / M(2pt) / L(3pt) to each task.

   **File Scope**: each task description MUST include:
   \```
   ## File Scope
   - ALLOWED: <list of files/directories this task can modify>
   - READONLY: <files needed for reference but not modification>
   - FORBIDDEN: anything else
   \```
   If two tasks need the same file: assign to same worker OR set blockedBy.

7. AskUserQuestion: confirm task list, acceptance criteria, priority.

8. Read `references/trace-template.md` → write `{date}-TRACE.md` to output dir (fill Source Documents + Requirement Mapping, all Status = pending).

### Phase 2: API Contract (TL solo)

1. Read `references/api-contract-template.md` → write `{date}-API_CONTRACT.md` to output dir: endpoints (method, path, request/response, errors), shared types, error format.
2. AskUserQuestion: confirm contract.
3. Update `{date}-TRACE.md`: fill API Contract Trace table.
4. Contract change rule: any change requires TL approval. Worker → TL → decision → notify all workers.

### Phase 3: Team Assembly

1. TeamCreate: `"dev-<project>-<feature>"`

2. Read `references/process-log-template.md` → init `{date}-PROCESS_LOG.md` in output dir.
   Read `references/issues-template.md` → init `{date}-ISSUES.md` in output dir.

3. **TL decides worker count:**
   \```
   Calculate total workload: sum of all task points (S=1, M=2, L=3)
   Target: 3-5 points per worker
   frontend + backend → at least 1 of each
   Interdependent tasks → assign to same worker
   Upper limit: 5 workers max
   \```

4. Spawn agents (Task tool with team_name):
   - challenger (Sonnet, teammate)
   - workers (Sonnet, teammates)

5. **Load prompt templates on demand**: Glob `**/dev-team/**/prompts/` → Read.
   Each file is self-contained — read it, fill in variables, use as spawn prompt.

6. Update `{date}-TRACE.md` Worker column. Append `{date}-PROCESS_LOG.md`: `team-assembled`.

7. Assign initial tasks:
   - TL assigns first task to each worker (TaskUpdate owner).
   - After initial assignment, workers self-assign subsequent tasks.
   - Notify challenger: review task decomposition + API Contract.

### Phase 4: Pipeline Development & Review

**Three parallel pipelines:**

| Pipeline | Actor | Trigger |
|----------|-------|---------|
| Development | Workers | Self-assign from TaskList |
| Review | TL → QA sub-agents | Worker marks task completed |
| Challenge | Challenger | TL notifies at checkpoints |

1. Workers execute tasks in parallel, each within their File Scope.

2. Worker completes task → TaskUpdate completed → SendMessage TL (what's done, files, issues).
   Worker then self-assigns next available task from TaskList.

3. **TL receives completion:**
   a. Update TRACE → `done`, append PROCESS_LOG (`task-completed`).
   b. Read `references/qa-review-template.md` → spawn QA sub-agent (Task tool, subagent_type: "general-purpose", model: "sonnet", NOT a teammate).
   c. QA sub-agent reviews and returns structured result.

4. **QA result handling:**
   - **PASS** → TL updates TRACE → `qa-pass`, appends PROCESS_LOG (`review-pass`).
   - **FAIL** → TL updates TRACE → `qa-fail`, appends PROCESS_LOG (`review-fail`), adds ISSUES entry. Creates fix task with file_scope (goes back to task pool).

5. **Challenger checkpoints** (TL notifies challenger to review):
   - After Phase 2: review API Contract design
   - After each batch of completed tasks: review cross-task consistency
   - Phase 5: participate in contract verification

6. **Edge case handling:**
   - Worker finds task too complex → SendMessage TL → TL splits or reassigns.
   - Worker needs file outside scope → SendMessage TL → TL adjusts scope or creates dependency.
   - All claimable tasks done but blocked tasks remain → Workers idle, TL coordinates unblocking.
   - Adding workers mid-flight: TL spawns new worker, assigns tasks.

### Phase 5: Contract Consistency Check

TL spawns dedicated QA sub-agent for contract verification + notifies challenger to participate.
Sub-agent uses structured prefix `CONTRACT-CHECK: {endpoint} | Backend: {pass/fail} | Frontend: {pass/fail}`:
- Backend API matches contract? Frontend calls match contract?
- Request/Response alignment? Error handling? Shared types?

TL updates TRACE API Contract Trace Verified column.
Inconsistencies → add ISSUES entry. Fail → back to pipeline (create fix task). Pass → Phase 6.

### Phase 6: Delivery

1. Finalize `{date}-TRACE.md` Summary counts.
2. Read `references/delivery-report-template.md` → write `{date}-DELIVERY_REPORT.md` to output dir.
3. Present to user: list all 5 output files (`{date}-TRACE.md`, `{date}-API_CONTRACT.md`, `{date}-PROCESS_LOG.md`, `{date}-ISSUES.md`, `{date}-DELIVERY_REPORT.md`) with paths.
4. Shutdown: shutdown_request to challenger + all workers → confirm all teammates closed → TeamDelete.
5. Do NOT auto-commit/push. User decides.
```

**Step 2: Verify line count is reasonable (target: ~170-190 lines)**

Run: `wc -l plugins/dev-team/skills/dev-team/SKILL.md`
Expected: Between 160-200 lines.

**Step 3: Commit**

```bash
git add plugins/dev-team/skills/dev-team/SKILL.md
git commit -m "feat(dev-team): rewrite SKILL.md for task pool architecture v2.0"
```

---

### Task 7: Update GUIDE.zh-TW.md

**Files:**
- Modify: `plugins/dev-team/docs/GUIDE.zh-TW.md`

**Step 1: Replace GUIDE.zh-TW.md with updated content reflecting v2.0**

Key changes to make:
- Version: 1.3.0 → 2.0.0
- Architecture diagram: remove pg-leader, qa-leader, explore-leader; add challenger
- Role table: update to TL + challenger + workers
- v1.3 → v2.0 changelog: replace lightweight/full mode with task pool
- Phase descriptions: update to reflect new flow
- Communication path diagram: flatten hierarchy
- File structure: update prompts list (remove leaders, add challenger, add qa-review-template)
- FAQ: update to reflect new architecture

The guide should be ~250 lines, following the same structure as v1.3 guide but with updated content for v2.0.

**Step 2: Verify the file reads correctly and is ~250 lines**

Run: `wc -l plugins/dev-team/docs/GUIDE.zh-TW.md`
Expected: Between 230-270 lines.

**Step 3: Commit**

```bash
git add plugins/dev-team/docs/GUIDE.zh-TW.md
git commit -m "docs(dev-team): update GUIDE.zh-TW.md for v2.0 task pool architecture"
```

---

### Task 8: Update plugin.json version

**Files:**
- Modify: `plugins/dev-team/.claude-plugin/plugin.json`

**Step 1: Update version and description**

Old:
```json
{
  "version": "1.3.0",
  "name": "dev-team",
  "description": "開發團隊：多角色流水線協作（PM/開發者/QA），動態規模，混合 teammates + sub-agents",
```

New:
```json
{
  "version": "2.0.0",
  "name": "dev-team",
  "description": "開發團隊：任務池架構（TL + challenger + workers），自取任務、事件驅動 QA、file scope 防護",
```

**Step 2: Commit**

```bash
git add plugins/dev-team/.claude-plugin/plugin.json
git commit -m "chore(dev-team): bump version to 2.0.0"
```

---

### Task 9: Update project memory

**Files:**
- Modify: `~/.claude/projects/C--Users-a0304-IdeaProjects-TouchFish-Skills/memory/MEMORY.md`

**Step 1: Update dev-team section in MEMORY.md**

Update the line about dev-team to reflect v2.0:
- Change "dev-team v1.3.0" references to "dev-team v2.0.0"
- Update description: task pool architecture, challenger role, no more leaders

**Step 2: No commit needed (memory is outside repo)**

---

### Task 10: Final verification

**Step 1: Verify all expected files exist**

```bash
cd C:/Users/a0304/IdeaProjects/TouchFish-Skills
ls plugins/dev-team/skills/dev-team/prompts/
# Expected: challenger.md  worker.md (only 2 files)
ls plugins/dev-team/skills/dev-team/references/
# Expected: 6 files (5 original + qa-review-template.md)
```

**Step 2: Verify no references to removed roles in SKILL.md**

```bash
grep -i "pg-leader\|qa-leader\|explore-leader\|lightweight\|full mode" plugins/dev-team/skills/dev-team/SKILL.md
# Expected: no matches
```

**Step 3: Verify version consistency**

```bash
grep "version" plugins/dev-team/.claude-plugin/plugin.json
# Expected: "version": "2.0.0"
grep "版本" plugins/dev-team/docs/GUIDE.zh-TW.md | head -1
# Expected: contains "2.0.0"
```

**Step 4: Git log to verify all commits**

```bash
git log --oneline -10
```

Expected: 7 new commits for tasks 1-8.
