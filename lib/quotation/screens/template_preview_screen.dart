import 'package:cargo_setu/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../models/shifting_list_model.dart';
import '../../customer/models/template_model.dart';
import '../../customer/services/template_service.dart';
import '../widgets/quotation_action_sheet.dart';

class TemplatePreviewScreen extends StatefulWidget {
  final ShiftingListItem shifting;

  const TemplatePreviewScreen({super.key, required this.shifting});

  @override
  State<TemplatePreviewScreen> createState() => _TemplatePreviewScreenState();
}

class _TemplatePreviewScreenState extends State<TemplatePreviewScreen> {
  final TemplateService _templateService = TemplateService();

  bool _isLoading = true;
  List<TemplateModel> _templates = [];
  final Map<int, String> _htmlContents = {};

  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _fetchTemplates();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _fetchTemplates() async {
    try {
      final templates = await _templateService.getTemplatesByType(type: 'QUOTATION');
      // Sort to bring favorite/default first
      templates.sort((a, b) {
        if (a.isFavoriteTemplate && !b.isFavoriteTemplate) return -1;
        if (!a.isFavoriteTemplate && b.isFavoriteTemplate) return 1;
        return 0;
      });

      if (mounted) {
        setState(() {
          _templates = templates;
        });
      }

      // Fetch HTML for all templates
      for (var t in templates) {
        _fetchHtmlContent(t.id);
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to load quotation templates');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _fetchHtmlContent(int templateId) async {
    try {
      final html = await _templateService.getTemplatePreviewHtml(templateId);
      if (html != null && mounted) {
        setState(() {
          _htmlContents[templateId] = html;
        });
      }
    } catch (e) {
      debugPrint('Error fetching HTML for template $templateId: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.primary),
          onPressed: () => Get.back(),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.shifting.customerName.isNotEmpty
                  ? widget.shifting.customerName
                  : 'Customer Quotation',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            Text(
              widget.shifting.routeSummary,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.normal,
                color: AppColors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primaryBlue))
          : _templates.isEmpty
              ? const Center(
                  child: Text(
                    'No quotation templates available.',
                    style: TextStyle(color: AppColors.onSurfaceVariant),
                  ),
                )
              : Column(
                  children: [
                    // Active selection header banner
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppColors.primaryBlueLight,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.primaryBlue.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.check_circle, size: 18, color: AppColors.primaryBlue),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'SELECTED FOR GENERATION',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.primaryBlue,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                Text(
                                  _templates[_currentPage].name,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primary,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.primaryBlue,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '${_currentPage + 1} of ${_templates.length}',
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    Expanded(
                      child: PageView.builder(
                        controller: _pageController,
                        onPageChanged: (index) {
                          setState(() => _currentPage = index);
                        },
                        itemCount: _templates.length,
                        itemBuilder: (context, index) {
                          final template = _templates[index];
                          final isSelected = index == _currentPage;
                          return _buildTemplatePage(template, isSelected);
                        },
                      ),
                    ),
                    const SizedBox(height: 6),

                    // Carousel Dots Indicator
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        _templates.length,
                        (index) => AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          width: _currentPage == index ? 18 : 8,
                          height: 8,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(4),
                            color: _currentPage == index
                                ? AppColors.primaryBlue
                                : AppColors.surfaceContainerHigh,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                  ],
                ),
      bottomNavigationBar: _templates.isEmpty ? null : _buildBottomActionBar(),
    );
  }

  Widget _buildTemplatePage(TemplateModel template, bool isSelected) {
    final html = _htmlContents[template.id];

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    if (isSelected) ...[
                      const Icon(Icons.radio_button_checked, size: 18, color: AppColors.primaryBlue),
                      const SizedBox(width: 6),
                    ],
                    Expanded(
                      child: Text(
                        template.name,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isSelected ? AppColors.primaryBlue : AppColors.primary,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              if (template.isFavoriteTemplate)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEF3C7),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: const Color(0xFFFDE68A)),
                  ),
                  child: const Text(
                    'Company Default',
                    style: TextStyle(
                      color: Color(0xFFB45309),
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )
              else
                IconButton(
                  icon: const Icon(Icons.star_border, color: AppColors.textHint),
                  tooltip: 'Set as Company Default',
                  onPressed: () async {
                    try {
                      final success = await _templateService.setDefaultTemplate(template.id);
                      if (success) {
                        Get.snackbar(
                          'Success',
                          'Set "${template.name}" as default quotation template',
                          snackPosition: SnackPosition.BOTTOM,
                        );
                        _fetchTemplates();
                      }
                    } catch (e) {
                      Get.snackbar(
                        'Error',
                        'Failed to set default template',
                        snackPosition: SnackPosition.BOTTOM,
                      );
                    }
                  },
                )
            ],
          ),
          const SizedBox(height: 8),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: isSelected ? AppColors.primaryBlue : AppColors.border,
                  width: isSelected ? 2.0 : 1.0,
                ),
                borderRadius: BorderRadius.circular(10),
                color: Colors.white,
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: AppColors.primaryBlue.withValues(alpha: 0.12),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : null,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: html == null
                    ? const Center(
                        child: CircularProgressIndicator(color: AppColors.primaryBlue),
                      )
                    : _WebViewPreview(htmlContent: html),
              ),
            ),
          ),
          const SizedBox(height: 6),
          TextButton.icon(
            onPressed: html == null
                ? null
                : () => Get.to(
                      () => _FullScreenHtmlPreviewScreen(
                        htmlContent: html,
                        templateName: template.name,
                      ),
                    ),
            icon: const Icon(Icons.fullscreen, color: AppColors.primaryBlue, size: 20),
            label: const Text(
              'Full Screen Preview',
              style: TextStyle(
                color: AppColors.primaryBlue,
                fontWeight: FontWeight.w600,
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildBottomActionBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -4),
          )
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _actionButton(
                  icon: Icons.chat,
                  color: const Color(0xFF16A34A),
                  bgColor: const Color(0xFFF0FDF4),
                  label: 'WhatsApp',
                  onTap: () => _showActionSheet('whatsapp'),
                ),
                _actionButton(
                  icon: Icons.email_outlined,
                  color: AppColors.primaryBlue,
                  bgColor: AppColors.primaryBlueLight,
                  label: 'Email',
                  onTap: () => _showActionSheet('email'),
                ),
                _actionButton(
                  icon: Icons.download_outlined,
                  color: AppColors.primary,
                  bgColor: AppColors.surfaceContainerLow,
                  label: 'Download',
                  onTap: () => _showActionSheet('download'),
                ),
                _actionButton(
                  icon: Icons.open_in_new,
                  color: const Color(0xFF9333EA),
                  bgColor: const Color(0xFFFAF5FF),
                  label: 'Open',
                  onTap: () => _showActionSheet('open'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _actionButton({
    required IconData icon,
    required Color color,
    required Color bgColor,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              backgroundColor: bgColor,
              radius: 20,
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showActionSheet(String actionType) {
    if (_templates.isEmpty) return;
    final template = _templates[_currentPage];

    QuotationActionSheet.show(
      context: context,
      actionType: actionType,
      shiftingId: widget.shifting.shiftingId,
      templateId: template.id,
      templateName: template.name,
      customerMobileNo: widget.shifting.customerMobileNo,
      customerEmail: widget.shifting.customerEmail,
    );
  }
}

class _WebViewPreview extends StatefulWidget {
  final String htmlContent;
  const _WebViewPreview({required this.htmlContent});

  @override
  State<_WebViewPreview> createState() => _WebViewPreviewState();
}

class _WebViewPreviewState extends State<_WebViewPreview> {
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
    return Stack(
      children: [
        WebViewWidget(controller: _controller),
        if (_isLoading)
          const Center(
            child: CircularProgressIndicator(color: AppColors.primaryBlue),
          ),
      ],
    );
  }
}

class _FullScreenHtmlPreviewScreen extends StatefulWidget {
  final String htmlContent;
  final String templateName;

  const _FullScreenHtmlPreviewScreen({
    required this.htmlContent,
    required this.templateName,
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
          widget.templateName,
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
