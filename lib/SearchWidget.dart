import 'dart:async';

import 'package:flutter/material.dart';
import 'package:list_manager/utils/FilterUtils/FilterController.dart';

class SearchWidget<T> extends StatelessWidget {
  SearchWidget({
    Key? key,
    required this.filterController,
    this.debounceDuration = const Duration(milliseconds: 500),
    this.inputBorder,
    this.hintText = "Search",
    this.contentPadding =
        const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
    this.controller,
    this.style,
    this.hintStyle,
    this.decoration,
  }) : super(key: key);

  final FilterController filterController;
  final String hintText;
  final InputBorder? inputBorder;
  final EdgeInsets? contentPadding;
  final TextEditingController? controller;
  final Duration debounceDuration;
  final TextStyle? style;
  final TextStyle? hintStyle;
  final InputDecoration? decoration;

  Timer? debounceCall;

  @override
  Widget build(BuildContext context) {
    return TextField(
      style: style,
      controller: controller,
      onChanged: (value) {
        if (debounceCall != null) debounceCall?.cancel();
        debounceCall = Timer(debounceDuration, () {
          filterController.applyFilters(query: value);
        });
      },
      decoration: decoration ??
          InputDecoration(
            hintText: hintText,
            hintStyle: hintStyle,
            contentPadding: contentPadding,
            border: inputBorder,
          ),
    );
  }
}
