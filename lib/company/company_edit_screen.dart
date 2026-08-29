import 'package:cargo_setu/company/company_controller.dart';
import 'package:cargo_setu/company/widgets/company_form_widget.dart';
import 'package:cargo_setu/theme/app_colors.dart';
import 'package:cargo_setu/widgets/app_dialog.dart';
import 'package:cargo_setu/widgets/loading_overlay.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Screen to edit an existing company.
class CompanyEditScreen extends StatelessWidget {
  const CompanyEditScreen({super.key});

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
          'Edit Company Profile',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: AppColors.border, height: 1),
        ),
      ),
      body: Obx(() {
        final company = companyCtrl.currentCompany.value;

        if (company == null) {
          return const Center(
            child: Text(
              'No company data to edit',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          );
        }

        return LoadingOverlay(
          isLoading: companyCtrl.isSubmitting.value,
          message: 'Updating company profile...',
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: CompanyFormWidget(
              company: company,
              isSubmitting: companyCtrl.isSubmitting.value,
              onSubmit: (updatedCompany, logoFile) async {
                final success = await companyCtrl.updateCompany(
                  updatedCompany,
                  logoFile: logoFile,
                );
                if (success && context.mounted) {
                  await AppDialog.showSuccess(
                    context,
                    title: 'Profile Updated! ✨',
                    message:
                        'Company profile and brand assets have been updated successfully.',
                    positiveBtnText: 'Back to Profile',
                    onPositive: () {
                      Navigator.of(context).pop();
                      Get.back();
                    },
                  );
                }
              },
            ),
          ),
        );
      }),
    );
  }
}
