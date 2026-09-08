# AI Usage Log

This document transparently records the prompts, architectural decisions, and review iterations involved in developing the Currency Exchange Tracker.

---

## 1. Initial Prompt & Project Scaffolding

- **Prompt:** Implement the Axis Mobile Assessment (Currency Exchange Tracker) following Clean Architecture, BLoC/Cubit state management, Service Locator (`get_it`), Dio HTTP client, Hive local caching, GoRouter navigation, offline resilience, 7-day historical chart, comprehensive automated testing, and accessibility support.
- **Generated Codebase:**
  - Project directory structure with strict separation of concerns (`core`, `features/exchange/data`, `features/exchange/domain`, `features/exchange/presentation`).
  - Data layer models handling inverse exchange rate calculation ($1 / \text{rate}_{\text{EGP}}$).
  - Business logic handling state transitions and failure mappings (`Either<Failure, T>`).

---

## 2. Engineering Decisions & Architectural Choices

### Accepted as Best Practices:
1. **Layered Clean Architecture:**
   - `Domain`: Pure Dart entities and UseCases with no Flutter or external package dependencies.
   - `Data`: Repository implementation orchestrating remote API data sources and Hive local cache.
   - `Presentation`: Cubits emitting immutable states consumed via `BlocBuilder` in Flutter widgets.
2. **Offline-First Resilience & Stale Cache Fallback:**
   - Caching both the latest rates payload and individual currency 7-day historical datasets.
   - Gracefully returning stale cached data when `ServerException` occurs (e.g., timeout, captive portal, or server downtime despite device reporting network connectivity).
3. **Parallel Historical Fetching (`Future.wait`):**
   - Executing the 7 individual daily rate requests in parallel rather than sequentially, reducing network wait time and latency.
4. **UX & Error Handling:**
   - Shimmer placeholder for the historical chart during loading.
   - Explicit "Try again" retry actions on both the main list error state and the detail chart error state.
   - Visual badges with contextual coloring (EGP strengthened vs. weakened).
5. **Accessibility & Semantics:**
   - Semantic labels on interactive tiles, historical chart elements, and theme toggles for screen readers.

### Rejected / Refactored Patterns:
- **Calling Dio/HTTP directly in Cubits:** Strictly rejected in favor of Domain UseCases and Repository abstraction.
- **Single monolithic Cubit:** Rejected in favor of isolated Cubits (`RatesListCubit` and `CurrencyDetailCubit`) to decouple list lifecycle from detail chart state.
- **Sequential network requests:** Refactored to asynchronous concurrency using `Future.wait`.

---

## 3. Review & Verification Log

- **Static Analysis:** Verified clean with strict linter rules (`flutter analyze`).
- **Automated Tests:** Comprehensive unit, datasource, repository, cubit, and widget tests (`flutter test`).
- **Git Commit Workflow:** Incremental commits representing logical milestones and bug fixes.
