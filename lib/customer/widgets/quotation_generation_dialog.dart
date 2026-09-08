import 'dart:developer';
import 'package:cargo_setu/customer/models/customer_model.dart';
import 'package:cargo_setu/customer/models/template_model.dart';
import 'package:cargo_setu/customer/services/template_service.dart';
import 'package:cargo_setu/network/api_request.dart';
import 'package:cargo_setu/theme/app_colors.dart';
import 'package:cargo_setu/widgets/app_dialog.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:webview_flutter/webview_flutter.dart';

class QuotationGenerationDialog extends StatefulWidget {
  final CustomerModel customer;

  const QuotationGenerationDialog({
    super.key,
    required this.customer,
  });

  static Future<void> show(BuildContext context, {required CustomerModel customer}) {
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => QuotationGenerationDialog(customer: customer),
    );
  }

  @override
  State<QuotationGenerationDialog> createState() => _QuotationGenerationDialogState();
}

class _QuotationGenerationDialogState extends State<QuotationGenerationDialog> {
  final TemplateService _templateService = TemplateService();

  int _currentStep = 1; // 1: Choose Template, 2: Select Shifting & Actions
  bool _isLoadingTemplates = true;
  String? _templatesError;
  List<TemplateModel> _templates = [];
  TemplateModel? _selectedTemplate;

  Shifting? _selectedShifting;
  bool _isDownloadingPdf = false;
  bool _isSendingEmail = false;

  @override
  void initState() {
    super.initState();
    _loadTemplates();
    _initSelectedShifting();
  }

  void _initSelectedShifting() {
    if (widget.customer.shiftings.isNotEmpty) {
      _selectedShifting = widget.customer.shiftings.first;
    }
  }

  Future<void> _loadTemplates() async {
    setState(() {
      _isLoadingTemplates = true;
      _templatesError = null;
    });

    try {
      final list = await _templateService.getTemplatesByType(type: 'QUOTATION');
      setState(() {
        _templates = list;
        _isLoadingTemplates = false;
        // Pre-select favorite or first
        if (_templates.isNotEmpty) {
          final fav = _templates.firstWhereOrNull((t) => t.isFavoriteTemplate);
          _selectedTemplate = fav ?? _templates.first;
        }
      });
    } catch (e) {
      log('❌ Failed to load templates: $e');
      setState(() {
        _isLoadingTemplates = false;
        _templatesError = 'Failed to load templates. Please check your connection.';
      });
    }
  }

  Future<void> _toggleFavorite(TemplateModel template) async {
    final oldState = template.isFavoriteTemplate;
    setState(() {
      for (var t in _templates) {
        t.isFavoriteTemplate = (t.id == template.id);
      }
    });

    try {
      final success = await _templateService.setDefaultTemplate(template.id);
      if (success) {
        Get.snackbar(
          'Default Template',
          '${template.name} is now your company default template ⭐',
          snackPosition: SnackPosition.TOP,
          backgroundColor: const Color(0xFF1E293B),
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );
      } else {
        // Revert
        setState(() {
          template.isFavoriteTemplate = oldState;
        });
      }
    } catch (e) {
      setState(() {
        template.isFavoriteTemplate = oldState;
      });
      Get.snackbar('Error', 'Failed to update default template');
    }
  }

  void _showPreview(TemplateModel template) async {
    Get.dialog(
      const Center(
        child: CircularProgressIndicator(color: AppColors.primaryBlue),
      ),
      barrierDismissible: false,
    );

    try {
      final html = await _templateService.getTemplatePreviewHtml(template.id);
      Get.back(); // close loading

      if (html == null || html.trim().isEmpty) {
        Get.snackbar(
          'Preview',
          'No preview content available for this template.',
          snackPosition: SnackPosition.TOP,
        );
        return;
      }

      Get.dialog(
        _TemplateHtmlPreviewDialog(
          templateName: template.name,
          templateType: template.type,
          htmlContent: html,
        ),
      );
    } catch (e) {
      Get.back(); // close loading
      final errorMsg = ApiRequest.formatErrorMessage(e, defaultMessage: 'Failed to load template preview');
      Get.snackbar(
        'Preview Failed',
        errorMsg,
        snackPosition: SnackPosition.TOP,
        backgroundColor: const Color(0xFFEF4444),
        colorText: Colors.white,
      );
    }
  }

