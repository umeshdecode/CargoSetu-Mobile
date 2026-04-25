
import 'package:cargo_setu/theme/app_theme.dart';
import 'package:flutter/material.dart';

class CustomText extends StatefulWidget {
  var title;
  Color? colors;
  double fontSize;
  double height;
  FontWeight fontWeight;
  TextAlign textAlign;
  int? maxLines;
  TextDecoration? decoration;
  TextOverflow? overflow;

  CustomText({
    super.key,
    required this.title,
    this.colors,
    this.fontSize = AppTheme.medium,
    this.height = 1,
    this.fontWeight = FontWeight.normal,
    this.textAlign = TextAlign.center,
    this.maxLines,
    this.decoration,
    this.overflow,
  });

  @override
  State<CustomText> createState() => _CustomTextState();
}

class _CustomTextState extends State<CustomText> {
  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Text(
      widget.title.toString(),
      textAlign: widget.textAlign,
      overflow: widget.overflow,
      style: TextStyle(
        color: widget.colors ?? (isDarkMode ? Colors.white : Colors.white),
        fontSize: widget.fontSize,
        fontWeight: widget.fontWeight,
        height: widget.height,
        decoration: widget.decoration,
      ),
      textScaleFactor: 1,
      // softWrap: true,
      maxLines: widget.maxLines,
    );
  }
}
