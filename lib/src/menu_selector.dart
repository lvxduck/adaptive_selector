import 'package:flutter/material.dart';

class MenuSelector<T> extends StatelessWidget {
  const MenuSelector({
    Key? key,
    required this.visible,
    required this.width,
    required this.optionsBuilder,
    this.minWidth,
  }) : super(key: key);

  final bool visible;
  final double? minWidth;
  final double width;
  final WidgetBuilder optionsBuilder;

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 200),
      opacity: visible ? 1 : 0,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        curve: Curves.easeInOut,
        width: minWidth != null
            ? width < minWidth!
                ? minWidth
                : width
            : width,
        // height: visible ? 160 : 0,
        constraints: BoxConstraints(
          maxHeight: visible ? 160 : 0,
          minHeight: 0,
        ),
        child: Material(
          elevation: 3,
          clipBehavior: Clip.hardEdge,
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          child: optionsBuilder(context),
        ),
      ),
    );
  }
}
