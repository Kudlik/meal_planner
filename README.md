# Jedzonko

A Flutter meal planning app for households. Plan the week's meals on a shared grid, track what's been cooked and eaten, and get a shopping list that updates automatically as meals are prepared.

## Overview

Jedzonko lets you assign recipes to a 2-week grid (8 days split into 4 day-pairs) across 4 meal types. The plan and shopping list sync in real time across all household devices via Firebase — no login required. As meals are marked as prepared or eaten, their ingredients are automatically removed from the shopping list.

## Features

### Menu planning
- 4×4 swipeable grid: 4 day-pairs (Dni 1–2, 3–4, 5–6, 7–8) × 4 meal types (Śniadanie, Deser, Lunch, Kolacja)
- Browse and pick recipes from a built-in library, filtered by meal type
- Swipe left/right to navigate between day-pairs; meal type labels stay fixed
- Tap a filled card to mark it as **Prepared** or **Eaten**, or remove it from the plan

### Meal status tracking
- **Prepared** — meal has been cooked; ingredients are removed from the shopping list; MealReady icon shown on the card
- **Eaten** — meal has been eaten; card switches to a dark muted style with the Eaten icon
- Tapping the same status again toggles it back to normal

### Shopping list
- Auto-generated from all planned meals that haven't been prepared or eaten yet
- Ingredients are summed across the full plan (scaled for 2 people × 2 days per slot)
- Manual items can be added, edited, and categorised
- Quantities of recipe-derived items can be adjusted per-item
- Items grouped and sorted by category (owoce, warzywa, nabiał, mięso, sypkie, etc.)
- Mark items as bought — checked items move to the bottom and state persists

### Real-time household sync
- All changes (plan, statuses, shopping list) sync instantly across devices via Firestore
- No account or login — the household shares a single hardcoded document (`household_01`)
- Optimistic UI: local state updates immediately, Firestore confirms in the background

## Tech stack

| Layer | Technology |
|---|---|
| Framework | Flutter (Dart) |
| State management | Provider (`ChangeNotifier`) |
| Backend / sync | Firebase Firestore |
| Icons | SVG via `flutter_svg` |

## Project structure

```
lib/
├── data/           # Repositories (PlanRepository, ShoppingRepository, RecipeRepository)
├── models/         # Data models (Meal, Ingredient, PlanSlot, ShoppingItem, ...)
├── screens/        # UI screens (MenuScreen, ShoppingListScreen, MealPickerScreen, SplashScreen)
├── state/          # AppState — single source of truth, subscribes to Firestore stream
├── theme/          # Colors and text styles
└── widgets/        # Shared widgets (MealCard, TopNavigation, BottomDrawer, ...)
```

## Getting started

1. Set up a Firebase project and run `flutterfire configure --platforms=android` to generate `firebase_options.dart` and `google-services.json`
2. Create a Firestore database in the Firebase console
3. Then:

```bash
flutter pub get
flutter run
```

Requires Flutter 3.x and Dart SDK ^3.11.5.
