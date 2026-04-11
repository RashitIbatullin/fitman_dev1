import 'package:shelf/shelf.dart';
import 'package:shelf_web_socket/shelf_web_socket.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import '../../../services/chat/chat_service.dart';

class ChatWsController {
  static Handler get handler {
    return (Request request) {
      final token = request.requestedUri.queryParameters['token'];
      if (token == null) {
        return Response.forbidden('Missing authentication token.');
      }

      try {
        final decodedToken = JwtDecoder.decode(token);
        final userId = decodedToken['userId'];
        if (userId == null) {
          return Response.forbidden('Invalid token: missing userId.');
        }

        final handler = webSocketHandler((webSocket) {
          ChatService.instance.handleConnection(userId as String, webSocket);
        });
        
        return handler(request);

      } catch (e) {
        return Response.forbidden('Invalid authentication token.');
      }
    };
  }
}
