import 'dart:convert';
import 'package:cargo_setu/util/textfield.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class StepAddress extends StatefulWidget {
  final Map<String, String> data;
  final VoidCallback onChanged;

  const StepAddress(this.data, {super.key, required this.onChanged});

  @override
  State<StepAddress> createState() => _StepAddressState();
}

class _StepAddressState extends State<StepAddress> {
  List cities = [];
  bool loading = false;

  late final TextEditingController cityController;
  late final TextEditingController stateController;
  late final TextEditingController pincodeController;

  @override
  void initState() {
    super.initState();
    cityController = TextEditingController(text: widget.data['city'] ?? "");
    stateController = TextEditingController(text: widget.data['state'] ?? "");
    pincodeController =
        TextEditingController(text: widget.data['pincode'] ?? "");
  }

  @override
  void dispose() {
    cityController.dispose();
    stateController.dispose();
    pincodeController.dispose();
    super.dispose();
  }

  Future<void> searchCity(String query) async {
    if (query.length < 3) {
      setState(() => cities.clear());
      return;
    }

    setState(() => loading = true);

    try {
      final res = await http.get(
        Uri.parse(
          "https://photon.komoot.io/api/?q=${Uri.encodeComponent(query)}",
        ),
        headers: const {
          "Accept": "application/json",
          "User-Agent": "CargoSetuApp/1.0",
        },
      );

      if (res.statusCode == 200) {
        final decoded = jsonDecode(res.body);
        setState(() {
          cities = decoded['features'] ?? [];
        });
      }
    } catch (_) {
      setState(() => cities.clear());
    } finally {
      setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// CITY
          CoustomTextField(
            labelText: "City",
            isRequired: true,
            textEditingController: cityController, // ✅ FIX
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

          /// LOADING
          if (loading)
            const Padding(
              padding: EdgeInsets.all(8),
              child: CircularProgressIndicator(strokeWidth: 2),
            ),

          /// DROPDOWN LIST
          if (cities.isNotEmpty)
            Container(
              margin: const EdgeInsets.only(top: 6),
              constraints: const BoxConstraints(maxHeight: 200),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
                color: Colors.white,
              ),
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: cities.length,
                itemBuilder: (_, index) {
                  final p = cities[index]['properties'];
                  return ListTile(
                    title: Text(p['name'] ?? ''),
                    subtitle: Text(p['state'] ?? ''),
                    onTap: () {
                      cityController.text = p['name'] ?? '';
                      stateController.text = p['state'] ?? '';
                      widget.data['city'] = cityController.text;
                      widget.data['state'] = stateController.text;
                      cities.clear();
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
            textEditingController: stateController, // ✅ FIX
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
            textEditingController: pincodeController, // ✅ FIX
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
