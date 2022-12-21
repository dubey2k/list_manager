import 'package:chips_choice/chips_choice.dart';
import 'package:flutter/material.dart';
import 'package:list_manager/utils/FilterUtils/FilterController.dart';
import 'package:list_manager/utils/FilterUtils/FilterData.dart';
import 'package:provider/provider.dart';

class FilterView extends StatefulWidget {
  final String title;
  final Function onChange;
  final FilterController controller;
  const FilterView({
    Key? key,
    required this.onChange,
    required this.title,
    required this.controller,
  }) : super(key: key);

  @override
  _FilterViewState createState() => _FilterViewState();
}

class _FilterViewState extends State<FilterView> {
  int selFilterIndex = 0;

  void listener() {
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(listener);
  }

  @override
  void dispose() {
    super.dispose();
    widget.controller.removeListener(listener);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      // color: accent,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.title,
                  style: const TextStyle(
                      fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                getFuncBtn(isClear: true),
                getFuncBtn(),
              ],
            ),
          ),
          getChips(),
        ],
      ),
    );
  }

  getFuncBtn({bool isClear = false}) {
    if (widget.controller.filterStatus == FilterStatus.FILTER_IDLE ||
        widget.controller.filterStatus == FilterStatus.FILTER_LOADING) {
      return const Center(
        child: SizedBox(
          height: 24,
          width: 24,
          child: CircularProgressIndicator(),
        ),
      );
    } else if (widget.controller.filterStatus == FilterStatus.FILTER_ERROR) {
      return const SizedBox();
    } else {
      return OutlinedButton(
        onPressed: () async {
          if (isClear) {
            widget.controller.clearFilter();
          } else {
            widget.controller.applyFilters();
          }
          Navigator.pop(context);
        },
        style: OutlinedButton.styleFrom(primary: Colors.amber.shade200),
        child: Text(isClear ? "Clear" : "Apply"),
      );
    }
  }

  getChips() {
    if (widget.controller.filterStatus == FilterStatus.FILTER_IDLE ||
        widget.controller.filterStatus == FilterStatus.FILTER_LOADING) {
      return const Center(
        child: SizedBox(
          height: 24,
          width: 24,
          child: CircularProgressIndicator(),
        ),
      );
    } else if (widget.controller.filterStatus == FilterStatus.FILTER_ERROR ||
        widget.controller.filterData == null ||
        widget.controller.filterData!.isEmpty) {
      return Center(
        child: Text(
          widget.controller.error,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      );
    } else {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 15),
          FilterChips(
            filterOptions: List.generate(
              widget.controller.filterData!.length,
              (index) {
                final res = widget.controller.getFilterOptions(index);
                return FilterOptionModel(name: res?.name ?? "", id: "");
              },
            ).toList(),
            OnSelect: (val) {
              if (mounted) {
                setState(() {
                  selFilterIndex = val;
                });
              }
            },
          ),
          const SizedBox(height: 15),
          FilterChips(
            subFilter: true,
            selected: widget.controller.filterData!
                .elementAt(selFilterIndex)
                .selected,
            filterOptions: List.generate(
              widget.controller.filterData![selFilterIndex].subFilterOptions
                  .length,
              (index) {
                var res = widget.controller
                    .getSubFilterOptions(selFilterIndex, index);
                return FilterOptionModel(name: res?.name ?? "", id: "");
              },
            ),
            OnSelect: (List<int> val) {
              widget.controller.setSubFilters(selFilterIndex, val);
            },
          ),
        ],
      );
    }
  }
}

class FilterChips extends StatefulWidget {
  final List<String>? filter;
  final List<FilterOptionModel> filterOptions;
  List<int> selected;
  final Function OnSelect;
  final bool subFilter;
  FilterChips({
    Key? key,
    required this.filterOptions,
    required this.OnSelect,
    this.subFilter = false,
    this.selected = const [],
    this.filter,
  });
  @override
  _FilterChipsState createState() => _FilterChipsState();
}

class _FilterChipsState extends State<FilterChips> {
  late int value;
  @override
  void initState() {
    super.initState();
    value = widget.subFilter ? -1 : 0;
  }

  @override
  Widget build(BuildContext context) {
    return widget.subFilter
        ? ChipsChoice<int>.multiple(
            choiceActiveStyle: const C2ChoiceStyle(
              brightness: Brightness.light,
              margin: EdgeInsets.symmetric(horizontal: 8),
            ),
            choiceStyle: const C2ChoiceStyle(
              brightness: Brightness.light,
              margin: EdgeInsets.symmetric(horizontal: 8),
            ),
            value: widget.selected,
            onChanged: (val) {
              if (mounted) {
                setState(
                  () {
                    widget.selected = val;
                    widget.OnSelect(widget.selected);
                  },
                );
              }
            },
            choiceItems: C2Choice.listFrom<int, FilterOptionModel>(
              source: widget.filterOptions,
              // List.generate(widget.filterOptions.length, (index) {
              //   widget.filterOptions[index].
              // }),
              value: (i, v) => i,
              label: (i, v) => v.name,
            ),
          )
        : ChipsChoice<int>.single(
            choiceActiveStyle: C2ChoiceStyle(
              brightness: Brightness.dark,
              showCheckmark: false,
              // color: accent2,
              labelStyle:
                  const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              borderRadius: BorderRadius.circular(10),
              padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
              margin: const EdgeInsets.symmetric(horizontal: 8),
            ),
            choiceStyle: C2ChoiceStyle(
              // color: accent,
              borderRadius: BorderRadius.circular(10),
              labelStyle:
                  const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
              margin: const EdgeInsets.symmetric(horizontal: 8),
            ),
            value: value,
            onChanged: (val) {
              if (mounted) {
                setState(
                  () {
                    value = val;
                    widget.OnSelect(value);
                  },
                );
              }
            },
            choiceItems: C2Choice.listFrom<int, FilterOptionModel>(
              source: widget.filterOptions,
              value: (i, v) => i,
              label: (i, v) => v.name,
            ),
          );
  }
}
