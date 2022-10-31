import 'package:flutter/material.dart';

import 'adaptive_selector.dart';
import 'adaptive_selector_options_container.dart';

class BottomSheetSelector<T> extends StatelessWidget {
  const BottomSheetSelector({
    Key? key,
    required this.selectorValue,
    required this.title,
    required this.buildItem,
    this.onSearch,
  }) : super(key: key);

  final String title;
  final Widget Function(Option<T>) buildItem;
  final ValueNotifier<SelectorValue<T>> selectorValue;
  final ValueChanged<String>? onSearch;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 2 / 3,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(16),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 12),
            if (onSearch != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: TextFormField(
                  decoration: const InputDecoration(
                    hintText: 'Enter school name',
                  ),
                  onChanged: onSearch,
                ),
              ),
            Expanded(
              child: AdaptiveSelectiveOptionsWidget(
                selectorValue: selectorValue,
                buildItem: buildItem,
              ),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}
