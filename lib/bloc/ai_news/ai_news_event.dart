import 'package:equatable/equatable.dart';

/// Abstract base class for all AI news-related events
abstract class AiNewsEvent extends Equatable {
  const AiNewsEvent();

  @override
  List<Object> get props => [];
}

/// Event to fetch fresh AI news from the API
class AiNewsFetched extends AiNewsEvent {
  const AiNewsFetched();
}

/// Event to refresh AI news by pulling latest data
class AiNewsRefreshed extends AiNewsEvent {
  const AiNewsRefreshed();
}
