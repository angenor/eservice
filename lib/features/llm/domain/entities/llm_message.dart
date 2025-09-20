import 'package:equatable/equatable.dart';

enum MessageRole {
  user,
  assistant,
  system,
}

enum MessageType {
  text,
  voice,
  orderIntent,
}

class ExtractedData extends Equatable {
  final String id;
  final String messageId;
  final String type;
  final String value;
  final double confidence;
  final Map<String, dynamic>? additionalInfo;
  
  const ExtractedData({
    required this.id,
    required this.messageId,
    required this.type,
    required this.value,
    required this.confidence,
    this.additionalInfo,
  });
  
  @override
  List<Object?> get props => [
    id,
    messageId,
    type,
    value,
    confidence,
    additionalInfo,
  ];
}

class LLMMessage extends Equatable {
  final String id;
  final String conversationId;
  final MessageRole role;
  final String content;
  final MessageType type;
  final Map<String, dynamic>? metadata;
  final DateTime timestamp;
  final ExtractedData? extractedData;
  
  const LLMMessage({
    required this.id,
    required this.conversationId,
    required this.role,
    required this.content,
    required this.type,
    this.metadata,
    required this.timestamp,
    this.extractedData,
  });
  
  @override
  List<Object?> get props => [
    id,
    conversationId,
    role,
    content,
    type,
    metadata,
    timestamp,
    extractedData,
  ];
}