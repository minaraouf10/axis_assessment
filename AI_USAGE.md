# AI usage log

This file records prompts and decisions from building the Currency Exchange Tracker.

## 2026-09-08 — Implementation in Cursor

**Prompt used:** implement the Axis assessment from `CURSOR_BUILD_SPEC.md` (Currency Exchange Tracker: Clean Architecture, Cubit, get_it, Dio, Hive, go_router, offline cache, 7-day chart, tests, incremental git history).

**What the agent generated:** full `lib/` tree matching the spec folder structure, unit/cubit/widget tests, and README.

**Accepted as-is:**
- Layer split (`data` / `domain` / `presentation`) and `Either<Failure, T>` mapping in the repository
- Separate `RatesListCubit` and `CurrencyDetailCubit`
- Hive JSON cache (no TypeAdapter codegen) for latest rates and history
- Chart shimmer via `shimmer` instead of a spinner
- Green/red rule: EGP strengthened when EGP-per-unit **decreased**

**Edited / constrained:**
- Did not invent extra assessment docs beyond README and this log
- `AI_USAGE.md` written here to match the actual Cursor session, not a fabricated multi-day prompt history
- Git history kept as the spec’s 20 focused commits rather than one dump commit

**Rejected:**
- Calling Dio from a Cubit
- Merging list + detail into one Cubit
- Squashing the required commit plan
