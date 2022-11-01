import 'package:flutter/material.dart';

import '../adaptive_selector.dart';

class AdaptiveSelectorOptionsWidget<T> extends StatefulWidget {
  const AdaptiveSelectorOptionsWidget({
    Key? key,
    required this.selectorValue,
    required this.buildItem,
    this.separatorBuilder,
    this.loadingBuilder,
    this.errorBuilder,
    this.emptyDataBuilder,
  }) : super(key: key);

  final ValueNotifier<SelectorValue<T>> selectorValue;
  final Widget Function(AdaptiveSelectorOption<T>) buildItem;
  final IndexedWidgetBuilder? separatorBuilder;
  final WidgetBuilder? loadingBuilder;
  final WidgetBuilder? errorBuilder;
  final WidgetBuilder? emptyDataBuilder;

  @override
  State<AdaptiveSelectorOptionsWidget<T>> createState() =>
      _AdaptiveSelectorOptionsWidgetState<T>();
}

class _AdaptiveSelectorOptionsWidgetState<T>
    extends State<AdaptiveSelectorOptionsWidget<T>> {
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
          separatorBuilder:
              widget.separatorBuilder ?? (_, __) => const SizedBox(),
        ),
        if (widget.selectorValue.value.loading)
          widget.loadingBuilder?.call(context) ??
              const ColoredBox(
                color: Colors.white38,
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              ),
        if (!widget.selectorValue.value.loading && (options?.isEmpty ?? false))
          widget.emptyDataBuilder?.call(context) ??
              const SizedBox(
                height: 100,
                child: Center(
                  child: Text('No data'),
                ),
              ),
        if (widget.selectorValue.value.error)
          widget.errorBuilder?.call(context) ??
              const SizedBox(
                height: 100,
                child: Center(
                  child: Icon(Icons.error),
                ),
              ),
      ],
    );
  }
}
