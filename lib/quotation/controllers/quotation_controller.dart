import 'package:get/get.dart';
import '../models/shifting_list_model.dart';
import '../services/shifting_service.dart';
import '../../customer/services/template_service.dart';

class QuotationController extends GetxController {
  final ShiftingApiService _shiftingApiService = ShiftingApiService();
  final TemplateService templateService = TemplateService();

  final RxList<ShiftingListItem> allShiftings = <ShiftingListItem>[].obs;
  final RxBool isLoading = false.obs;
  final RxString loadError = ''.obs;
  final RxString searchQuery = ''.obs;
  final RxBool hasMore = true.obs;
  
  int _currentPage = 0;
  final int _pageSize = 15;

  @override
  void onInit() {
    super.onInit();
    fetchShiftings(refresh: true);
    
    debounce(searchQuery, (_) => searchShiftings(), time: const Duration(milliseconds: 500));
  }

  List<ShiftingListItem> get filteredShiftings => allShiftings.toList();

  Future<void> fetchShiftings({bool refresh = false}) async {
    if (isLoading.value || (!hasMore.value && !refresh)) return;

    if (refresh) {
      _currentPage = 0;
      allShiftings.clear();
      hasMore.value = true;
      loadError.value = '';
    }

    isLoading.value = true;

    try {
      List<ShiftingListItem> result;
      if (searchQuery.value.isNotEmpty) {
        result = await _shiftingApiService.searchShiftings(
          query: searchQuery.value,
          pageNumber: _currentPage,
          pageSize: _pageSize,
        );
      } else {
        result = await _shiftingApiService.getShiftings(
          pageNumber: _currentPage,
          pageSize: _pageSize,
        );
      }

      if (result.length < _pageSize) {
        hasMore.value = false;
      }
      
      if (refresh) {
        allShiftings.assignAll(result);
      } else {
        allShiftings.addAll(result);
      }
      _currentPage++;
    } catch (e) {
      loadError.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  void searchShiftings() {
    fetchShiftings(refresh: true);
  }
}
