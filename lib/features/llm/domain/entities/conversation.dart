import 'package:equatable/equatable.dart';
import 'llm_message.dart';

enum ConversationType {
  voice,
  chat,
  shortcut,
}

class LLMConversation extends Equatable {
  final String id;
  final String userId;
  final ConversationType type;
  final String? title;
  final Map<String, dynamic> context;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isActive;
  final List<LLMMessage> messages;
  
  const LLMConversation({
    required this.id,
    required this.userId,
    required this.type,
    this.title,
    required this.context,
    required this.createdAt,
    required this.updatedAt,
    required this.isActive,
    required this.messages,
  });
  
  @override
  List<Object?> get props => [
    id,
    userId,
    type,
    title,
    context,
    createdAt,
    updatedAt,
    isActive,
    messages,
  ];
}