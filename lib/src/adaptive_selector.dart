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
    this.initial,
    required this.options,
    this.isMultiple = false,
    this.type = SelectorType.bottomSheet,
    this.onSearch,
    this.onChanged,
    this.onLoadMore,
    this.onMultipleChanged,
    this.decoration = const InputDecoration(),
    this.loading = false,
    this.allowClear = true,
    this.enable = true,
    this.hasMoreData = false,
    this.refreshWhenShow = false,
    this.itemBuilder,
    this.separatorBuilder,
    this.loadingBuilder,
    this.errorBuilder,
    this.emptyDataBuilder,
    this.fieldBuilder,
    this.debounceDuration = const Duration(milliseconds: 500),
    this.bottomSheetSize = 0.5,
    this.maxMenuHeight = 260,
    this.minMenuWidth,
  })  : assert(bottomSheetSize <= 1.0 && bottomSheetSize >= 0),
        super(key: key);

  /// Determine the [SelectorType] type.
  ///
  /// Defaults to [SelectorType.bottomSheet]
  final SelectorType type;

  /// Determine if the [AdaptiveSelector] is multiple or not.
  final bool isMultiple;

  /// The value used to for an initial options.
  ///
  /// Defaults to null.
  final List<AdaptiveSelectorOption<T>>? initial;

  /// The list of options the user can select.
  final List<AdaptiveSelectorOption<T>>? options;

  // callbacks
  final ValueChanged<String>? onSearch;
  final ValueChanged<AdaptiveSelectorOption<T>?>? onChanged;

  /// For mode multiple
  final ValueChanged<List<AdaptiveSelectorOption<T>>>? onMultipleChanged;

  /// Using for loading infinity page
  final VoidCallback? onLoadMore;

  /// The custom builder for option tile
  final Widget Function(
    AdaptiveSelectorOption<T> value,
    bool isSelected,
    VoidCallback onTap,
  )? itemBuilder;

  /// The custom field builder widget for option
  ///
  /// Tips:
  ///
  /// Use the AdaptiveSelector.of(context) method to access methods such as showSelector and handleTextChange,
  /// or properties such as type, enable, decoration, and so on.
  final Widget Function(
    BuildContext context,
    AdaptiveSelectorController<T> controller,
  )? fieldBuilder;

  /// The separatorBuilder to custom list options UI
  final IndexedWidgetBuilder? separatorBuilder;

  /// The custom loading builder
  final WidgetBuilder? loadingBuilder;

  /// The custom error builder
  final WidgetBuilder? errorBuilder;

  /// The custom empty data builder
  final WidgetBuilder? emptyDataBuilder;

  /// The input decoration of TextField
  final InputDecoration decoration;

  /// Determine if the [AdaptiveSelector] is loading.
  ///
  /// Default to false
  final bool loading;

  /// Determine if the [AdaptiveSelector] is allow to clear selected options
  ///
  /// Defaults to true
  final bool allowClear;

  /// Determine if the [AdaptiveSelector] is enabled.
  ///
  /// Defaults to true.
  final bool enable;

  /// Determine if the [AdaptiveSelector] is has more data to load.
  ///
  /// If true [onLoadMore] will be called to fetch more data.
  ///
  /// Defaults to true.
  final bool hasMoreData;

  /// The debounce duration of textField to reduce text change event
  ///
  /// Defaults to 500 milliseconds
  final Duration debounceDuration;

  /// Determine if the [AdaptiveSelector] should refresh data when shown or continue to use old data.
  ///
  /// Defaults to false
  final bool refreshWhenShow;

  /// Determine the height of the menu selector.
  ///
  /// Default to 260
  final double maxMenuHeight;

  /// The min width of menu selector
  ///
  /// If this is null, the width of the menu will be the same as the width of the selector field
  final double? minMenuWidth;

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
