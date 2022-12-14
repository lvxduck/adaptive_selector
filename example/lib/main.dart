import 'package:adaptive_selector/adaptive_selector.dart';
import 'package:example/selectors/basic_usage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_portal/flutter_portal.dart';

import 'selectors/async_value_selector.dart';
import 'selectors/custom_tile_selector.dart';

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
        tabBarTheme: TabBarTheme(
          unselectedLabelColor: Colors.grey[600]!,
          labelColor: Colors.grey[900]!,
          labelStyle: const TextStyle(fontWeight: FontWeight.w700),
        ),
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
  SelectorType selectorType = SelectorType.menu;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      initialIndex: 0,
      length: 2,
      child: Scaffold(
        body: ListView(
          padding: const EdgeInsets.all(32),
          children: [
            Text(
              'Adaptive selector',
              style: Theme.of(context).textTheme.headline4,
            ),
            const Label('Select selector type'),
            AdaptiveSelector<SelectorType>(
              options: SelectorType.values
                  .map(
                    (e) => AdaptiveSelectorOption(
                      label: e.name,
                      value: e,
                    ),
                  )
                  .toList(),
              type: SelectorType.menu,
              initialOption: AdaptiveSelectorOption(
                label: SelectorType.menu.name,
                value: SelectorType.menu,
              ),
              allowClear: false,
              onChanged: (option) {
                setState(() {
                  selectorType = option!.value;
                });
              },
            ),
            const Label('Basic Usage'),
            BasicUsage(
              selectorType: selectorType,
            ),
            const Label('Search, Infinity list'),
            AsyncValueSelector(
              selectorType: selectorType,
            ),
            const Label('Custom tile'),
            CustomTileSelector(
              selectorType: selectorType,
            ),
            const SizedBox(height: 32),
          ],
        ),
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

class Label extends StatelessWidget {
  const Label(
    this.data, {
    Key? key,
  }) : super(key: key);

  final String data;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 14, bottom: 6),
      child: Text(
        data,
        style: TextStyle(
          color: Theme.of(context).primaryColor,
          fontSize: 16,
        ),
      ),
    );
  }
}
