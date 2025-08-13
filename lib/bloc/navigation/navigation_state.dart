import 'package:equatable/equatable.dart';

/// Represents the state of the navigation system
/// Contains information about selected tab and search mode
class NavigationState extends Equatable {
  final int selectedIndex;
  final bool isSearching;

  const NavigationState({
    required this.selectedIndex,
    required this.isSearching,
  });

  /// Initial state with first tab selected and search disabled
  const NavigationState.initial()
      : selectedIndex = 0,
        isSearching = false;

  /// Creates a copy of the current state with updated values
  NavigationState copyWith({
    int? selectedIndex,
    bool? isSearching,
  }) {
    return NavigationState(
      selectedIndex: selectedIndex ?? this.selectedIndex,
      isSearching: isSearching ?? this.isSearching,
    );
  }

  @override
  List<Object> get props => [selectedIndex, isSearching];
}
