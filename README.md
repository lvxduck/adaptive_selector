<div align="center">
  <h1>adaptive_selector</h1>
  <div>
    <a title="pub.dev" href="https://pub.dev/packages/adaptive_selector" >
      <img src="https://img.shields.io/pub/v/adaptive_selector.svg?style=flat-square&include_prereleases&color=dc143c" />
    </a>
    <a title="GitHub License" href="https://github.com/lvxduck/adaptive_selector/blob/master/LICENSE">
      <img src="https://img.shields.io/badge/License-MIT-yellow.svg" />
    </a>
    <a title="Made with Fluent Design" href="https://lvxduck.github.io/adaptive_selector">
      <img src="https://img.shields.io/badge/-web demo-green">
    </a>
  </div>
  <br/>
  <p>
      Simple and robust Selector that adaptive for all platform.
  </p>
</div>

<div align="center">
  <a href="https://lvxduck.github.io/adaptive_selector">
    <img src="https://raw.githubusercontent.com/lvxduck/adaptive_selector/master/demo/example-showcase.png" />
  </a>
</div>

---


## Getting started

### Basic usage
```dart
// Create list option
final options = SelectorType.values
  .map((e) => AdaptiveSelectorOption(label: e.name, value: e))
  .toList();
// Apply option to AdaptiveSelector
AdaptiveSelector(
  options: options,
  initialOption: options.first,
  type: SelectorType.menu,
  allowClear: false,
),
```

### Async selector
```dart
AdaptiveSelector(
  options: asyncOptions,
  decoration: const InputDecoration(
    hintText: 'Select school',
  ),
  loading: loading,
  onSearch: handleSearch,
  hasMoreData: hasMore,
  onLoadMore: handleLoadMore,
),
```
