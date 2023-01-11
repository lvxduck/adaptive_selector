import 'package:adaptive_selector/adaptive_selector.dart';
import 'package:faker/faker.dart';
import 'package:flutter/material.dart';

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
  final faker = Faker();

  late final jobOptions = List.generate(5, (index) => faker.job)
      .map(
        (e) => AdaptiveSelectorOption(
          label: e.title(),
          value: e,
        ),
      )
      .toList();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: AdaptiveSelector(
                options: jobOptions,
                type: widget.selectorType,
                initialOption: jobOptions.first,
                decoration: const InputDecoration(hintText: 'Select job'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: AdaptiveSelector(
                options: jobOptions,
                type: widget.selectorType,
                initialOption: jobOptions.first,
                decoration: const InputDecoration(hintText: 'Select job'),
                enable: false,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: AdaptiveSelector(
                options: jobOptions,
                type: widget.selectorType,
                initialOption: jobOptions.first,
                decoration: const InputDecoration(hintText: 'Select job'),
                allowClear: false,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: AdaptiveSelector(
                options: jobOptions,
                type: widget.selectorType,
                initialOption: jobOptions.first,
                decoration: const InputDecoration(hintText: 'Select job'),
                allowClear: false,
                minMenuWidth: 300,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
