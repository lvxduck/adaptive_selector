import 'package:flutter/material.dart';

import '../adaptive_selector.dart';

class AdaptiveSelectiveOptionsWidget<T> extends StatefulWidget {
  const AdaptiveSelectiveOptionsWidget({
    Key? key,
    required this.selectorValue,
    required this.buildItem,
  }) : super(key: key);

  final ValueNotifier<SelectorValue<T>> selectorValue;
  final Widget Function(Option<T>) buildItem;

  @override
  State<AdaptiveSelectiveOptionsWidget<T>> createState() =>
      _AdaptiveSelectiveOptionsWidgetState<T>();
}

class _AdaptiveSelectiveOptionsWidgetState<T>
    extends State<AdaptiveSelectiveOptionsWidget<T>> {
  @override
  void initState() {
    widget.selectorValue.addListener(onChange);
    super.initState();
  }

  @override
  void dispose() {
    widget.selectorValue.removeListener(onChange);
    super.dispose();
  }

  void onChange() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    final options = widget.selectorValue.value.options;
    return Stack(
      children: [
        ListView.separated(
          itemCount: options?.length ?? 0,
          padding: const EdgeInsets.symmetric(vertical: 4),
          itemBuilder: (_, index) => widget.buildItem(options![index]),
          separatorBuilder: (_, __) => const SizedBox(),
        ),
        if (widget.selectorValue.value.loading)
          const Center(
            child: CircularProgressIndicator(),
          ),
        if (!widget.selectorValue.value.loading && (options?.isEmpty ?? false))
          const SizedBox(
            height: 100,
            child: Center(
              child: Text('No data'),
            ),
          ),
      ],
    );
  }
}
