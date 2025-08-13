import 'package:equatable/equatable.dart';

/// Abstract base class for all navigation events
/// Used to trigger navigation state changes
abstract class NavigationEvent extends Equatable {
  const NavigationEvent();

  @override
  List<Object> get props => [];
}

/// Event triggered when a bottom navigation tab is tapped
/// Contains the index of the selected tab
class TabChanged extends NavigationEvent {
  final int selectedIndex;

  const TabChanged(this.selectedIndex);

  @override
  List<Object> get props => [selectedIndex];
}

/// Event triggered to toggle the search mode on/off
class SearchToggled extends NavigationEvent {
  const SearchToggled();
}

/// Event triggered to clear the search and reset search mode
class SearchCleared extends NavigationEvent {
  const SearchCleared();
}
