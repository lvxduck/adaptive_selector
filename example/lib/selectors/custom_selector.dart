import 'package:adaptive_selector/adaptive_selector.dart';
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

  late final options = List.generate(10, (index) => faker.person)
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
        AdaptiveSelector<Person>(
          options: options,
          type: widget.selectorType,
          initialOption: options.first,
          maxMenuHeight: 320,
          decoration: InputDecoration(
            hintText: 'Select job',
            prefixIcon: const Icon(Icons.person),
            fillColor: Colors.green.withOpacity(0.2),
          ),
          itemBuilder: (option, selected, onTap) {
            return PersonSelectorTile(
              onTap: onTap,
              option: option,
              isSelected: selected,
            );
          },
        ),
        const SizedBox(height: 16),
        AdaptiveSelector<Person>(
          options: options,
          type: widget.selectorType,
          initialOptions: options.getRange(0, 5).toList(),
          isMultiple: true,
          maxMenuHeight: 320,
          fieldBuilder: (controller, onSearch, onTap) {
            return CustomField(
              controller: controller,
              onTap: onTap,
              onSearch: onSearch,
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
    required this.isSelected,
    required this.onTap,
  }) : super(key: key);

  final AdaptiveSelectorOption<Person> option;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 52,
        color: isSelected
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
    required this.onTap,
    required this.controller,
    this.onSearch,
  }) : super(key: key);

  final VoidCallback onTap;
  final AdaptiveSelectorController<Person> controller;
  final ValueChanged<String>? onSearch;

  @override
  Widget build(BuildContext context) {
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
                  avatar: const Icon(Icons.person),
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
                      onChanged: onSearch,
                      maxLines: null,
                      onTap: onTap,
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
