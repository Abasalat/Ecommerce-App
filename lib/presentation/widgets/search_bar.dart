// lib/presentation/widgets/enhanced_search_bar_widget.dart

import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class EnhancedSearchBarWidget extends StatefulWidget {
  final Function(String) onSearchChanged;
  final Function(List<String>) onFiltersChanged;
  final List<String> availableFilters;

  const EnhancedSearchBarWidget({
    super.key,
    required this.onSearchChanged,
    required this.onFiltersChanged,
    this.availableFilters = const [
      'Price: Low to High',
      'Price: High to Low',
      'Rating: High to Low',
      'Newest First',
      'Popular',
    ],
  });

  @override
  State<EnhancedSearchBarWidget> createState() =>
      _EnhancedSearchBarWidgetState();
}

class _EnhancedSearchBarWidgetState extends State<EnhancedSearchBarWidget>
    with SingleTickerProviderStateMixin {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _showFilters = false;
  List<String> _selectedFilters = [];
  late AnimationController _animationController;
  late Animation<double> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _slideAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _toggleFilters() {
    setState(() {
      _showFilters = !_showFilters;
    });
    if (_showFilters) {
      _animationController.forward();
      _focusNode.unfocus(); // Hide keyboard when filters open
    } else {
      _animationController.reverse();
    }
  }

  void _addFilter(String filter) {
    if (!_selectedFilters.contains(filter)) {
      setState(() {
        _selectedFilters.add(filter);
      });
      widget.onFiltersChanged(_selectedFilters);
    }
    _toggleFilters(); // Close filters after selection
  }

  void _removeFilter(String filter) {
    setState(() {
      _selectedFilters.remove(filter);
    });
    widget.onFiltersChanged(_selectedFilters);
  }

  void _clearAll() {
    setState(() {
      _controller.clear();
      _selectedFilters.clear();
    });
    widget.onSearchChanged('');
    widget.onFiltersChanged([]);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Search Bar with Integrated Filter Chips
        Container(
          margin: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Theme.of(context).dividerColor),
            boxShadow: [
              BoxShadow(
                color: AppColors.shadowColor.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              // Search Input Row
              Row(
                children: [
                  // Search Icon
                  Padding(
                    padding: const EdgeInsets.only(left: 16),
                    child: Icon(Icons.search, color: AppColors.primaryColor),
                  ),

                  // Search Input
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      focusNode: _focusNode,
                      onChanged: widget.onSearchChanged,
                      style: TextStyle(
                        color: Theme.of(context).textTheme.displayLarge?.color,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Search products...',
                        hintStyle: TextStyle(
                          color: Theme.of(context).textTheme.bodyMedium?.color,
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                      ),
                    ),
                  ),

                  // Action Buttons
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Clear button
                      if (_controller.text.isNotEmpty ||
                          _selectedFilters.isNotEmpty)
                        IconButton(
                          icon: Icon(
                            Icons.clear,
                            color: Theme.of(
                              context,
                            ).textTheme.bodyMedium?.color,
                            size: 20,
                          ),
                          onPressed: _clearAll,
                        ),
                      // Filter button
                      IconButton(
                        icon: Icon(
                          Icons.tune,
                          color: _showFilters
                              ? AppColors.primaryColor
                              : Theme.of(context).textTheme.bodyMedium?.color,
                        ),
                        onPressed: _toggleFilters,
                      ),
                    ],
                  ),
                ],
              ),

              // Selected Filters Chips (Inside Search Bar)
              if (_selectedFilters.isNotEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: _selectedFilters.map((filter) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primaryColor,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              filter,
                              style: TextStyle(
                                color: AppColors.textWhite,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 4),
                            GestureDetector(
                              onTap: () => _removeFilter(filter),
                              child: Icon(
                                Icons.close,
                                color: AppColors.textWhite,
                                size: 16,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
            ],
          ),
        ),

        // Animated Filter Panel
        AnimatedBuilder(
          animation: _slideAnimation,
          builder: (context, child) {
            return ClipRect(
              child: Align(
                alignment: Alignment.topCenter,
                heightFactor: _slideAnimation.value,
                child: child,
              ),
            );
          },
          child: Container(
            margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Theme.of(context).dividerColor),
              boxShadow: [
                BoxShadow(
                  color: AppColors.shadowColor.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Filters',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).textTheme.displayLarge?.color,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: widget.availableFilters.map((filter) {
                    final isSelected = _selectedFilters.contains(filter);
                    return GestureDetector(
                      onTap: () => _addFilter(filter),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.primaryColor.withOpacity(0.1)
                              : Colors.transparent,
                          border: Border.all(
                            color: isSelected
                                ? AppColors.primaryColor
                                : Theme.of(context).dividerColor,
                          ),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          filter,
                          style: TextStyle(
                            color: isSelected
                                ? AppColors.primaryColor
                                : Theme.of(
                                    context,
                                  ).textTheme.displayLarge?.color,
                            fontWeight: isSelected
                                ? FontWeight.w600
                                : FontWeight.normal,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
