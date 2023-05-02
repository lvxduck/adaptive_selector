import 'package:flutter/material.dart';

import '../../adaptive_selector.dart';

class AdaptiveSelectorOptionsWidget<T> extends StatefulWidget {
  const AdaptiveSelectorOptionsWidget({
    Key? key,
    required this.controller,
    required this.buildItem,
    this.separatorBuilder,
    this.loadingBuilder,
    this.errorBuilder,
    this.emptyDataBuilder,
    this.onLoadMore,
    this.scrollController,
    required this.selectorType,
  }) : super(key: key);

  final AdaptiveSelectorController<T> controller;

  final Widget Function(AdaptiveSelectorOption<T>) buildItem;
  final IndexedWidgetBuilder? separatorBuilder;
  final WidgetBuilder? loadingBuilder;
  final WidgetBuilder? errorBuilder;
  final WidgetBuilder? emptyDataBuilder;
  final VoidCallback? onLoadMore;
  final ScrollController? scrollController;
  final SelectorType selectorType;

  @override
  State<AdaptiveSelectorOptionsWidget<T>> createState() =>
      _AdaptiveSelectorOptionsWidgetState<T>();
}

class _AdaptiveSelectorOptionsWidgetState<T>
    extends State<AdaptiveSelectorOptionsWidget<T>> {
  @override
  void initState() {
    widget.controller.addListener(onChange);
    super.initState();
  }

  @override
  void dispose() {
    widget.controller.removeListener(onChange);
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
    final options = widget.controller.options;
    return Stack(
      children: [
        if (options.isNotEmpty)
          NotificationListener<ScrollNotification>(
            onNotification: handleScrollNotification,
            child: ListView.separated(
              shrinkWrap: true,
              controller: widget.scrollController,
              keyboardDismissBehavior:
                  widget.selectorType == SelectorType.bottomSheet
                      ? ScrollViewKeyboardDismissBehavior.onDrag
                      : ScrollViewKeyboardDismissBehavior.manual,
              itemCount: options.length + (widget.controller.hasMore ? 1 : 0),
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
        if (widget.controller.error != null)
          widget.errorBuilder?.call(context) ??
              SizedBox(
                height: 200,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error),
                      Text(widget.controller.error.toString()),
                    ],
                  ),
                ),
              )
        else if (widget.controller.loading)
          widget.loadingBuilder?.call(context) ??
              const ColoredBox(
                color: Colors.white38,
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              )
        else if (!widget.controller.loading && options.isEmpty)
          widget.emptyDataBuilder?.call(context) ??
              const SizedBox(
                height: 100,
                child: Center(
                  child: Text('No data'),
                ),
              )
      ],
    );
  }
}
