import 'package:dart_frog/dart_frog.dart';
import 'package:fitman_backend/middleware/cors_middleware.dart';

Handler middleware(Handler handler) {
  // Apply CORS middleware globally.
  // Auth middleware should be applied on a per-route basis.
  return handler.use(fromShelfMiddleware(corsMiddleware()));
}