  Future<void> _handleDownloadPdf() async {
    if (_selectedShifting == null || _selectedShifting!.shiftingId == null) {
      Get.snackbar('Error', 'Please select a valid shifting first');
      return;
    }

    setState(() => _isDownloadingPdf = true);

    try {
      final shiftingId = _selectedShifting!.shiftingId!;
      final templateId = _selectedTemplate?.id;

      // 1. Download PDF bytes from server (60s timeout configured)
      final pdfBytes = await _templateService.downloadQuotationPdf(
        shiftingId,
        templateId: templateId,
      );

      if (pdfBytes == null || pdfBytes.isEmpty) {
        setState(() => _isDownloadingPdf = false);
        Get.snackbar(
          'Error',
          'Failed to retrieve quotation PDF content from server',
          snackPosition: SnackPosition.TOP,
          backgroundColor: const Color(0xFFEF4444),
          colorText: Colors.white,
        );
        return;
      }

      setState(() => _isDownloadingPdf = false);

      final fileName = 'Quotation_${widget.customer.firstName}_$shiftingId.pdf'
          .replaceAll(' ', '_');

      // 2. Allow user to select download folder
      String? chosenDirectory;
      try {
        chosenDirectory = await FilePicker.getDirectoryPath(
          dialogTitle: 'Select folder to save $fileName',
        );
      } catch (pickerErr) {
        log('⚠️ Folder picker error: $pickerErr');
      }

      String? targetDir = chosenDirectory;
      if (targetDir == null || targetDir.trim().isEmpty) {
        // User cancelled folder picker - ask if they want to save in default Downloads folder
        final bool? saveInDefault = await Get.dialog<bool>(
          AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: const Row(
              children: [
                Icon(Icons.folder_open, color: AppColors.primaryBlue),
                SizedBox(width: 8),
                Text('Save Location', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ],
            ),
            content: const Text(
              'No custom folder was selected. Would you like to save the quotation in the default Downloads folder?',
              style: TextStyle(fontSize: 13, height: 1.4),
            ),
            actions: [
              TextButton(
                onPressed: () => Get.back(result: false),
                child: const Text('Cancel Download', style: TextStyle(color: AppColors.textSecondary)),
              ),
              ElevatedButton(
                onPressed: () => Get.back(result: true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text('Save in Downloads'),
              ),
            ],
          ),
        );

        if (saveInDefault != true) {
          Get.snackbar(
            'Download Cancelled',
            'Download cancelled: no destination folder selected.',
            snackPosition: SnackPosition.TOP,
          );
          return;
        }
      }

      // 3. Save PDF file to chosen directory (or default)
      final savedPath = await _templateService.savePdfToFile(
        bytes: pdfBytes,
        fileName: fileName,
        targetDirectoryPath: targetDir,
      );

      if (savedPath != null) {
        if (mounted) {
          AppDialog.showSuccess(
            context,
            title: 'Quotation Downloaded! 📄',
            message: 'Quotation PDF has been saved successfully.\n\nPath:\n$savedPath',
            positiveBtnText: 'OK',
          );
        }
      } else {
        Get.snackbar(
          'Save Failed',
          'Failed to save PDF to the selected folder. Please verify storage permissions.',
          snackPosition: SnackPosition.TOP,
          backgroundColor: const Color(0xFFEF4444),
          colorText: Colors.white,
        );
      }
    } catch (e) {
      setState(() => _isDownloadingPdf = false);
      final errorMsg = ApiRequest.formatErrorMessage(e, defaultMessage: 'Failed to download quotation PDF');
      Get.snackbar(
        'Download Failed',
        errorMsg,
        snackPosition: SnackPosition.TOP,
        backgroundColor: const Color(0xFFEF4444),
        colorText: Colors.white,
        duration: const Duration(seconds: 4),
      );
    }
  }

  Future<void> _handleSendQuotation() async {
    if (_selectedShifting == null || _selectedShifting!.shiftingId == null) {
      Get.snackbar('Error', 'Please select a valid shifting first');
      return;
    }

    if (widget.customer.email.isEmpty) {
      Get.snackbar(
        'Email Missing',
        'This customer has no email address configured. Please add an email in Edit Customer.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: const Color(0xFFEF4444),
        colorText: Colors.white,
      );
      return;
    }

    setState(() => _isSendingEmail = true);

    try {
      final shiftingId = _selectedShifting!.shiftingId!;
      final templateId = _selectedTemplate?.id;

      final result = await _templateService.sendQuotation(
        shiftingId,
        templateId: templateId,
      );

      setState(() => _isSendingEmail = false);

      if (result['success'] == true) {
        if (mounted) {
          AppDialog.showSuccess(
            context,
            title: 'Quotation Sent! ✉️',
            message: 'Quotation has been successfully generated and emailed to ${widget.customer.email}.',
            positiveBtnText: 'Done',
            onPositive: () => Navigator.of(context).pop(),
          );
        }
      } else {
        Get.snackbar('Failed', result['message'] ?? 'Failed to send quotation');
      }
    } catch (e) {
      setState(() => _isSendingEmail = false);
      final errorMsg = ApiRequest.formatErrorMessage(e, defaultMessage: 'Failed to send quotation');
      Get.snackbar(
        'Error',
        errorMsg,
        snackPosition: SnackPosition.TOP,
        backgroundColor: const Color(0xFFEF4444),
        colorText: Colors.white,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      elevation: 0,
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 460, maxHeight: 680),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.12),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildHeader(),
              _buildStepIndicator(),
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: _currentStep == 1 ? _buildStep1Content() : _buildStep2Content(),
                ),
              ),
              _buildFooter(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 18, 12, 14),
      decoration: const BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.receipt_long, color: Colors.white, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Generate Quotation',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  widget.customer.fullName,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.8),
                    fontSize: 12,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white, size: 20),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  Widget _buildStepIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      color: AppColors.surfaceContainerLow,
      child: Row(
        children: [
          _buildStepPill(
            stepNumber: 1,
            title: 'Template',
            isActive: _currentStep == 1,
            isDone: _currentStep > 1,
          ),
          Expanded(
            child: Container(
              height: 2,
              margin: const EdgeInsets.symmetric(horizontal: 8),
              color: _currentStep > 1 ? AppColors.primaryBlue : AppColors.border,
            ),
          ),
          _buildStepPill(
            stepNumber: 2,
            title: 'Shifting & Generate',
            isActive: _currentStep == 2,
            isDone: false,
          ),
        ],
      ),
    );
  }

  Widget _buildStepPill({
    required int stepNumber,
    required String title,
    required bool isActive,
    required bool isDone,
  }) {
    final Color badgeColor = isDone
        ? const Color(0xFF16A34A)
        : (isActive ? AppColors.primaryBlue : AppColors.textHint);

    return Row(
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: badgeColor,
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: isDone
              ? const Icon(Icons.check, size: 14, color: Colors.white)
              : Text(
                  '$stepNumber',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
            color: isActive ? AppColors.textPrimary : AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildStep1Content() {
    if (_isLoadingTemplates) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 40),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(strokeWidth: 3, color: AppColors.primaryBlue),
              SizedBox(height: 16),
              Text(
                'Loading document templates...',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
              ),
            ],
          ),
        ),
      );
    }

    if (_templatesError != null) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 30),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, color: AppColors.error, size: 40),
              const SizedBox(height: 12),
              Text(
                _templatesError!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
              ),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: _loadTemplates,
                icon: const Icon(Icons.refresh, size: 16),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (_templates.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 30),
        child: Center(
          child: Text(
            'No quotation templates found.\nPlease configure templates in settings.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textSecondary),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Select Quotation Template',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Tap the star to set a template as your company default.',
          style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
        ),
        const SizedBox(height: 16),
        ..._templates.map((tmpl) {
          final isSelected = _selectedTemplate?.id == tmpl.id;
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primaryBlueLight : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected ? AppColors.primaryBlue : AppColors.border,
                width: isSelected ? 1.8 : 1.0,
              ),
            ),
            child: InkWell(
              onTap: () {
                setState(() => _selectedTemplate = tmpl);
              },
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Radio<int>(
                      value: tmpl.id,
                      groupValue: _selectedTemplate?.id,
                      activeColor: AppColors.primaryBlue,
                      onChanged: (val) {
                        setState(() => _selectedTemplate = tmpl);
                      },
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  tmpl.name,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ),
                              if (tmpl.isFavoriteTemplate)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFEF3C7),
                                    borderRadius: BorderRadius.circular(4),
                                    border: Border.all(color: const Color(0xFFFDE68A)),
                                  ),
                                  child: const Text(
                                    'Default',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFFB45309),
                                    ),
                                  ),
                                ),
                            ],
                          ),

                        ],
                      ),
                    ),
                    // Favorite star button
                    IconButton(
                      icon: Icon(
                        tmpl.isFavoriteTemplate ? Icons.star : Icons.star_border,
                        color: tmpl.isFavoriteTemplate ? const Color(0xFFF59E0B) : AppColors.textHint,
                        size: 22,
                      ),
                      tooltip: tmpl.isFavoriteTemplate ? 'Company Default' : 'Set as Default',
                      onPressed: () => _toggleFavorite(tmpl),
                    ),
                    // Preview button
                    IconButton(
                      icon: const Icon(Icons.remove_red_eye_outlined, size: 20, color: AppColors.primaryBlue),
                      tooltip: 'Preview Template',
                      onPressed: () => _showPreview(tmpl),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildStep2Content() {
    final shiftings = widget.customer.shiftings;

    if (shiftings.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.warning_amber_rounded, color: Color(0xFFF59E0B), size: 48),
              const SizedBox(height: 12),
              const Text(
                'No Shifting Found',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              const Text(
                'This customer currently has no shifting records. Please add a shifting first.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Selected Template summary card
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: AppColors.primaryBlueLight,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.primaryBlue.withValues(alpha: 0.3)),
          ),
          child: Row(
            children: [
              const Icon(Icons.description, size: 20, color: AppColors.primaryBlue),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Selected Template',
                        style: TextStyle(fontSize: 10, color: AppColors.textSecondary)),
                    Text(
                      _selectedTemplate?.name ?? 'Standard Quotation',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryBlue,
                      ),
                    ),
                  ],
                ),
              ),
              TextButton(
                onPressed: () => setState(() => _currentStep = 1),
                style: TextButton.styleFrom(
                  visualDensity: VisualDensity.compact,
                  padding: EdgeInsets.zero,
                ),
                child: const Text('Change', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),

        // Shifting selection
        const Text(
          'Select Shifting',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          shiftings.length > 1
              ? 'Customer has multiple shiftings. Select which one to quote.'
              : 'Shifting details for this quotation:',
          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
        ),
        const SizedBox(height: 12),

        ...shiftings.map((shift) {
          final isSelected = _selectedShifting?.shiftingId == shift.shiftingId ||
              (shiftings.length == 1 && _selectedShifting == null);
          if (shiftings.length == 1 && _selectedShifting == null) {
            _selectedShifting = shift;
          }

          final charges = shift.charges;
          double sub = charges.transportCharge +
              charges.packingCharge +
              charges.loadingCharge +
              charges.unloadingCharge +
              charges.unpackingCharge +
              charges.carTransportCharge +
              charges.riskInsureCharge +
              charges.storageCharge +
              charges.statisticalCharge +
              charges.serviceCharge;
          double gst = (sub * charges.gstRate) / 100;
          double grandTotal = sub + gst;

          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.surfaceContainerLow : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected ? AppColors.primaryBlue : AppColors.border,
                width: isSelected ? 1.6 : 1.0,
              ),
            ),
            child: InkWell(
              onTap: () {
                setState(() => _selectedShifting = shift);
              },
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        if (shiftings.length > 1)
                          Radio<int?>(
                            value: shift.shiftingId,
                            groupValue: _selectedShifting?.shiftingId,
                            activeColor: AppColors.primaryBlue,
                            onChanged: (val) {
                              setState(() => _selectedShifting = shift);
                            },
                          ),
                        Expanded(
                          child: Row(
                            children: [
                              const Icon(Icons.route, size: 16, color: AppColors.secondary),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  '${shift.shiftFromCity.isNotEmpty ? shift.shiftFromCity : "Origin"} ➔ ${shift.shiftToCity.isNotEmpty ? shift.shiftToCity : "Destination"}',
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceContainerLowest,
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: AppColors.surfaceContainerHigh),
                          ),
                          child: Text(
                            shift.shiftingType.toUpperCase(),
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: AppColors.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        if (shift.shiftingStartDate != null)
                          Text(
                            'Date: ${shift.shiftingStartDate!.day}/${shift.shiftingStartDate!.month}/${shift.shiftingStartDate!.year}',
                            style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                          )
                        else
                          const Text('Date: Not scheduled',
                              style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                        Text(
                          'Total: ₹${grandTotal > 0 ? grandTotal.toStringAsFixed(0) : "0"}',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF16A34A),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: AppColors.border)),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
      ),
      child: _currentStep == 1
          ? Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.textSecondary,
                    side: const BorderSide(color: AppColors.border),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text('Cancel'),
                ),
                ElevatedButton.icon(
                  onPressed: _selectedTemplate == null
                      ? null
                      : () {
                          setState(() => _currentStep = 2);
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                  icon: const Icon(Icons.arrow_forward, size: 18),
                  label: const Text('Next: Shifting', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            )
          : Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    // Download PDF Button
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _isDownloadingPdf || _isSendingEmail
                            ? null
                            : _handleDownloadPdf,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.primaryBlue,
                          side: const BorderSide(color: AppColors.primaryBlue, width: 1.4),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        icon: _isDownloadingPdf
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primaryBlue),
                              )
                            : const Icon(Icons.download, size: 18),
                        label: Text(
                          _isDownloadingPdf ? 'Downloading...' : 'Download PDF',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    // Send to Customer Button
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _isDownloadingPdf || _isSendingEmail
                            ? null
                            : _handleSendQuotation,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF16A34A),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        icon: _isSendingEmail
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                              )
                            : const Icon(Icons.send_rounded, size: 18),
                        label: Text(
                          _isSendingEmail ? 'Sending...' : 'Send to Customer',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton.icon(
                      onPressed: () => setState(() => _currentStep = 1),
                      icon: const Icon(Icons.arrow_back, size: 16),
                      label: const Text('Back to Templates'),
                      style: TextButton.styleFrom(foregroundColor: AppColors.textSecondary),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Close', style: TextStyle(color: AppColors.textSecondary)),
                    ),
                  ],
                ),
              ],
            ),
    );
  }
}

