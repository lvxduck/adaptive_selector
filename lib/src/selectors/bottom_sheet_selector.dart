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
    final media = MediaQuery.of(context);
    return Container(
      height: media.size.height / 5 * 3,
      margin: EdgeInsets.only(
        bottom: media.viewInsets.bottom,
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
          Expanded(child: optionsBuilder(context)),
        ],
      ),
    );
  }
}
