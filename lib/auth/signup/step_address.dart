import 'package:cargo_setu/services/location_service.dart';
import 'package:cargo_setu/util/textfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class StepAddress extends StatefulWidget {
  final Map<String, String> data;
  final VoidCallback onChanged;

  const StepAddress(this.data, {super.key, required this.onChanged});

  @override
  State<StepAddress> createState() => _StepAddressState();
}

class _StepAddressState extends State<StepAddress> {
  List<LocationSuggestion> suggestions = [];
  bool loading = false;

  late final TextEditingController cityController;
  late final TextEditingController stateController;
  late final TextEditingController pincodeController;

  @override
  void initState() {
    super.initState();
    cityController = TextEditingController(text: widget.data['city'] ?? "");
    stateController = TextEditingController(text: widget.data['state'] ?? "");
    pincodeController = TextEditingController(
      text: widget.data['pincode'] ?? "",
    );
  }

  @override
  void dispose() {
    cityController.dispose();
    stateController.dispose();
    pincodeController.dispose();
    super.dispose();
  }

  Future<void> searchCity(String query) async {
    if (query.trim().length < 2) {
      setState(() => suggestions.clear());
      return;
    }

    setState(() => loading = true);

    try {
      final list = await LocationService.searchLocations(query);
      if (mounted) {
        setState(() {
          suggestions = list;
        });
      }
    } catch (_) {
      if (mounted) setState(() => suggestions.clear());
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// CITY with Autocomplete Search
          CoustomTextField(
            labelText: "City",
            isRequired: true,
            textEditingController: cityController,
            onChanged: (v) {
              widget.data['city'] = v;
              widget.data['state'] = "";
              stateController.clear();
              widget.onChanged();
              searchCity(v);
            },
            onTextValidator: (v) =>
                v == null || v.isEmpty ? "City is required" : null,
          ),

          /// LOADING INDICATOR
          if (loading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            ),

          /// DROPDOWN SUGGESTIONS LIST
          if (suggestions.isNotEmpty)
            Container(
              margin: const EdgeInsets.only(top: 6),
              constraints: const BoxConstraints(maxHeight: 200),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(10),
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ListView.separated(
                shrinkWrap: true,
                padding: EdgeInsets.zero,
                itemCount: suggestions.length,
                separatorBuilder: (_, __) =>
                    Divider(height: 1, color: Colors.grey.shade200),
                itemBuilder: (_, index) {
                  final item = suggestions[index];
                  return ListTile(
                    dense: true,
                    leading: const Icon(Icons.location_on_outlined,
                        size: 18, color: Color(0xFF2563EB)),
                    title: Text(
                      item.city.isNotEmpty ? item.city : item.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 13.5,
                      ),
                    ),
                    subtitle: Text(
                      [
                        if (item.state.isNotEmpty) item.state,
                        if (item.country.isNotEmpty) item.country,
                      ].join(', '),
                      style: TextStyle(
                        fontSize: 11.5,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    onTap: () {
                      final selectedCity =
                          item.city.isNotEmpty ? item.city : item.name;
                      cityController.text = selectedCity;
                      stateController.text = item.state;
                      widget.data['city'] = selectedCity;
                      widget.data['state'] = item.state;
                      if (item.country.isNotEmpty) {
                        widget.data['country'] = item.country;
                      }
                      if (item.postcode != null &&
                          item.postcode!.isNotEmpty &&
                          item.postcode!.length == 6) {
                        pincodeController.text = item.postcode!;
                        widget.data['pincode'] = item.postcode!;
                      }
                      suggestions.clear();
                      widget.onChanged();
                      setState(() {});
                    },
                  );
                },
              ),
            ),

          const SizedBox(height: 16),

          /// STATE
          CoustomTextField(
            labelText: "State",
            isRequired: true,
            readOnly: true,
            textEditingController: stateController,
            onChanged: (_) {},
            onTextValidator: (v) =>
                v == null || v.isEmpty ? "State is required" : null,
          ),

          const SizedBox(height: 16),

          /// PINCODE
          CoustomTextField(
            labelText: "Pincode",
            isRequired: true,
            keyboardType: TextInputType.number,
            maxLength: 6,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
            ],
            textEditingController: pincodeController,
            onChanged: (v) {
              widget.data['pincode'] = v;
              widget.onChanged();
            },
            onTextValidator: (v) {
              if (v == null || v.isEmpty) return "Pincode required";
              if (v.length != 6) return "Invalid pincode";
              return null;
            },
          ),
        ],
      ),
    );
  }
}
