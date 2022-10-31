import 'package:flutter/material.dart';

import 'adaptive_selector.dart';
import 'adaptive_selector_options_container.dart';

class OverlaySelector<T> extends StatelessWidget {
  const OverlaySelector({
    Key? key,
    required this.visible,
    required this.width,
    required this.buildItem,
    required this.selectorValue,
    this.minWidth,
  }) : super(key: key);

  final bool visible;
  final double? minWidth;
  final double width;
  final Widget Function(Option<T>) buildItem;
  final ValueNotifier<SelectorValue<T>> selectorValue;

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      duration: Duration(
        milliseconds: visible ? 100 : 200,
      ),
      opacity: visible ? 1 : 0,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeInOut,
        width: minWidth != null
            ? width < minWidth!
                ? minWidth
                : width
            : width,
        height: visible ? 160 : 0,
        child: Material(
          elevation: 3,
          clipBehavior: Clip.hardEdge,
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          child: AdaptiveSelectiveOptionsWidget(
            selectorValue: selectorValue,
            buildItem: buildItem,
          ),
        ),
      ),
    );
  }
}
