import 'package:flutter/material.dart';

class DateOptionWrapper extends StatelessWidget {
  final Color backColor;
  final String title;
  final TextStyle? textStyle;
  final BorderRadius? radius;
  final Function? onTap;
  final EdgeInsetsGeometry? padding, margin;
  const DateOptionWrapper({
    super.key,
    required this.backColor,
    required this.title,
    this.textStyle,
    this.radius,
    this.onTap,
    this.padding,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        await onTap?.call();
      },
      child: Container(
        margin:
            margin ?? const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        padding:
            padding ?? const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: backColor,
          borderRadius: radius ?? BorderRadius.circular(10),
        ),
        child: Text(
          title,
          style: textStyle ??
              const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
