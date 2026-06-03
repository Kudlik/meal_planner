# Meal Planner

A simple, offline-first Flutter app for planning weekly meals and generating a shopping list automatically.

## Overview

Meal Planner lets you assign recipes to a 2-week grid (8 days, split into 4 day-pairs), then automatically builds a shopping list from the ingredients of your chosen meals. Everything is stored locally on the device — no account, no backend, no internet connection required.

## Features

### Menu planning
- 4×4 grid of meal slots: 4 day-pairs (Dni 1-2, 3-4, 5-6, 7-8) × 4 meal types (Śniadanie, Deser, Lunch, Kolacja)
- Browse and pick recipes from a built-in recipe library, filtered by meal type
- Remove individual meals from a slot or clear the entire plan at once

### Shopping list
- Automatically generated from all assigned meals; ingredients are summed across the full plan (quantities scaled for 2 people × 2 days per slot)
- Manual items can be added, edited, and categorised independently of the plan
- Quantities of recipe-derived items can be adjusted without affecting the underlying recipe data
- Items are grouped and sorted by category (owoce, warzywa, nabiał, mięso, sypkie, etc.)
- Mark items as bought — checked items move to the bottom of the list and the state persists across app restarts

### Export & import
- Share the current plan as a `plan.json` file via the native OS share sheet (AirDrop, email, messaging apps, etc.)
- Load a previously exported plan from a JSON file using the native file picker
- Fully offline and peer-to-peer — no cloud service involved

## Tech stack

| Layer | Technology |
|---|---|
| Framework | Flutter (Dart) |
| State management | Provider (`ChangeNotifier`) |
| Persistence | JSON files via `path_provider` |
| File sharing | `share_plus` |
| File picking | `file_picker` |

## Project structure

```
lib/
├── data/           # Repositories and export/import service
├── models/         # Data models (Meal, Ingredient, PlanSlot, ShoppingItem, ...)
├── screens/        # UI screens (MenuScreen, ShoppingListScreen, MealPickerScreen)
├── state/          # AppState (ChangeNotifier, single source of truth)
├── theme/          # Colors and text styles
└── widgets/        # Shared widgets (CategoryBadge, ...)
```

## Getting started

```bash
flutter pub get
flutter run
```

Requires Flutter 3.x and Dart SDK ^3.11.5.
