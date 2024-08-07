import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:list_manager/Components/DateOptionWrapper.dart';
import 'package:list_manager/utils/FilterUtils/FilterData.dart';
import '../utils/FilterUtils/FilterController.dart';

Color backColor = const Color.fromARGB(255, 224, 224, 224);

class FilterComponent extends StatefulWidget {
  final String title;
  final FilterController controller;
  final Widget? apply, clear;
  final TextStyle? titleStyle;
  const FilterComponent({
    Key? key,
    required this.title,
    required this.controller,
    this.apply,
    this.clear,
    this.titleStyle,
  }) : super(key: key);

  @override
  _FilterComponentState createState() => _FilterComponentState();
}

class _FilterComponentState extends State<FilterComponent> {
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
    return SafeArea(
      child: widget.controller.filterStatus != FilterStatus.FILTER_LOADED
          ? const Center(child: CircularProgressIndicator())
          : Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        widget.title,
                        style: widget.titleStyle ??
                            const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const Spacer(),
                      clearButton(),
                    ],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: widget.controller.filterItems.map((ele) {
                        return FilterItem(
                          selectionWidget: ele,
                          setFilterQuery: widget.controller.setFilterQuery,
                        );
                      }).toList(),
                    ),
                  ),
                ),
                applyButton()
              ],
            ),
    );
  }

  applyButton() {
    if (widget.controller.filterStatus == FilterStatus.FILTER_ERROR) {
      return const SizedBox();
    } else {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: TextButton(
          style: TextButton.styleFrom(
              backgroundColor: Colors.blue,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5))),
          onPressed: () {
            widget.controller
                .applyFilters(query: widget.controller.searchQuery);
            Navigator.pop(context);
          },
          child: const Text(
            "Apply",
            style: TextStyle(color: Colors.white),
          ),
        ),
      );
    }
  }

  clearButton() {
    if (widget.controller.filterStatus == FilterStatus.FILTER_ERROR) {
      return const SizedBox();
    } else {
      return TextButton(
        onPressed: () {
          widget.controller.clearFilter();
          Navigator.pop(context);
        },
        child: const Text(
          "Reset",
          style: TextStyle(color: Colors.black),
        ),
      );
    }
  }
}

class FilterItem<T> extends StatefulWidget {
  final FilterData selectionWidget;
  Function? setFilterQuery;
  FilterItem({
    super.key,
    required this.selectionWidget,
    required this.setFilterQuery,
  });

  @override
  State<FilterItem<T>> createState() => _FilterItemState<T>();
}

