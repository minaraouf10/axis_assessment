# Currency Exchange Tracker

Flutter app for the Axis Mobile technical assessment. It shows live EGP exchange rates for USD, EUR, GBP, SAR, and JPY, daily change, a 7-day history chart, light/dark theme, and an offline Hive cache.

## Setup

```bash
flutter pub get
flutter run
```

Android needs network access (`INTERNET` is already declared in the manifest).

## Architecture

Clean Architecture per feature:

- `lib/core` — DI (`get_it`), Dio, connectivity, theming, routing, shared widgets
- `lib/features/exchange/domain` — entities, repository contract, use cases (pure Dart)
- `lib/features/exchange/data` — remote API, Hive cache, repository implementation
- `lib/features/exchange/presentation` — Cubits + UI

Rates are inverted from the Frankfurter-style CDN payload (`1 / egp.usd`) so tiles show **EGP per 1 foreign unit**. Green daily change means the EGP strengthened (fewer EGP needed than yesterday).

## Tests

```bash
flutter test
```

## API

- Latest: `https://latest.currency-api.pages.dev/v1/currencies/egp.json`
- Historical: `https://{YYYY-MM-DD}.currency-api.pages.dev/v1/currencies/egp.json`
