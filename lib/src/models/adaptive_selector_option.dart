class AdaptiveSelectorOption<T> {
  AdaptiveSelectorOption({
    required this.label,
    required this.value,
  });

  final String label;
  final T value;

  @override
  int get hashCode => Object.hash(label, value);

  @override
  bool operator ==(Object other) {
    if (other is! AdaptiveSelectorOption) return false;
    final item = other;
    return label == item.label && value == item.value;
  }
}
