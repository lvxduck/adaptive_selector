import 'package:flutter/material.dart';

import '../../adaptive_selector.dart';
import '../models/adaptive_selector_option.dart';

class AdaptiveSelectorTile<T> extends StatelessWidget {
  const AdaptiveSelectorTile({
    Key? key,
    required this.option,
    required this.isSelected,
    required this.onTap,
  }) : super(key: key);

  final AdaptiveSelectorOption<T> option;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 46,
        color: isSelected
            ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
            : null,
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Text(option.label),
      ),
    );
  }
}
