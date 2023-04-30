import 'dart:async';

import 'package:flutter/material.dart';

import 'adaptive_selector_controller.dart';
import 'models/adaptive_selector_option.dart';
import 'models/selector_type.dart';
import 'selectors/bottom_sheet_selector.dart';
import 'selectors/menu_selector.dart';
import 'widgets/adaptive_selector_field.dart';
import 'widgets/adaptive_selector_multiple_field.dart';
import 'widgets/adaptive_selector_options_container.dart';
import 'widgets/adaptive_selector_tile.dart';

class AdaptiveSelector<T> extends StatefulWidget {
  const AdaptiveSelector({
    Key? key,
    this.onSearch,
    this.onChanged,
    this.onMultipleChanged,
    this.decoration = const InputDecoration(),
    this.loading = false,
    this.allowClear = true,
    this.enable = true,
    required this.options,
    this.itemBuilder,
    this.initial,
    this.type = SelectorType.bottomSheet,
    this.separatorBuilder,
    this.loadingBuilder,
    this.errorBuilder,
    this.emptyDataBuilder,
    this.debounceDuration = const Duration(milliseconds: 500),
    this.maxMenuHeight = 260,
    this.minMenuWidth,
    this.hasMoreData = false,
    this.onLoadMore,
    this.isMultiple = false,
    this.fieldBuilder,
    this.refreshWhenShow = false,
    this.bottomSheetSize = 0.5,
  })  : assert(bottomSheetSize <= 1.0 && bottomSheetSize >= 0),
        super(key: key);

  final SelectorType type;
  final bool isMultiple;

  /// Initial options
  final List<AdaptiveSelectorOption<T>>? initial;
  final List<AdaptiveSelectorOption<T>>? options;

  // callbacks
  final ValueChanged<String>? onSearch;
  final ValueChanged<AdaptiveSelectorOption<T>?>? onChanged;

  /// For mode multiple
  final ValueChanged<List<AdaptiveSelectorOption<T>>>? onMultipleChanged;

  /// Using for loading infinity page
  final VoidCallback? onLoadMore;

  // Widget builder
  /// Builder Function for item
  ///
  /// Default is AdaptiveSelectorOption widget
  final Widget Function(
    AdaptiveSelectorOption<T> value,
    bool isSelected,
    VoidCallback onTap,
  )? itemBuilder;
  final Widget Function(
    BuildContext context,
    AdaptiveSelectorController<T> controller,
  )? fieldBuilder;
  final IndexedWidgetBuilder? separatorBuilder;
  final WidgetBuilder? loadingBuilder;
  final WidgetBuilder? errorBuilder;
  final WidgetBuilder? emptyDataBuilder;

  // style
  final InputDecoration decoration;
  final bool loading;
  final bool allowClear;
  final bool enable;
  final bool hasMoreData;
  final Duration debounceDuration;
  final bool refreshWhenShow;

  // for menu selector
  final double maxMenuHeight;
  final double? minMenuWidth;

  // for bottom sheet
  /// The fractional value of the screen height to use when
  /// displaying the widget.
  ///
  /// The default value is `0.5`.
  final double bottomSheetSize;

  /// The data from the closest instance of this class that encloses the given
  /// context.
  ///
  /// Typical usage of the [AdaptiveSelectorState.of] function is to customize
  /// the AdaptiveSelectorFiled.
  static AdaptiveSelectorState of(BuildContext context) {
    return context.findAncestorStateOfType<AdaptiveSelectorState>()!;
  }

  @override
  State<AdaptiveSelector<T>> createState() => AdaptiveSelectorState<T>();
}

class AdaptiveSelectorState<T> extends State<AdaptiveSelector<T>> {
  Timer? _timer;

  late final controller = AdaptiveSelectorController<T>(
    options: widget.options ?? [],
    selectedOptions: {...?widget.initial},
    loading: false,
    hasMore: widget.hasMoreData,
    isMultiple: widget.isMultiple,
    enable: widget.enable,
  );

  void handleTextChange(String value) {
    if (_timer != null) {
      _timer?.cancel();
    }
    _timer = Timer(
      widget.debounceDuration,
      () => widget.onSearch?.call(value),
    );
  }