class _FilterItemState<T> extends State<FilterItem<T>> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: widget.selectionWidget.padding ??
          const EdgeInsets.fromLTRB(10, 10, 10, 5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            widget.selectionWidget.title,
            style: widget.selectionWidget.headerStyle ??
                const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 10),
          getSelectionWidget(),
        ],
      ),
    );
  }

  getSelectionWidget() {
    switch (widget.selectionWidget.runtimeType) {
      case FDropdownData:
        {
          final data = widget.selectionWidget as FDropdownData;
          return Container(
            decoration: BoxDecoration(
              color: data.backColor ?? backColor,
              borderRadius: BorderRadius.circular(data.radius ?? 10),
            ),
            child: Center(
              child: DropdownSearch<FilterOptionData>(
                popupProps: PopupProps.menu(
                  showSearchBox: data.showSearchBox ?? false,
                  isFilterOnline: data.isFilterOnline ?? false,
                  fit: FlexFit.loose,
                ),
                items: data.options,
                dropdownDecoratorProps: DropDownDecoratorProps(
                    dropdownSearchDecoration: InputDecoration(
                      hintText: "Select/Search options",
                      border: InputBorder.none,
                      contentPadding: data.padding ??
                          const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 0,
                          ),
                    ),
                    textAlignVertical: TextAlignVertical.center),
                asyncItems: data.searchData != null
                    ? (search) async {
                        return await data.searchData!(search);
                      }
                    : null,
                itemAsString: (item) => item.name ?? item.id,
                onChanged: (value) async {
                  if (value != null) {
                    data.value = value;
                    await data.onChange?.call();
                    widget.setFilterQuery!(data.key, value.id);
                    setState(() {});
                  }
                },
                selectedItem: data.value,
              ),
            ),
          );
        }
      case FSliderData:
        {
          final data = widget.selectionWidget as FSliderData;
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      data.selLabels == null
                          ? data.labels.start
                          : data.selLabels!.start,
                      style: data.labelStyle ??
                          const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    Text(
                      data.selLabels == null
                          ? data.labels.end
                          : data.selLabels!.end,
                      style: data.labelStyle ??
                          const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                  ],
                ),
              ),
              RangeSlider(
                values: data.selValues ?? data.values,
                min: data.min,
                max: data.max,
                divisions: 20,
                labels: data.labels,
                activeColor: data.activeColor,
                inactiveColor: data.inactiveColor,
                onChanged: (values) async {
                  data.selValues = values;
                  data.selLabels = RangeLabels(values.start.round().toString(),
                      values.end.round().toString());
                  await data.onChange?.call();
                  widget.setFilterQuery!(data.minKey, data.selValues?.start);
                  widget.setFilterQuery!(data.maxKey, data.selValues?.end);
                  setState(() {});
                },
              ),
            ],
          );
        }
      case FCheckboxData:
        {
          final data = widget.selectionWidget as FCheckboxData;
          return Column(
            children: data.options.map((ele) {
              return CheckboxListTile(
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 0, horizontal: 10),
                title: Text(
                  ele.name ?? ele.id,
                  style: data.checkTitleStyle ?? const TextStyle(fontSize: 16),
                ),
                value: data.states[data.options.indexOf(ele)],
                onChanged: (value) async {
                  if (value != null) {
                    int ind = data.options.indexOf(ele);
                    data.states[ind] = value;
                    await data.onChange?.call();

                    List<String> options = [];

                    for (var i = 0; i < data.options.length; i++) {
                      if (data.states[i]) {
                        options.add(data.options[i].id);
                      }
                    }

                    widget.setFilterQuery!(data.key, options);
                    setState(() {});
                  }
                },
              );
            }).toList(),
          );
        }
      case FRadioData:
        {
          final data = widget.selectionWidget as FRadioData;
          return Column(
            children: data.options.map((ele) {
              return RadioListTile<FilterOptionData>(
                activeColor: data.activeColor,
                title: Text(
                  ele.name ?? ele.id,
                  style: data.titleStyle ??
                      const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w700),
                ),
                value: ele,
                onChanged: (value) async {
                  if (value != null) {
                    data.selected = value;
                    await data.onChange?.call();
                    widget.setFilterQuery!(data.key, value.id);
                    setState(() {});
                  }
                },
                groupValue: data.selected,
              );
            }).toList(),
          );
        }
      case FDateData:
        {
          final data = widget.selectionWidget as FDateData;
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 20),
                child: Column(
                  children: [
                    DateOptionWrapper(
                      title: "Last 30 Days",
                      onTap: () async {
                        data.selStart = DateTime.now();
                        data.selEnd =
                            DateTime.now().subtract(const Duration(days: 30));
                        await data.onChange?.call();
                        widget.setFilterQuery!(
                            data.startDateKey,
                            DateFormat("dd/MM/yyyy")
                                .format(data.selStart ?? data.start));
                        widget.setFilterQuery!(
                            data.endDateKey,
                            DateFormat("dd/MM/yyyy")
                                .format(data.selEnd ?? data.end));
                        setState(() {});
                      },
                      backColor: backColor,
                    ),
                    DateOptionWrapper(
                      title: "Last 90 Days",
                      onTap: () async {
                        data.selStart = DateTime.now();
                        data.selEnd =
                            DateTime.now().subtract(const Duration(days: 90));
                        await data.onChange?.call();
                        widget.setFilterQuery!(
                            data.startDateKey,
                            DateFormat("dd/MM/yyyy")
                                .format(data.selStart ?? data.start));
                        widget.setFilterQuery!(
                            data.endDateKey,
                            DateFormat("dd/MM/yyyy")
                                .format(data.selEnd ?? data.end));
                        setState(() {});
                      },
                      backColor: backColor,
                    ),
                    DateOptionWrapper(
                      title: "Last 180 Days",
                      onTap: () async {
                        data.selStart = DateTime.now();
                        data.selEnd =
                            DateTime.now().subtract(const Duration(days: 180));
                        await data.onChange?.call();
                        widget.setFilterQuery!(
                            data.startDateKey,
                            DateFormat("dd/MM/yyyy")
                                .format(data.selStart ?? data.start));
                        widget.setFilterQuery!(
                            data.endDateKey,
                            DateFormat("dd/MM/yyyy")
                                .format(data.selEnd ?? data.end));
                        setState(() {});
                      },
                      backColor: backColor,
                    ),
                    DateOptionWrapper(
                      title: "Last 365 Days",
                      onTap: () async {
                        data.selStart = DateTime.now();
                        data.selEnd =
                            DateTime.now().subtract(const Duration(days: 365));
                        await data.onChange?.call();
                        widget.setFilterQuery!(
                            data.startDateKey,
                            DateFormat("dd/MM/yyyy")
                                .format(data.selStart ?? data.start));
                        widget.setFilterQuery!(
                            data.endDateKey,
                            DateFormat("dd/MM/yyyy")
                                .format(data.selEnd ?? data.end));
                        setState(() {});
                      },
                      backColor: backColor,
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Expanded(
                          child: DateOptionWrapper(
                            title: "Select\nStart Date",
                            onTap: () async {
                              final date = await showDatePicker(
                                context: context,
                                initialDate: DateTime.now(),
                                firstDate: DateTime.now()
                                    .subtract(const Duration(days: 365 * 2)),
                                lastDate: DateTime.now(),
                              );
                              if (date != null) {
                                data.selStart = date;
                                await data.onChange?.call();
                                widget.setFilterQuery!(
                                    data.startDateKey,
                                    DateFormat("dd/MM/yyyy")
                                        .format(data.selStart ?? data.start));
                                widget.setFilterQuery!(
                                    data.endDateKey,
                                    DateFormat("dd/MM/yyyy")
                                        .format(data.selEnd ?? data.end));
                                setState(() {});
                              }
                            },
                            backColor: backColor,
                          ),
                        ),
                        Expanded(
                          child: DateOptionWrapper(
                            title: "Select\nEnd Date",
                            onTap: () async {
                              final date = await showDatePicker(
                                context: context,
                                initialDate: DateTime.now(),
                                firstDate: DateTime.now()
                                    .subtract(const Duration(days: 365 * 2)),
                                lastDate: DateTime.now(),
                              );
                              if (date != null) {
                                data.selEnd = date;
                                await data.onChange?.call();
                                widget.setFilterQuery!(
                                    data.startDateKey,
                                    DateFormat("dd/MM/yyyy")
                                        .format(data.selStart ?? data.start));
                                widget.setFilterQuery!(
                                    data.endDateKey,
                                    DateFormat("dd/MM/yyyy")
                                        .format(data.selEnd ?? data.end));
                                setState(() {});
                              }
                            },
                            backColor: backColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Expanded(
                          child: RichText(
                            textAlign: TextAlign.center,
                            text: TextSpan(
                              text:
                                  "${DateFormat('dd MMM').format(data.selStart ?? data.start)}\n",
                              style: data.dateTextStyle ??
                                  const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                    color: Colors.black,
                                  ),
                              children: [
                                TextSpan(
                                  text: DateFormat('yyyy')
                                      .format(data.selStart ?? data.start),
                                  style: data.dateTextStyle ??
                                      const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 24,
                                        color: Colors.black,
                                      ),
                                )
                              ],
                            ),
                          ),
                        ),
                        Expanded(
                          child: RichText(
                            textAlign: TextAlign.center,
                            text: TextSpan(
                              text:
                                  "${DateFormat('dd MMM').format(data.selEnd ?? data.end)}\n",
                              style: data.dateTextStyle ??
                                  const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                    color: Colors.black,
                                  ),
                              children: [
                                TextSpan(
                                  text: DateFormat('yyyy')
                                      .format(data.selEnd ?? data.end),
                                  style: data.dateTextStyle ??
                                      const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 24,
                                        color: Colors.black,
                                      ),
                                )
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          );
        }
      default:
        return const SizedBox();
    }
  }
}
