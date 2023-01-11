import '../../adaptive_selector.dart';

class SelectorValue<T> {
  SelectorValue({
    this.options,
    this.selectedOption,
    this.error = false,
    required this.loading,
    required this.hasMore,
  });

  final AdaptiveSelectorOption<T>? selectedOption;
  final bool loading;
  final bool error;
  final bool hasMore;
  final List<AdaptiveSelectorOption<T>>? options;
}
