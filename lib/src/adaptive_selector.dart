import 'dart:async';

import 'package:flutter/material.dart';

import 'models/adaptive_selector_option.dart';
import 'models/selector_type.dart';
import 'models/selector_value.dart';
import 'selectors/bottom_sheet_selector.dart';
import 'selectors/menu_selector.dart';
import 'widgets/adaptive_selector_options_container.dart';
import 'widgets/adaptive_selector_tile.dart';

class AdaptiveSelector<T> extends StatefulWidget {
  const AdaptiveSelector({
    Key? key,
    this.onSearch,
    this.onChanged,
    this.decoration,
    this.minMenuWidth,
    this.loading = false,
    this.nullable = true,
    this.enable = true,
    this.separatorBuilder,
    required this.options,
    this.itemBuilder,
    this.initialValue,
    this.type = SelectorType.bottomSheet,
    this.bottomSheetTitle,
    this.loadingBuilder,
    this.errorBuilder,
    this.emptyDataBuilder,
    this.debounceDuration = const Duration(milliseconds: 500),
    this.maxMenuHeight = 160,
  }) : super(key: key);

  final SelectorType type;
  final AdaptiveSelectorOption<T>? initialValue;
  final List<AdaptiveSelectorOption<T>>? options;

  // callbacks
  final ValueChanged<String>? onSearch;
  final ValueChanged<AdaptiveSelectorOption<T>?>? onChanged;

  // Widget builder
  final Widget Function(
    AdaptiveSelectorOption<T> value,
    bool isSelected,
    VoidCallback onTap,
  )? itemBuilder;
  final IndexedWidgetBuilder? separatorBuilder;
  final WidgetBuilder? loadingBuilder;
  final WidgetBuilder? errorBuilder;
  final WidgetBuilder? emptyDataBuilder;

  // style
  final InputDecoration? decoration;
  final bool loading;
  final bool nullable;
  final bool enable;
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
  final scrollController = ScrollController();
  final key = GlobalKey();
  late final ValueNotifier<SelectorValue<T>> selectorNotifier = ValueNotifier(
    SelectorValue(
      options: widget.options,
      selectedOption: widget.initialValue,
      loading: false,
    ),
  );

  Timer? _timer;
  bool visible = false;
  late AdaptiveSelectorOption<T>? selectedOption = widget.initialValue;

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
    textController.text = selectedOption?.label ?? '';
    super.initState();
  }

  @override
  void didUpdateWidget(covariant AdaptiveSelector<T> oldWidget) {
    selectorNotifier.value = SelectorValue(
      options: widget.options,
      selectedOption: selectedOption,
      loading: widget.loading,
    );
    super.didUpdateWidget(oldWidget);
  }

  late Widget optionsWidget = AdaptiveSelectorOptionsWidget<T>(
    selectorValue: selectorNotifier,
    loadingBuilder: widget.loadingBuilder,
    errorBuilder: widget.errorBuilder,
    emptyDataBuilder: widget.emptyDataBuilder,
    separatorBuilder: widget.separatorBuilder,
    buildItem: buildItem,
  );

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: textController,
      onChanged: debounceSearch,
      onTap: () {
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
      decoration: InputDecoration(
        fillColor: !widget.enable
            ? Theme.of(context).colorScheme.onBackground.withOpacity(0.08)
            : null,
        contentPadding: const EdgeInsets.only(left: 16),
        suffixIcon: widget.loading && !visible
            ? const SizedBox.square(
                dimension: 28,
                child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                  ),
                ),
              )
            : selectedOption != null && widget.nullable
                ? InkWell(
                    onTap: () {
                      updateOption(null);
                      widget.onSearch?.call('');
                    },
                    child: const Icon(Icons.clear),
                  )
                : const Icon(Icons.keyboard_arrow_down),
      ).copyWith(
        hintText: widget.decoration?.hintText,
        prefixIcon: widget.decoration?.prefixIcon,
        suffixIcon: widget.decoration?.suffixIcon,
        errorText: widget.decoration?.errorText,
      ),
    );
  }

  void showBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useRootNavigator: true,
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height - 100,
      ),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(12),
        ),
      ),
      builder: (_) {
        return BottomSheetSelector<T>(
          title: widget.bottomSheetTitle ??
              widget.decoration?.hintText ??
              'Selector',
          onSearch: widget.onSearch != null ? debounceSearch : null,
          decoration: widget.decoration,
          optionsBuilder: (context) {
            return optionsWidget;
          },
        );
      },
    );
  }

  void showMenu() {
    showMenuSelector(
      context: context,
      minWidth: widget.minMenuWidth,
      builder: (context) {
        return MenuSelector(
          maxHeight: widget.maxMenuHeight,
          optionsBuilder: (context) {
            return optionsWidget;
          },
        );
      },
    );
  }

  Widget buildItem(AdaptiveSelectorOption<T> option) {
    onTap() {
      Navigator.of(context).pop();
      FocusManager.instance.primaryFocus?.unfocus();
      updateOption(option);
    }

    return widget.itemBuilder?.call(option, option == selectedOption, onTap) ??
        AdaptiveSelectorTile(
          option: option,
          isSelected: option == selectedOption,
          onTap: onTap,
        );
  }

  void updateOption(AdaptiveSelectorOption<T>? option) {
    setState(() {
      selectedOption = option;
    });
    textController.text = option?.label ?? '';
    widget.onChanged?.call(option);
  }
}
