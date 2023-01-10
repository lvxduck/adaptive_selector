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
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            Expanded(
              child: Text(
                option.label,
              ),
            ),
            const SizedBox(width: 16),
            if (isSelected)
              Checkbox(
                value: isSelected,
                onChanged: (_) => onTap(),
              ),
          ],
        ),
      ),
    );
  }
}
