import 'package:flutter/material.dart';

class BottomSheetSelector<T> extends StatelessWidget {
  const BottomSheetSelector({
    Key? key,
    required this.title,
    required this.optionsBuilder,
    this.onSearch,
    this.decoration,
  }) : super(key: key);

  final String title;
  final ValueChanged<String>? onSearch;
  final WidgetBuilder optionsBuilder;
  final InputDecoration? decoration;

  @override
  Widget build(BuildContext context) {
    print(MediaQuery.of(context).viewInsets.bottom);
    return Container(
      height: MediaQuery.of(context).size.height * 3 / 4 +
          MediaQuery.of(context).viewInsets.bottom,
      margin: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(16),
        ),
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
            ),
          Expanded(child: optionsBuilder(context)),
        ],
      ),
    );
  }
}
