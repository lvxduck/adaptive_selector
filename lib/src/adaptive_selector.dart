import 'dart:async';

import 'package:flutter/material.dart';

import 'adaptive_selector_controller.dart';
import 'models/adaptive_selector_option.dart';
import 'models/selector_type.dart';
import 'selectors/bottom_sheet_selector.dart';
import 'selectors/menu_selector.dart';
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
    this.initialOption,
    this.type = SelectorType.bottomSheet,
    this.bottomSheetTitle,
    this.separatorBuilder,
    this.loadingBuilder,
    this.errorBuilder,
    this.emptyDataBuilder,
    this.debounceDuration = const Duration(milliseconds: 500),
    this.maxMenuHeight = 160,
    this.minMenuWidth,
    this.hasMoreData = false,
    this.onLoadMore,
    this.initialOptions,
    this.isMultiple = false,
    this.fieldBuilder,
  }) : super(key: key);

  final SelectorType type;
  final bool isMultiple;

  /// Initial selected option
  final AdaptiveSelectorOption<T>? initialOption;
  final List<AdaptiveSelectorOption<T>>? initialOptions;
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
    AdaptiveSelectorController<T> controller,
    ValueChanged<String>? onSearch,
    VoidCallback onTap,
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

  // for menu selector
  final double maxMenuHeight;
  final double? minMenuWidth;

  // for bottom sheet only
  final String? bottomSheetTitle;

  @override
  State<AdaptiveSelector<T>> createState() => AdaptiveSelectorState<T>();
}

class AdaptiveSelectorState<T> extends State<AdaptiveSelector<T>> {
  final textController = TextEditingController();
  Timer? _timer;

  Set<AdaptiveSelectorOption<T>> get initialOptions => {
        if (widget.isMultiple)
          ...?widget.initialOptions
        else if (widget.initialOption != null)
          widget.initialOption!,
      };

  late final controller = AdaptiveSelectorController<T>(
    options: widget.options ?? [],
    selectedOptions: initialOptions,
    loading: false,
    hasMore: widget.hasMoreData,
    isMultiple: widget.isMultiple,
  );

  void debounceSearch(String value) {
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
    if (!widget.isMultiple) {
      textController.text = widget.initialOption?.label ?? '';
    }
    controller.selectedOptionsNotifier.addListener(() {
      final options = controller.selectedOptions;
      if (widget.isMultiple) {
        widget.onMultipleChanged?.call(options);
      } else {
        widget.onChanged?.call(options.isNotEmpty ? options.first : null);
      }
      if (!widget.isMultiple) {
        textController.text = options.isNotEmpty ? options.first.label : '';
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
    );
  }

  void showSelector() {
    widget.onSearch?.call('');
    switch (widget.type) {
      case SelectorType.bottomSheet:
        showBottomSheet();
        break;
      case SelectorType.menu:
        showMenu();
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final inputDecoration = widget.decoration.copyWith(
      filled: true,
      fillColor: widget.enable ? widget.decoration.fillColor : Colors.grey[200],
      suffixIcon: ValueListenableBuilder<Set<AdaptiveSelectorOption<T>>>(
        valueListenable: controller.selectedOptionsNotifier,
        builder: (_, selectedOption, ___) {
          return selectedOption.isNotEmpty && widget.allowClear
              ? InkWell(
                  onTap: controller.clearSelectedOption,
                  child: const Icon(Icons.clear),
                )
              : const Icon(Icons.keyboard_arrow_down);
        },
      ),
    );
    if (widget.isMultiple) {
      return widget.fieldBuilder
              ?.call(controller, debounceSearch, showSelector) ??
          MultipleSelectorTextField(
            onTap: showSelector,
            decoration: inputDecoration,
            controller: controller,
            onSearch: widget.onSearch != null ? debounceSearch : null,
          );
    }
    return TextFormField(
      controller: textController,
      onChanged: debounceSearch,
      onTap: () {
        widget.onSearch?.call('');
        switch (widget.type) {
          case SelectorType.bottomSheet:
            showBottomSheet();
            break;
          case SelectorType.menu:
            showMenu();
            break;
        }
      },
      readOnly:
          widget.type == SelectorType.bottomSheet || widget.onSearch == null,
      enabled: widget.enable,
      decoration: inputDecoration,
    );
  }

  void showBottomSheet() async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useRootNavigator: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return BottomSheetSelector<T>(
          title: widget.bottomSheetTitle ??
              widget.decoration.hintText ??
              'Selector',
          onSearch: widget.onSearch != null ? debounceSearch : null,
          decoration: widget.decoration,
          optionsBuilder: (context, controller) {
            return optionsWidget(scrollController: controller);
          },
        );
      },
    );
    FocusManager.instance.primaryFocus?.unfocus();
  }

  void showMenu() {
    showMenuSelector(
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
