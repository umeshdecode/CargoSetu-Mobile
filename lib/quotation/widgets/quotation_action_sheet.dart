import 'dart:io';
import 'package:cargo_setu/theme/app_colors.dart';
import 'package:cargo_setu/customer/services/template_service.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

class QuotationActionSheet extends StatefulWidget {
  final String actionType;
  final int shiftingId;
  final int templateId;
  final String templateName;
  final String customerMobileNo;
  final String customerEmail;

  const QuotationActionSheet({
    super.key,
    required this.actionType,
    required this.shiftingId,
    required this.templateId,
    required this.templateName,
    required this.customerMobileNo,
    required this.customerEmail,
  });

  static void show({
    required BuildContext context,
    required String actionType,
    required int shiftingId,
    required int templateId,
    required String templateName,
    required String customerMobileNo,
    required String customerEmail,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: QuotationActionSheet(
          actionType: actionType,
          shiftingId: shiftingId,
          templateId: templateId,
          templateName: templateName,
          customerMobileNo: customerMobileNo,
          customerEmail: customerEmail,
        ),
      ),
    );
  }

  @override
  State<QuotationActionSheet> createState() => _QuotationActionSheetState();
}

class _QuotationActionSheetState extends State<QuotationActionSheet> {
  final TemplateService _templateService = TemplateService();
  bool _isLoading = false;
  late TextEditingController _phoneController;

