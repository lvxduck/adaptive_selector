import 'package:flutter/material.dart';

import '../../adaptive_selector.dart';

class AdaptiveSelectorTile<T> extends StatelessWidget {
  const AdaptiveSelectorTile({
    Key? key,
    required this.option,
    required this.selector,
  }) : super(key: key);

  final AdaptiveSelectorOption<T> option;
  final AdaptiveSelectorState<T> selector;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        if (selector.mounted) {
          selector.handleTapOption(option);
        }
      },
      child: Container(
        height: 46,
        color: selector.isSelected(option)
            ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
            : null,
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Text(option.label),
      ),
    );
  }
}
