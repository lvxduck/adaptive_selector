import 'package:flutter/material.dart';

import '../../adaptive_selector.dart';

class BottomSheetSelector<T> extends StatelessWidget {
  const BottomSheetSelector({
    Key? key,
    required this.selector,
  }) : super(key: key);

  final AdaptiveSelectorState<T> selector;

  @override
  Widget build(BuildContext context) {
    final onSearch = selector.widget.onSearch;
    final decoration = selector.widget.decoration;
    final bottomSheetSize = selector.widget.bottomSheetSize;
    return Stack(
      children: [
        GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: Navigator.of(context).pop,
        ),
        DraggableScrollableSheet(
          initialChildSize: onSearch != null ? 1 : bottomSheetSize,
          minChildSize: bottomSheetSize,
          snap: true,
          snapAnimationDuration: const Duration(milliseconds: 200),
          builder: (context, controller) {
            final options = selector.buildOptionsWidget(
              scrollController: controller,
            );
            return selector.widget.bottomSheetBuilder
                    ?.call(context, options, selector) ??
                Padding(
                  padding: const EdgeInsets.only(top: 60),
                  child: Material(
                    color: Colors.white,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(12),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(height: 8),
                        Container(
                          height: 6,
                          width: 64,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(100),
                          ),
                        ),
                        const SizedBox(height: 16),
                        if (onSearch != null)
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 14),
                            child: TextFormField(
                              autofocus: true,
                              decoration: InputDecoration(
                                prefixIcon: const Icon(
                                  Icons.search,
                                  size: 24,
                                ),
                                contentPadding:
                                    const EdgeInsets.only(right: 16),
                                hintText: decoration.hintText,
                              ),
                              onChanged: selector.handleTextChange,
                            ),
                          )
                        else ...[
                          Text(
                            decoration.hintText ?? 'Select',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w500,
                            ),
                            textAlign: TextAlign.start,
                          ),
                          const SizedBox(height: 6),
                        ],
                        Expanded(child: options),
                      ],
                    ),
                  ),
                );
          },
        ),
      ],
    );
  }
}
