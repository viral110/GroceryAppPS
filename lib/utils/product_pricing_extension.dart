import 'package:online_groceries_app/features/admin/products/models/produce_model.dart';

extension ProductPricing on ProductModel {
  /// ✅ Sorted packaging (small → large)
  List<String> get sortedPackaging {
    final list = List<String>.from(packaging);
    list.sort((a, b) => _multiplier(a).compareTo(_multiplier(b)));
    return list;
  }

  /// ✅ Default packaging (largest one)
  String get defaultPackaging {
    if (sortedPackaging.isNotEmpty) {
      return sortedPackaging.last;
    }
    return priceUnit;
  }

  /// ✅ Multiplier for a packaging
  double multiplierFor(String packagingLabel) {
    return _multiplier(packagingLabel);
  }

  /// ✅ Unit price for a packaging
  double unitPriceFor(String packagingLabel) {
    return price * multiplierFor(packagingLabel);
  }

  double _multiplier(String label) {
    final lower = label.toLowerCase().trim();
    final value =
        double.tryParse(lower.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 1.0;

    // 1. Volume Logic (L / ML)
    if (lower.contains('ml') || lower.contains('milliliter')) {
      return value / 1000; // 400ml -> 0.4
    }
    if (lower.contains('liter') ||
        lower.contains('litre') ||
        lower.endsWith('l')) {
      return value;
    }

    // 2. Weight Logic (KG / G)
    // Check KG first because 'g' is inside the word 'kg'
    if (lower.contains('kg') || lower.contains('kilogram')) {
      return value;
    }
    if (lower.contains('gram') || lower.contains('gm') || lower.contains('g')) {
      return value / 1000; // 500g -> 0.5
    }

    return 1.0; // Default multiplier
  }

  // /// 🔒 Internal logic (single source of truth)
  // double _multiplier(String label) {
  //   final value = double.tryParse(label.replaceAll(RegExp(r'[^0-9.]'), ''));
  //   final lower = label.toLowerCase();
  //   if (lower.contains('kg')) {
  //     return value ?? 1.0;
  //   }
  //   if (lower.contains('g')) {
  //     return ((value ?? 0) / 1000);
  //   }
  //   return 1.0;
  // }
}
