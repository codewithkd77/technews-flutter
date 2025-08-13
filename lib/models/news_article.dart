import 'package:equatable/equatable.dart';

/// Data model representing a news article
/// Contains all the properties needed to display and manage news articles
class NewsArticle extends Equatable {
  final String title;
  final String? description;
  final String? content;
  final String? imageUrl;
  final String? source;
  final String? url;
  final String? createdAt;

  const NewsArticle({
    required this.title,
    this.description,
    this.content,
    this.imageUrl,
    this.source,
    this.url,
    this.createdAt,
  });

  /// Factory constructor to create NewsArticle from JSON
  factory NewsArticle.fromJson(Map<String, dynamic> json) {
    return NewsArticle(
      title: json['title'] ?? '',
      description: json['description'],
      content: json['content'],
      imageUrl: json['imageUrl'],
      source: json['source'],
      url: json['url'],
      createdAt: json['createdAt'],
    );
  }

  /// Convert NewsArticle to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'content': content,
      'imageUrl': imageUrl,
      'source': source,
      'url': url,
      'createdAt': createdAt,
    };
  }

  /// Create a copy of NewsArticle with updated fields
  NewsArticle copyWith({
    String? title,
    String? description,
    String? content,
    String? imageUrl,
    String? source,
    String? url,
    String? createdAt,
  }) {
    return NewsArticle(
      title: title ?? this.title,
      description: description ?? this.description,
      content: content ?? this.content,
      imageUrl: imageUrl ?? this.imageUrl,
      source: source ?? this.source,
      url: url ?? this.url,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [
        title,
        description,
        content,
        imageUrl,
        source,
        url,
        createdAt,
      ];
}
