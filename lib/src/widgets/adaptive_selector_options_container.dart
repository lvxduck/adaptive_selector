import 'package:flutter/material.dart';

import '../../adaptive_selector.dart';
import '../models/adaptive_selector_option.dart';
import '../models/selector_value.dart';

class AdaptiveSelectorOptionsWidget<T> extends StatefulWidget {
  const AdaptiveSelectorOptionsWidget({
    Key? key,
    required this.selectorValue,
    required this.buildItem,
    this.separatorBuilder,
    this.loadingBuilder,
    this.errorBuilder,
    this.emptyDataBuilder,
    this.onLoadMore,
  }) : super(key: key);

  final ValueNotifier<SelectorValue<T>> selectorValue;
  final Widget Function(AdaptiveSelectorOption<T>) buildItem;
  final IndexedWidgetBuilder? separatorBuilder;
  final WidgetBuilder? loadingBuilder;
  final WidgetBuilder? errorBuilder;
  final WidgetBuilder? emptyDataBuilder;
  final VoidCallback? onLoadMore;

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
      if (mounted) {
        setState(() {});
      }
    });
  }

  bool handleScrollNotification(ScrollNotification notification) {
    if (notification is ScrollEndNotification) {
      if (notification.metrics.extentAfter == 0) {
        widget.onLoadMore?.call();
      }
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final options = widget.selectorValue.value.options;
    return Stack(
      children: [
        if (options != null && options.isNotEmpty)
          NotificationListener<ScrollNotification>(
            onNotification: handleScrollNotification,
            child: ListView.separated(
              shrinkWrap: true,
              itemCount:
                  options.length + (widget.selectorValue.value.hasMore ? 1 : 0),
              padding: const EdgeInsets.symmetric(vertical: 4),
              itemBuilder: (_, index) {
                if (index == options.length) {
                  return Container(
                    height: 64,
                    alignment: Alignment.center,
                    child: const CircularProgressIndicator(),
                  );
                }
                return widget.buildItem(options[index]);
              },
              separatorBuilder:
                  widget.separatorBuilder ?? (_, __) => const SizedBox(),
            ),
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
