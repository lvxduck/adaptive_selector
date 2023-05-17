import 'package:adaptive_selector/adaptive_selector.dart';
import 'package:example/main.dart';
import 'package:faker/faker.dart';
import 'package:flutter/material.dart';

class CustomSelector extends StatefulWidget {
  const CustomSelector({
    Key? key,
    required this.selectorType,
  }) : super(key: key);

  final SelectorType selectorType;

  @override
  State<CustomSelector> createState() => _CustomSelectorState();
}

class _CustomSelectorState extends State<CustomSelector> {
  final faker = Faker();

  late final options = List.generate(30, (index) => faker.person)
      .map(
        (e) => AdaptiveSelectorOption(
          label: e.name(),
          value: e,
        ),
      )
      .toList();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Label('Custom decoration'),
        AdaptiveSelector<Person>(
          options: options,
          type: widget.selectorType,
          initial: [options.first],
          maxMenuHeight: 320,
          decoration: InputDecoration(
            hintText: 'Select user',
            prefixIcon: const Icon(Icons.person),
            fillColor: Colors.green.withOpacity(0.2),
            suffixIcon: const Icon(Icons.lock_clock),
          ),
          itemBuilder: (_, option, selector) {
            return PersonSelectorTile(
              option: option,
              selector: selector,
            );
          },
        ),
        const Label('Custom fieldBuilder'),
        AdaptiveSelector<Person>(
          options: options,
          type: widget.selectorType,
          initial: options.getRange(0, 5).toList(),
          isMultiple: true,
          maxMenuHeight: 320,
          fieldBuilder: (_, selector) {
            return CustomField(selector: selector);
          },
        ),
        const Label('Custom bottom sheet'),
        AdaptiveSelector<Person>(
          options: options,
          type: SelectorType.bottomSheet,
          initial: [options.first],
          bottomSheetBuilder: (context, options, selector) {
            return Padding(
              padding: const EdgeInsets.only(top: 60),
              child: Material(
                color: Colors.white,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(12),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 8),
                    Container(
                      height: 6,
                      width: 64,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(100),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Select user',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      child: TextFormField(
                        autofocus: true,
                        decoration: const InputDecoration(
                          prefixIcon: Icon(
                            Icons.search,
                            size: 24,
                          ),
                          contentPadding: EdgeInsets.only(right: 16),
                          hintText: 'Search',
                        ),
                      ),
                    ),
                    Expanded(child: options),
                  ],
                ),
              ),
            );
          },
        ),
        const Label('Custom menu'),
        AdaptiveSelector<Person>(
          options: options,
          type: SelectorType.menu,
          initial: [options.first],
          menuBuilder: (context, options, selector) {
            return Material(
              elevation: 3,
              color: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: BorderSide(color: Theme.of(context).primaryColor),
              ),
              child: options,
            );
          },
        ),
      ],
    );
  }
}

class PersonSelectorTile extends StatelessWidget {
  const PersonSelectorTile({
    Key? key,
    required this.option,
    required this.selector,
  }) : super(key: key);

  final AdaptiveSelectorOption<Person> option;
  final AdaptiveSelectorState<Person> selector;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        selector.handleTapOption(option);
      },
      child: Container(
        height: 52,
        color: selector.isSelected(option)
            ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
            : null,
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            CircleAvatar(
              maxRadius: 18,
              child: Text(option.value.firstName().substring(0, 2)),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(option.value.name()),
                const SizedBox(height: 4),
                Text.rich(
                  TextSpan(
                    children: [
                      const TextSpan(text: 'First name: '),
                      TextSpan(
                        text: option.value.firstName(),
                      ),
                    ],
                    style: TextStyle(
                      color: Colors.grey[500],
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class CustomField extends StatelessWidget {
  const CustomField({
    Key? key,
    required this.selector,
  }) : super(key: key);

  final AdaptiveSelectorState<Person> selector;

  @override
  Widget build(BuildContext context) {
    final controller = selector.controller;
    return ValueListenableBuilder(
      valueListenable: controller.selectedOptionsNotifier,
      builder: (context, value, _) {
        return Wrap(
          spacing: 12,
          runSpacing: 12,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: controller.selectedOptions
              .map<Widget>(
                (e) => Chip(
                  label: Text(e.label),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  avatar: const CircleAvatar(
                    child: Icon(Icons.person, size: 18),
                  ),
                  side: const BorderSide(),
                  backgroundColor: Colors.white,
                  onDeleted: () {
                    controller.selectOption(e);
                  },
                ),
              )
              .toList()
            ..add(
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      border: Border.all(),
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: const Icon(
                      Icons.person_add_alt_1,
                      size: 16,
                    ),
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 100,
                    child: TextField(
                      onChanged: selector.handleTextChange,
                      onTap: selector.showSelector,
                      readOnly: selector.widget.onSearch == null,
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        errorBorder: InputBorder.none,
                        disabledBorder: InputBorder.none,
                        contentPadding: EdgeInsets.zero,
                        filled: false,
                        hintText: 'Add...',
                      ),
                    ),
                  ),
                ],
              ),
            ),
        );
      },
    );
  }
}
