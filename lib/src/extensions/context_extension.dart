import 'package:flutter/cupertino.dart';

extension ContextExtension on BuildContext {
  Size? findSize() {
    if (!mounted) return null;
    final textFieldRenderBox = findRenderObject() as RenderBox?;
    return textFieldRenderBox?.size;
  }

  RelativeRect? findRelativeRect() {
    if (!mounted) return null;
    var overlay =
        Overlay.maybeOf(this)?.context.findRenderObject() as RenderBox?;
    if (overlay == null) return null;
    final textFieldRenderBox = findRenderObject() as RenderBox;
    return RelativeRect.fromSize(
      Rect.fromPoints(
        textFieldRenderBox.localToGlobal(
          textFieldRenderBox.size.bottomLeft(Offset.zero),
          ancestor: overlay,
        ),
        textFieldRenderBox.localToGlobal(
            textFieldRenderBox.size.bottomRight(Offset.zero),
            ancestor: overlay),
      ),
      Size(overlay.size.width, overlay.size.height),
    );
  }
}
