import 'package:flutter/material.dart';
import 'package:flutter_portal/flutter_portal.dart';

import 'bottom_sheet_selector.dart';
import 'overlay_selector.dart';

class Option<T> {
  Option({
    required this.label,
    required this.value,
  });

  final String label;
  final T value;

  @override
  int get hashCode => Object.hash(label, value);

  @override
  bool operator ==(Object other) {
    if (other is! Option) return false;
    final item = other;
    return label == item.label && value == item.value;
  }
}

class SelectorValue<T> {
  SelectorValue({
    this.options,
    this.selectedOption,
    required this.loading,
  });

  final Option<T>? selectedOption;
  final bool loading;
  final List<Option<T>>? options;
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
  }) : super(key: key);

  final bool bottomSheet;
  final Option<T>? initialValue;
  final Option<T>? value;
  final List<Option<T>>? options;
  final ValueChanged<String>? onSearch;
  final ValueChanged<Option<T>?>? onChange;
  final InputDecoration? decoration;
  final bool loading;
  final double? minWidth;
  final bool nullable;
  final bool enable;
  final Widget Function(Option<T> value, bool isSelected) itemBuilder;
  final IndexedWidgetBuilder? separatorBuilder;

  @override
  State<AdaptiveSelector<T>> createState() => AdaptiveSelectorState<T>();
}

class AdaptiveSelectorState<T> extends State<AdaptiveSelector<T>> {
  final textController = TextEditingController();
  final scrollController = ScrollController();
  final key = GlobalKey();
  late final ValueNotifier<SelectorValue<T>> selectorValue = ValueNotifier(
    SelectorValue(
      options: widget.options,
      selectedOption: widget.value,
      loading: false,
    ),
  );

  bool visible = false;
  late Option<T>? selectedOption = widget.initialValue;

  @override
  void didUpdateWidget(covariant AdaptiveSelector<T> oldWidget) {
    if (widget.value != null) {
      if (widget.value != oldWidget.value) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _updateOption(widget.value);
        });
      }
    }
    if (widget.bottomSheet) {
      selectorValue.value = SelectorValue(
        options: widget.options,
        selectedOption: selectedOption,
        loading: widget.loading,
      );
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  void initState() {
    textController.text = selectedOption?.label ?? '';
    super.initState();
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
        portalFollower: OverlaySelector<T>(
          visible: visible,
          width: width,
          minWidth: widget.minWidth,
          options: widget.options,
          buildItem: (item) => _buildItem(item, onTap: () {
            FocusScope.of(context).requestFocus(FocusNode());
            _updateOption(item);
          }),
          loading: widget.loading,
        ),
        child: Focus(
          onFocusChange: (hasFocus) {
            setState(() {
              visible = hasFocus;
            });
          },
          child: TextFormField(
            controller: textController,
            onChanged: widget.onSearch,
            onTap: () {
              if (widget.bottomSheet) {
                _showBottomSheetOptions();
              }
            },
            readOnly: widget.bottomSheet || widget.onSearch == null,
            enabled: widget.enable,
            decoration: InputDecoration(
              hintText: 'Select',
              fillColor: !widget.enable
                  ? Theme.of(context).colorScheme.onBackground.withOpacity(0.08)
                  : null,
              contentPadding: const EdgeInsets.only(
                left: 16,
                top: 16,
                bottom: 16,
              ),
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
                  : widget.value != null && widget.nullable
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
      constraints: const BoxConstraints(maxHeight: 800),
      builder: (_) {
        return BottomSheetSelector<T>(
          selectorValue: selectorValue,
          title: widget.decoration?.hintText ?? 'Selector',
          onSearch: widget.onSearch,
          buildItem: (item) => _buildItem(item, onTap: () {
            FocusManager.instance.primaryFocus?.unfocus();
            _updateOption(item);
            Navigator.of(context).pop();
          }),
        );
      },
    );
  }

  Widget _buildItem(Option<T> option, {required VoidCallback onTap}) {
    return Material(
      color: Colors.white,
      child: InkWell(
        onTap: onTap,
        child: widget.itemBuilder(
          option,
          option == selectedOption,
        ),
      ),
    );
  }

  void _updateOption(Option<T>? option) {
    setState(() {
      selectedOption = option;
    });
    textController.text = option?.label ?? '';
    widget.onChange?.call(option);
  }
}
