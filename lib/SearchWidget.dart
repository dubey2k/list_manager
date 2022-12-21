import 'package:flutter/material.dart';
import 'package:list_manager/utils/FilterUtils/FilterController.dart';

import 'utils/SearchUtils/SearchController.dart';

class SearchWidget<T> extends StatelessWidget {
  const SearchWidget({
    Key? key,
    required this.filterController,
    this.inputBorder,
    this.hintText = "Search",
    this.contentPadding =
        const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
    this.controller,
  }) : super(key: key);

  final FilterController filterController;
  final String hintText;
  final InputBorder? inputBorder;
  final EdgeInsets? contentPadding;
  final TextEditingController? controller;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: (value) {
        filterController.applyFilters(query: value);
      },
      decoration: InputDecoration(
        hintText: hintText,
        contentPadding: contentPadding,
        border: inputBorder,
      ),
    );
  }
}