  @override
  void initState() {
    super.initState();
    _phoneController = TextEditingController(text: widget.customerMobileNo);
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _handleWhatsApp() async {
    final phone = _phoneController.text.trim();
    if (phone.isEmpty) {
      Get.snackbar('Validation', 'Please enter a valid mobile number');
      return;
    }

    setState(() => _isLoading = true);
    try {
      final bytes = await _templateService.downloadQuotationPdf(
        widget.shiftingId,
        templateId: widget.templateId,
      );

      if (bytes != null) {
        final tempDir = Directory.systemTemp;
        final file = File('${tempDir.path}/Quotation_${widget.shiftingId}.pdf');
        await file.writeAsBytes(bytes, flush: true);

        // Sanitize phone for wa.me
        final cleanPhone = phone.replaceAll(RegExp(r'[^\d+]'), '');
        final url = Uri.parse('https://wa.me/$cleanPhone');

        if (await canLaunchUrl(url)) {
          await launchUrl(url, mode: LaunchMode.externalApplication);
          if (mounted) {
            Get.back();
            Get.snackbar(
              'WhatsApp Opened',
              'Quotation generated with template "${widget.templateName}". Share on WhatsApp.',
              snackPosition: SnackPosition.BOTTOM,
            );
          }
        } else {
          Get.snackbar(
            'Error',
            'Could not launch WhatsApp app',
            snackPosition: SnackPosition.BOTTOM,
          );
        }
      } else {
        Get.snackbar(
          'Error',
          'Failed to generate quotation PDF',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to process WhatsApp request: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleEmail() async {
    setState(() => _isLoading = true);
    try {
      final res = await _templateService.sendQuotation(
        widget.shiftingId,
        templateId: widget.templateId,
      );

      if (mounted) {
        Get.back();
        if (res['success'] == true) {
          Get.snackbar(
            'Success',
            res['message'] ?? 'Quotation emailed to customer successfully',
            snackPosition: SnackPosition.BOTTOM,
          );
        } else {
          Get.snackbar(
            'Error',
            res['message'] ?? 'Failed to send email quotation',
            snackPosition: SnackPosition.BOTTOM,
          );
        }
      }
    } catch (e) {
      if (mounted) {
        Get.snackbar(
          'Error',
          'Failed to send email quotation',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleDownload() async {
    setState(() => _isLoading = true);
    try {
      final bytes = await _templateService.downloadQuotationPdf(
        widget.shiftingId,
        templateId: widget.templateId,
      );

      if (bytes != null) {
        String? targetPath;
        try {
          targetPath = await FilePicker.getDirectoryPath();
        } catch (_) {}

        final savedPath = await _templateService.savePdfToFile(
          bytes: bytes,
          fileName: 'Quotation_${widget.shiftingId}.pdf',
          targetDirectoryPath: targetPath,
        );

        if (savedPath != null && mounted) {
          Get.back();
          Get.snackbar(
            'Downloaded',
            'Saved to: $savedPath',
            duration: const Duration(seconds: 4),
            snackPosition: SnackPosition.BOTTOM,
          );
        }
      } else {
        Get.snackbar(
          'Error',
          'Failed to download quotation PDF',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to download quotation PDF: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleOpen() async {
    setState(() => _isLoading = true);
    try {
      final bytes = await _templateService.downloadQuotationPdf(
        widget.shiftingId,
        templateId: widget.templateId,
      );

      if (bytes != null) {
        final savedPath = await _templateService.savePdfToFile(
          bytes: bytes,
          fileName: 'Quotation_${widget.shiftingId}.pdf',
        );

        if (savedPath != null && mounted) {
          Get.back();
          final Uri fileUri = Uri.file(savedPath);
          if (await canLaunchUrl(fileUri)) {
            await launchUrl(fileUri, mode: LaunchMode.externalApplication);
          } else {
            Get.snackbar(
              'Saved to device',
              'Quotation saved to: $savedPath',
              snackPosition: SnackPosition.BOTTOM,
              duration: const Duration(seconds: 4),
            );
          }
        }
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to open document: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.actionType == 'whatsapp'
        ? 'Send via WhatsApp'
        : widget.actionType == 'email'
            ? 'Send via Email'
            : widget.actionType == 'open'
                ? 'Open Quotation Document'
                : 'Download Quotation PDF';

    final icon = widget.actionType == 'whatsapp'
        ? Icons.chat
        : widget.actionType == 'email'
            ? Icons.email_outlined
            : widget.actionType == 'open'
                ? Icons.open_in_new
                : Icons.download_outlined;

    final color = widget.actionType == 'whatsapp'
        ? const Color(0xFF16A34A)
        : widget.actionType == 'email'
            ? AppColors.primaryBlue
            : widget.actionType == 'open'
                ? const Color(0xFF9333EA)
                : AppColors.primary;

    final mediaHeight = MediaQuery.of(context).size.height;

    return Container(
      constraints: BoxConstraints(maxHeight: mediaHeight * 0.85),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Drag handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerHigh,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // Selected Template Indicator Banner
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.primaryBlueLight,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.primaryBlue.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle, size: 16, color: AppColors.primaryBlue),
                    const SizedBox(width: 6),
                    const Text(
                      'Selected Template: ',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryBlue,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        widget.templateName,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // Header
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: color.withValues(alpha: 0.1),
                    radius: 20,
                    child: Icon(icon, color: color, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 20),
                    onPressed: () => Get.back(),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Divider(height: 1),
              const SizedBox(height: 16),

              // Action specific body
              if (widget.actionType == 'whatsapp') ...[
                const Text(
                  'Customer Mobile Number',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 6),
                TextField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    hintText: 'Enter mobile number',
                    prefixIcon: const Icon(Icons.phone_outlined, size: 18),
                    filled: true,
                    fillColor: AppColors.surfaceContainerLow,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 44,
                  child: ElevatedButton.icon(
                    onPressed: _isLoading ? null : _handleWhatsApp,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF16A34A),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    icon: _isLoading
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                          )
                        : const Icon(Icons.send, size: 18),
                    label: const Text('Send on WhatsApp', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ] else if (widget.actionType == 'email') ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.email_outlined, size: 20, color: AppColors.secondary),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Send PDF to Customer Email',
                              style: TextStyle(fontSize: 11, color: AppColors.onSurfaceVariant),
                            ),
                            Text(
                              widget.customerEmail.isNotEmpty
                                  ? widget.customerEmail
                                  : 'No email provided',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: widget.customerEmail.isNotEmpty
                                    ? AppColors.primary
                                    : Colors.red,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 44,
                  child: ElevatedButton.icon(
                    onPressed: (widget.customerEmail.isEmpty || _isLoading) ? null : _handleEmail,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryBlue,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    icon: _isLoading
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                          )
                        : const Icon(Icons.send, size: 18),
                    label: const Text('Send Email', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ] else if (widget.actionType == 'open') ...[
                const Text(
                  'Generate and open the quotation PDF document directly on your device.',
                  style: TextStyle(fontSize: 13, color: AppColors.onSurfaceVariant),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 44,
                  child: ElevatedButton.icon(
                    onPressed: _isLoading ? null : _handleOpen,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF9333EA),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    icon: _isLoading
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                          )
                        : const Icon(Icons.open_in_new, size: 18),
                    label: const Text('Open Document', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ] else ...[
                const Text(
                  'Download the quotation PDF file to your preferred directory.',
                  style: TextStyle(fontSize: 13, color: AppColors.onSurfaceVariant),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 44,
                  child: ElevatedButton.icon(
                    onPressed: _isLoading ? null : _handleDownload,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    icon: _isLoading
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                          )
                        : const Icon(Icons.download, size: 18),
                    label: const Text('Download PDF', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
