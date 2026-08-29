import 'package:cargo_setu/company/company_controller.dart';
import 'package:cargo_setu/company/widgets/company_form_widget.dart';
import 'package:cargo_setu/routes/app_routes.dart';
import 'package:cargo_setu/theme/app_colors.dart';
import 'package:cargo_setu/widgets/app_dialog.dart';
import 'package:cargo_setu/widgets/loading_overlay.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Screen to create a new company.
class CompanyCreateScreen extends StatelessWidget {
  const CompanyCreateScreen({super.key});

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
          'Register Transport Company',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.2,
          ),
        ),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: AppColors.border, height: 1),
        ),
      ),
      body: Obx(() => LoadingOverlay(
            isLoading: companyCtrl.isSubmitting.value,
            message: 'Setting up your company profile...',
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Futuristic Hero Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
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
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.25),
                            ),
                          ),
                          child: const Icon(
                            Icons.local_shipping_rounded,
                            color: Colors.white,
                            size: 32,
                          ),
                        ),
                        const SizedBox(width: 16),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Create Organization',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Establish your legal entity to enable Bilty generation, Quotations, and Fleet management.',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12.5,
                                  height: 1.35,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 22),

                  // Company form
                  CompanyFormWidget(
                    company: null,
                    isSubmitting: companyCtrl.isSubmitting.value,
                    onSubmit: (company, logoFile) async {
                      final success = await companyCtrl.createCompany(
                        company,
                        logoFile: logoFile,
                      );
                      if (success && context.mounted) {
                        await AppDialog.showSuccess(
                          context,
                          title: 'Company Created! 🎉',
                          message:
                              '${company.companyName} has been registered successfully. You now have full access to all CargoSetu TMS tools.',
                          positiveBtnText: 'Open Dashboard',
                          onPositive: () {
                            Navigator.of(context).pop();
                            Get.offAllNamed(AppRoutes.dashboard);
                          },
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
          )),
    );
  }
}
