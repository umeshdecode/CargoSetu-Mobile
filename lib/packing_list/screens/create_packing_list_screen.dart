import 'package:cargo_setu/packing_list/controllers/packing_list_controller.dart';
import 'package:cargo_setu/packing_list/models/packing_item_model.dart';
import 'package:cargo_setu/quotation/screens/template_preview_screen.dart';
import 'package:cargo_setu/theme/app_colors.dart';
import 'package:cargo_setu/widgets/app_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CreatePackingListScreen extends StatelessWidget {
  const CreatePackingListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<PackingListController>();
    final shifting = controller.selectedShifting.value;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.white,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Packaging List',
              style: TextStyle(
                color: Color(0xFF0F172A),
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            if (shifting != null)
              Text(
                '${shifting.customerName} • ${shifting.routeSummary}',
                style: const TextStyle(
                  color: Color(0xFF64748B),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
          ],
        ),
        actions: [
          if (shifting != null)
            IconButton(
              icon: const Icon(Icons.picture_as_pdf_outlined, color: AppColors.primaryBlue),
              tooltip: 'Download / Send Packaging List',
              onPressed: () {
                Get.to(() => TemplatePreviewScreen(
                      docType: 'PACKING_LIST',
                      docTitle: 'Packaging List',
                      shifting: shifting,
                    ));
              },
            ),
          const SizedBox(width: 4),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: const Color(0xFFE2E8F0), height: 1),
        ),
      ),
      body: Column(
        children: [
          // ─── SHIFTING HEADER SUMMARY ───────────────────────
          if (shifting != null)
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.local_shipping_outlined, color: Colors.white, size: 22),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            shifting.customerName.isNotEmpty ? shifting.customerName : 'Customer',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14.5,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Route: ${shifting.shiftFromCity} ➔ ${shifting.shiftToCity}',
                            style: const TextStyle(
                              color: Color(0xFF94A3B8),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Obx(() => Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.accentOrange,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '${controller.packingItems.length} Items',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        )),
                  ],
                ),
              ),
            ),

          // ─── ITEM SEARCH BAR & COUNTER BAR ──────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Column(
              children: [
                TextField(
                  onChanged: (val) => controller.itemSearchQuery.value = val,
                  decoration: InputDecoration(
                    hintText: 'Filter items by name, category, box no...',
                    hintStyle: const TextStyle(fontSize: 12.5, color: Color(0xFF94A3B8)),
                    prefixIcon: const Icon(Icons.filter_list_rounded, color: Color(0xFF64748B), size: 18),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: AppColors.primaryBlue),
                    ),
                  ),
                ),
                Obx(() {
                  final total = controller.packingItems.length;
                  final filtered = controller.filteredPackingItems.length;
                  if (controller.itemSearchQuery.value.trim().isNotEmpty) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Showing $filtered of $total items',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primaryBlue,
                          ),
                        ),
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                }),
              ],
            ),
          ),

          // ─── PACKAGING ITEMS LIST ──────────────────────────
          Expanded(
            child: Obx(() {
              if (controller.isLoadingItems.value) {
                return const Center(
                  child: CircularProgressIndicator(color: AppColors.primaryBlue),
                );
              }

              if (controller.itemsError.value.isNotEmpty && controller.packingItems.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline_rounded, size: 44, color: Color(0xFFEF4444)),
                        const SizedBox(height: 12),
                        Text(
                          controller.itemsError.value,
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Color(0xFF64748B), fontSize: 13.5),
                        ),
                        const SizedBox(height: 14),
                        ElevatedButton.icon(
                          onPressed: () {
                            if (shifting != null) controller.fetchPackingItems(shifting.shiftingId);
                          },
                          icon: const Icon(Icons.refresh, size: 16),
                          label: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                );
              }

              final list = controller.filteredPackingItems;

              if (list.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: const BoxDecoration(
                            color: Color(0xFFF1F5F9),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.post_add_rounded, size: 40, color: Color(0xFF94A3B8)),
                        ),
                        const SizedBox(height: 14),
                        const Text(
                          'No Packaging Items Added Yet',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Tap "+ Add Item" below to start adding packaging list items with auto Sr. No. counting.',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 13, color: Color(0xFF64748B)),
                        ),
                      ],
                    ),
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                itemCount: list.length,
                itemBuilder: (context, index) {
                  final item = list[index];
                  final srNo = index + 1;
                  return _PackingItemCard(
                    srNo: srNo,
                    item: item,
                    onEdit: () => _showAddEditItemSheet(context, item: item, itemIndex: index),
                    onDelete: () => _confirmDeleteItem(context, index),
                  );
                },
              );
            }),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          child: SizedBox(
            height: 48,
            child: Row(
              children: [
                if (shifting != null) ...[
                  Expanded(
                    flex: 4,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Get.to(() => TemplatePreviewScreen(
                              docType: 'PACKING_LIST',
                              docTitle: 'Packaging List',
                              shifting: shifting,
                            ));
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primaryBlue,
                        side: const BorderSide(color: AppColors.primaryBlue, width: 1.5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      icon: const Icon(Icons.picture_as_pdf_outlined, size: 18),
                      label: const Text(
                        'Export/Send',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                ],
                Expanded(
                  flex: 6,
                  child: ElevatedButton.icon(
                    onPressed: () => _showAddEditItemSheet(context),
                    icon: const Icon(Icons.add_circle_outline_rounded, size: 18),
                    label: Text(
                      'Add Item (#${controller.nextSrNo})',
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryBlue,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ─── CONFIRM DELETE DIALOG ───────────────────────────────
  void _confirmDeleteItem(BuildContext context, int index) {
    final controller = Get.find<PackingListController>();
    final item = controller.packingItems[index];

    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete Packaging Item?'),
        content: Text('Are you sure you want to remove "${item.itemName}" from the packaging list?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel', style: TextStyle(color: Color(0xFF64748B))),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              controller.deletePackingItem(index);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  // ─── ADD / EDIT ITEM BOTTOM SHEET ────────────────────────
  void _showAddEditItemSheet(BuildContext context, {PackingItemModel? item, int? itemIndex}) {
    final controller = Get.find<PackingListController>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: _AddEditPackingItemSheet(
          item: item,
          itemIndex: itemIndex,
          controller: controller,
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════
//  ADD / EDIT ITEM BOTTOM SHEET CONTENT WIDGET
// ══════════════════════════════════════════════════════════
class _AddEditPackingItemSheet extends StatefulWidget {
  final PackingItemModel? item;
  final int? itemIndex;
  final PackingListController controller;

  const _AddEditPackingItemSheet({
    this.item,
    this.itemIndex,
    required this.controller,
  });

  @override
  State<_AddEditPackingItemSheet> createState() => _AddEditPackingItemSheetState();
}

class _AddEditPackingItemSheetState extends State<_AddEditPackingItemSheet> {
  late final TextEditingController itemNameCtrl;
  late final TextEditingController pkgNoCtrl;
  late final TextEditingController roomNameCtrl;
  late final TextEditingController remarksCtrl;

  late String selectedCategory;
  late String selectedCondition;

  @override
  void initState() {
    super.initState();
    final isEdit = widget.item != null && widget.itemIndex != null;
    final defaultPkgNo = isEdit
        ? widget.item!.packageNumber
        : widget.controller.generateNextBoxNo();

    itemNameCtrl = TextEditingController(text: widget.item?.itemName ?? '');
    pkgNoCtrl = TextEditingController(text: defaultPkgNo);
    roomNameCtrl = TextEditingController(text: widget.item?.roomName ?? 'General');
    remarksCtrl = TextEditingController(text: widget.item?.remarks ?? '');

    selectedCategory = widget.item?.category ?? 'Furniture';
    selectedCondition = widget.item?.conditionStatus ?? 'Good';
  }

  @override
  void dispose() {
    itemNameCtrl.dispose();
    pkgNoCtrl.dispose();
    roomNameCtrl.dispose();
    remarksCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleSave({required bool keepOpen}) async {
    final name = itemNameCtrl.text.trim();
    if (name.isEmpty) {
      AppSnackbar.warning('Please enter the item name.');
      return;
    }

    final isEdit = widget.item != null && widget.itemIndex != null;

    if (isEdit) {
      final updated = widget.item!.copyWith(
        itemName: name,
        packageNumber: pkgNoCtrl.text.trim(),
        roomName: roomNameCtrl.text.trim(),
        category: selectedCategory,
        conditionStatus: selectedCondition,
        remarks: remarksCtrl.text.trim(),
      );
      final ok = await widget.controller.updatePackingItem(
        index: widget.itemIndex!,
        updatedItem: updated,
      );
      if (ok && mounted) {
        Navigator.of(context).pop();
      }
    } else {
      final ok = await widget.controller.addPackingItem(
        itemName: name,
        packageNumber: pkgNoCtrl.text.trim(),
        roomName: roomNameCtrl.text.trim(),
        category: selectedCategory,
        conditionStatus: selectedCondition,
        remarks: remarksCtrl.text.trim(),
      );

      if (ok) {
        if (keepOpen) {
          setState(() {
            itemNameCtrl.clear();
            remarksCtrl.clear();
            pkgNoCtrl.text = widget.controller.generateNextBoxNo();
          });
        } else {
          if (mounted) {
            Navigator.of(context).pop();
          }
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.item != null && widget.itemIndex != null;
    final autoSrNo = isEdit ? (widget.itemIndex! + 1) : widget.controller.nextSrNo;
    final maxHeight = MediaQuery.of(context).size.height * 0.80;

    return Container(
      constraints: BoxConstraints(maxHeight: maxHeight),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 10),
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFCBD5E1),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Sheet Header: Title + Auto Sr. No Badge
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.primaryBlue.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                'Sr. No. #$autoSrNo',
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.primaryBlue,
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              isEdit ? 'Edit Packaging Item' : 'Add Packaging Item',
                              style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF0F172A),
                              ),
                            ),
                          ],
                        ),
                        IconButton(
                          onPressed: () => Navigator.of(context).pop(),
                          icon: const Icon(Icons.close_rounded, color: Color(0xFF64748B)),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // ─── QUICK SUGGESTIONS CHIPS ────────────────
                    if (!isEdit) ...[
                      const Text(
                        'QUICK ITEM SUGGESTIONS',
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF94A3B8),
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 6),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: widget.controller.quickItemSuggestions.map((sug) {
                            return Padding(
                              padding: const EdgeInsets.only(right: 6),
                              child: ActionChip(
                                label: Text(sug, style: const TextStyle(fontSize: 11.5)),
                                backgroundColor: const Color(0xFFF1F5F9),
                                side: BorderSide.none,
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                onPressed: () {
                                  setState(() {
                                    itemNameCtrl.text = sug;
                                    if (sug.contains('TV') || sug.contains('Air Conditioner') || sug.contains('Refrigerator') || sug.contains('Washing')) {
                                      selectedCategory = 'Electronics';
                                    } else if (sug.contains('Bed') || sug.contains('Sofa') || sug.contains('Table') || sug.contains('Wardrobe')) {
                                      selectedCategory = 'Furniture';
                                    } else if (sug.contains('Carton')) {
                                      selectedCategory = 'Cartons & Boxes';
                                    }
                                  });
                                },
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                      const SizedBox(height: 14),
                    ],

                    // ─── ITEM NAME ─────────────────────────────
                    const Text(
                      'Item Name *',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF334155)),
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: itemNameCtrl,
                      decoration: InputDecoration(
                        hintText: 'e.g. Sofa 3 Seater, LED TV 55", Refrigerator',
                        hintStyle: const TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
                        filled: true,
                        fillColor: const Color(0xFFF8FAFC),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // ─── CATEGORY & CUSTOM PACKAGING NO ─────────
                    Row(
                      children: [
                        // Custom Packaging No
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Custom Packaging No / Box',
                                style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: Color(0xFF334155)),
                              ),
                              const SizedBox(height: 6),
                              TextField(
                                controller: pkgNoCtrl,
                                decoration: InputDecoration(
                                  hintText: 'e.g. BOX-001',
                                  hintStyle: const TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
                                  filled: true,
                                  fillColor: const Color(0xFFF8FAFC),
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        // Room Name
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Room Name',
                                style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: Color(0xFF334155)),
                              ),
                              const SizedBox(height: 6),
                              TextField(
                                controller: roomNameCtrl,
                                decoration: InputDecoration(
                                  hintText: 'e.g. Living Room, Bedroom',
                                  hintStyle: const TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
                                  filled: true,
                                  fillColor: const Color(0xFFF8FAFC),
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // ─── CATEGORY SELECTOR ─────────────────────
                    const Text(
                      'Category',
                      style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: Color(0xFF334155)),
                    ),
                    const SizedBox(height: 6),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: widget.controller.itemCategories.map((cat) {
                          final isSelected = selectedCategory == cat;
                          return Padding(
                            padding: const EdgeInsets.only(right: 6),
                            child: ChoiceChip(
                              label: Text(cat),
                              selected: isSelected,
                              selectedColor: AppColors.primaryBlue,
                              backgroundColor: const Color(0xFFF1F5F9),
                              labelStyle: TextStyle(
                                color: isSelected ? Colors.white : const Color(0xFF334155),
                                fontSize: 12,
                                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                              ),
                              side: BorderSide.none,
                              onSelected: (val) {
                                if (val) setState(() => selectedCategory = cat);
                              },
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // ─── ITEM CONDITION ────────────────────────
                    const Text(
                      'Item Condition',
                      style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: Color(0xFF334155)),
                    ),
                    const SizedBox(height: 6),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: widget.controller.itemConditions.map((cond) {
                          final isSelected = selectedCondition == cond;
                          return Padding(
                            padding: const EdgeInsets.only(right: 6),
                            child: ChoiceChip(
                              label: Text(cond),
                              selected: isSelected,
                              selectedColor: const Color(0xFF1E293B),
                              backgroundColor: const Color(0xFFF1F5F9),
                              labelStyle: TextStyle(
                                color: isSelected ? Colors.white : const Color(0xFF334155),
                                fontSize: 12,
                                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                              ),
                              side: BorderSide.none,
                              onSelected: (val) {
                                if (val) setState(() => selectedCondition = cond);
                              },
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // ─── REMARK ────────────────────────────────
                    const Text(
                      'Remark / Notes',
                      style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: Color(0xFF334155)),
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: remarksCtrl,
                      maxLines: 2,
                      decoration: InputDecoration(
                        hintText: 'e.g. Glass top wrapped with bubble wrap, slight scratch on leg',
                        hintStyle: const TextStyle(fontSize: 12.5, color: Color(0xFF94A3B8)),
                        filled: true,
                        fillColor: const Color(0xFFF8FAFC),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // ─── SUBMIT ACTION BUTTONS ─────────────────
                    Obx(() => Row(
                          children: [
                            if (!isEdit) ...[
                              Expanded(
                                child: SizedBox(
                                  height: 48,
                                  child: OutlinedButton(
                                    onPressed: widget.controller.isSavingItem.value
                                        ? null
                                        : () => _handleSave(keepOpen: true),
                                    style: OutlinedButton.styleFrom(
                                      side: const BorderSide(color: AppColors.primaryBlue),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    child: const Text(
                                      '+ Add & Next',
                                      style: TextStyle(
                                        fontSize: 13.5,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.primaryBlue,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                            ],
                            Expanded(
                              flex: isEdit ? 1 : 2,
                              child: SizedBox(
                                height: 48,
                                child: ElevatedButton(
                                  onPressed: widget.controller.isSavingItem.value
                                      ? null
                                      : () => _handleSave(keepOpen: false),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primaryBlue,
                                    foregroundColor: Colors.white,
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: Text(
                                    isEdit ? 'Save Changes' : 'Add Item',
                                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        )),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════
//  PACKAGING ITEM CARD
// ══════════════════════════════════════════════════════════
class _PackingItemCard extends StatelessWidget {
  final int srNo;
  final PackingItemModel item;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _PackingItemCard({
    required this.srNo,
    required this.item,
    required this.onEdit,
    required this.onDelete,
  });

  Color _getConditionColor(String status) {
    switch (status.toLowerCase()) {
      case 'good':
      case 'new':
        return const Color(0xFF10B981);
      case 'minor scratch':
      case 'minor dent':
        return const Color(0xFFF59E0B);
      case 'damaged':
      case 'broken':
        return const Color(0xFFEF4444);
      case 'fragile':
        return const Color(0xFF8B5CF6);
      default:
        return const Color(0xFF64748B);
    }
  }

  @override
  Widget build(BuildContext context) {
    final condColor = _getConditionColor(item.conditionStatus);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Row: Auto Sr. No + Box No + Actions
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  // Sr. No. Badge
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: AppColors.primaryBlue.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        '#$srNo',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primaryBlue,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  // Custom Packaging / Box No Badge
                  if (item.packageNumber.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: const Color(0xFFCBD5E1)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.inventory_2_outlined, size: 12, color: Color(0xFF475569)),
                          const SizedBox(width: 4),
                          Text(
                            item.packageNumber,
                            style: const TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF334155),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              Row(
                children: [
                  IconButton(
                    onPressed: onEdit,
                    icon: const Icon(Icons.edit_outlined, size: 18, color: Color(0xFF475569)),
                    constraints: const BoxConstraints(),
                    padding: const EdgeInsets.all(6),
                  ),
                  const SizedBox(width: 4),
                  IconButton(
                    onPressed: onDelete,
                    icon: const Icon(Icons.delete_outline_rounded, size: 18, color: Color(0xFFEF4444)),
                    constraints: const BoxConstraints(),
                    padding: const EdgeInsets.all(6),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 10),

          // Item Name
          Text(
            item.itemName,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: Color(0xFF0F172A),
            ),
          ),

          const SizedBox(height: 8),

          // Badges Row: Category + Condition + Room
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              // Category Chip
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'Category: ${item.category}',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF475569),
                  ),
                ),
              ),

              // Condition Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: condColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'Condition: ${item.conditionStatus}',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: condColor,
                  ),
                ),
              ),

              // Room Name Chip
              if (item.roomName.isNotEmpty && item.roomName != 'General')
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    'Room: ${item.roomName}',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF64748B),
                    ),
                  ),
                ),
            ],
          ),

          // Remarks if present
          if (item.remarks.isNotEmpty) ...[
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFF1F5F9)),
              ),
              child: Text(
                'Remark: ${item.remarks}',
                style: const TextStyle(
                  fontSize: 11.5,
                  fontStyle: FontStyle.italic,
                  color: Color(0xFF64748B),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
