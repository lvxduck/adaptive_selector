import 'package:flutter/material.dart';

import '../../adaptive_selector.dart';

class AdaptiveSelectorField<T> extends StatefulWidget {
  const AdaptiveSelectorField({
    Key? key,
    required this.decoration,
    required this.controller,
  }) : super(key: key);

  final InputDecoration decoration;
  final AdaptiveSelectorController<T> controller;

  @override
  State<AdaptiveSelectorField<T>> createState() =>
      _AdaptiveSelectorFieldState<T>();
}

class _AdaptiveSelectorFieldState<T> extends State<AdaptiveSelectorField<T>> {
  final textController = TextEditingController();

  void updateTextField() {
    final options = widget.controller.selectedOptions;
    textController.text = options.isNotEmpty ? options.first.label : '';
  }

  @override
  void initState() {
    updateTextField();
    widget.controller.selectedOptionsNotifier.addListener(
      updateTextField,
    );
    super.initState();
  }

  @override
  void dispose() {
    widget.controller.selectedOptionsNotifier.removeListener(
      updateTextField,
    );
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final selector = AdaptiveSelector.of(context);
    return TextFormField(
      controller: textController,
      onChanged: selector.handleTextChange,
      onTap: () async {
        textController.clear();
        await selector.showSelector();
        updateTextField();
      },
      readOnly: selector.widget.type == SelectorType.bottomSheet ||
          selector.widget.onSearch == null,
      enabled: selector.widget.enable,
      decoration: widget.decoration,
    );
  }
}
