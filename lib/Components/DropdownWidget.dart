import 'package:flutter/material.dart';

class DropdownWidget extends StatefulWidget {
  final List<String> choices;
  final Function(String) onChange;
  final Color? backColor;
  final double? radius;
  String? value;
  final Widget? hintWidget;
  DropdownWidget({
    super.key,
    required this.choices,
    required this.onChange,
    this.backColor = const Color.fromARGB(255, 228, 228, 228),
    this.radius = 10,
    this.value,
    this.hintWidget,
  });

  @override
  State<DropdownWidget> createState() => _DropdownWidgetState();
}

class _DropdownWidgetState extends State<DropdownWidget> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: widget.backColor,
        borderRadius: BorderRadius.circular(widget.radius ?? 10),
      ),
      child: DropdownButton(
        hint: widget.hintWidget ?? const Text("Select options"),
        value: widget.value,
        icon: const Icon(Icons.keyboard_arrow_down),
        isExpanded: true,
        items: widget.choices.map((String item) {
          return DropdownMenuItem(
            value: item,
            child: Text(item),
          );
        }).toList(),
        padding: const EdgeInsets.symmetric(horizontal: 12),
        underline: const SizedBox(),
        borderRadius: BorderRadius.circular(10),
        onChanged: (String? newValue) {
          widget.onChange.call(newValue!);
          setState(() {
            widget.value = newValue;
          });
        },
      ),
    );
  }
}
