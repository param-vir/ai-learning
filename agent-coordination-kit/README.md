# Agent coordination kit

A lightweight, file-based way to run several software projects with AI coding agents: one **CEO agent** above
several **project leads**, each lead coordinating a **lead reviewer** agent and a few **worker** sessions. A human
**Owner** makes the decisions only they can make.

It needs no server. Everything is markdown files, git, and the agents' own session tools (for example Claude Code
sessions and a Codex agent). It is meant to be copied and adapted.

## Roles
| Role | Who | Owns | Never |
|---|---|---|---|
| **Owner** | the human | business, pricing, policy, production, payments, credentials | copy-pasting between agents |
| **CEO agent** | one Claude Code session | the company picture, cross-project priorities and dependencies, one Owner interface (inbox + daily brief), holding leads to their dates | project work: code, reviews, deploys |
| **Project lead** | one Claude Code session per project | its project end to end: plan, dispatch, review gate, NEXT list, state summary | sitting idle while unblocked work exists |
| **Lead reviewer** | e.g. a Codex agent per project | design review, primary ACCEPT/CHANGES at an exact commit, production execution under the Owner's approval | editing the lead's files |
| **Workers (pools)** | 2-5 sessions per project | one task card each; reviewing other workers' changes | editing the ledger, board or decisions |

## What's in here
- `protocol/CEO_CHARTER.md`: what the CEO owns and never does; cadence; how it talks to leads.
- `protocol/HANDOFF_PROTOCOL.md`: lead <-> reviewer <-> workers: ledger, signals, task cards, review/merge gate.
- `protocol/RULES.md`: the hard-won rules (time, real-path checks, NEXT lists, approvals, secrets, resources).
- `templates/`: state summary, accountability tracker, Owner decision inbox, decision log, run log, daily brief,
  task card, ledger entry, signal line.
- `prompts/`: the CEO's hourly check-in, the morning brief, and an optional overnight resource watch.
- `bin/check-sources.sh`: fingerprints each project's summary sections so the hourly check-in reads only what
  changed.

## Getting started
1. Create a private repo for the CEO (copy `templates/` into it; configure `bin/check-sources.sh`).
2. Give each project a lead session and a `PENDING.md` with a **STATE OF PLAY** section (template) and a NEXT
   list.
3. For each project with a lead reviewer agent, create its track folder (see HANDOFF_PROTOCOL §8).
4. Start the CEO session and schedule `prompts/hourly-checkin.md` (hourly) and `prompts/morning-brief.md`
   (daily). Scheduled prompts in Claude Code are session-only: re-create them after a restart.
5. The Owner talks to any lead directly at any time. Every instruction they give must land in that project's
   decision log or task record, the same turn.

## Known limits (be honest about them)
- **Approvals.** An LLM reviewer (such as Codex's automatic approval review) will not trust approvals relayed by
  another agent. Use numbered one-line batches, a few standing sentences for safe classes of action, and
  local scripts for secrets. A deterministic signature check is the real fix (see RULES.md).
- **Polling.** File signals plus polling add minutes of latency. A real message bus with wake-ups is the
  upgrade path.
- **Durability.** Scheduled prompts and session-only timers die on restart; an always-on host helps.
