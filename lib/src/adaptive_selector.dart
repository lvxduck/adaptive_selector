import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_portal/flutter_portal.dart';

import 'adaptive_selector_options_container.dart';
import 'bottom_sheet_selector.dart';
import 'menu_selector.dart';

class AdaptiveSelectorOption<T> {
  AdaptiveSelectorOption({
    required this.label,
    required this.value,
  });

  final String label;
  final T value;

  @override
  int get hashCode => Object.hash(label, value);

  @override
  bool operator ==(Object other) {
    if (other is! AdaptiveSelectorOption) return false;
    final item = other;
    return label == item.label && value == item.value;
  }
}

class SelectorValue<T> {
  SelectorValue({
    this.options,
    this.selectedOption,
    required this.loading,
    this.error = false,
  });

  final AdaptiveSelectorOption<T>? selectedOption;
  final bool loading;
  final bool error;
  final List<AdaptiveSelectorOption<T>>? options;
}

class AdaptiveSelector<T> extends StatefulWidget {
  const AdaptiveSelector({
    Key? key,
    this.value,
    this.onSearch,
    this.onChange,
    this.decoration,
    this.minWidth,
    this.loading = false,
    this.nullable = true,
    this.enable = true,
    this.separatorBuilder,
    required this.options,
    required this.itemBuilder,
    this.initialValue,
    this.bottomSheet = false,
    this.bottomSheetTitle,
    this.loadingBuilder,
    this.errorBuilder,
    this.emptyDataBuilder,
    this.debounceDuration = const Duration(milliseconds: 500),
    this.maxMenuHeight = 160,
  }) : super(key: key);

  final bool bottomSheet;
  final AdaptiveSelectorOption<T>? initialValue;
  final AdaptiveSelectorOption<T>? value;
  final List<AdaptiveSelectorOption<T>>? options;
  final ValueChanged<String>? onSearch;
  final ValueChanged<AdaptiveSelectorOption<T>?>? onChange;
  final InputDecoration? decoration;
  final bool loading;
  final double? minWidth;
  final bool nullable;
  final bool enable;
  final Duration debounceDuration;

  // menu selector;
  final double maxMenuHeight;

  // builder
  final Widget Function(AdaptiveSelectorOption<T> value, bool isSelected)
      itemBuilder;
  final IndexedWidgetBuilder? separatorBuilder;
  final WidgetBuilder? loadingBuilder;
  final WidgetBuilder? errorBuilder;
  final WidgetBuilder? emptyDataBuilder;

  //
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
      selectedOption: widget.value,
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
    if (widget.value != null) {
      if (widget.value != oldWidget.value) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _updateOption(widget.value);
        });
      }
    }
    selectorNotifier.value = SelectorValue(
      options: widget.options,
      selectedOption: selectedOption,
      loading: widget.loading,
    );
    super.didUpdateWidget(oldWidget);
  }

  bool isShowBottom() {
    final box = key.currentContext?.findRenderObject() as RenderBox?;
    if (box == null) return true;
    final position = box.localToGlobal(Offset.zero);
    if (position.dy > MediaQuery.of(context).size.height * 2 / 3) {
      return false;
    }
    return true;
  }

  late Widget optionsWidget = AdaptiveSelectorOptionsWidget<T>(
    selectorValue: selectorNotifier,
    loadingBuilder: widget.loadingBuilder,
    errorBuilder: widget.errorBuilder,
    emptyDataBuilder: widget.emptyDataBuilder,
    separatorBuilder: widget.separatorBuilder,
    buildItem: _buildItem,
  );

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (_, box) {
      final width = box.maxWidth;
      return PortalTarget(
        key: key,
        visible: !widget.bottomSheet,
        anchor: isShowBottom()
            ? const Aligned(
                follower: Alignment.topCenter,
                target: Alignment.bottomCenter,
              )
            : const Aligned(
                follower: Alignment.bottomCenter,
                target: Alignment.topCenter,
              ),
        portalFollower: MenuSelector<T>(
          visible: visible,
          width: width,
          minWidth: widget.minWidth,
          maxHeight: widget.maxMenuHeight,
          optionsBuilder: (context) {
            return optionsWidget;
          },
        ),
        child: Focus(
          onFocusChange: (hasFocus) {
            setState(() {
              visible = hasFocus;
            });
          },
          child: TextFormField(
            controller: textController,
            onChanged: debounceSearch,
            onTap: () {
              if (widget.bottomSheet) {
                _showBottomSheetOptions();
              }
            },
            readOnly: widget.bottomSheet || widget.onSearch == null,
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
                            _updateOption(null);
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
          ),
        ),
      );
    });
  }

  void _showBottomSheetOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height - 100,
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

  Widget _buildItem(AdaptiveSelectorOption<T> option) {
    return Material(
      color: Colors.white,
      child: InkWell(
        onTap: () {
          if (widget.bottomSheet) {
            FocusManager.instance.primaryFocus?.unfocus();
            _updateOption(option);
            Navigator.of(context).pop();
          } else {
            FocusScope.of(context).requestFocus(FocusNode());
            _updateOption(option);
          }
        },
        child: widget.itemBuilder(
          option,
          option == selectedOption,
        ),
      ),
    );
  }

  void _updateOption(AdaptiveSelectorOption<T>? option) {
    setState(() {
      selectedOption = option;
    });
    textController.text = option?.label ?? '';
    widget.onChange?.call(option);
  }
}
