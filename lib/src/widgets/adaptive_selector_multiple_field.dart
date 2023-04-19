import 'package:flutter/material.dart';

import '../adaptive_selector_controller.dart';

class MultipleSelectorTextField<T> extends StatefulWidget {
  const MultipleSelectorTextField({
    Key? key,
    required this.onTap,
    required this.decoration,
    required this.controller,
    this.onSearch,
  }) : super(key: key);

  final VoidCallback onTap;
  final InputDecoration decoration;
  final AdaptiveSelectorController<T> controller;
  final ValueChanged<String>? onSearch;

  @override
  State<MultipleSelectorTextField<T>> createState() =>
      _MultipleSelectorTextFieldState();
}

class _MultipleSelectorTextFieldState<T>
    extends State<MultipleSelectorTextField<T>> {
  final focus = FocusNode();
  bool hasFocus = false;

  @override
  void initState() {
    widget.controller.addListener(() {
      if (mounted) {
        setState(() {});
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final selectedOptions = widget.controller.selectedOptions;
    return Focus(
      onFocusChange: (hasFocus) {
        setState(() {
          this.hasFocus = hasFocus;
        });
      },
      child: InkWell(
        onTapDown: (_) {
          if (!hasFocus) {
            focus.requestFocus();
            widget.onTap();
          }
        },
        splashFactory: NoSplash.splashFactory,
        highlightColor: Colors.transparent,
        focusColor: Colors.transparent,
        hoverColor: hasFocus ? Colors.transparent : null,
        child: InputDecorator(
          isFocused: hasFocus,
          decoration: widget.decoration,
          child: selectedOptions.isEmpty
              ? Text(
                  widget.decoration.hintText ?? '',
                  style: widget.decoration.hintStyle ??
                      Theme.of(context).inputDecorationTheme.hintStyle,
                )
              : Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: widget.controller.selectedOptions
                      .map<Widget>(
                        (e) => Chip(
                          label: Text(e.label),
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                          onDeleted: () {
                            widget.controller.selectOption(e);
                          },
                        ),
                      )
                      .toList()
                    ..add(
                      widget.onSearch == null
                          ? const SizedBox()
                          : ConstrainedBox(
                              constraints: const BoxConstraints(minWidth: 48),
                              child: IntrinsicWidth(
                                child: TextField(
                                  focusNode: focus,
                                  readOnly: widget.onSearch == null,
                                  onChanged: widget.onSearch,
                                  decoration: const InputDecoration(
                                    border: InputBorder.none,
                                    focusedBorder: InputBorder.none,
                                    enabledBorder: InputBorder.none,
                                    errorBorder: InputBorder.none,
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
