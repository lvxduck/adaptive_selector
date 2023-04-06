import 'package:flutter/cupertino.dart';

import '../adaptive_selector.dart';

class AdaptiveSelectorController<T> extends ChangeNotifier {
  AdaptiveSelectorController({
    required this.options,
    required Set<AdaptiveSelectorOption<T>> selectedOptions,
    this.error = false,
    required this.loading,
    required this.hasMore,
    required this.isMultiple,
  }) {
    selectedOptionsNotifier = ValueNotifier(selectedOptions);
  }

  final bool isMultiple;
  List<AdaptiveSelectorOption<T>> options;
  late ValueNotifier<Set<AdaptiveSelectorOption<T>>> selectedOptionsNotifier;

  List<AdaptiveSelectorOption<T>> get selectedOptions =>
      selectedOptionsNotifier.value.toList();
  bool loading;
  bool error;
  bool hasMore;

  void selectOption(AdaptiveSelectorOption<T> option) {
    print(option);
    if (isMultiple) {
      if (selectedOptionsNotifier.value.contains(option)) {
        selectedOptionsNotifier.value =
            selectedOptionsNotifier.value.where((e) => e != option).toSet();
      } else {
        selectedOptionsNotifier.value = {
          ...selectedOptionsNotifier.value,
          option
        };
      }
    } else {
      selectedOptionsNotifier.value = {option};
    }
    notifyListeners();
  }

  void clearSelectedOption() {
    selectedOptionsNotifier.value.clear();
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
