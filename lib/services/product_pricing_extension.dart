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

  /// 🔒 Internal logic (single source of truth)
  double _multiplier(String label) {
    final value = double.tryParse(label.replaceAll(RegExp(r'[^0-9.]'), ''));

    final lower = label.toLowerCase();

    if (lower.contains('kg')) {
      return value ?? 1.0;
    }

    if (lower.contains('g')) {
      return ((value ?? 0) / 1000);
    }

    return 1.0;
  }
}
