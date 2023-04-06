import 'package:flutter/cupertino.dart';

extension ContextExtension on BuildContext {
  Size findSize() {
    final textFieldRenderBox = findRenderObject() as RenderBox;
    return textFieldRenderBox.size;
  }

  RelativeRect findRelativeRect() {
    var overlay = Overlay.of(this).context.findRenderObject() as RenderBox;
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
