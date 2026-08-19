// File Path: sreerajp_authenticator/lib/widgets/add_account/tag_autocomplete_field.dart
// Author: Sreeraj P
// Description: Autocomplete tag input field with instant matching on 1st character and tag browser support

import 'package:flutter/material.dart';
import 'browse_tags_bottom_sheet.dart';

class TagAutocompleteField extends StatefulWidget {
  final TextEditingController controller;
  final List<String> availableTags;
  final String labelText;
  final String hintText;

  const TagAutocompleteField({
    super.key,
    required this.controller,
    required this.availableTags,
    this.labelText = 'Tags (Comma separated)',
    this.hintText = 'e.g., Work, Crypto, VIP',
  });

  @override
  State<TagAutocompleteField> createState() => _TagAutocompleteFieldState();
}

class _TagAutocompleteFieldState extends State<TagAutocompleteField> {
  final FocusNode _focusNode = FocusNode();
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;
  List<String> _currentSuggestions = [];

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onTextChanged);
    _focusNode.addListener(_onFocusChanged);
  }

  @override
  void didUpdateWidget(covariant TagAutocompleteField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_onTextChanged);
      widget.controller.addListener(_onTextChanged);
    }
  }

  @override
  void dispose() {
    _removeOverlay();
    widget.controller.removeListener(_onTextChanged);
    _focusNode.removeListener(_onFocusChanged);
    _focusNode.dispose();
    super.dispose();
  }

  void _onFocusChanged() {
    if (!_focusNode.hasFocus) {
      _removeOverlay();
    } else {
      _updateSuggestions();
    }
  }

  void _onTextChanged() {
    if (_focusNode.hasFocus) {
      _updateSuggestions();
    }
  }

  /// Parses the active tag segment being typed (after the last comma).
  String _getActiveQuery() {
    final text = widget.controller.text;
    final lastCommaIndex = text.lastIndexOf(',');
    if (lastCommaIndex == -1) {
      return text.trimLeft();
    }
    return text.substring(lastCommaIndex + 1).trimLeft();
  }

  /// Returns already-typed tags (before the active segment) in lowercase.
  Set<String> _getAlreadySelectedTags() {
    final text = widget.controller.text;
    final segments = text.split(',');
    if (segments.length <= 1) {
      return {};
    }
    // Take all segments except the last one
    return segments
        .take(segments.length - 1)
        .map((s) => s.trim().toLowerCase())
        .where((s) => s.isNotEmpty)
        .toSet();
  }

  void _updateSuggestions() {
    final query = _getActiveQuery();

    if (query.isEmpty || widget.availableTags.isEmpty) {
      _removeOverlay();
      return;
    }

    final queryLower = query.toLowerCase();
    final alreadySelected = _getAlreadySelectedTags();

    // Match tags starting with or containing query on the 1st character
    final matches = widget.availableTags.where((tag) {
      final tagLower = tag.toLowerCase();
      // Exclude if already selected in prior segments
      if (alreadySelected.contains(tagLower)) return false;
      return tagLower.contains(queryLower);
    }).toList();

    // Sort: prioritize tags that start with the query, then alphabetical
    matches.sort((a, b) {
      final aStarts = a.toLowerCase().startsWith(queryLower);
      final bStarts = b.toLowerCase().startsWith(queryLower);
      if (aStarts && !bStarts) return -1;
      if (!aStarts && bStarts) return 1;
      return a.toLowerCase().compareTo(b.toLowerCase());
    });

    if (matches.isEmpty) {
      _removeOverlay();
      return;
    }

    _currentSuggestions = matches;
    _showOrUpdateOverlay();
  }

  void _showOrUpdateOverlay() {
    if (_overlayEntry == null) {
      _overlayEntry = _createOverlayEntry();
      Overlay.of(context).insert(_overlayEntry!);
    } else {
      _overlayEntry!.markNeedsBuild();
    }
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  void _selectSuggestion(String tag) {
    final text = widget.controller.text;
    final lastCommaIndex = text.lastIndexOf(',');

    String newText;
    if (lastCommaIndex == -1) {
      newText = '$tag, ';
    } else {
      final prefix = text.substring(0, lastCommaIndex + 1);
      newText = '$prefix $tag, ';
    }

    widget.controller.value = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: newText.length),
    );

    _removeOverlay();
  }

  void _openBrowseTags() {
    _removeOverlay();
    // Parse current tags in controller
    final currentTags = widget.controller.text
        .split(',')
        .map((t) => t.trim())
        .where((t) => t.isNotEmpty)
        .toList();

    BrowseTagsBottomSheet.show(
      context: context,
      availableTags: widget.availableTags,
      currentlySelectedTags: currentTags,
      onTagsSelected: (selectedTags) {
        if (selectedTags.isEmpty) {
          widget.controller.text = '';
        } else {
          final formatted = '${selectedTags.join(', ')}, ';
          widget.controller.value = TextEditingValue(
            text: formatted,
            selection: TextSelection.collapsed(offset: formatted.length),
          );
        }
      },
    );
  }

  OverlayEntry _createOverlayEntry() {
    final renderBox = context.findRenderObject() as RenderBox?;
    final size = renderBox?.size ?? const Size(200, 50);

    return OverlayEntry(
      builder: (context) {
        final theme = Theme.of(context);
        final isDark = theme.brightness == Brightness.dark;

        return Positioned(
          width: size.width,
          child: CompositedTransformFollower(
            link: _layerLink,
            showWhenUnlinked: false,
            offset: Offset(0, size.height + 4),
            child: Material(
              elevation: 6,
              shadowColor: Colors.black38,
              borderRadius: BorderRadius.circular(10),
              color: isDark ? const Color(0xFF1E222B) : theme.cardColor,
              child: Container(
                constraints: const BoxConstraints(maxHeight: 180),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: theme.dividerColor.withValues(alpha: 0.6),
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    shrinkWrap: true,
                    itemCount: _currentSuggestions.length,
                    separatorBuilder: (_, _) => Divider(
                      height: 1,
                      color: theme.dividerColor.withValues(alpha: 0.3),
                    ),
                    itemBuilder: (context, index) {
                      final tag = _currentSuggestions[index];
                      final tagDisplay = tag.startsWith('#') ? tag : '#$tag';

                      return InkWell(
                        onTap: () => _selectSuggestion(tag),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 10,
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.label_outlined,
                                size: 16,
                                color: theme.colorScheme.primary,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  tagDisplay,
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                    color: theme.colorScheme.onSurface,
                                  ),
                                ),
                              ),
                              Text(
                                'Tap to add',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: theme.colorScheme.onSurfaceVariant
                                      .withValues(alpha: 0.6),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: TextFormField(
        controller: widget.controller,
        focusNode: _focusNode,
        decoration: InputDecoration(
          labelText: widget.labelText,
          hintText: widget.hintText,
          border: const OutlineInputBorder(),
          prefixIcon: const Icon(Icons.label_outlined),
          suffixIcon: IconButton(
            icon: const Icon(Icons.sell_outlined),
            tooltip: 'Browse existing tags',
            onPressed: _openBrowseTags,
          ),
        ),
      ),
    );
  }
}
