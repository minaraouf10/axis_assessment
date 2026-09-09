# AI Usage Log

This document records how AI tools were used throughout the development of the Currency Exchange Tracker, following the assessment's required format: prompt → output → decision → reasoning.

---

## Session 1: Project Scaffolding & Architecture

### Prompt 1.1 — Initial Project Structure
- **Prompt:** "Create a Flutter project for a Currency Exchange Tracker using Clean Architecture (domain/data/presentation), BLoC/Cubit for state management, get_it for DI, Dio for HTTP, Hive for local caching, and GoRouter for navigation. Base currency is EGP, target currencies: USD, EUR, GBP, SAR, JPY. The API is https://latest.currency-api.pages.dev/v1/currencies/egp.json"
- **AI Output:** Generated a full project scaffold with:
  - `lib/core/` — DI container, Dio client wrapper, network info, theme system, shared widgets
  - `lib/features/exchange/domain/` — `CurrencyRate`, `HistoricalPoint`, `SupportedCurrency` entities, repository contract, two use cases
  - `lib/features/exchange/data/` — Models with `fromJson`/`toJson`, remote and local data sources, repository implementation
  - `lib/features/exchange/presentation/` — `RatesListCubit`, `CurrencyDetailCubit`, pages, and widgets
- **Decision:** ✅ Accepted with modifications
- **Why:** The generated structure correctly applied Clean Architecture with proper dependency direction (domain has no Flutter imports). I modified: (1) added `clock` injection to `ExchangeRemoteDataSourceImpl` for deterministic testing, (2) used `sealed class` for states instead of abstract class for exhaustive Dart 3 pattern matching, (3) changed the barrel file approach to a single `app_import.dart` for convenience in a small project.
- **⚠️ Later reversed — see [Session 6.6](#prompt-66--reversing-my-own-barrel-decision).** Decision (3) was mine, not the AI's, and it was wrong. It silently broke the very layer separation the rest of the architecture was built to enforce.

### Prompt 1.2 — Rate Inversion Logic
- **Prompt:** "The API returns EGP-to-foreign rates (e.g., egp.usd = 0.019). I need to display foreign-to-EGP (e.g., 1 USD = 52.01 EGP). Implement the inversion in the model layer."
- **AI Output:** Created `CurrencyRateModel.fromInvertedApi()` with `1 / egpToForeign` inversion, plus daily change calculation comparing today's inverted rate with yesterday's.
- **Decision:** ✅ Accepted as-is
- **Why:** The inversion logic was correct and placed in the data layer (model), keeping the domain entity clean. The edge case of `egpToForeign == 0` was handled by returning 0.

---

## Session 2: Offline Caching & Error Resilience

### Prompt 2.1 — Cache Layer
- **Prompt:** "Implement Hive-based local caching for both latest rates and historical rates per currency. Cache should persist between app launches."
- **AI Output:** Generated `ExchangeLocalDataSourceImpl` storing JSON-encoded lists in a Hive box with keys `latest_rates` and `history_{CODE}`.
- **Decision:** ✅ Accepted with modification
- **Why:** The serialization approach was clean. I modified `getCachedLatestRates` to mark returned items with `isFromCache: true` via `copyWith`, so the UI can show an offline indicator.

### Prompt 2.2 — Stale Cache Fallback
- **Prompt:** "When the device is online but the API fails (timeout, server error), fall back to stale cached data instead of showing an error. Only show error if both remote AND cache fail."
- **AI Output:** Added a nested try-catch in `ExchangeRepositoryImpl`: on `ServerException`, attempt `getCachedLatestRates`; if that also throws `CacheException`, return `ServerFailure`.
- **Decision:** ✅ Accepted as-is
- **Why:** This handles the real-world scenario of captive portals or server downtime where `connectivity_plus` reports "connected" but the API is unreachable. Applied the same pattern to `getHistoricalRates`.

---

## Session 3: Parallel Fetching & Performance

### Prompt 3.1 — Historical Data Parallelization
- **Prompt:** "The 7 historical API calls are sequential. Refactor to use Future.wait for parallel execution."
- **AI Output:** Replaced the sequential loop with `Future.wait(dates.map(...))`, wrapping each call in try-catch to return `null` on failure, then filtering with `whereType<HistoricalPointModel>()`.
- **Decision:** ✅ Accepted as-is
- **Why:** Parallel fetching reduces total latency from ~7x to ~1x single request time. The null-safety pattern ensures partial failures don't crash the entire fetch — if 5 of 7 days succeed, the chart still renders with available data.

---

## Session 4: UI, UX & Accessibility

### Prompt 4.1 — Chart Error State with Retry
- **Prompt:** "When historical chart data fails but the rate header loaded successfully, show the rate header with an error message and retry button below — not a full-screen error."
- **AI Output:** Created `CurrencyDetailChartError` state containing both the rate and the error message, rendered as a `ListView` with `_RateHeader` + `ErrorView` with `onRetry`.
- **Decision:** ✅ Accepted as-is
- **Why:** Partial error states provide better UX than all-or-nothing — the user can still see the current rate while retrying the chart.

### Prompt 4.2 — Shimmer Loading & Offline Banner
- **Prompt:** "Use shimmer placeholders instead of spinners for the chart loading state. Add an offline banner showing last update time."
- **AI Output:** Generated `HistoryChartShimmer` using the `shimmer` package with theme-aware colors, and `OfflineBanner` with formatted timestamp.
- **Decision:** ✅ Accepted with minor edit
- **Why:** Shimmer gives a more polished loading experience. I adjusted the shimmer colors to use `surfaceContainerHighest` instead of hardcoded grays for proper dark mode support.

### Prompt 4.3 — Accessibility Semantics
- **Prompt:** "Add semantic labels to the currency rate tiles, chart, and theme toggle for screen reader accessibility."
- **AI Output:** Added `Semantics` widgets with descriptive labels to `CurrencyRateTile`, `HistoryLineChart`, `_RateHeader`, and `ThemeToggleButton`.
- **Decision:** ✅ Accepted as-is
- **Why:** Accessibility is a quality signal. The labels describe both the element type and its current value (e.g., "USD to Egyptian Pound, rate: 48.2000 EGP").

---

## Session 5: Testing

### Prompt 5.1 — Unit & Widget Tests
- **Prompt:** "Write comprehensive tests covering: remote data source (fetch + error), local data source (cache + retrieve + miss), repository (online/offline/stale-cache matrix), use cases, cubits (state transitions), and widget tests for both pages."
- **AI Output:** Generated 39 tests across 9 test files using `mocktail` for mocking and `bloc_test` for cubit testing.
- **Decision:** ✅ Accepted with modifications
- **Why:** Test coverage was thorough. I modified: (1) fixed test payloads to match the 5 supported currencies, (2) added `BlocProvider<ThemeCubit>.value` in `rates_list_page_test` because the page uses `ThemeToggleButton`, (3) used `ThemeState(mode: ThemeMode.light)` named parameter instead of positional.
- **Gap this suite missed:** it asserted state transitions and widget *presence*, but never that a widget had meaningful *content* — which is why the empty `CircleAvatar` in [Session 6.2](#prompt-62--the-regression-i-introduced) slipped through with a green build. Five tests were added during the fix round to cover the specific defects found (48 total).

---

## Session 6: AI-Assisted Code Review & Fix Round

After the feature work was complete, I ran a full review pass — asking the model to
evaluate the project the way a senior Flutter developer scoring this assessment would,
rather than asking it to write more code. This session is the most useful one in this
log, because it is where AI output was most often *wrong in interesting ways* and where
I had to overrule it.

### Prompt 6.1 — Adversarial Self-Review
- **Prompt:** "Review this project as a senior Flutter developer evaluating a technical assessment. Score it against these criteria: Architecture & Layer Separation, State Management, Error Handling & Resilience, Code Quality, UI & UX, Testing, Git History. Be blunt about what would lose points."
- **AI Output:** Produced a scored review (7.0/10 overall) identifying: an empty `CircleAvatar` rendering as a grey circle on the main list, broken indentation in `currency_rate_tile.dart`, an unguarded `(value as num)` cast, `NetworkFailure` declared but never emitted, two unused widget files, and the `app_import.dart` barrel violating layer separation.
- **Decision:** ✅ Accepted the findings, ❌ rejected its initial framing of one of them
- **Why:** Every code-level finding was real and independently verifiable — I confirmed each one before acting. But the review's first pass described the git problem as "7 duplicated commits," which turned out to be a wrong diagnosis (see 6.5). Taking a review at face value is exactly the failure mode this log is supposed to catch.

### Prompt 6.2 — The Regression I Introduced
- **Context:** The review flagged `CircleAvatar()` with no child in `currency_rate_tile.dart`.
- **What actually happened:** Commit `402fb04` added the flag emoji correctly. A later commit — `5af76bc`, tellingly titled *"fix: resolve syntax issues"* — stripped the child back out while fixing an unrelated parse error. `SupportedCurrency.flag` existed and was referenced nowhere in `lib/`.
- **Decision:** ✅ Accepted the fix (`0b90fc5`)
- **Why:** This is the clearest example in the project of AI-assisted editing causing a silent visual regression. The commit compiled, the analyzer was clean, and all 43 tests passed — nothing automated caught it, because no test asserted the avatar had content. The lesson I took: a green build is not evidence the UI is correct.

### Prompt 6.3 — Unguarded Cast (Accepted)
- **Prompt:** "The `(value as num).toDouble()` in `_fetchRates` is unguarded. What's the actual failure mode?"
- **AI Output:** Explained that a `null` or `String` for any of the 200+ currencies throws a raw `TypeError`, not `ServerException` — and because `fetchHistoricalRates` only catches `ServerException` inside its `Future.wait`, that error escapes and kills all 7 days instead of dropping one.
- **Decision:** ✅ Accepted (`0b793ee`)
- **Why:** The reasoning traced a concrete path from a malformed byte to a broken screen. Fix skips non-numeric entries and only throws when *no* usable rate remains, so one bad currency can't take down the other 199.

### Prompt 6.4 — Cubit Lifecycle (Accepted, Beyond Original Scope)
- **Prompt:** "Are there race conditions in the connectivity-change auto-refresh, or emit-after-close risks in either cubit?"
- **AI Output:** Identified that `CurrencyDetailCubit.load()` skipped the network fetch entirely when `initialRate` was passed from the list, so a cached rate could sit on screen indefinitely. Separately flagged that both cubits `emit` after an `await` with no `isClosed` check — a `StateError` if the user navigates back mid-fetch.
- **Decision:** ✅ Accepted both (`036dc99`)
- **Why:** Neither was in my original review request; both were real. The `isClosed` bug in particular would only surface under fast navigation, which no existing test exercised.

### Prompt 6.5 — Where I Overruled the Diagnosis
- **Prompt:** "Clean up the git history: 7 duplicated commits and one commit whose message is raw AI output."
- **AI Output:** Proposed `git rebase -i a7a066e^` to reword the offending commit.
- **Decision:** ❌ **Rejected — the diagnosis was wrong**
- **Why:** Running it produced real conflicts across 6 files. Inspecting `git log --graph` showed the actual structure: two branches forked from `bf29220`, *each independently made the same 8 commits*, then got merged at `717f687`. I verified this by comparing tree hashes:

  ```
  a7a066e == af873c3    b43f113 == f9cf7c2    3a64100 == ddc82cf    70d25a3 == 8011c3b
  447cb4e == ecdce90    e657a5e == 367cf02    c0bc5ab == 07e8b48    eca0d9b == 5401b22
  ```

  All eight pairs are byte-identical. So it was never "7 duplicate commits" needing individual attention — it was one fully redundant branch. The correct fix is to drop the merge line (which removes the whole duplicate branch) and reword `af873c3` instead of `a7a066e`. Had I run the AI's original command and force-resolved the conflicts, I would have corrupted the history rather than cleaned it.

### Prompt 6.6 — Reversing My Own Barrel Decision
- **Prompt:** "Is the global `app_import.dart` barrel a real violation of Clean Architecture layer separation, or acceptable pragmatism at this project size?"
- **AI Output:** Argued it was a material violation: the single barrel re-exported Dart, Flutter, every third-party package, **and all three feature layers**, meaning the domain layer could transitively see data and presentation — inverting the dependency rule the architecture exists to enforce. It also noted the irony that my *tests* used explicit imports, proving I knew the correct pattern.
- **Decision:** ✅ Accepted — reversed my own earlier choice (`0257a44`)
- **Why:** This is the judgment call I got wrong in Session 1, and I want it on the record rather than quietly edited out. I chose the single barrel for typing convenience and told myself it was fine "in a small project." It was not: it defeated the entire point of the folder structure I had just built. Replaced with four layered barrels —

  | Barrel | May import |
  |---|---|
  | `core/core.dart` | Dart/Flutter + shared packages + `core/` |
  | `domain/domain.dart` | `core.dart` only |
  | `data/data.dart` | `domain.dart` + data sources, models, repo impl |
  | `presentation/presentation.dart` | `domain.dart` + presentation-only packages (`flutter_bloc`, `go_router`, `fl_chart`, `shimmer`) |

  `presentation.dart` deliberately imports `domain.dart`, **never** `data.dart` — the UI talks to use cases only. `injection_container.dart` is kept out of `core.dart` because as the composition root it must wire data and presentation, which would create an export cycle. The rule is now mechanically checkable:

  ```bash
  grep -rn "data/\|presentation/" lib/features/exchange/domain/   # must return nothing
  ```

### Prompt 6.7 — Where I Declined to Let AI Act
- **Context:** The history rewrite in 6.5 required `git rebase` + `--force-with-lease` on commits already pushed to `origin/master`.
- **Decision:** ❌ Rejected automated execution; ran it manually instead
- **Why:** Rewriting already-published history is destructive and hard to reverse. I took a `backup-before-rewrite` branch first and ran the rebase by hand so I could inspect the todo list and the resulting log before force-pushing. Generating the commands was a good use of AI; executing them unattended against a shared branch was not.

### Fix Round — Commits

| Commit | Change |
|---|---|
| `70d57f6` | Remove unused `AppTextField` / `AppDropdown` (dead scaffolding) |
| `0b90fc5` | Restore flag emoji in tile avatar + fix indentation |
| `0b793ee` | Guard non-numeric values in rate payload |
| `1c87daa` | Return `NetworkFailure` when offline with no cache |
| `036dc99` | Always refetch latest rate; guard `emit` after close |
| `0257a44` | Split global barrel into layered barrels |

Result: `flutter analyze` clean, **48 tests passing** (up from 43), `dart format` clean
across 58 files.

---

## Summary of AI Judgment Calls

| Pattern | Decision | Rationale |
|---------|----------|-----------|
| Calling Dio directly in Cubits | ❌ Rejected | Violates Clean Architecture; routed through UseCases and Repository |
| Single monolithic Cubit for both screens | ❌ Rejected | Decoupled `RatesListCubit` and `CurrencyDetailCubit` for independent lifecycles |
| Sequential historical API calls | ❌ Rejected → Refactored | `Future.wait` parallelization cuts latency ~7x |
| Full-screen error when only chart fails | ❌ Rejected | Partial error state (`CurrencyDetailChartError`) preserves rate header |
| Hardcoded shimmer colors | ❌ Rejected → Edited | Used theme-aware `surfaceContainerHighest` for dark mode support |
| Generated test structure | ✅ Accepted with edits | Fixed fixture data, added missing BlocProviders, corrected named parameters |
| Single global `app_import.dart` barrel | ❌ **Reversed my own call** | Let domain see data/presentation; replaced with four layered barrels (`0257a44`) |
| "7 duplicate commits" git diagnosis | ❌ Rejected — wrong | Tree-hash comparison showed one fully redundant *branch*, not 7 loose commits |
| `git rebase` + force-push run by AI | ❌ Rejected | Destructive on pushed history; generated the commands, ran them manually with a backup branch |
| Unguarded `(value as num)` cast | ✅ Accepted | One malformed currency would `TypeError` out of `Future.wait` and kill all 7 days |
| `emit` after `await` without `isClosed` | ✅ Accepted | `StateError` when user navigates back mid-fetch; untested by the existing suite |

---

## What This Log Is Actually Evidence Of

The Session 1–5 entries show AI used the ordinary way: scaffolding, boilerplate, test
generation. The interesting material is Session 6, and the pattern there is that AI was
most valuable as a **critic** and least reliable as an **authority**:

- It found six real defects I had stopped seeing, including a UI regression that a clean
  analyzer and 43 passing tests had failed to catch.
- It talked me out of an architectural decision I had defended in writing in this very
  document (Session 1.1 → 6.6). I left the original claim in place with a correction
  rather than editing it away.
- It was confidently wrong about the git history, and running its suggested command
  unverified would have made things worse. The tree-hash check that disproved it took
  about a minute.

Every finding in Session 6 was independently verified against the codebase before it was
acted on — the fix commits are timestamped after the review, and each one is scoped to a
single concern.
