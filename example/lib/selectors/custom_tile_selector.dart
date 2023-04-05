import 'package:adaptive_selector/adaptive_selector.dart';
import 'package:faker/faker.dart';
import 'package:flutter/material.dart';

class CustomTileSelector extends StatefulWidget {
  const CustomTileSelector({
    Key? key,
    required this.selectorType,
  }) : super(key: key);

  final SelectorType selectorType;

  @override
  State<CustomTileSelector> createState() => _CustomTileSelectorState();
}

class _CustomTileSelectorState extends State<CustomTileSelector> {
  final faker = Faker();

  late final options = List.generate(5, (index) => faker.person)
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
      children: [
        AdaptiveSelector<Person>(
          options: options,
          type: widget.selectorType,
          initialOption: options.first,
          decoration: const InputDecoration(hintText: 'Select job'),
          itemBuilder: (option, selected, onTap) {
            return PersonSelectorTile(
              onTap: onTap,
              option: option,
              isSelected: selected,
            );
          },
        ),
        const SizedBox(height: 12),
        AdaptiveSelector<Person>(
          options: options,
          type: widget.selectorType,
          initialOption: options.first,
          maxMenuHeight: 500,
          decoration: InputDecoration(
            hintText: 'Select job',
            prefixIcon: const Icon(Icons.person),
            fillColor: Colors.green.withOpacity(0.2),
          ),
        ),
        const SizedBox(height: 12),
        AdaptiveSelector<Person>(
          options: options,
          type: widget.selectorType,
          initialOptions: options,
          isMultiple: true,
          maxMenuHeight: 320,
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
