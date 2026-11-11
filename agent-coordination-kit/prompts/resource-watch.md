Overnight shared-machine resource watch (run every ~20 min while heavy jobs run; delete itself after <end time>).
Read-only: `sysctl -n vm.loadavg; sysctl -n vm.swapusage; memory_pressure | tail -1` (macOS; use free/vmstat on
Linux). SAFE = memory free >= 30% AND 1-min load < 15 AND swap free >= 0.5 GB. If NOT safe, send ONE short message to
the session running heavy jobs: "PAUSE after the current job (mem free Y%, load Z, swap free X)"; don't repeat within
60 min; when safe again, send ONE "resume allowed". Never kill or edit any process or file yourself. Log one line.
Notify the Owner only if memory free < 10% and two pauses already failed.
Note: macOS grows swap on demand, so memory pressure (not swap free) is the real freeze signal. Heavy job loops must
also check these gates themselves before each job, because a queued message may not reach a busy session in time.
