# Multi-agent handoff protocol (portable to any project "track")

How a **lead reviewer** agent (for example a Codex agent), an **observer/lead** (a Claude Code session) and
**worker** sessions hand work to each other without the Owner copy-pasting messages. Replace `<track>` with the
project name.

## 1. Roles
| Role | Does | Never |
|---|---|---|
| **Owner** | business, pricing and policy calls; production, payments and deploys | copy-paste between agents |
| **Lead reviewer** | designs, reviews source, gives the primary ACCEPT or CHANGES, approves merges where delegated, runs production steps under the Owner's approval | edits the observer's files |
| **Observer (project lead)** | dispatches tasks, keeps the files below, merges under the merge rule, gives the Owner plain-language updates, keeps a NEXT list | implements large work itself |
| **Workers (pools)** | implement one task card each, and review other workers' work | edit the ledger, board or decisions files |

Independent review is always done by a session that did **not** write the change.

## 2. Files (in `<protocol-root>/<track>/guidance/`)
```
LEDGER.md                  append-only conversation between the agents (the only place they talk)
signals/<agent>.txt        one line per agent: the latest sequence number it wrote to the ledger
signals/README.md          the short form of this protocol
tasks/BOARD.md             one row per task: status, owner, branch/MR, next action (the observer writes it)
tasks/<ID>-<slug>.md       one task card per task (section 5)
tasks/records/<ID>-<head>/ retained evidence: INDEX.md + logs (head, command, runtime, exit code)
FEATURE_DECISIONS.md       the Owner's decisions as feature decisions + testable behaviours
MR_RECONCILIATION.md       every merge request's disposition: merged at which head, with which qualifications
```
**Single writer per file.** Agents append only their own ledger entries and change only their own signal file.
If the ledger grows past a few thousand lines, rotate it (start a new file per month) so agents can still read it.

## 3. Signalling
1. **Write first:** append a ledger entry with the heading `## <From> -> <To>: <short subject> (<seq> <date>)`.
2. **Then signal:** overwrite your own signal file with one line:
   `seq=<n> at=<ISO time from the date command> entry="<the exact heading>"`.
   **Always take the time from `date +%Y-%m-%dT%H:%M:%S%z`. Never estimate it.**
3. **Watch the other side's signal file.** For example, a 3-second loop in the observer:
   ```bash
   G=<protocol-root>/<track>/guidance; F=$G/signals/reviewer.txt; last=$(cut -d' ' -f1 "$F")
   while true; do
     cur=$(cat "$F"); key=$(echo "$cur" | cut -d' ' -f1)
     [ -n "$cur" ] && [ "$key" != "$last" ] && { echo "SIGNAL: $cur"; last=$key; }
     sleep 3
   done
   ```
   The reviewer agent polls the observer's signal file on its own heartbeat. In Codex, that's an automation
   the Owner creates.
4. **Read only the new entry** (from its heading to the next `## `), act on it, then reply in the ledger.

**Never end in mutual waiting.** If both sides are idle, the observer acts on what is already agreed or asks one
concrete question.

## 4. Talking to workers
Every dispatch includes:
- the task card path;
- the base branch and **exact SHA**, the new branch name, and the merge-request target;
- the exact files the task owns, plus the files it must not touch;
- the laws to prove (red first, then green) and the evidence folder;
- the reply format: MR, head SHA, evidence paths, and **what is NOT proven**.

## 5. Task card
See `templates/TASK_CARD.md`. When a design changes, update the card's **CURRENT INSTRUCTION** header, so there
is only ever one live instruction.

## 6. Review and merge gate
1. **Self-check before calling it ready.** Exact head, retained records, what each law does and does not prove.
2. **The lead reviewer's primary review:** ACCEPT or CHANGES at that **exact head SHA**.
3. **The independent review** by a non-author session at the **same exact head**.
4. **Any new commit invalidates both.** Re-review only the delta. Implementers **hold** once a head is accepted.
5. **The standing merge rule** (Owner-granted): the observer merges once the reviewer's ACCEPT and the
   independent ACCEPT exist at the same head, and records it in MR_RECONCILIATION.md. Areas the Owner marks
   sensitive (e.g. money paths) also need the reviewer's explicit merge approval.
6. **Product defects or weakened laws get CHANGES.** Evidence-scope gaps on sound code become recorded
   qualifications, not another round.
7. **After each merge,** verify the merged tree equals the accepted head plus the target.
8. **Release gates must exercise the real thing:**
   - the real runtime;
   - the real user-visible path, including authenticated reads;
   - the real artifact: the rendered page, the actual audio, the actual purchase.

   On failure, record the failing check's name and error code.

## 7. Rules that travel
- Escalate to the Owner only business, policy, pricing, payment, production, credential and customer-data calls.
- Relay Owner decisions verbatim into the ledger, with the exact question asked.
- Persist state in files, not chat. Use absolute dates.
- Pace usage under the Owner's caps.
- Holds stay holds: nothing in production, payment, provider or deploy without the Owner's words.

## 8. Starting a new track
1. Create `<protocol-root>/<track>/guidance/{signals,tasks/records}`. Add LEDGER.md, tasks/BOARD.md,
   FEATURE_DECISIONS.md and MR_RECONCILIATION.md. Add the signal files (start each at `seq=0`).
2. Put the short form of this protocol in `signals/README.md`.
3. The Owner tells the reviewer agent (once, in its own chat) the ledger path, its signal file, its heartbeat, its
   scope, and **the track's end condition** if the track is temporary.
4. The observer starts its watch loop, then starts 2-3 worker sessions and points each at its first card.
5. First ledger entry: roles, merge rule, holds and the Owner's priorities, in their words.
6. **Temporary tracks close explicitly:** a closing ledger entry, signals set to closed, watchers stopped, the
   board marked CLOSED.
