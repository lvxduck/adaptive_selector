import 'package:flutter/cupertino.dart';

import '../adaptive_selector.dart';

class AdaptiveSelectorController<T> extends ChangeNotifier {
  AdaptiveSelectorController({
    required this.options,
    required this.selectedOptions,
    this.error = false,
    required this.loading,
    required this.hasMore,
    required this.isMultiple,
  });

  final bool isMultiple;
  List<AdaptiveSelectorOption<T>> options;
  List<AdaptiveSelectorOption<T>> selectedOptions;
  bool loading;
  bool error;
  bool hasMore;

  void selectOption(AdaptiveSelectorOption<T> option) {
    if (isMultiple) {
      if (selectedOptions.contains(option)) {
        selectedOptions.remove(option);
      } else {
        selectedOptions.add(option);
      }
    } else {
      selectedOptions.clear();
      selectedOptions.add(option);
    }
    notifyListeners();
  }

  void clearSelectedOption() {
    selectedOptions.clear();
    notifyListeners();
  }

  void update({
    required List<AdaptiveSelectorOption<T>> options,
    required bool error,
    required bool loading,
    required bool hasMore,
  }) {
    this.options = options;
    this.error = error;
    this.loading = loading;
    this.hasMore = hasMore;
    notifyListeners();
  }
}
