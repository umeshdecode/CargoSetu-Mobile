import 'dart:async';
import 'package:cargo_setu/services/location_service.dart';
import 'package:cargo_setu/theme/app_colors.dart';
import 'package:flutter/material.dart';

/// Shared city/state autocomplete field reusing [LocationService] (Photon GeoJSON + Indian city fallback).
/// Supports debounced search, loading indicator, empty state, and canonical city/state/coordinate capture.
class CityAutocompleteField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final String? hint;
  final Widget? prefixIcon;
  final String? Function(String?)? validator;
  final ValueChanged<LocationSuggestion>? onLocationSelected;
  final ValueChanged<String>? onChanged;
  final Future<List<LocationSuggestion>> Function(String query)? searchFn;
  final Future<List<LocationSuggestion>> Function(String query)?
  suggestionsFetcher;
  final Duration debounceDuration;

  const CityAutocompleteField({
    super.key,
    required this.controller,
    required this.label,
    this.hint,
    this.prefixIcon,
    this.validator,
    this.onLocationSelected,
    this.onChanged,
    this.searchFn,
    this.suggestionsFetcher,
    this.debounceDuration = const Duration(milliseconds: 280),
  });

  @override
  State<CityAutocompleteField> createState() => _CityAutocompleteFieldState();
}

class _CityAutocompleteFieldState extends State<CityAutocompleteField> {
  Timer? _debounce;
  List<LocationSuggestion> _suggestions = [];
  bool _isLoading = false;
  bool _hasSearched = false;
  bool _suppressNextChange = false;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_onFocusChange);
  }

  void _onFocusChange() {
    if (!_focusNode.hasFocus && mounted) {
      Future.delayed(const Duration(milliseconds: 180), () {
        if (mounted && !_focusNode.hasFocus) {
          setState(() {
            _suggestions = [];
            _hasSearched = false;
          });
        }
      });
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    super.dispose();
  }

  void _onTextChanged(String value) {
    widget.onChanged?.call(value);
    if (_suppressNextChange) {
      _suppressNextChange = false;
      return;
    }

    _debounce?.cancel();
    final trimmed = value.trim();
    if (trimmed.length < 2) {
      setState(() {
        _suggestions = [];
        _isLoading = false;
        _hasSearched = false;
      });
      return;
    }

    setState(() => _isLoading = true);
    _debounce = Timer(widget.debounceDuration, () async {
      try {
        final search =
            widget.searchFn ??
            widget.suggestionsFetcher ??
            LocationService.searchLocations;
        final results = await search(trimmed);
        if (mounted) {
          setState(() {
            _suggestions = results;
            _isLoading = false;
            _hasSearched = true;
          });
        }
      } catch (_) {
        if (mounted) {
          setState(() {
            _suggestions = LocationService.fallbackSuggestions(trimmed);
            _isLoading = false;
            _hasSearched = true;
          });
        }
      }
    });
  }

  void _selectSuggestion(LocationSuggestion item) {
    _debounce?.cancel();
    _suppressNextChange = true;
    final canonical = item.canonicalCity;
    widget.controller.text = canonical;
    widget.controller.selection = TextSelection.fromPosition(
      TextPosition(offset: canonical.length),
    );
    setState(() {
      _suggestions = [];
      _isLoading = false;
      _hasSearched = false;
    });
    widget.onLocationSelected?.call(item);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label.isNotEmpty) ...[
          Text(
            widget.label,
            style: const TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
              color: Color(0xFF475569),
            ),
          ),
          const SizedBox(height: 6),
        ],
        TextFormField(
          controller: widget.controller,
          focusNode: _focusNode,
          validator: widget.validator,
          onChanged: _onTextChanged,
          style: const TextStyle(fontSize: 14, color: Color(0xFF0F172A)),
          decoration: InputDecoration(
            hintText: widget.hint,
            hintStyle: const TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
            prefixIcon: widget.prefixIcon,
            suffixIcon: _isLoading
                ? const Padding(
                    padding: EdgeInsets.all(12),
                    child: SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                : (widget.controller.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(
                            Icons.clear,
                            size: 16,
                            color: Color(0xFF94A3B8),
                          ),
                          onPressed: () {
                            widget.controller.clear();
                            setState(() {
                              _suggestions = [];
                              _hasSearched = false;
                            });
                            widget.onChanged?.call('');
                          },
                        )
                      : null),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 12,
            ),
            filled: true,
            fillColor: const Color(0xFFF8FAFC),
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
              borderSide: const BorderSide(
                color: AppColors.primaryBlue,
                width: 1.5,
              ),
            ),
          ),
        ),
        if (_suggestions.isNotEmpty)
          Container(
            margin: const EdgeInsets.only(top: 4),
            constraints: const BoxConstraints(maxHeight: 210),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFE2E8F0)),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x14000000),
                  blurRadius: 8,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: ListView.separated(
              shrinkWrap: true,
              padding: EdgeInsets.zero,
              itemCount: _suggestions.length,
              separatorBuilder: (_, _) =>
                  const Divider(height: 1, color: Color(0xFFF1F5F9)),
              itemBuilder: (context, index) {
                final item = _suggestions[index];
                return InkWell(
                  splashFactory: InkRipple.splashFactory,
                  onTap: () => _selectSuggestion(item),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.location_on_outlined,
                          size: 16,
                          color: AppColors.primaryBlue,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.canonicalCity,
                                style: const TextStyle(
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF0F172A),
                                ),
                              ),
                              if (item.displayName.isNotEmpty)
                                Text(
                                  item.displayName,
                                  style: const TextStyle(
                                    fontSize: 11.5,
                                    color: Color(0xFF64748B),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          )
        else if (_hasSearched &&
            !_isLoading &&
            widget.controller.text.trim().length >= 2)
          Container(
            margin: const EdgeInsets.only(top: 4),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: const Row(
              children: [
                Icon(Icons.info_outline, size: 14, color: Color(0xFF64748B)),
                SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'No matching cities found — you can still continue with your entered city.',
                    style: TextStyle(fontSize: 11.5, color: Color(0xFF64748B)),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
