import 'package:flutter/material.dart';

import '../../adaptive_selector.dart';

class MultipleSelectorTextField<T> extends StatefulWidget {
  const MultipleSelectorTextField({
    Key? key,
    required this.decoration,
    required this.controller,
  }) : super(key: key);

  final InputDecoration decoration;
  final AdaptiveSelectorController<T> controller;

  @override
  State<MultipleSelectorTextField<T>> createState() =>
      _MultipleSelectorTextFieldState();
}

class _MultipleSelectorTextFieldState<T>
    extends State<MultipleSelectorTextField<T>> {
  final textController = TextEditingController();
  final focus = FocusNode();
  bool hasFocus = false;

  @override
  void initState() {
    widget.controller.addListener(() {
      if (mounted) {
        setState(() {});
      }
    });
    focus.addListener(() {
      setState(() {
        this.hasFocus = focus.hasFocus;
      });
    });
    super.initState();
  }

  @override
  void dispose() {
    focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final selector = AdaptiveSelector.of(context);
    final selectedOptions = widget.controller.selectedOptions;
    return AbsorbPointer(
      absorbing: !selector.widget.enable,
      child: InkWell(
        onTapDown: (_) async {
          if (!hasFocus) {
            focus.requestFocus();
            await selector.showSelector();
            textController.clear();
          }
        },
        splashFactory: NoSplash.splashFactory,
        highlightColor: Colors.transparent,
        focusColor: Colors.transparent,
        hoverColor: hasFocus ? Colors.transparent : null,
        child: InputDecorator(
          isFocused: hasFocus,
          decoration: widget.decoration,
          child: Wrap(
            spacing: 12,
            runSpacing: 12,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: widget.controller.selectedOptions
                .map<Widget>(
                  (e) => Chip(
                    label: Text(e.label),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    onDeleted: () {
                      widget.controller.selectOption(e);
                    },
                  ),
                )
                .toList()
              ..add(
                ConstrainedBox(
                  constraints: const BoxConstraints(minWidth: 48),
                  child: IntrinsicWidth(
                    child: TextField(
                      controller: textController,
                      focusNode: focus,
                      readOnly:
                          selector.widget.type == SelectorType.bottomSheet ||
                              selector.widget.onSearch == null,
                      onChanged: selector.widget.onSearch,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        errorBorder: InputBorder.none,
                        hintText: selectedOptions.isEmpty
                            ? widget.decoration.hintText
                            : null,
                        disabledBorder: InputBorder.none,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ),
                ),
              ),
          ),
        ),
      ),
    );
  }
}
