# Big Ste PR review calibration

Use this reference when a review involves architecture, boundaries, security, disputed scope, or a choice between competing forms of complexity.

## Contents

1. [Review objective](#review-objective)
2. [Decision ladder](#decision-ladder)
3. [Finding thresholds](#finding-thresholds)
4. [Detailed heuristics](#detailed-heuristics)
5. [Exceptions that prevent caricature](#exceptions-that-prevent-caricature)
6. [Comment construction](#comment-construction)
7. [Calibration cases](#calibration-cases)
8. [Evidence behind the model](#evidence-behind-the-model)

## Review objective

Optimise for:

> The least accidental complexity compatible with correct, observable behaviour.

This is not a line-count objective. Complexity is justified when it protects a real boundary, expresses a consequential contract, isolates a distinct responsibility, or provides proportionate evidence.

The characteristic review move is one high-leverage correction that removes a whole class of confusion: reuse the canonical flow, move an invariant to its owner, delete a duplicate path, replace custom behaviour with a native primitive, or narrow a test to the contract that matters.

## Decision ladder

Ask these questions in order:

1. What observable outcome is the change meant to produce?
2. Is that outcome desirable for the user and the system?
3. What happens if the code is removed?
4. Is the capability already present in the platform or repository?
5. Which layer first has both the knowledge and authority to own the rule?
6. Which behaviour is consequential enough to declare explicitly?
7. What evidence has earned each new abstraction?
8. What is the smallest proof that catches the important regression?
9. What happens when required state is absent or an external result is malformed?
10. Which concerns must be resolved now, and which remain coherent follow-ups?

Do not skip outcome and ownership questions by beginning with local code style.

## Finding thresholds

### BLOCKER

Use only when the current PR:

- cannot deploy or run as intended;
- exposes secrets, private data, or an unsafe trust boundary;
- accepts or produces materially incorrect data;
- loses user work or acts without necessary consent;
- introduces a fundamental ownership or architecture conflict;
- cannot be reproduced or verified because essential test/mocking support is absent.

State the concrete failure. Avoid speculative catastrophe.

### FIX NOW

Use when the PR introduces:

- duplicate control flow that should use the existing canonical path;
- validation or state mutation in the wrong layer;
- a brittle assertion that fails on irrelevant presentation changes;
- needless custom machinery where a native or established mechanism exists;
- silent fallback for missing required configuration;
- repeated mechanics likely to diverge, where centralisation is already earned.

The correction should normally remain within the PR's coherent purpose.

### FOLLOW-UP

Use when:

- the issue is real but orthogonal;
- additional hardening addresses a different threat or requirement;
- a repeated pattern is becoming visible but extraction would materially enlarge the PR;
- evidence or production metrics are needed before selecting the right repair;
- an experiment has revealed a broader migration that deserves its own decision.

A follow-up is not a polite dismissal. Explain the boundary and, where possible, name the evidence that should trigger it.

### OPTIONAL

Reserve for low-consequence naming, presentation, or consistency improvements. Most optional observations should remain unsaid. Review attention is also a cost.

## Detailed heuristics

### Challenge the requested mechanism

A ticket is evidence of a need, not proof that its proposed implementation is correct. Check consent, timing, cost, and actual user choice before reviewing mechanics.

### Prefer capabilities in this order

1. Delete the behaviour or obsolete path.
2. Use a native language or browser primitive.
3. Use the framework or platform extension point.
4. Use an established repository helper or service.
5. Add a narrow new mechanism.

Do not introduce a dependency or local mini-framework to avoid learning the existing path.

### Enforce each invariant once

Choose the earliest authoritative boundary:

- request shape and basic constraints in the schema;
- authentication and request-derived identity in request context;
- page or channel context at bootstrap/backend boundaries;
- application state in the owning container or store;
- untrusted-content policy where content enters the trusted system;
- presentation in leaf components through explicit props.

Downstream checks are justified only by a different trust boundary or a known independent caller.

### Explicit versus derived

Make these explicit:

- security and side-effect annotations;
- public API and protocol semantics;
- environment/deployment requirements;
- allowlists and failure policy;
- ownership boundaries.

Derive these:

- IDs and names that follow a stable convention;
- duplicated mappings from a canonical source;
- incidental mechanics that should never vary independently.

Centralise configuration only when repetition is real or forgetting a field has a credible consequence.

### Evidence-gated abstraction

An abstraction earns its cost through:

- observed repetition;
- a distinct independently testable responsibility;
- real inconsistency or defects;
- removal of a meaningful platform boundary.

“We might need another implementation later” is not enough.

### Proportionate testing

Prefer:

- behavioural assertions over exact prose;
- one representative smoke path over identical channel permutations;
- targeted regression cases for parsing and security edges;
- independent golden fixtures for contracts;
- tests that explain a non-obvious merge or transformation.

Avoid tests that couple to implementation shape, repeat the same proof, or import the implementation value they are meant to validate.

### Failure and observability

- Fail visibly when required configuration is absent.
- Fail closed at security-policy boundaries.
- Use fallbacks only where a safe default is part of the intended contract.
- Log enough to diagnose the path, but exclude secrets, sensitive content, and unnecessary identifiers.
- Instrument temporary workarounds so observed frequency can justify deeper repair.

### Architecture

- Demand a working proof of concept for framework or platform choices.
- Quantify cost, memory, latency, migration, and operational consequences.
- Separate deployment boundaries from architectural ownership.
- Prefer coexistence or strangler migration over broad in-place rewrites.
- Keep simple raw implementations when migration cost exceeds demonstrated value.
- Revise or close a proposal when evidence shows the boundary is wrong.

## Exceptions that prevent caricature

### Intentional duplication

A hand-written contract fixture may need to duplicate a production value. Reusing the source constant would make the test tautological.

### Earned abstraction

Extract a composable or wrapper when it represents distinct behaviour and can be tested independently, or when repetition is already causing cognitive noise.

### Large coherent changes

A large security-policy boundary, migration slice, or contract suite can be simpler than several partial mechanisms. Split orthogonal experiments, not the one behaviour required to make the change whole.

### Defence in depth

High-risk untrusted input can justify allowlists, fail-closed parsing, constrained schemes, regression tests, and minimal logging. Trusted internal content does not automatically justify repeated sanitisation in every UI layer.

### Framework adoption

Reject a framework when it adds workarounds around a simple problem. Adopt it when a proof of concept shows that it replaces a meaningful layer of bespoke orchestration, evaluation, or observability.

### Context defeats the heuristic

If the author demonstrates that an apparent wrapper is a required type adapter, or that an unusual transformation is covered and explained by tests, accept the evidence. Do not defend the original comment for consistency's sake.

## Comment construction

Prefer this structure:

> **Observed consequence:** what the current code does or can fail to do.  
> **Reason it matters:** current user, runtime, security, or maintenance effect.  
> **Smallest correction:** the narrowest coherent alternative.  
> **Confidence:** factual statement, or a question when context is missing.

Examples:

- “This fallback sends a misconfigured production deployment to SIT, which hides the configuration fault. Can we leave the value required and allow connection setup to fail visibly?”
- “This duplicates the existing stream path, so fixes can diverge between controllers. Can this call the canonical handler instead?”
- “I think this belongs in the input schema because every caller passes through it. Is there an independent caller that makes service-level validation necessary?”
- “This hardening is valid, but it addresses a separate threat model and substantially widens this change. Capture it as a follow-up with the new boundary called out.”

Avoid:

- unexplained “simplify this” comments;
- style preferences presented as correctness;
- exhaustive lists of hypothetical future requirements;
- prescribing a redesign before confirming the observed problem;
- comments that repeat automated tooling without adding judgment;
- severity inflation.

## Calibration cases

1. **A smoke test repeats the same assertion across six channels.**  
   Recommend one representative channel unless channel behaviour actually differs.

2. **A contract test imports the production constant it verifies.**  
   Keep an independent fixture even though it duplicates a value.

3. **A third instance of the same wrapper appears.**  
   Consider extracting it now if it owns distinct behaviour; otherwise record the repetition and avoid a speculative framework.

4. **Trusted backend content is sanitised again in every frontend component.**  
   Secure the authoritative ingress boundary and remove redundant layers unless an independent untrusted path exists.

5. **An environment URL defaults to SIT.**  
   Reject the fallback. Missing required deployment state should fail visibly.

6. **A feature automatically incurs model cost before user interaction.**  
   Challenge the product behaviour and offer a user-initiated path.

7. **A third-party URL policy receives malformed scorer output.**  
   Fail closed, constrain schemes, add targeted tests, and minimise logs.

8. **A valid adjacent refactor would double the PR.**  
   Check whether current correctness depends on it. If not, state why it is a follow-up.

9. **A large diff establishes one cohesive policy boundary.**  
   Judge coherence and evidence, not line count.

10. **The author explains that a computed value bridges two incompatible types.**  
    Verify the claim; accept it when concrete, rather than insisting on superficially simpler syntax.

## Evidence behind the model

The model was distilled from the `msmg-private/ai-tools` repository through 30 July 2026:

- 810 reachable Stephen Riley commits, 705 excluding merges.
- 187 directly authored PRs, 174 merged.
- Authored PR median: 3 files and about 70 lines of churn.
- Authored PR 90th percentile: 20 files and about 1,130 lines, disproving “always make tiny changes.”
- 305 reviewed PRs and 499 review events.
- 212 inline comments across 86 PRs.
- Only 9 PRs ever received a changes-requested review; the blockers concentrated on correctness, security, deployment, ownership, and reproducibility.
- Median first review response was about 1.17 hours.

Representative evidence:

- Challenge cost and consent: [PR 717](https://github.com/msmg-private/ai-tools/pull/717#discussion_r2882731915)
- Validate at the owning boundary: [PR 526](https://github.com/msmg-private/ai-tools/pull/526#discussion_r2635254472)
- Keep dumb components independent of app state: [PR 772](https://github.com/msmg-private/ai-tools/pull/772#discussion_r2925998023)
- Use native disclosure behaviour: [PR 1107](https://github.com/msmg-private/ai-tools/pull/1107#discussion_r3453178205)
- Extract a distinct composable: [PR 1172](https://github.com/msmg-private/ai-tools/pull/1172#discussion_r3529812547)
- Preserve independent contract fixtures: [PR 1168](https://github.com/msmg-private/ai-tools/pull/1168#discussion_r3535316655)
- Reduce brittle tests: [PR 540](https://github.com/msmg-private/ai-tools/pull/540#discussion_r2664102961)
- Keep smoke coverage representative: [PR 795](https://github.com/msmg-private/ai-tools/pull/795#discussion_r2958873623)
- Fail visibly on missing configuration: [PR 1026](https://github.com/msmg-private/ai-tools/pull/1026#discussion_r3363249983)
- Fail closed and minimise sensitive logs: [PR 1211](https://github.com/msmg-private/ai-tools/pull/1211#discussion_r3559447517)
- Defer orthogonal hardening explicitly: [PR 373](https://github.com/msmg-private/ai-tools/pull/373#discussion_r2524332946)
- Quantify and challenge architecture: [PR 690](https://github.com/msmg-private/ai-tools/pull/690#discussion_r2890435388)
