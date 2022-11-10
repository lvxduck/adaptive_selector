## adaptive_selector

##### Simple and robust Selector that adaptive for all platform.

| Menu Selector | Bottom Sheet Selector    |
| :---:   | :---: |
| ![](https://raw.githubusercontent.com/lvxduck/adaptive_selector/master/demo/m_selector.jpg) | ![](https://raw.githubusercontent.com/lvxduck/adaptive_selector/master/demo/b_selector.jpg) |
| ![](https://raw.githubusercontent.com/lvxduck/adaptive_selector/master/demo/m_selector_search.jpg) | ![](https://raw.githubusercontent.com/lvxduck/adaptive_selector/master/demo/b_selector_search.jpg) |
| ![](https://raw.githubusercontent.com/lvxduck/adaptive_selector/master/demo/m_selector.jpg) | ![](https://raw.githubusercontent.com/lvxduck/adaptive_selector/master/demo/b_selector_keyboard.jpg) |

## Getting started

#### Basic usage
```dart
AdaptiveSelector(
  options: options,
  decoration: const InputDecoration(
    hintText: 'Select school',
  ),
  itemBuilder: (option, isSelected) => SelectorTile(
    option: option,
    isSelected: isSelected,
  ),
),
```

#### Async selector
```dart
AdaptiveSelector(
  options: asyncOptions,
  decoration: const InputDecoration(
    hintText: 'Select school',
  ),
  itemBuilder: (option, isSelected) => SelectorTile(
    option: option,
    isSelected: isSelected,
  ),
  loading: loading,
  onSearch: onSearch,
),
```
