/// Creates an adaptive selector option item
class AdaptiveSelectorOption<T> {
  AdaptiveSelectorOption({
    this.id,
    required this.label,
    required this.value,
  });

  /// The id that identifies this item
  final String? id;

  /// The label that identifies this item
  final String label;

  /// The value attached to this item
  final T value;

  /// The hash code for this object.
  @override
  int get hashCode => Object.hash(label, value);

  @override
  bool operator ==(Object other) {
    if (other is! AdaptiveSelectorOption) return false;
    final item = other;
    if (id != null) {
      return id == item.id;
    }
    return label == item.label && value == item.value;
  }
}
