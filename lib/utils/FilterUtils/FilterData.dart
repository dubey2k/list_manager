import 'package:flutter/material.dart';

typedef SearchData = Future<List<FilterOptionData>> Function(String);

class FilterData {
  final String title;
  final EdgeInsetsGeometry? padding;
  final TextStyle? headerStyle;
  const FilterData(this.title, {this.padding, this.headerStyle});
}

class FilterOptionData {
  String id;
  String? name;
  FilterOptionData({
    required this.id,
    required this.name,
  });
}

class FDropdownData extends FilterData {
  final String key;
  FilterOptionData? value;
  final List<FilterOptionData> options;
  final bool? isFilterOnline;
  final bool? showSearchBox;
  final Function? onChange;
  final SearchData? searchData;
  final Color? backColor;
  final double? radius;
  FDropdownData({
    required String title,
    EdgeInsetsGeometry? padding,
    TextStyle? headerStyle,
    required this.key,
    required this.onChange,
    required this.options,
    this.backColor,
    this.radius,
    this.isFilterOnline,
    this.showSearchBox,
    this.searchData,
  }) : super(title, padding: padding, headerStyle: headerStyle);
}

class FSliderData extends FilterData {
  final String minKey, maxKey;
  final double min, max;
  final Function? onChange;
  final TextStyle? labelStyle;
  RangeValues values;
  RangeLabels labels;
  RangeValues? selValues;
  RangeLabels? selLabels;
  final Color? activeColor, inactiveColor;

  FSliderData({
    required String title,
    EdgeInsetsGeometry? padding,
    TextStyle? headerStyle,
    required this.minKey,
    required this.maxKey,
    required this.labels,
    required this.values,
    required this.min,
    required this.max,
    this.onChange,
    this.labelStyle,
    this.activeColor,
    this.inactiveColor,
  }) : super(title, padding: padding, headerStyle: headerStyle);
}

class FDateData extends FilterData {
  final String startDateKey, endDateKey;
  DateTime start, end;
  DateTime? selStart, selEnd;
  final Function? onChange;
  final TextStyle? dateTextStyle;

  FDateData({
    required String title,
    EdgeInsetsGeometry? padding,
    TextStyle? headerStyle,
    required this.startDateKey,
    required this.endDateKey,
    required this.start,
    required this.end,
    this.onChange,
    this.dateTextStyle,
  }) : super(title, padding: padding, headerStyle: headerStyle);
}

class FCheckboxData extends FilterData {
  final String key;
  final List<FilterOptionData> options;
  late List<bool> states;
  final Function? onChange;
  final TextStyle? checkTitleStyle;

  FCheckboxData({
    required String title,
    EdgeInsetsGeometry? padding,
    TextStyle? headerStyle,
    required this.key,
    required this.onChange,
    required this.options,
    this.checkTitleStyle,
  }) : super(title, padding: padding, headerStyle: headerStyle) {
    states = List.filled(options.length, false);
  }
}

class FRadioData extends FilterData {
  final String key;
  final List<FilterOptionData> options;
  FilterOptionData? selected;
  final Function? onChange;
  final Color? activeColor;
  final TextStyle? titleStyle;
  FRadioData({
    EdgeInsetsGeometry? padding,
    TextStyle? headerStyle,
    required String title,
    required this.key,
    required this.options,
    this.onChange,
    this.titleStyle,
    this.activeColor,
  }) : super(title, padding: padding, headerStyle: headerStyle);
}

enum FilterType { dropdown, slider, date, checkbox, radio }
