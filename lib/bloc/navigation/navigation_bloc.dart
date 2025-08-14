import 'package:flutter_bloc/flutter_bloc.dart';
import 'navigation_event.dart';
import 'navigation_state.dart';

class NavigationBloc extends Bloc<NavigationEvent, NavigationState> {
  NavigationBloc() : super(const NavigationState.initial()) {
    on<TabChanged>(_onTabChanged);
    on<SearchToggled>(_onSearchToggled);
    on<SearchCleared>(_onSearchCleared);
  }

  void _onTabChanged(TabChanged event, Emitter<NavigationState> emit) {
    emit(state.copyWith(
      selectedIndex: event.selectedIndex,
      isSearching: false,
    ));
  }

  void _onSearchToggled(SearchToggled event, Emitter<NavigationState> emit) {
    emit(state.copyWith(isSearching: !state.isSearching));
  }

  void _onSearchCleared(SearchCleared event, Emitter<NavigationState> emit) {
    emit(state.copyWith(isSearching: false));
  }
}
