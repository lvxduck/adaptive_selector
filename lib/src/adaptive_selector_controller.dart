import 'package:flutter/cupertino.dart';

import '../adaptive_selector.dart';

class AdaptiveSelectorController<T> extends ChangeNotifier {
  AdaptiveSelectorController({
    required this.options,
    required List<AdaptiveSelectorOption<T>> selectedOptions,
    required this.loading,
    required this.hasMore,
    required this.isMultiple,
  }) {
    selectedOptionsNotifier = ValueNotifier(selectedOptions);
  }

  List<AdaptiveSelectorOption<T>> options;
  late ValueNotifier<List<AdaptiveSelectorOption<T>>> selectedOptionsNotifier;

  List<AdaptiveSelectorOption<T>> get selectedOptions =>
      selectedOptionsNotifier.value;

  bool loading;
  Object? error;
  bool hasMore;
  bool isMultiple;

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
      selectedOptionsNotifier.value = options.isEmpty ? [] : [options.last];
    }
    notifyListeners();
  }

  void clearSelectedOption() {
    selectedOptionsNotifier.value = [];
    notifyListeners();
  }

  void update({
    required List<AdaptiveSelectorOption<T>> options,
    required bool loading,
    required bool hasMore,
    required bool isMultiple,
  }) {
    this.options = options;
    this.loading = loading;
    this.hasMore = hasMore;
    this.isMultiple = isMultiple;
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
