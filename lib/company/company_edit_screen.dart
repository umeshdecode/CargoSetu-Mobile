import 'package:cargo_setu/company/company_controller.dart';
import 'package:cargo_setu/company/widgets/company_form_widget.dart';
import 'package:cargo_setu/theme/app_colors.dart';
import 'package:cargo_setu/widgets/app_dialog.dart';
import 'package:cargo_setu/widgets/loading_overlay.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Screen to edit an existing company.
class CompanyEditScreen extends StatefulWidget {
  const CompanyEditScreen({super.key});

  @override
  State<CompanyEditScreen> createState() => _CompanyEditScreenState();
}

class _CompanyEditScreenState extends State<CompanyEditScreen> {
  late final CompanyController companyCtrl;

  @override
  void initState() {
    super.initState();
    companyCtrl = Get.isRegistered<CompanyController>()
        ? Get.find<CompanyController>()
        : Get.put(CompanyController());

    if (companyCtrl.currentCompany.value == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        companyCtrl.fetchCurrentCompany();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
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
        final isLoading = companyCtrl.isLoading.value;

        if (company == null) {
          if (isLoading) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: AppColors.primaryBlue),
                  SizedBox(height: 16),
                  Text(
                    'Loading company details...',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            );
          }

          return Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline,
                      size: 56, color: AppColors.textHint),
                  const SizedBox(height: 16),
                  const Text(
                    'No company data available to edit',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () => companyCtrl.fetchCurrentCompany(),
                    icon: const Icon(Icons.refresh, size: 18),
                    label: const Text('Retry Fetch'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryBlue,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
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