/// Renders Thymeleaf HTML/CSS templates in a native WebView with full CSS styling
/// and an interactive full-screen preview mode with pinch-to-zoom support.
class _TemplateHtmlPreviewDialog extends StatefulWidget {
  final String templateName;
  final String templateType;
  final String htmlContent;

  const _TemplateHtmlPreviewDialog({
    required this.templateName,
    required this.templateType,
    required this.htmlContent,
  });

  @override
  State<_TemplateHtmlPreviewDialog> createState() => _TemplateHtmlPreviewDialogState();
}

class _TemplateHtmlPreviewDialogState extends State<_TemplateHtmlPreviewDialog> {
  late final WebViewController _controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initController();
  }

  void _initController() {
    String html = widget.htmlContent;
    // Inject viewport meta if not present so it scales nicely on mobile
    if (!html.contains('name="viewport"')) {
      if (html.contains('<head>')) {
        html = html.replaceFirst(
          '<head>',
          '<head><meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=5.0, user-scalable=yes">',
        );
      } else if (html.contains('<html>')) {
        html = html.replaceFirst(
          '<html>',
          '<html><head><meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=5.0, user-scalable=yes"></head>',
        );
      }
    }

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..enableZoom(true)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (_) {
            if (mounted) setState(() => _isLoading = false);
          },
        ),
      )
      ..loadHtmlString(html);
  }

  void _openFullScreen() {
    Get.to(
      () => _FullScreenHtmlPreviewScreen(
        htmlContent: widget.htmlContent,
        title: '${widget.templateName} (${widget.templateType})',
      ),
      transition: Transition.fadeIn,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 520, maxHeight: 680),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Row
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Preview: ${widget.templateName}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.primaryBlueLight,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              widget.templateType.toUpperCase(),
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primaryBlue,
                              ),
                            ),
                          ),

                        ],
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.fullscreen, color: AppColors.primaryBlue, size: 24),
                  tooltip: 'Full Screen Preview',
                  onPressed: _openFullScreen,
                ),
                IconButton(
                  icon: const Icon(Icons.close, size: 20),
                  onPressed: () => Get.back(),
                ),
              ],
            ),
            const Divider(height: 16),

            // WebView Body
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.border),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Stack(
                    children: [
                      WebViewWidget(controller: _controller),
                      if (_isLoading)
                        const Center(
                          child: CircularProgressIndicator(color: AppColors.primaryBlue),
                        ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _openFullScreen,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primaryBlue,
                      side: const BorderSide(color: AppColors.primaryBlue),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                    icon: const Icon(Icons.fullscreen, size: 18),
                    label: const Text('Full Screen Preview', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Get.back(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryBlue,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                    child: const Text('Close'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _FullScreenHtmlPreviewScreen extends StatefulWidget {
  final String htmlContent;
  final String title;

  const _FullScreenHtmlPreviewScreen({
    required this.htmlContent,
    required this.title,
  });

  @override
  State<_FullScreenHtmlPreviewScreen> createState() => _FullScreenHtmlPreviewScreenState();
}

class _FullScreenHtmlPreviewScreenState extends State<_FullScreenHtmlPreviewScreen> {
  late final WebViewController _controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    String html = widget.htmlContent;
    if (!html.contains('name="viewport"')) {
      if (html.contains('<head>')) {
        html = html.replaceFirst(
          '<head>',
          '<head><meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=5.0, user-scalable=yes">',
        );
      } else if (html.contains('<html>')) {
        html = html.replaceFirst(
          '<html>',
          '<html><head><meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=5.0, user-scalable=yes"></head>',
        );
      }
    }

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..enableZoom(true)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (_) {
            if (mounted) setState(() => _isLoading = false);
          },
        ),
      )
      ..loadHtmlString(html);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        title: Text(
          widget.title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.close),
            tooltip: 'Close Full Screen',
            onPressed: () => Get.back(),
          ),
        ],
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(color: AppColors.primaryBlue),
            ),
        ],
      ),
    );
  }
}
