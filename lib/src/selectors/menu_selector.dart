import 'package:flutter/material.dart';

Future<T?> showMenuSelector<T>({
  required BuildContext context,
  required WidgetBuilder builder,
}) {
  final NavigatorState navigator = Navigator.of(context);
  final textFieldRenderBox = context.findRenderObject() as RenderBox;
  var overlay = Overlay.of(context)!.context.findRenderObject() as RenderBox;
  return navigator.push(
    _OverlayMenuRoute<T>(
      context: context,
      capturedThemes: InheritedTheme.capture(
        from: context,
        to: navigator.context,
      ),
      textFieldSize: textFieldRenderBox.size,
      position: RelativeRect.fromSize(
        Rect.fromPoints(
          textFieldRenderBox.localToGlobal(
              textFieldRenderBox.size.bottomLeft(Offset.zero),
              ancestor: overlay),
          textFieldRenderBox.localToGlobal(
              textFieldRenderBox.size.bottomRight(Offset.zero),
              ancestor: overlay),
        ),
        Size(overlay.size.width, overlay.size.height),
      ),
      child: builder(context),
    ),
  );
}

class MenuSelector<T> extends StatelessWidget {
  const MenuSelector({
    Key? key,
    required this.optionsBuilder,
    required this.maxHeight,
  }) : super(key: key);

  final WidgetBuilder optionsBuilder;
  final double maxHeight;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: maxHeight,
        minWidth: 320,
      ),
      child: Material(
        elevation: 3,
        clipBehavior: Clip.hardEdge,
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        child: optionsBuilder(context),
      ),
    );
  }
}

// todo: use TransitionRoute for animation
class _OverlayMenuRoute<T> extends OverlayRoute<T> {
  final BuildContext context;
  final Widget child;
  final CapturedThemes capturedThemes;
  final RelativeRect position;
  final Size textFieldSize;

  _OverlayMenuRoute({
    required this.context,
    required this.capturedThemes,
    required this.child,
    required this.position,
    required this.textFieldSize,
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
            behavior: HitTestBehavior.translucent,
            onPointerDown: (_) => popAndUnFocus(),
            onPointerSignal: (_) => popAndUnFocus(),
          );
        },
      ),
      OverlayEntry(
        builder: (context) => CustomSingleChildLayout(
          delegate: _PopupMenuRouteLayout(
            context,
            position,
            textFieldSize,
          ),
          child: child,
        ),
      ),
    ];
  }
}

// Positioning of the menu on the screen.
class _PopupMenuRouteLayout extends SingleChildLayoutDelegate {
  // Rectangle of underlying button, relative to the overlay's dimensions.
  final RelativeRect position;
  final BuildContext context;
  final Size textFieldSize;

  _PopupMenuRouteLayout(
    this.context,
    this.position,
    this.textFieldSize,
  );

  @override
  BoxConstraints getConstraintsForChild(BoxConstraints constraints) {
    final parentRenderBox = context.findRenderObject() as RenderBox;
    final keyBoardHeight = MediaQuery.of(context).viewInsets.bottom;
    final safeAreaTop = MediaQuery.of(context).padding.top;
    final safeAreaBottom = MediaQuery.of(context).padding.bottom;
    final totalSafeArea = safeAreaTop + safeAreaBottom;
    final maxHeight = constraints.minHeight - keyBoardHeight - totalSafeArea;
    return BoxConstraints.loose(
      Size(
        parentRenderBox.size.width - position.right - position.left,
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

    return Offset(x, y);
  }

  @override
  bool shouldRelayout(_PopupMenuRouteLayout oldDelegate) {
    return true;
  }
}
