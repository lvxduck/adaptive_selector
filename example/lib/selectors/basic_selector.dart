import 'package:adaptive_selector/adaptive_selector.dart';
import 'package:faker/faker.dart';
import 'package:flutter/material.dart';

class PersonFilter {
  final int page;
  final String? keyword;

  PersonFilter({required this.page, this.keyword});

  PersonFilter copyWith({int? page, String? keyword}) {
    return PersonFilter(
      page: page ?? this.page,
      keyword: keyword ?? this.keyword,
    );
  }
}

class BasicUsage extends StatefulWidget {
  const BasicUsage({
    Key? key,
    required this.selectorType,
  }) : super(key: key);

  final SelectorType selectorType;

  @override
  State<BasicUsage> createState() => _BasicUsageState();
}

class _BasicUsageState extends State<BasicUsage> {
  late List<AdaptiveSelectorOption<Person>> userOptions = [];
  bool loading = false;
  bool hasMoreData = true;
  PersonFilter filter = PersonFilter(page: 1);

  Future<List<Person>> getList(PersonFilter filter) async {
    await Future.delayed(const Duration(seconds: 1));
    return List.generate(20, (index) => faker.person);
  }

  void handleSearch(value) async {
    setState(() {
      loading = true;
    });
    final data = await getList(filter);
    setState(() {
      filter = filter.copyWith(keyword: value);
      userOptions = data
          .map((e) => AdaptiveSelectorOption(label: e.name(), value: e))
          .toList();
      hasMoreData = random.boolean();
      loading = false;
    });
  }

  void handleLoadMore() async {
    if (!hasMoreData) return;
    final data = await getList(filter);
    setState(() {
      filter = filter.copyWith(page: filter.page + 1);
      userOptions.addAll(
        data
            .map((e) => AdaptiveSelectorOption(label: e.name(), value: e))
            .toList(),
      );
      hasMoreData = random.boolean();
    });
  }

  bool enable = true;
  bool allowClear = true;
  bool refreshWhenShow = false;
  bool shouldShowMinMenuWidth = false;
  bool shouldShowMaxMenuHeight = false;
  bool shouldShowError = false;
  bool multiple = false;
  bool searchAble = false;
  double minMenuWidth = 320;
  double maxMenuHeight = 120;

  @override
  void initState() {
    handleSearch('');
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SwitchListTile(
          value: enable,
          onChanged: (value) => setState(() => enable = value),
          title: const Text('Enable'),
        ),
        SwitchListTile(
          value: allowClear,
          onChanged: (value) => setState(() => allowClear = value),
          title: const Text('Allow clear'),
        ),
        SwitchListTile(
          value: refreshWhenShow,
          onChanged: (value) => setState(() => refreshWhenShow = value),
          title: const Text('Refresh when show'),
        ),
        SwitchListTile(
          value: shouldShowError,
          onChanged: (value) => setState(() => shouldShowError = value),
          title: const Text('Show error'),
        ),
        SwitchListTile(
          value: multiple,
          onChanged: (value) => setState(() => multiple = value),
          title: const Text('Multiple'),
        ),
        SwitchListTile(
          value: searchAble,
          onChanged: (value) => setState(() => searchAble = value),
          title: const Text('Searchable'),
        ),
        ListTile(
          title: Row(
            children: [
              Expanded(
                child: Text(
                  'Min menu width: ${shouldShowMinMenuWidth ? minMenuWidth.toInt().toString() : ''}',
                ),
              ),
              Switch(
                value: shouldShowMinMenuWidth,
                onChanged: (value) =>
                    setState(() => shouldShowMinMenuWidth = value),
              ),
            ],
          ),
          horizontalTitleGap: 0,
          subtitle: shouldShowMinMenuWidth
              ? Slider(
                  value: minMenuWidth,
                  onChanged: (value) => setState(() => minMenuWidth = value),
                  min: 100,
                  max: 2000,
                  divisions: 10,
                )
              : null,
        ),
        ListTile(
          title: Row(
            children: [
              Expanded(
                child: Text(
                  'Max menu height: ${shouldShowMaxMenuHeight ? maxMenuHeight.toInt().toString() : ''}',
                ),
              ),
              Switch(
                value: shouldShowMaxMenuHeight,
                onChanged: (value) =>
                    setState(() => shouldShowMaxMenuHeight = value),
              ),
            ],
          ),
          horizontalTitleGap: 0,
          subtitle: shouldShowMaxMenuHeight
              ? Slider(
                  value: maxMenuHeight,
                  onChanged: (value) => setState(() => maxMenuHeight = value),
                  min: 100,
                  max: 400,
                  divisions: 10,
                )
              : null,
        ),
        AdaptiveSelector(
          options: userOptions,
          type: widget.selectorType,
          // initialOption: userOptions.first,
          decoration: InputDecoration(
            hintText: 'Select user',
            errorText: shouldShowError ? 'Error!' : null,
          ),
          enable: enable,
          allowClear: allowClear,
          isMultiple: multiple,
          refreshWhenShow: refreshWhenShow,
          onSearch: searchAble ? handleSearch : null,
          loading: loading,
          hasMoreData: hasMoreData,
          onLoadMore: handleLoadMore,
          minMenuWidth: shouldShowMinMenuWidth ? minMenuWidth : null,
          maxMenuHeight: shouldShowMaxMenuHeight ? maxMenuHeight : 160,
        ),
      ],
    );
  }
}
