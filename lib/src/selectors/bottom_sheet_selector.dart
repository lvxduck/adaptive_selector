import 'package:flutter/material.dart';

class BottomSheetSelector<T> extends StatelessWidget {
  const BottomSheetSelector({
    Key? key,
    required this.optionsBuilder,
    this.onSearch,
    this.decoration,
    required this.bottomSheetSize,
  }) : super(key: key);

  final ValueChanged<String>? onSearch;
  final ScrollableWidgetBuilder optionsBuilder;
  final InputDecoration? decoration;
  final double bottomSheetSize;

  @override
  Widget build(BuildContext context) {
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
            return Padding(
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
                            contentPadding: const EdgeInsets.only(right: 16),
                            hintText: decoration?.hintText,
                          ),
                          onChanged: onSearch,
                        ),
                      )
                    else ...[
                      Text(
                        decoration?.hintText ?? 'Select',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.start,
                      ),
                      const SizedBox(height: 6),
                    ],
                    Expanded(child: optionsBuilder(context, controller)),
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
