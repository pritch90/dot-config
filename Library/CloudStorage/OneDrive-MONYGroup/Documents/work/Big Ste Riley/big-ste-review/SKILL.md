---
name: big-ste-review
description: "Reviews pull requests using the Big Ste decision model: evidence-gated simplicity, correct ownership, proportionate tests, visible failures, and disciplined scope. Use when reviewing a PR, diff, patch, or proposed coding change; when checking whether a solution is overengineered; or when deciding which findings should block, be fixed now, or become follow-up work."
---

# Big Ste Review

Review for the least accidental complexity compatible with correct, observable behaviour. Seek the smallest coherent solution, not the smallest diff.

## Gather evidence

1. Read repository instructions and the surrounding code before judging the diff.
2. Establish the PR's intended user, runtime, and operational outcome.
3. Inspect the complete diff, tests, PR description, linked issue, existing review threads, and checks when available.
4. Use repository-native and GitHub tooling. When `gh` is available, prefer it to browser archaeology.
5. Distinguish observed facts from assumptions. Ask one precise question when missing context could reverse a finding.

For architectural, security-sensitive, unusually large, or disputed reviews, read [references/review-calibration.md](references/review-calibration.md) before concluding.

## Review in this order

1. **Outcome** — Does the change solve the real problem without violating user intent, consent, cost, or operational constraints?
2. **Necessity** — Can code, configuration, or an obsolete path disappear?
3. **Existing capability** — Can a language, browser, framework, platform, or repository-standard mechanism do this already?
4. **Ownership** — Is each invariant enforced once, at the earliest layer with the information and authority to own it?
5. **Explicitness** — Make security, side effects, public contracts, and deployment behaviour explicit. Derive incidental mechanics that should not vary.
6. **Abstraction** — Require observed repetition, a distinct independently testable responsibility, or demonstrated inconsistency. Reject speculative flexibility.
7. **Evidence** — Ask for the smallest test or observation that would catch the important regression. Test behaviour, not incidental wording or implementation shape.
8. **Failure** — Prefer visible failure for missing required state, conservative handling at untrusted boundaries, and safe observability for workarounds.
9. **Scope** — Separate necessary corrections from valid but orthogonal follow-up work.

## Calibrate findings

Classify each concern:

- **BLOCKER** — Current correctness, security, privacy, deployment, data-loss, or fundamental ownership failure. The PR should not merge.
- **FIX NOW** — A concrete defect or meaningful avoidable complexity introduced by this PR, with a small coherent correction.
- **FOLLOW-UP** — Valid work that is not required for this PR to be safe and coherent. Name the reason it can be deferred.
- **OPTIONAL** — A genuine improvement with little behavioural consequence. Omit it unless it materially helps the author.

Do not manufacture findings to fill categories. Prefer a few high-leverage comments. Approve when no material concern remains.

## Preserve the important exceptions

- Do not equate simplicity with fewer lines or smaller diffs.
- Do not apply DRY to independent contract fixtures that must detect drift.
- Do not reject abstractions that isolate a real responsibility or remove demonstrated repetition.
- Do not demand defence in depth without a credible threat path; do demand it at high-risk untrusted boundaries.
- Do not hide missing required configuration behind a convenient fallback.
- Do not expand the PR merely because adjacent debt is visible.
- Accept a concrete author explanation when it defeats the initial heuristic.
- Change the recommendation when new evidence changes the model.

## Report

Lead with a one-sentence verdict. Then list only supported findings, highest severity first. For each finding:

1. Point to the smallest relevant file and line range.
2. State the observed behaviour or failure mode.
3. Explain why it matters now.
4. Recommend the simplest coherent correction, without prescribing a large redesign unless necessary.

End with explicitly deferred follow-ups only when they were raised during the review. If there are no material findings, say so plainly and identify any residual uncertainty or unverified check. Do not modify code, submit reviews, or post comments unless the user asks.
