import 'package:cargo_setu/customer/models/template_model.dart';
import 'package:cargo_setu/customer/services/template_service.dart';
import 'package:cargo_setu/packing_list/widgets/document_action_sheet.dart';
import 'package:cargo_setu/quotation/models/shifting_list_model.dart';
import 'package:cargo_setu/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DocumentTemplateDialog extends StatefulWidget {
  final String docType;
  final String docTitle;
  final ShiftingListItem shifting;

  const DocumentTemplateDialog({
    super.key,
    required this.docType,
    required this.docTitle,
    required this.shifting,
  });

  static void show({
    required BuildContext context,
    required String docType,
    required String docTitle,
    required ShiftingListItem shifting,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: DocumentTemplateDialog(
          docType: docType,
          docTitle: docTitle,
          shifting: shifting,
        ),
      ),
    );
  }

  @override
  State<DocumentTemplateDialog> createState() => _DocumentTemplateDialogState();
}

class _DocumentTemplateDialogState extends State<DocumentTemplateDialog> {
  final TemplateService _templateService = TemplateService();

  bool _isLoading = true;
  List<TemplateModel> _templates = [];
  TemplateModel? _selectedTemplate;

  @override
  void initState() {
    super.initState();
    _fetchTemplates();
  }

  Future<void> _fetchTemplates() async {
    try {
      final list = await _templateService.getTemplatesByType(type: widget.docType);
      list.sort((a, b) {
        if (a.isFavoriteTemplate && !b.isFavoriteTemplate) return -1;
        if (!a.isFavoriteTemplate && b.isFavoriteTemplate) return 1;
        return 0;
      });

      if (mounted) {
        setState(() {
          _templates = list;
          if (_templates.isNotEmpty) {
            _selectedTemplate = _templates.first;
          }
        });
      }
    } catch (e) {
      debugPrint('Error fetching templates: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _setDefault(TemplateModel template) async {
    try {
      final success = await _templateService.setDefaultTemplate(template.id);
      if (success) {
        Get.snackbar(
          'Default Template',
          '"${template.name}" set as default for ${widget.docTitle}',
          snackPosition: SnackPosition.BOTTOM,
        );
        _fetchTemplates();
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to set default template');
    }
  }

  void _triggerAction(String actionType) {
    final templateId = _selectedTemplate?.id ?? 0;
    final templateName = _selectedTemplate?.name ?? 'Standard ${widget.docTitle}';

    Navigator.of(context).pop();

    DocumentActionSheet.show(
      context: context,
      docType: widget.docType,
      docTitle: widget.docTitle,
      actionType: actionType,
      shiftingId: widget.shifting.shiftingId,
      templateId: templateId,
      templateName: templateName,
      customerMobileNo: widget.shifting.customerMobileNo,
      customerEmail: widget.shifting.customerEmail,
    );
  }

  @override
  Widget build(BuildContext context) {
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

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Download / Send ${widget.docTitle}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      Text(
                        widget.shifting.customerName.isNotEmpty
                            ? widget.shifting.customerName
                            : 'Select template and export option',
                        style: const TextStyle(
                          fontSize: 12.5,
                          color: Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Color(0xFF64748B)),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Divider(height: 1),
              const SizedBox(height: 16),

              const Text(
                'Select Document Template',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF334155),
                ),
              ),
              const SizedBox(height: 10),

              if (_isLoading)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(20.0),
                    child: CircularProgressIndicator(color: AppColors.primaryBlue),
                  ),
                )
              else if (_templates.isEmpty)
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.description_outlined, color: AppColors.primaryBlue, size: 28),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Standard ${widget.docTitle} Template',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF0F172A),
                              ),
                            ),
                            const SizedBox(height: 2),
                            const Text(
                              'Default system layout with company header & logo',
                              style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.check_circle, color: Color(0xFF16A34A), size: 20),
                    ],
                  ),
                )
              else
                Column(
                  children: _templates.map((tmpl) {
                    final isSelected = _selectedTemplate?.id == tmpl.id;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedTemplate = tmpl),
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isSelected ? const Color(0xFFEFF6FF) : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected ? AppColors.primaryBlue : const Color(0xFFE2E8F0),
                            width: isSelected ? 1.5 : 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
                              color: isSelected ? AppColors.primaryBlue : const Color(0xFF94A3B8),
                              size: 20,
                            ),
                            const SizedBox(width: 12),
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
                                            fontWeight: FontWeight.bold,
                                            color: isSelected ? AppColors.primaryBlue : const Color(0xFF0F172A),
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      if (tmpl.isFavoriteTemplate)
                                        Container(
                                          margin: const EdgeInsets.only(left: 6),
                                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFFEF3C7),
                                            borderRadius: BorderRadius.circular(6),
                                          ),
                                          child: const Text(
                                            'Default',
                                            style: TextStyle(
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                              color: Color(0xFFD97706),
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                  const SizedBox(height: 2),
                                   Text(
                                     (tmpl.filePath != null && tmpl.filePath!.isNotEmpty)
                                         ? 'Custom HTML Template'
                                         : 'System Template',
                                     style: const TextStyle(fontSize: 11.5, color: Color(0xFF64748B)),
                                   ),
                                ],
                              ),
                            ),
                            if (!tmpl.isFavoriteTemplate)
                              IconButton(
                                icon: const Icon(Icons.star_outline, size: 18, color: Color(0xFF94A3B8)),
                                tooltip: 'Set as Default',
                                onPressed: () => _setDefault(tmpl),
                              ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),

              const SizedBox(height: 20),
              const Text(
                'Select Export / Delivery Option',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF334155),
                ),
              ),
              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: _ActionButton(
                      icon: Icons.download_outlined,
                      label: 'Download PDF',
                      color: AppColors.primary,
                      onTap: () => _triggerAction('download'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _ActionButton(
                      icon: Icons.chat,
                      label: 'WhatsApp',
                      color: const Color(0xFF16A34A),
                      onTap: () => _triggerAction('whatsapp'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: _ActionButton(
                      icon: Icons.email_outlined,
                      label: 'Email PDF',
                      color: AppColors.primaryBlue,
                      onTap: () => _triggerAction('email'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _ActionButton(
                      icon: Icons.open_in_new,
                      label: 'Open / Preview',
                      color: const Color(0xFF9333EA),
                      onTap: () => _triggerAction('open'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color.withValues(alpha: 0.08),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withValues(alpha: 0.3)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 18, color: color),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
