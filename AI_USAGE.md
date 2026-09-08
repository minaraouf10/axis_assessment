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