  @override
  void initState() {
    controller.selectedOptionsNotifier.addListener(() {
      final options = controller.selectedOptions;
      if (widget.isMultiple) {
        widget.onMultipleChanged?.call(options);
      } else {
        widget.onChanged?.call(options.isNotEmpty ? options.first : null);
      }
    });
    super.initState();
  }

  @override
  void didUpdateWidget(covariant AdaptiveSelector<T> oldWidget) {
    controller.update(
      options: widget.options ?? [],
      loading: widget.loading,
      hasMore: widget.hasMoreData,
      isMultiple: widget.isMultiple,
      error: false,
      enable: widget.enable,
    );
    super.didUpdateWidget(oldWidget);
  }

  Widget optionsWidget({ScrollController? scrollController}) {
    return AdaptiveSelectorOptionsWidget<T>(
      controller: controller,
      loadingBuilder: widget.loadingBuilder,
      errorBuilder: widget.errorBuilder,
      emptyDataBuilder: widget.emptyDataBuilder,
      separatorBuilder: widget.separatorBuilder,
      onLoadMore: widget.onLoadMore,
      buildItem: buildItem,
      scrollController: scrollController,
      selectorType: widget.type,
    );
  }

  Future showSelector() async {
    if (controller.options.isEmpty || widget.refreshWhenShow) {
      widget.onSearch?.call('');
    }
    switch (widget.type) {
      case SelectorType.bottomSheet:
        return showBottomSheet();
      case SelectorType.menu:
        return showMenu();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.fieldBuilder != null) {
      return widget.fieldBuilder!.call(context, controller);
    }
    final inputDecoration = widget.decoration.copyWith(
      filled: widget.decoration.filled ?? true,
      fillColor: widget.decoration.fillColor ??
          (widget.enable ? widget.decoration.fillColor : Colors.grey[200]),
      suffixIcon: widget.decoration.suffixIcon ??
          ValueListenableBuilder<Set<AdaptiveSelectorOption<T>>>(
            valueListenable: controller.selectedOptionsNotifier,
            builder: (_, selectedOption, ___) {
              if (selectedOption.isNotEmpty && widget.allowClear) {
                return Tooltip(
                  message:
                      MaterialLocalizations.of(context).deleteButtonTooltip,
                  child: InkWell(
                    onTap: controller.clearSelectedOption,
                    child: const Icon(Icons.clear),
                  ),
                );
              } else {
                return InkWell(
                  onTap: showSelector,
                  child: const Icon(Icons.keyboard_arrow_down),
                );
              }
            },
          ),
    );
    if (widget.isMultiple) {
      return MultipleSelectorTextField(
        decoration: inputDecoration,
        controller: controller,
      );
    }
    return AdaptiveSelectorField(
      decoration: inputDecoration,
      controller: controller,
    );
  }

  Future showBottomSheet() async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useRootNavigator: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return BottomSheetSelector<T>(
          onSearch: widget.onSearch != null ? handleTextChange : null,
          decoration: widget.decoration,
          bottomSheetSize: widget.bottomSheetSize,
          optionsBuilder: (context, controller) {
            return optionsWidget(scrollController: controller);
          },
        );
      },
    );
    FocusManager.instance.primaryFocus?.unfocus();
  }

  Future showMenu() {
    return showMenuSelector(
      context: context,
      minWidth: widget.minMenuWidth,
      builder: (context) {
        return MenuSelector(
          maxHeight: widget.maxMenuHeight,
          optionsBuilder: (context) {
            return optionsWidget();
          },
        );
      },
    );
  }

  Widget buildItem(AdaptiveSelectorOption<T> option) {
    onTap() {
      if (!widget.isMultiple) {
        Navigator.of(context).pop();
        FocusManager.instance.primaryFocus?.unfocus();
      }
      controller.selectOption(option);
    }

    final isSelected = controller.selectedOptions.contains(option);
    return widget.itemBuilder?.call(option, isSelected, onTap) ??
        AdaptiveSelectorTile(
          option: option,
          isSelected: isSelected,
          onTap: onTap,
        );
  }
}
