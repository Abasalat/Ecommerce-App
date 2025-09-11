import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../data/repositories/category_repository.dart';

class CategoryFilterWidget extends StatelessWidget {
  final List<CategoryItem> categories;
  final String selectedFilter;
  final Function(String) onFilterSelected;

  const CategoryFilterWidget({
    super.key,
    required this.categories,
    required this.selectedFilter,
    required this.onFilterSelected,
  });

  @override
  Widget build(BuildContext context) {
    // Create filter list with "All" at the beginning
    final filterItems = ['All', ...categories.map((cat) => cat.name)];

    return Container(
      height: 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: filterItems.length,
        itemBuilder: (context, index) {
          final filter = filterItems[index];
          final isSelected = filter == selectedFilter;

          return Container(
            margin: EdgeInsets.only(
              right: index == filterItems.length - 1 ? 0 : 12,
            ),
            child: _buildFilterChip(context, filter, isSelected),
          );
        },
      ),
    );
  }

  Widget _buildFilterChip(
    BuildContext context,
    String filter,
    bool isSelected,
  ) {
    return GestureDetector(
      onTap: () => onFilterSelected(filter),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primaryColor
              : Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(25),
          border: Border.all(
            color: isSelected
                ? AppColors.primaryColor
                : Theme.of(context).dividerColor,
            width: 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primaryColor.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : [],
        ),
        child: Center(
          child: Text(
            _formatFilterName(filter),
            style: TextStyle(
              color: isSelected
                  ? AppColors.textWhite
                  : Theme.of(context).textTheme.displayLarge?.color,
              fontSize: 14,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  String _formatFilterName(String filter) {
    if (filter == 'All') return filter;

    // Format category names like "beauty" -> "Beauty"
    return filter
        .split('-')
        .map(
          (word) => word.isNotEmpty
              ? '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}'
              : word,
        )
        .join(' ');
  }
}
