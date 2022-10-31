import 'package:flutter/material.dart';

import 'adaptive_selector.dart';

class BottomSheetSelector<T> extends StatefulWidget {
  const BottomSheetSelector({
    Key? key,
    required this.selectorValue,
    required this.title,
    required this.buildItem,
    this.onSearch,
  }) : super(key: key);

  final String title;
  final Widget Function(Option<T>) buildItem;
  final ValueNotifier<SelectorValue<T>> selectorValue;
  final ValueChanged<String>? onSearch;

  @override
  State<BottomSheetSelector<T>> createState() => _BottomSheetSelectorState<T>();
}

class _BottomSheetSelectorState<T> extends State<BottomSheetSelector<T>> {
  @override
  void initState() {
    widget.selectorValue.addListener(() {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) setState(() {});
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 2 / 3,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(16),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Text(
              widget.title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 12),
            if (widget.onSearch != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: TextFormField(
                  decoration: const InputDecoration(
                    hintText: 'Enter school name',
                  ),
                  onChanged: widget.onSearch,
                ),
              ),
            Expanded(
              child: Stack(
                children: [
                  ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shrinkWrap: false,
                    itemCount: widget.selectorValue.value.options?.length ?? 0,
                    itemBuilder: (_, index) => widget
                        .buildItem(widget.selectorValue.value.options![index]),
                  ),
                  if (widget.selectorValue.value.loading)
                    const Center(
                      child: CircularProgressIndicator(),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}
