import 'package:flutter_bloc/flutter_bloc.dart';
import 'navigation_event.dart';
import 'navigation_state.dart';

/// BLoC responsible for managing navigation state
/// Handles bottom navigation tab changes and search mode toggling
class NavigationBloc extends Bloc<NavigationEvent, NavigationState> {
  NavigationBloc() : super(const NavigationState.initial()) {
    // Register event handlers
    on<TabChanged>(_onTabChanged);
    on<SearchToggled>(_onSearchToggled);
    on<SearchCleared>(_onSearchCleared);
  }

  /// Handles tab change events
  /// Updates the selected index and disables search mode when changing tabs
  void _onTabChanged(TabChanged event, Emitter<NavigationState> emit) {
    emit(state.copyWith(
      selectedIndex: event.selectedIndex,
      isSearching: false, // Disable search when changing tabs
    ));
  }

  /// Handles search toggle events
  /// Toggles the search mode on/off
  void _onSearchToggled(SearchToggled event, Emitter<NavigationState> emit) {
    emit(state.copyWith(isSearching: !state.isSearching));
  }

  /// Handles search clear events
  /// Disables search mode and clears any search-related state
  void _onSearchCleared(SearchCleared event, Emitter<NavigationState> emit) {
    emit(state.copyWith(isSearching: false));
  }
}
