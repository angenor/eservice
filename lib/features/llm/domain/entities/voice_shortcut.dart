import 'package:equatable/equatable.dart';

class VoiceShortcut extends Equatable {
  final String id;
  final String userId;
  final String name;
  final String phrase;
  final Map<String, dynamic> orderData;
  final bool isActive;
  final DateTime createdAt;
  final int usageCount;
  
  const VoiceShortcut({
    required this.id,
    required this.userId,
    required this.name,
    required this.phrase,
    required this.orderData,
    required this.isActive,
    required this.createdAt,
    required this.usageCount,
  });
  
  @override
  List<Object?> get props => [
    id,
    userId,
    name,
    phrase,
    orderData,
    isActive,
    createdAt,
    usageCount,
  ];
}