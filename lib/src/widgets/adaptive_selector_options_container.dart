import 'package:flutter/material.dart';

import '../../adaptive_selector.dart';
import 'adaptive_selector_tile.dart';

class AdaptiveSelectorOptionsWidget<T> extends StatelessWidget {
  const AdaptiveSelectorOptionsWidget({
    Key? key,
    this.scrollController,
    required this.selector,
  }) : super(key: key);

  final AdaptiveSelectorState<T> selector;
  final ScrollController? scrollController;

  AdaptiveSelectorController<T> get controller => selector.controller;

  bool get _hasMoreData => selector.widget.hasMoreData;

  bool handleScrollNotification(ScrollNotification notification) {
    if (notification is ScrollEndNotification) {
      if (notification.metrics.extentAfter == 0 && _hasMoreData) {
        if (selector.widget.onLoadMore != null) {
          controller.guardFuture(() => selector.widget.onLoadMore!.call());
        }
      }
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (_, __) {
        final options = controller.options;
        return Stack(
          children: [
            if (options.isNotEmpty)
              NotificationListener<ScrollNotification>(
                onNotification: handleScrollNotification,
                child: ListView.separated(
                  shrinkWrap: true,
                  controller: scrollController,
                  keyboardDismissBehavior:
                      selector.widget.type == SelectorType.bottomSheet
                          ? ScrollViewKeyboardDismissBehavior.onDrag
                          : ScrollViewKeyboardDismissBehavior.manual,
                  itemCount: options.length + (_hasMoreData ? 1 : 0),
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  itemBuilder: (context, index) {
                    if (index == options.length) {
                      return Container(
                        height: 64,
                        alignment: Alignment.center,
                        child: const CircularProgressIndicator(),
                      );
                    }
                    final option = options[index];
                    return selector.widget.itemBuilder
                            ?.call(context, option, selector) ??
                        AdaptiveSelectorTile(
                          option: option,
                          selector: selector,
                        );
                  },
                  separatorBuilder: selector.widget.separatorBuilder ??
                      (_, __) => const SizedBox(),
                ),
              ),
            if (controller.error != null)
              selector.widget.errorBuilder?.call(context) ??
                  SizedBox(
                    height: 200,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.error),
                          Text(controller.error.toString()),
                        ],
                      ),
                    ),
                  )
            else if (selector.widget.loading)
              selector.widget.loadingBuilder?.call(context) ??
                  const ColoredBox(
                    color: Colors.white38,
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  )
            else if (!selector.widget.loading && options.isEmpty)
              selector.widget.emptyDataBuilder?.call(context) ??
                  const SizedBox(
                    height: 100,
                    child: Center(
                      child: Text('No data'),
                    ),
                  )
          ],
        );
      },
    );
  }
}
