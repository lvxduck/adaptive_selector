import 'package:adaptive_selector/adaptive_selector.dart';
import 'package:example/selectors/basic_selector.dart';
import 'package:flutter/material.dart';

import 'selectors/custom_selector.dart';

void main() {
  runApp(
    const MyApp(),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        tabBarTheme: TabBarTheme(
          unselectedLabelColor: Colors.grey[600]!,
          labelColor: Colors.grey[900]!,
          labelStyle: const TextStyle(fontWeight: FontWeight.w700),
        ),
        inputDecorationTheme: InputDecorationTheme(
          isDense: true,
          filled: true,
          fillColor: Colors.white,
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
    return Scaffold(
      body: SingleChildScrollView(
        child: Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            constraints: const BoxConstraints(maxWidth: 800),
            alignment: Alignment.center,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Builder(
                  builder: (context) {
                    return SizedBox(
                      height: MediaQuery.of(context).padding.top + 12,
                    );
                  },
                ),
                Text(
                  'Adaptive selector',
                  style: Theme.of(context)
                      .textTheme
                      .headlineMedium
                      ?.copyWith(color: Colors.grey[800]),
                ),
                const SizedBox(height: 12),
                const Label('Selector type'),
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
                  initial: [
                    AdaptiveSelectorOption(
                      label: SelectorType.menu.name,
                      value: SelectorType.menu,
                    ),
                  ],
                  decoration: const InputDecoration(hintText: 'Select type'),
                  allowClear: false,
                  onChanged: (option) {
                    setState(() {
                      selectorType = option!.value;
                    });
                  },
                ),
                const Label('Basic'),
                BasicUsage(
                  selectorType: selectorType,
                ),
                const Label('Custom'),
                CustomSelector(
                  selectorType: selectorType,
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
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
