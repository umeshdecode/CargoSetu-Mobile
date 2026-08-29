import 'dart:convert';

import 'package:cargo_setu/company/company_controller.dart';
import 'package:cargo_setu/routes/app_routes.dart';
import 'package:cargo_setu/theme/app_colors.dart';
import 'package:cargo_setu/widgets/app_dialog.dart';
import 'package:cargo_setu/widgets/section_header.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Company profile view screen — displays all company details and brand logo.
class CompanyProfileScreen extends StatelessWidget {
  const CompanyProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final companyCtrl = Get.find<CompanyController>();

    return Scaffold(
      backgroundColor: AppColors.bgLight,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          'Company Profile',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined, color: AppColors.primaryBlue),
            onPressed: () => Get.toNamed(AppRoutes.companyEdit),
            tooltip: 'Edit Company',
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: AppColors.border, height: 1),
        ),
      ),
      body: Obx(() {
        final company = companyCtrl.currentCompany.value;

        if (companyCtrl.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(
              color: AppColors.primaryBlue,
            ),
          );
        }

        if (company == null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.business_outlined,
                    size: 64, color: AppColors.textHint),
                const SizedBox(height: 16),
                const Text(
                  'No company data available',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => Get.toNamed(AppRoutes.companyCreate),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Create Company'),
                ),
              ],
            ),
          );
        }

        final logo = company.logoUrlOrBase64;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // Company Header Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF1E3A8A), Color(0xFF2563EB)],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF2563EB).withValues(alpha: 0.25),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Brand Logo with glowing border
                    Container(
                      width: 84,
                      height: 84,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.8),
                          width: 2.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.15),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: (logo != null && logo.isNotEmpty)
                            ? _buildLogoImage(logo)
                            : Center(
                                child: Text(
                                  company.companyName.isNotEmpty
                                      ? company.companyName[0].toUpperCase()
                                      : 'C',
                                  style: const TextStyle(
                                    fontSize: 34,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.primaryBlue,
                                  ),
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      company.companyName,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      company.companyEmail,
                      style: const TextStyle(
                        fontSize: 13.5,
                        color: Colors.white70,
                      ),
                    ),
                    if (company.companyUUID != null) ...[
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 4.5,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.2),
                          ),
                        ),
                        child: Text(
                          'ID: ${company.companyUUID!}',
                          style: const TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Contact Details Section
              _buildSection(
                icon: Icons.phone_in_talk,
                title: 'Contact Details',
                items: [
                  if (company.whatsappNumber != null)
                    _InfoRow('WhatsApp', '+${company.whatsappNumber!}'),
                  if (company.contactNo1 != null)
                    _InfoRow('Contact No. 1', '+${company.contactNo1!}'),
                  if (company.contactNo2 != null)
                    _InfoRow('Contact No. 2', '+${company.contactNo2!}'),
                  if (company.landlineNo != null)
                    _InfoRow('Landline', company.landlineNo!),
                  if (company.tollFreeNumber != null)
                    _InfoRow('Toll-Free', company.tollFreeNumber!),
                ],
              ),

              const SizedBox(height: 16),

              // Tax & Legal Section
              _buildSection(
                icon: Icons.receipt_long,
                title: 'Tax & Legal',
                items: [
                  if (company.panNumber != null)
                    _InfoRow('PAN Number', company.panNumber!),
                  if (company.gstNumber != null)
                    _InfoRow('GST Number', company.gstNumber!),
                ],
              ),

              const SizedBox(height: 16),

              // Address Section
              _buildSection(
                icon: Icons.location_on,
                title: 'Address',
                items: [
                  if (company.address != null)
                    _InfoRow('Street', company.address!),
                  if (company.city != null) _InfoRow('City', company.city!),
                  if (company.state != null)
                    _InfoRow('State', company.state!),
                  if (company.country != null)
                    _InfoRow('Country', company.country!),
                  if (company.branch != null)
                    _InfoRow('Branch', company.branch!),
                  if (company.mainBranch != null)
                    _InfoRow('Main Branch', company.mainBranch!),
                ],
              ),

              const SizedBox(height: 16),

              // Additional Section
              if (company.website != null && company.website!.isNotEmpty)
                _buildSection(
                  icon: Icons.language,
                  title: 'Online Presence',
                  items: [
                    _InfoRow('Website', company.website!),
                  ],
                ),

              const SizedBox(height: 24),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => Get.toNamed(AppRoutes.companyEdit),
                      icon: const Icon(Icons.edit_outlined, size: 18),
                      label: const Text('Edit Profile'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primaryBlue,
                        side: const BorderSide(
                            color: AppColors.primaryBlue, width: 1.5),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _handleDeleteCompany(context, companyCtrl),
                      icon: const Icon(Icons.delete_outline, size: 18),
                      label: const Text('Request Delete'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.error,
                        side: const BorderSide(
                            color: AppColors.error, width: 1.5),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildLogoImage(String source) {
    if (source.startsWith('http://') || source.startsWith('https://')) {
      return Image.network(
        source,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) =>
            const Icon(Icons.business, size: 36, color: AppColors.primaryBlue),
      );
    }
    try {
      final cleanBase64 =
          source.contains(',') ? source.split(',').last : source;
      final bytes = base64Decode(cleanBase64);
      return Image.memory(bytes, fit: BoxFit.cover);
    } catch (_) {
      return const Icon(Icons.business, size: 36, color: AppColors.primaryBlue);
    }
  }

  Widget _buildSection({
    required IconData icon,
    required String title,
    required List<_InfoRow> items,
  }) {
    if (items.isEmpty) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(
            icon: icon,
            title: title,
            padding: const EdgeInsets.only(bottom: 12),
          ),
          ...items.map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 125,
                      child: Text(
                        item.label,
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        item.value,
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  void _handleDeleteCompany(
    BuildContext context,
    CompanyController companyCtrl,
  ) async {
    final confirmed = await AppDialog.showConfirm(
      context,
      title: 'Delete Company Profile?',
      message:
          'This will deactivate your company profile. All transport documents associated with this workspace will be archived.',
      positiveBtnText: 'Delete Workspace',
      negativeBtnText: 'Cancel',
    );

    if (confirmed == true) {
      final id = companyCtrl.currentCompany.value?.companyId;
      if (id != null) {
        final success = await companyCtrl.deleteCompany(id);
        if (success) {
          Get.offAllNamed(AppRoutes.dashboard);
        }
      }
    }
  }
}

class _InfoRow {
  final String label;
  final String value;
  const _InfoRow(this.label, this.value);
}
