import 'package:cargo_setu/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/vehicle_controller.dart';
import '../models/vehicle_catalogue_models.dart';

class VehicleCataloguePickerBottomSheet extends StatefulWidget {
  final ValueChanged<CatalogueDetailModel> onModelSelected;

  const VehicleCataloguePickerBottomSheet({
    super.key,
    required this.onModelSelected,
  });

  static void show(BuildContext context, {required ValueChanged<CatalogueDetailModel> onModelSelected}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => VehicleCataloguePickerBottomSheet(onModelSelected: onModelSelected),
    );
  }

  @override
  State<VehicleCataloguePickerBottomSheet> createState() => _VehicleCataloguePickerBottomSheetState();
}

class _VehicleCataloguePickerBottomSheetState extends State<VehicleCataloguePickerBottomSheet> {
  final TextEditingController _searchController = TextEditingController();
  String? _selectedBrandSlug;
  bool _fetchingDetail = false;
  int? _fetchingId;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onBrandSelected(VehicleController controller, String? slug) {
    setState(() {
      _selectedBrandSlug = slug;
      _searchController.clear();
    });
    controller.loadCatalogueModels(slug);
  }

  Future<void> _selectModel(VehicleController controller, CatalogueModelItem item) async {
    setState(() {
      _fetchingDetail = true;
      _fetchingId = item.id;
    });

    final detail = await controller.fetchCatalogueDetail(item.id);

    setState(() {
      _fetchingDetail = false;
      _fetchingId = null;
    });

    if (detail != null) {
      Get.back();
      widget.onModelSelected(detail);
    } else {
      Get.snackbar(
        'Notice',
        'Model specifications unavailable, auto-filling name & brand.',
        backgroundColor: Colors.orange.shade700,
        colorText: Colors.white,
      );
      Get.back();
      widget.onModelSelected(CatalogueDetailModel(
        id: item.id,
        name: item.name,
        slug: item.slug,
        brand: item.brandName != null
            ? CatalogueBrandModel(id: 0, name: item.brandName!, slug: item.brandSlug ?? '')
            : null,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<VehicleController>();

    return Container(
      height: MediaQuery.of(context).size.height * 0.82,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Drag Handle
          Container(
            margin: const EdgeInsets.only(top: 10, bottom: 6),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header Title
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(Icons.directions_bus_outlined, color: AppColors.primaryBlue),
                    SizedBox(width: 8),
                    Text(
                      'Vehicle Catalogue',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.close, size: 20),
                  onPressed: () => Get.back(),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.border),

          // Search Field
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: _searchController,
              onChanged: (val) {
                setState(() => _selectedBrandSlug = null);
                controller.searchCatalogue(val);
              },
              decoration: InputDecoration(
                hintText: 'Search by model (e.g. Signa, Intra, Pro 2059)...',
                hintStyle: const TextStyle(fontSize: 13, color: AppColors.textHint),
                prefixIcon: const Icon(Icons.search, color: AppColors.primaryBlue, size: 20),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 18),
                        onPressed: () {
                          _searchController.clear();
                          controller.loadCatalogueModels(_selectedBrandSlug);
                        },
                      )
                    : null,
                filled: true,
                fillColor: AppColors.bgLight,
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: AppColors.primaryBlue, width: 1.5),
                ),
              ),
            ),
          ),

          // Brand Filter Horizontal Chips
          Obx(() {
            final brands = controller.catalogueBrands;
            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              child: Row(
                children: [
                  ChoiceChip(
                    label: const Text('All Brands'),
                    selected: _selectedBrandSlug == null,
                    selectedColor: AppColors.primaryBlue,
                    backgroundColor: AppColors.bgLight,
                    labelStyle: TextStyle(
                      fontSize: 12,
                      fontWeight: _selectedBrandSlug == null ? FontWeight.bold : FontWeight.w500,
                      color: _selectedBrandSlug == null ? Colors.white : AppColors.textPrimary,
                    ),
                    onSelected: (_) => _onBrandSelected(controller, null),
                  ),
                  const SizedBox(width: 8),
                  ...brands.map((b) {
                    final isSelected = _selectedBrandSlug == b.slug;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(b.name),
                        selected: isSelected,
                        selectedColor: AppColors.primaryBlue,
                        backgroundColor: AppColors.bgLight,
                        labelStyle: TextStyle(
                          fontSize: 12,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                          color: isSelected ? Colors.white : AppColors.textPrimary,
                        ),
                        onSelected: (_) => _onBrandSelected(controller, b.slug),
                      ),
                    );
                  }),
                ],
              ),
            );
          }),
          const SizedBox(height: 8),
          const Divider(height: 1, color: AppColors.border),

          // Catalogue Models List
          Expanded(
            child: Obx(() {
              if (controller.isCatalogueLoading.value) {
                return const Center(child: CircularProgressIndicator(color: AppColors.primaryBlue));
              }

              final models = controller.catalogueModels;
              if (models.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.find_in_page_outlined, size: 48, color: Colors.grey.shade400),
                      const SizedBox(height: 10),
                      const Text(
                        'No matching models found',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Try searching with a different keyword or brand.',
                        style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                );
              }

              return ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                itemCount: models.length,
                separatorBuilder: (ctx, i) => const Divider(height: 1, color: AppColors.border),
                itemBuilder: (ctx, i) {
                  final m = models[i];
                  final isCurrentFetching = _fetchingDetail && _fetchingId == m.id;

                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    leading: Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: AppColors.primaryBlue.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.local_shipping_outlined, color: AppColors.primaryBlue, size: 22),
                    ),
                    title: Text(
                      m.name,
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                    ),
                    subtitle: m.brandName != null
                        ? Text(
                            m.brandName!,
                            style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                          )
                        : null,
                    trailing: isCurrentFetching
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primaryBlue),
                          )
                        : const Icon(Icons.arrow_forward_ios, size: 14, color: AppColors.textHint),
                    onTap: _fetchingDetail ? null : () => _selectModel(controller, m),
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }
}
