import 'package:cargo_setu/widgets/app_dialog.dart';
import 'package:flutter/material.dart';

/// Legacy adapter for AlertDialogHelper forwarding to modern AppDialog.
class AlertDialogHelper extends StatelessWidget {
  final String title;
  final String message;
  final String positiveBtnText;
  final String negativeBtnText;
  final VoidCallback? positiveBtnClick;
  final VoidCallback? negativeBtnClick;

  const AlertDialogHelper({
    super.key,
    this.title = '',
    this.message = '',
    this.positiveBtnText = 'OK',
    this.negativeBtnText = '',
    this.positiveBtnClick,
    this.negativeBtnClick,
  });

  @override
  Widget build(BuildContext context) {
    return AppDialog(
      type: title.toLowerCase().contains("congrat") ||
              title.toLowerCase().contains("success")
          ? DialogType.success
          : DialogType.info,
      title: title.isNotEmpty ? title : "Notification",
      message: message,
      positiveBtnText:
          positiveBtnText.isNotEmpty ? positiveBtnText : "Continue",
      negativeBtnText:
          negativeBtnText.isNotEmpty ? negativeBtnText : null,
      onPositive: positiveBtnClick != null
          ? () {
              Navigator.of(context).pop();
              positiveBtnClick!();
            }
          : null,
      onNegative: negativeBtnClick != null
          ? () {
              Navigator.of(context).pop();
              negativeBtnClick!();
            }
          : null,
    );
  }
}
