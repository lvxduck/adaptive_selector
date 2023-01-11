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

class AsyncValueSelector extends StatefulWidget {
  const AsyncValueSelector({
    Key? key,
    required this.selectorType,
  }) : super(key: key);

  final SelectorType selectorType;

  @override
  State<AsyncValueSelector> createState() => _AsyncValueSelectorState();
}

class _AsyncValueSelectorState extends State<AsyncValueSelector> {
  late List<AdaptiveSelectorOption<Person>> userOptions = [];
  bool loading = false;
  bool hasMoreData = true;
  PersonFilter filter = PersonFilter(page: 1);

  Future<List<Person>> getList(PersonFilter filter) async {
    await Future.delayed(const Duration(seconds: 1));
    return List.generate(10, (index) => faker.person);
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
    });
    setState(() {
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

  @override
  Widget build(BuildContext context) {
    return AdaptiveSelector(
      options: userOptions,
      type: widget.selectorType,
      decoration: const InputDecoration(hintText: 'Select school'),
      loading: loading,
      onSearch: handleSearch,
      hasMoreData: hasMoreData,
      onLoadMore: handleLoadMore,
    );
  }
}
