# VocBuilder

An offline-first **English ↔ German vocabulary learning app** for Android, built with Flutter. Cards are reviewed using a **Spaced Repetition System (SRS)** inspired by the SM-2 algorithm, so you study smarter, not harder.

---

## Features

### Flashcards & Decks
- Organise cards into named **decks**.
- Each card stores:
  - German word + definite article (`der` / `die` / `das`)
  - English translation
  - Plural form
  - Word type: Noun, Verb, Adjective, Adverb, Phrase, Other
  - Example sentences (German & English)
  - Grammar extras: *ich*-form, Partizip II, comparative, superlative
  - Notes and tags

### Spaced Repetition (SRS)
Cards progress through three memory stages:

| Stage | Description |
|-------|-------------|
| **New** | Never reviewed |
| **Short-term** | Reviewed with minute-based intervals (10 min → 1 h → 1 day) |
| **Long-term** | Graduated to day-based intervals (3 → 7 → 14 → 30 → 90 days) |

After each review you rate the card:

| Rating | Effect |
|--------|--------|
| **Again** | Resets repetitions; ease factor −0.20; back to 10-minute interval |
| **Hard** | Ease factor −0.15; shorter next interval |
| **Good** | Normal SM-2 progression |
| **Easy** | Ease factor +0.15; accelerated interval |

### Add Cards
- **Manual entry** – fill in all fields directly.
- **Text-to-Card** – paste or type text; the app suggests cards via Google Translate.
- **Seed data** – a bundled CSV (`duo_cards_de_export1.csv`) pre-populates a starter deck on first launch.

### Import / Export
| Format | Import | Export |
|--------|--------|--------|
| CSV / TSV | ✅ (with or without header) | ✅ |
| JSON | ✅ | ✅ |
| TXT | ✅ (`word \| translation` etc.) | — |

Supported CSV header aliases: `german` / `front` / `term` / `word` and `english` / `back` / `translation` / `meaning`.

### Navigation
Five tabs via a bottom navigation bar:

| Tab | Screen |
|-----|--------|
| **Home** | Overview: due cards, progress by stage, quick actions |
| **Study** | Flashcard review session (optionally filtered by deck) |
| **Add** | Add-card hub: manual entry or Text-to-Card |
| **Decks** | List, create, and manage decks; view deck details |
| **Settings** | App preferences |

---

## Tech Stack

| Layer | Technology |
|-------|-----------|
| UI / Framework | Flutter 3, Material Design |
| State management | [Riverpod](https://riverpod.dev/) (with code generation) |
| Navigation | [go_router](https://pub.dev/packages/go_router) |
| Local database | [Drift](https://drift.simonbinder.eu/) (SQLite) |
| Translation | Google Translate via [`translator`](https://pub.dev/packages/translator) |
| File I/O | `file_picker`, `share_plus`, `permission_handler` |
| Utilities | `uuid`, `intl`, `equatable`, `collection`, `shared_preferences` |

### Architecture
The project follows **Clean Architecture** with three layers:

```
lib/
├── core/           # Enums, constants, theme, utilities
├── domain/         # Entities (Flashcard, Deck), repositories (interfaces), use-cases (SRS)
├── data/           # Drift database, repository implementations, services
│   └── services/   # ImportService, ExportService, TranslationService, DefaultSeedService
├── presentation/   # Riverpod providers, screens, widgets
└── router/         # go_router configuration
```

---

## Getting Started

### Prerequisites
- Flutter SDK `^3.11.5`
- Android SDK (API 21+)

### Run the app
```bash
flutter pub get
flutter run
```

### Generate code (Drift + Riverpod)
```bash
dart run build_runner build --delete-conflicting-outputs
```

### Run tests
```bash
flutter test
```

---

## Import File Formats

**CSV (no header)**
```
Hund;dog;der;Hunde
```

**CSV (with header)**
```
german;english;article;plural;type;example_de;example_en;notes
Katze;cat;die;Katzen;noun;Die Katze schläft.;The cat sleeps.;
```

**JSON**
```json
{
  "cards": [
    {
      "german": "Apfel",
      "english": "apple",
      "article": "der",
      "plural": "Äpfel",
      "type": "noun"
    }
  ]
}
```

**TXT** (one pair per line)
```
Buch | book
lernen - to learn
Schule;school
```

---

## License

This project is not published to pub.dev and is intended for personal use.
