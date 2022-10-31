import 'package:flutter/material.dart';

import 'adaptive_selector.dart';

class OverlaySelector<T> extends StatelessWidget {
  const OverlaySelector({
    Key? key,
    required this.visible,
    required this.width,
    required this.buildItem,
    required this.loading,
    this.minWidth,
    required this.options,
  }) : super(key: key);

  final bool visible;
  final List<Option<T>>? options;
  final double? minWidth;
  final double width;
  final Widget Function(Option<T>) buildItem;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      duration: Duration(
        milliseconds: visible ? 100 : 200,
      ),
      opacity: visible ? 1 : 0,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
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
          child: Stack(
            children: [
              ListView.separated(
                itemCount: options?.length ?? 0,
                padding: const EdgeInsets.symmetric(vertical: 4),
                itemBuilder: (_, index) => buildItem(options![index]),
                separatorBuilder: (_, __) => const SizedBox(),
              ),
              if (loading && visible)
                const SizedBox(
                  height: 32,
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
              if (!loading && (options?.isEmpty ?? false))
                SizedBox(
                  height: visible ? 100 : 0,
                  child: const Center(
                    child: Text('No data'),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
