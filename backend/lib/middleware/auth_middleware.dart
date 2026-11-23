import 'package:shelf/shelf.dart';
import '../controllers/auth_controller.dart';
import 'package:fitman_common/fitman_common.dart'; // Import User model
import '../logging/app_logger.dart';
import 'request_context.dart';

Middleware requireAuth() {
  return (Handler innerHandler) {
    return (Request request) async {
      String? token;

      // Check for token in Authorization header
      final authHeader = request.headers['authorization'];
      if (authHeader != null && authHeader.startsWith('Bearer ')) {
        token = authHeader.substring(7);
      }

      // If not in header, check query parameters (for WebSocket)
      token ??= request.requestedUri.queryParameters['token'];

      if (token == null) {
        return Response(401, body: '{"error": "Authentication required"}');
      }
      
      final payload = AuthController.verifyToken(token);

      if (payload == null) {
        return Response(401, body: '{"error": "Invalid or expired token"}');
      }

      final user = User.fromJwt(payload); // Convert payload to User object

      final requestContext = RequestContext.of(request);
      if (requestContext != null) {
        requestContext.userId = user.id;
        requestContext.userRole = user.roles.map((r) => r.name).join(',');
      }

      final updatedRequest = request.change(
          context: {'user': user} // Store User object in context
      );

      return innerHandler(updatedRequest);
    };
  };
}

Middleware requireRole(String role) {
  return (Handler innerHandler) {
    return (Request request) async {
      appLog.debug('Проверка роли', fields: {'role': role});
      final user = request.context['user'] as User?; // Now it's a User object

      if (user == null) {
        return Response(403, body: '{"error": "Insufficient permissions: User not authenticated"}');
      }

      final userRoleNames = user.roles.map((r) => r.name).toList(); // Access roles from User object
      appLog.debug('Роли пользователя', fields: {'roles': userRoleNames});

      if (!userRoleNames.contains(role)) { // Check if user has the required role name
        return Response(403, body: "{\"error\": \"Insufficient permissions: Role '$role' required\"}");
      }

      return innerHandler(request);
    };
  };
}