import 'dart:math';

import 'package:adaptive_selector/adaptive_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter_portal/flutter_portal.dart';

void main() {
  runApp(
    const Portal(
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        inputDecorationTheme: InputDecorationTheme(
          isDense: true,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(
              color: Colors.grey,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(
              color: Colors.grey,
            ),
          ),
          disabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(
              color: Colors.grey,
            ),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.blue),
            borderRadius: BorderRadius.circular(10),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.blue),
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
      home: const Demo(),
    );
  }
}

class Demo extends StatefulWidget {
  const Demo({Key? key}) : super(key: key);

  @override
  State<Demo> createState() => _DemoState();
}

class _DemoState extends State<Demo> {
  final options = [
    AdaptiveSelectorOption(label: 'label 1', value: 'value 1'),
    AdaptiveSelectorOption(label: 'label 2', value: 'value 2'),
    AdaptiveSelectorOption(label: 'label 3', value: 'value 3'),
    AdaptiveSelectorOption(label: 'label 4', value: 'value 4'),
    AdaptiveSelectorOption(label: 'label 4', value: 'value 4'),
    AdaptiveSelectorOption(label: 'label 4', value: 'value 4'),
    AdaptiveSelectorOption(label: 'label 4', value: 'value 4'),
  ];

  List<AdaptiveSelectorOption<String>> asyncOptions = [];
  bool loading = false;

  void onSearch(value) async {
    setState(() {
      loading = true;
    });
    await Future.delayed(const Duration(seconds: 1));
    setState(() {
      asyncOptions = List.generate(
        Random().nextInt(10) + 20,
        (index) => AdaptiveSelectorOption(
          label: 'label $value $index',
          value: 'value $value $index',
        ),
      );
    });
    setState(() {
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.all(32),
        children: [
          Text(
            'Overlay selector',
            style: Theme.of(context).textTheme.headline4,
          ),
          const SizedBox(height: 12),
          Text(
            'Simple Data',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 6),
          AdaptiveSelector(
            options: options,
            itemBuilder: (option, isSelected) => SelectorTile(
              option: option,
              isSelected: isSelected,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Async Data',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 6),
          // AdaptiveSelector(
          //   options: asyncOptions,
          //   itemBuilder: (option, isSelected) => SelectorTile(
          //     option: option,
          //     isSelected: isSelected,
          //   ),
          //   loading: loading,
          //   onSearch: onSearch,
          // ),
          const SizedBox(height: 120),
          const Text('Bottom selector'),
          AdaptiveSelector(
            options: options,
            bottomSheet: true,
            decoration: const InputDecoration(hintText: 'Select school'),
            itemBuilder: (option, isSelected) => SelectorTile(
              option: option,
              isSelected: isSelected,
            ),
          ),
          const SizedBox(height: 16),
          AdaptiveSelector(
            options: asyncOptions,
            bottomSheet: true,
            onSearch: onSearch,
            loading: loading,
            bottomSheetTitle: 'Select school',
            decoration: const InputDecoration(hintText: 'Select school'),
            itemBuilder: (option, isSelected) => SelectorTile(
              option: option,
              isSelected: isSelected,
            ),
          ),
        ],
      ),
    );
  }
}

class SelectorTile<T> extends StatelessWidget {
  const SelectorTile({
    Key? key,
    required this.option,
    required this.isSelected,
  }) : super(key: key);

  final AdaptiveSelectorOption<T> option;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 46,
      alignment: Alignment.centerLeft,
      color: isSelected
          ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
          : null,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Text(
        option.label,
      ),
    );
  }
}
