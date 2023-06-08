import 'package:flutter/cupertino.dart';

import '../adaptive_selector.dart';

class AdaptiveSelectorController<T> extends ChangeNotifier {
  AdaptiveSelectorController({
    required this.options,
    required List<AdaptiveSelectorOption<T>> selectedOptions,
    required this.isMultiple,
    required this.allowClear,
  }) {
    selectedOptionsNotifier = ValueNotifier(selectedOptions);
  }

  List<AdaptiveSelectorOption<T>> options;
  late ValueNotifier<List<AdaptiveSelectorOption<T>>> selectedOptionsNotifier;

  List<AdaptiveSelectorOption<T>> get selectedOptions =>
      selectedOptionsNotifier.value;

  Object? error;
  bool isMultiple;
  bool allowClear;

  void selectOption(AdaptiveSelectorOption<T> option) {
    var options = selectedOptionsNotifier.value;
    if (options.contains(option)) {
      options = options.where((e) => e != option).toList();
    } else {
      options = [...options, option];
    }
    if (isMultiple) {
      selectedOptionsNotifier.value = options;
    } else {
      if (options.isEmpty) {
        if (allowClear) {
          selectedOptionsNotifier.value = [];
        }
      } else {
        selectedOptionsNotifier.value = [options.last];
      }
    }
    notifyListeners();
  }

  void clearSelectedOption() {
    selectedOptionsNotifier.value = [];
    notifyListeners();
  }

  void update({
    required List<AdaptiveSelectorOption<T>> options,
    required bool isMultiple,
    required bool allowClear,
  }) {
    this.options = options;
    this.isMultiple = isMultiple;
    this.allowClear = allowClear;
    WidgetsBinding.instance.addPostFrameCallback(
      (_) {
        notifyListeners();
      },
    );
  }

  void guardFuture(Future Function() future) async {
    try {
      await future();
      this.error = null;
    } catch (e) {
      this.error = e;
    }
    notifyListeners();
  }
}
