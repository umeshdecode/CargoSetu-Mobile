import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/app_theme.dart';
import 'constant.dart';

class CoustomTextField extends StatefulWidget {
  final String? labelText;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final TextEditingController? textEditingController;
  final Function(String)? onChanged;
  final FormFieldValidator<String>? onTextValidator;
  final bool? obscureText;
  final int? maxLines;
  final int? minLines;
  final Function()? onTextFiledOnTap;
  final bool readOnly;
  final FocusNode? focusNode;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final int? maxLength;
  final double borderCorner;
  final Color? borderEnableColors;
  final Color? borderFocusColors;
  final Color? fillColor;
  final Color? cursorColor;
  final Color? textColor;
  final Color? hintColor;
  final TextAlign? textAlign;
  final EdgeInsetsGeometry? contentPadding;
  final double? fontSize;
  final FontWeight? fontWeight;
  final List<TextInputFormatter>? inputFormatters;
  final Function(String)? onSubmitted;
  final String? initialValue;
  final AutovalidateMode? autovalidateMode;
  final bool? isEnable;

  /// ✅ NEW
  final bool isRequired;

  const CoustomTextField({
    super.key,
    this.autovalidateMode,
    this.labelText,
    this.prefixIcon,
    this.suffixIcon,
    this.textEditingController,
    this.onChanged,
    this.obscureText,
    this.maxLines,
    this.minLines,
    this.onTextFiledOnTap,
    required this.onTextValidator,
    this.readOnly = false,
    this.focusNode,
    this.keyboardType,
    this.textInputAction,
    this.borderEnableColors,
    this.borderFocusColors,
    this.fillColor,
    this.cursorColor,
    this.textColor,
    this.textAlign,
    this.contentPadding,
    this.fontSize,
    this.fontWeight,
    this.maxLength,
    this.inputFormatters,
    this.hintColor,
    this.borderCorner = Constant.BTN_ROUNDED_CORNER,
    this.onSubmitted,
    this.initialValue,
    this.isEnable = true,
    this.isRequired = false,
  });

  @override
  State<CoustomTextField> createState() => _CoustomTextFieldState();
}

class _CoustomTextFieldState extends State<CoustomTextField> {
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    if (widget.textEditingController != null) {
      _hasText = widget.textEditingController!.text.isNotEmpty;
    } else if (widget.initialValue != null &&
        widget.initialValue!.isNotEmpty) {
      _hasText = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return MediaQuery(
      data: MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(1)),
      child: TextFormField(
        autovalidateMode: widget.autovalidateMode,
        cursorColor: widget.cursorColor ?? AppTheme.colorPrimary,
        textAlign: widget.textAlign ?? TextAlign.start,
        focusNode: widget.focusNode,
        enabled: widget.isEnable,
        initialValue:
        widget.textEditingController == null ? widget.initialValue : null,
        controller: widget.textEditingController,
        readOnly: widget.readOnly,
        keyboardType: widget.keyboardType,
        textInputAction: widget.textInputAction,
        obscureText: widget.obscureText ?? false,
        maxLines: widget.maxLines ?? 1,
        minLines: widget.minLines ?? 1,
        maxLength: widget.maxLength,
        inputFormatters: widget.inputFormatters,
        textAlignVertical: TextAlignVertical.center,
        autofocus: false,

        /// ✅ FIXED onChanged
        onChanged: (value) {
          setState(() => _hasText = value.isNotEmpty);
          if (widget.onChanged != null) {
            widget.onChanged!(value);
          }
        },

        onTap: widget.onTextFiledOnTap,
        onFieldSubmitted: widget.onSubmitted,
        validator: widget.onTextValidator,

        style: TextStyle(
          color: widget.textColor ?? AppTheme.colorBlack,
          fontSize: widget.fontSize ?? AppTheme.medium,
          fontWeight: widget.fontWeight ?? FontWeight.w300,
          fontFamily: AppTheme.appFontName,
        ),

        decoration: InputDecoration(
          contentPadding: widget.contentPadding,
          prefixIcon: widget.prefixIcon,
          suffixIcon: widget.suffixIcon,

          /// ✅ FIXED fill color (empty vs filled)
          filled: true,
          fillColor: widget.fillColor ??
              (_hasText
                  ? AppTheme.colorWhite
                  : AppTheme.colorWhite.withOpacity(0.95)),

          /// ✅ FIXED counter visibility
          counterText: widget.maxLength != null ? null : "",

          /// Borders
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(widget.borderCorner),
            borderSide: BorderSide(
              color: widget.borderEnableColors ?? AppTheme.colorIconGrey,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(widget.borderCorner),
            borderSide: BorderSide(
              color: widget.borderEnableColors ?? AppTheme.colorIconGrey,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(widget.borderCorner),
            borderSide: BorderSide(
              color: widget.borderFocusColors ?? AppTheme.colorPrimary,
              width: 2,
            ),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(widget.borderCorner),
            borderSide: BorderSide(
              color: AppTheme.colorError,
            ),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(widget.borderCorner),
            borderSide: BorderSide(
              color: AppTheme.colorError,
              width: 2,
            ),
          ),

          /// ✅ Mandatory indicator
          hintText: widget.isRequired
              ? "${widget.labelText} *"
              : widget.labelText,

          hintStyle: TextStyle(
            fontSize: AppTheme.small,
            color: widget.hintColor ?? AppTheme.colorBlack,
          ),

          errorStyle: TextStyle(
            color: AppTheme.colorError,
            fontSize: AppTheme.errorSize,
          ),
          errorMaxLines: 3,
        ),

        /// Keep your custom context menu
        contextMenuBuilder:
            (BuildContext context, EditableTextState editableTextState) {
          return AdaptiveTextSelectionToolbar.editable(
            onLookUp: () {},
            onSearchWeb: () {},
            onLiveTextInput: () {},
            onShare: () {},
            anchors: editableTextState.contextMenuAnchors,
            clipboardStatus: ClipboardStatus.notPasteable,
            onCopy: () => editableTextState
                .copySelection(SelectionChangedCause.toolbar),
            onCut: () =>
                editableTextState.cutSelection(SelectionChangedCause.toolbar),
            onPaste: () =>
                editableTextState.pasteText(SelectionChangedCause.tap),
            onSelectAll: () => editableTextState
                .selectAll(SelectionChangedCause.toolbar),
          );
        },
      ),
    );
  }
}
