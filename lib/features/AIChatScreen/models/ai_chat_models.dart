enum ChatSender { ai, user }

class ChatMessage {
  const ChatMessage({
    required this.text,
    required this.sender,
    required this.timestamp,
  });

  final String text;
  final ChatSender sender;
  final String timestamp;
}
