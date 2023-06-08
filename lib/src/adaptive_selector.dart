import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'adaptive_selector_controller.dart';
import 'models/adaptive_selector_option.dart';
import 'models/selector_type.dart';
import 'selectors/bottom_sheet_selector.dart';
import 'selectors/menu_selector.dart';
import 'widgets/adaptive_selector_field.dart';
import 'widgets/adaptive_selector_multiple_field.dart';
import 'widgets/adaptive_selector_options_container.dart';

/// Signature for a function that creates a selector
///
/// Used by [AdaptiveSelector.menuBuilder], [AdaptiveSelector.bottomSheetBuilder]
typedef SelectorBuilder<T> = Widget Function(
  BuildContext context,
  Widget child,
  AdaptiveSelectorState<T> selector,
);

/// Signature for a function that creates a selector field
///
/// Used by [AdaptiveSelector.fieldBuilder]
typedef SelectorFieldBuilder<T> = Widget Function(
  BuildContext context,
  AdaptiveSelectorState<T> selector,
);

/// Signature for a function that creates a selector item
///
/// Used by [AdaptiveSelector.itemBuilder]
typedef SelectorItemBuilder<T> = Widget Function(
  BuildContext context,
  AdaptiveSelectorOption<T> option,
  AdaptiveSelectorState<T> selector,
);

/// An AdaptiveSelector provides a list of options for a user to select.
///
/// There are 2 types of selector:
/// - Menu
/// - BottomSheet
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
    this.decoration = const InputDecoration(),
    this.loading = false,
    this.allowClear = true,
    this.enable = true,
    this.hasMoreData = false,
    this.refreshWhenShow = false,
    this.useRootNavigator = false,
    this.itemBuilder,
    this.separatorBuilder,
    this.loadingBuilder,
    this.errorBuilder,
    this.emptyDataBuilder,
    this.fieldBuilder,
    this.debounceDuration = const Duration(milliseconds: 500),
    this.bottomSheetSize = 0.6,
    this.maxMenuHeight = 260,
    this.minMenuWidth,
    this.bottomSheetBuilder,
    this.menuBehavior = HitTestBehavior.opaque,
    this.menuBuilder,
    this.controller,
  })  : assert(bottomSheetSize <= 1.0 && bottomSheetSize >= 0),
        assert(
          !(isMultiple == false && initial != null && initial.length > 1),
          'initial options must has length <= 1 if selector is not isMultiple',
        ),
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

  /// Called to fetch new options based on the keyword
  final AsyncValueSetter<String>? onSearch;

  /// Called when the user select or remove an option.
  final ValueChanged<List<AdaptiveSelectorOption<T>>>? onChanged;

  /// Using for loading infinity page
  final AsyncCallback? onLoadMore;

  /// The custom builder for option tile
  final SelectorItemBuilder<T>? itemBuilder;

  /// The custom field builder widget for option
  ///
  /// Tips:
  /// - Use the AdaptiveSelector.of(context) method to access methods such as showSelector and handleTextChange,
  /// or properties such as type, enable, decoration, and so on.
  /// - Take a look at [AdaptiveSelectorField]
  final SelectorFieldBuilder<T>? fieldBuilder;

  /// The separatorBuilder to custom list options UI
  final IndexedWidgetBuilder? separatorBuilder;

  /// The custom loading builder
  final WidgetBuilder? loadingBuilder;

  /// The custom error builder
  final WidgetBuilder? errorBuilder;

  /// The custom empty data builder
  final WidgetBuilder? emptyDataBuilder;

  /// The custom builder for bottomSheet UI
  final SelectorBuilder<T>? bottomSheetBuilder;

  /// The custom builder for bottomSheet UI
  final SelectorBuilder<T>? menuBuilder;

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

  /// The value that will pass to showModalBottomSheet function
  final bool useRootNavigator;

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

  /// Determine the [HitTestBehavior] of the menu selector.
  /// Default to [HitTestBehavior.opaque]
  final HitTestBehavior menuBehavior;

  /// Controls the selected options of selector.
  /// If null, this widget will create its own AdaptiveSelectorController.
  final AdaptiveSelectorController<T>? controller;

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

  bool isSelected(AdaptiveSelectorOption<T> option) =>
      controller.selectedOptions.contains(option);

  late final controller = widget.controller ??
      AdaptiveSelectorController<T>(
        options: widget.options ?? [],
        selectedOptions: [...?widget.initial],
        isMultiple: widget.isMultiple,
        allowClear: widget.allowClear,
      );

  void handleTextChange(String value) {
    if (widget.onSearch == null) return;
    if (_timer != null) {
      _timer?.cancel();
    }
    _timer = Timer(
      widget.debounceDuration,
      () {
        controller.guardFuture(() => widget.onSearch!.call(value));
      },
    );
  }

  @override
  void initState() {
    controller.selectedOptionsNotifier.addListener(() {
      widget.onChanged?.call(controller.selectedOptions);
    });
    super.initState();
  }

  @override
  void didUpdateWidget(covariant AdaptiveSelector<T> oldWidget) {
    if (widget.controller != null) {
      controller.update(
        options: widget.options ?? [],
        isMultiple: widget.isMultiple,
        allowClear: widget.allowClear,
      );
    }
    super.didUpdateWidget(oldWidget);
  }

  Widget buildOptionsWidget({ScrollController? scrollController}) {
    return AdaptiveSelectorOptionsWidget<T>(
      scrollController: scrollController,
      selector: this,
    );
  }

  /// Show selector based on [SelectorType]
  Future<void> showSelector() async {
    if (controller.options.isEmpty || widget.refreshWhenShow) {
      if (widget.onSearch != null) {
        controller.guardFuture(() => widget.onSearch!.call(''));
      }
    }
    switch (widget.type) {
      case SelectorType.bottomSheet:
        return showBottomSheet();
      case SelectorType.menu:
        return showMenu();
    }
  }

  /// Show the BottomSheet selector
  Future<void> showBottomSheet() async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useRootNavigator: widget.useRootNavigator,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return BottomSheetSelector<T>(selector: this);
      },
    );
    FocusManager.instance.primaryFocus?.unfocus();
  }

  /// Show the menu selector
  Future<void> showMenu() {
    return showMenuSelector(
      context: context,
      minWidth: widget.minMenuWidth,
      behavior: widget.menuBehavior,
      builder: (context) {
        return MenuSelector(selector: this);
      },
    );
  }

  void handleTapOption(AdaptiveSelectorOption<T> option) {
    if (!widget.isMultiple) {
      Navigator.of(context).pop();
      FocusManager.instance.primaryFocus?.unfocus();
    }
    controller.selectOption(option);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.fieldBuilder != null) {
      return widget.fieldBuilder!.call(context, this);
    }
    final inputDecoration = widget.decoration.copyWith(
      suffixIcon: widget.decoration.suffixIcon ??
          ValueListenableBuilder<List<AdaptiveSelectorOption<T>>>(
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
}
