import 'package:adaptive_selector/src/extensions/context_extension.dart';
import 'package:flutter/material.dart';

import '../../adaptive_selector.dart';

Future<T?> showMenuSelector<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  required HitTestBehavior behavior,
  double? minWidth,
}) {
  final navigator = Navigator.of(context);
  return navigator.push(
    _OverlayMenuRoute<T>(
      menuContext: context,
      minWidth: minWidth,
      behavior: behavior,
      capturedThemes: InheritedTheme.capture(
        from: context,
        to: navigator.context,
      ),
      child: builder(context),
    ),
  );
}

class MenuSelector<T> extends StatelessWidget {
  const MenuSelector({
    Key? key,
    required this.selector,
  }) : super(key: key);

  final AdaptiveSelectorState<T> selector;

  @override
  Widget build(BuildContext context) {
    final options = selector.buildOptionsWidget();
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: selector.widget.maxMenuHeight,
      ),
      child: selector.widget.menuBuilder?.call(context, options, selector) ??
          Material(
            elevation: 3,
            clipBehavior: Clip.hardEdge,
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            child: options,
          ),
    );
  }
}

// todo: use TransitionRoute for animation
class _OverlayMenuRoute<T> extends OverlayRoute<T> {
  final BuildContext menuContext;
  final Widget child;
  final CapturedThemes capturedThemes;
  final double? minWidth;
  final HitTestBehavior behavior;

  _OverlayMenuRoute({
    required this.menuContext,
    required this.capturedThemes,
    required this.behavior,
    required this.child,
    this.minWidth,
  });

  @override
  Iterable<OverlayEntry> createOverlayEntries() {
    return <OverlayEntry>[
      // Listen event pointerDown to pop route
      OverlayEntry(
        builder: (context) {
          void popAndUnFocus() {
            Navigator.of(context).pop();
            FocusManager.instance.primaryFocus?.unfocus();
          }

          return Listener(
            behavior: behavior,
            onPointerDown: (_) => popAndUnFocus(),
            onPointerSignal: (_) => popAndUnFocus(),
          );
        },
      ),
      OverlayEntry(
        maintainState: true,
        builder: (context) {
          late final position = menuContext.findRelativeRect();
          late final textFieldSize = menuContext.findSize();
          if (position == null || textFieldSize == null) {
            return const SizedBox();
          }
          return CustomSingleChildLayout(
            delegate: _PopupMenuRouteLayout(
              context: context,
              position: position,
              textFieldSize: textFieldSize,
              minWidth: minWidth,
            ),
            child: child,
          );
        },
      ),
    ];
  }
}

// Positioning of the menu on the screen.
class _PopupMenuRouteLayout extends SingleChildLayoutDelegate {
  // Rectangle of underlying button, relative to the overlay's dimensions.
  RelativeRect position;
  final BuildContext context;

  Size textFieldSize;
  final double? minWidth;

  _PopupMenuRouteLayout({
    required this.context,
    required this.position,
    required this.textFieldSize,
    this.minWidth,
  });

  @override
  BoxConstraints getConstraintsForChild(BoxConstraints constraints) {
    final keyBoardHeight = MediaQuery.of(context).viewInsets.bottom;
    final safeAreaTop = MediaQuery.of(context).padding.top;
    final safeAreaBottom = MediaQuery.of(context).padding.bottom;
    final totalSafeArea = safeAreaTop + safeAreaBottom;
    final maxHeight = constraints.minHeight - keyBoardHeight - totalSafeArea;
    // todo: calculate size when minWidth too large
    return BoxConstraints.loose(
      Size(
        minWidth ?? textFieldSize.width,
        maxHeight,
      ),
    );
  }

  @override
  Offset getPositionForChild(Size size, Size childSize) {
    // size: The size of the overlay.
    // childSize: The size of the menu, when fully open, as determined by
    // getConstraintsForChild.

    //keyBoardHeight is height of keyboard if showing
    final keyBoardHeight = MediaQuery.of(context).viewInsets.bottom;

    double x = position.left;

    // Find the ideal vertical position.
    double y = position.top;
    // check if keyboard overlaps selector
    if (y + childSize.height > size.height - keyBoardHeight) {
      y = y - childSize.height - textFieldSize.height;
    }
    if (minWidth != null) {
      x -= (minWidth! - textFieldSize.width) / 2;
      if (x < 0) x = position.left;
    }
    return Offset(x, y);
  }

  @override
  bool shouldRelayout(_PopupMenuRouteLayout oldDelegate) {
    return true;
  }
}
