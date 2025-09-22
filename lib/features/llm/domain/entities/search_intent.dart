import 'package:equatable/equatable.dart';

class SearchIntent extends Equatable {
  final String originalQuery;
  final String processedQuery;
  final SearchType type;
  final Map<String, dynamic> filters;
  final List<String> keywords;
  final double confidence;

  const SearchIntent({
    required this.originalQuery,
    required this.processedQuery,
    required this.type,
    required this.filters,
    required this.keywords,
    required this.confidence,
  });

  @override
  List<Object> get props => [
        originalQuery,
        processedQuery,
        type,
        filters,
        keywords,
        confidence,
      ];
}

enum SearchType {
  restaurant,
  dish,
  cuisine,
  nearMe,
  quickDelivery,
  budget,
  general,
}