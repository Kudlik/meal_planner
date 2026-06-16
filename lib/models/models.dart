class Meal {
  final String name;
  final String rawMealType; // as stored in JSON: Śniadanie, Deser, Lunch, Kolacja
  final String source;      // cookbook name from Plik
  final int page;           // from Strona

  const Meal({
    required this.name,
    required this.rawMealType,
    required this.source,
    required this.page,
  });

  // Maps JSON Typ_posiłku to the UI grid row label
  String get displayMealType {
    switch (rawMealType) {
      case 'Śniadanie': return 'Śniadanie';
      case 'Deser':     return 'Lunch';
      case 'Lunch':     return 'Obiad';
      case 'Kolacja':   return 'Kolacja';
      default:          return rawMealType;
    }
  }
}

class Ingredient {
  final String mealName;
  final String name;
  final double quantityPer1;
  final String unit;
  final String? category; // Typ produktu, lowercase

  const Ingredient({
    required this.mealName,
    required this.name,
    required this.quantityPer1,
    required this.unit,
    this.category,
  });
}

// A single cell in the 4×4 menu grid
class PlanSlot {
  final String dayKey;      // "1-2", "3-4", "5-6", "7-8"
  final String rawMealType; // JSON value: Śniadanie, Deser, Lunch, Kolacja
  String? mealName;
  String? status;           // null | 'prepared' | 'eaten'

  PlanSlot({required this.dayKey, required this.rawMealType, this.mealName, this.status});

  Map<String, dynamic> toJson() => {
    'dayKey': dayKey,
    'rawMealType': rawMealType,
    'mealName': mealName,
    'status': status,
  };

  factory PlanSlot.fromJson(Map<String, dynamic> j) => PlanSlot(
    dayKey: j['dayKey'] as String,
    rawMealType: j['rawMealType'] as String,
    mealName: j['mealName'] as String?,
    status: j['status'] as String?,
  );
}

class ShoppingItem {
  final String name;
  String unit;
  double quantity; // already doubled; 0 means no quantity
  final String? category;
  bool isBought;
  final bool isManual;

  ShoppingItem({
    required this.name,
    required this.unit,
    required this.quantity,
    this.category,
    this.isBought = false,
    this.isManual = false,
  });
}

// Manual-add overrides persisted to shopping_overrides.json
class ManualItem {
  final String name;
  final String quantity;
  final String? category;

  const ManualItem({required this.name, required this.quantity, this.category});

  Map<String, dynamic> toJson() => {'name': name, 'quantity': quantity, 'category': category};

  factory ManualItem.fromJson(Map<String, dynamic> j) => ManualItem(
    name: j['name'] as String,
    quantity: j['quantity'] as String? ?? '',
    category: j['category'] as String?,
  );
}

class QuantityOverride {
  final String itemName;
  final double delta; // user-set quantity minus the computed quantity at edit time
  final String unit;

  const QuantityOverride({
    required this.itemName,
    required this.delta,
    required this.unit,
  });

  Map<String, dynamic> toJson() => {
    'itemName': itemName,
    'delta': delta,
    'unit': unit,
  };

  factory QuantityOverride.fromJson(Map<String, dynamic> j) => QuantityOverride(
    itemName: j['itemName'] as String,
    delta: (j['delta'] as num?)?.toDouble() ?? 0.0,
    unit: j['unit'] as String? ?? '',
  );
}
