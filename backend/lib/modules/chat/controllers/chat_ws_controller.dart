import 'package:shelf/shelf.dart';
import 'package:shelf_web_socket/shelf_web_socket.dart';
import '../../../services/chat/chat_service.dart';

class ChatWsController {
  static Handler get handler {
    return (Request request) {
      final user = request.context['user'] as Map<String, dynamic>?;
      final userId = user?['userId'] as String?;

      if (userId == null) {
        // This should technically not be reached if requireAuth middleware is used
        return Response.forbidden('Authentication failed.');
      }

      final handler = webSocketHandler((webSocket) {
        ChatService.instance.handleConnection(userId, webSocket);
      });
      
      return handler(request);
    };
  }
}
