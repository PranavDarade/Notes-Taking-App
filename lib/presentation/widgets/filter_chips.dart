import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum FilterType {
  all,
  pinned,
  favorites,
  locked,
  recent,
}

class FilterChips extends ConsumerStatefulWidget {
  const FilterChips({super.key});

  @override
  ConsumerState<FilterChips> createState() => _FilterChipsState();
}

class _FilterChipsState extends ConsumerState<FilterChips> {
  FilterType _selectedFilter = FilterType.all;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: FilterType.values.map((filter) {
          final isSelected = _selectedFilter == filter;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(_getFilterLabel(filter)),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  _selectedFilter = filter;
                });
                // TODO: Implement filter logic
              },
              selectedColor: theme.colorScheme.primaryContainer,
              checkmarkColor: theme.colorScheme.onPrimaryContainer,
              backgroundColor: theme.colorScheme.surface,
              labelStyle: TextStyle(
                color: isSelected 
                    ? theme.colorScheme.onPrimaryContainer
                    : theme.colorScheme.onSurface,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  String _getFilterLabel(FilterType filter) {
    switch (filter) {
      case FilterType.all:
        return 'All';
      case FilterType.pinned:
        return 'Pinned';
      case FilterType.favorites:
        return 'Favorites';
      case FilterType.locked:
        return 'Locked';
      case FilterType.recent:
        return 'Recent';
    }
  }
}
