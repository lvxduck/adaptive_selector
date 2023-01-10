import '../../adaptive_selector.dart';

class SelectorValue<T> {
  SelectorValue({
    this.options,
    this.selectedOption,
    required this.loading,
    this.error = false,
  });

  final AdaptiveSelectorOption<T>? selectedOption;
  final bool loading;
  final bool error;
  final List<AdaptiveSelectorOption<T>>? options;
}
