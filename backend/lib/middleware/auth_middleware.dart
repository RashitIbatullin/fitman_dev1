import 'package:shelf/shelf.dart';
import '../controllers/auth_controller.dart';

Middleware requireAuth() {
  return (Handler innerHandler) {
    return (Request request) async {
      final authHeader = request.headers['authorization'];

      if (authHeader == null || !authHeader.startsWith('Bearer ')) {
        return Response(401, body: '{"error": "Authentication required"}');
      }

      final token = authHeader.substring(7);
      final payload = AuthController.verifyToken(token);

      print('Backend received token payload: $payload'); // Debug print

      if (payload == null) {
        return Response(401, body: '{"error": "Invalid or expired token"}');
      }

      final updatedRequest = request.change(
          context: {'user': payload}
      );

      return innerHandler(updatedRequest);
    };
  };
}

Middleware requireRole(String role) {
  return (Handler innerHandler) {
    return (Request request) async {
      print('Backend checking role: $role'); // Debug print
      final user = request.context['user'] as Map<String, dynamic>?;

      if (user == null) {
        return Response(403, body: '{"error": "Insufficient permissions: User not authenticated"}');
      }

      final userRoles = user['roles'] as List<dynamic>?;
      print('User roles from payload: $userRoles'); // Debug print

      if (userRoles == null || !userRoles.contains(role)) {
        return Response(403, body: '{"error": "Insufficient permissions: Role \'$role\' required"}');
      }

      return innerHandler(request);
    };
  };
}