import 'package:flutter/material.dart';

import '../../adaptive_selector.dart';
import '../adaptive_selector_controller.dart';

class MultipleSelectorTextField<T> extends StatefulWidget {
  const MultipleSelectorTextField({
    Key? key,
    required this.onTap,
    required this.decoration,
    required this.controller,
    this.onSearch,
    this.onMultipleChanged,
  }) : super(key: key);

  final VoidCallback onTap;
  final InputDecoration decoration;
  final AdaptiveSelectorController controller;
  final ValueChanged<List<AdaptiveSelectorOption<T>>>? onMultipleChanged;
  final ValueChanged<String>? onSearch;

  @override
  State<MultipleSelectorTextField> createState() =>
      _MultipleSelectorTextFieldState();
}

class _MultipleSelectorTextFieldState extends State<MultipleSelectorTextField> {
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
    return Focus(
      onFocusChange: (hasFocus) {
        setState(() {
          this.hasFocus = hasFocus;
        });
        // if (hasFocus) {
        //   widget.onTap();
        // }
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
                      widget.onMultipleChanged
                          ?.call(widget.controller.selectedOptions);
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
