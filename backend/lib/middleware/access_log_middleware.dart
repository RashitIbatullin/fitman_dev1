import 'package:shelf/shelf.dart';

import '../logging/app_logger.dart';
import 'request_context.dart';

/// Пишет одну запись на каждый HTTP-запрос.
///
/// Query-параметры не логируются: в них могут оказаться токены.
Middleware accessLogMiddleware() {
  return (Handler innerHandler) {
    return (Request request) async {
      final stopwatch = Stopwatch()..start();
      final context = RequestContext.of(request);
      final path = request.requestedUri.path;

      try {
        final response = await innerHandler(request);
        stopwatch.stop();

        appLog.info(
          'HTTP ${request.method} $path',
          fields: {
            'method': request.method,
            'route': context?.route ?? path,
            'status': response.statusCode,
            'duration_ms': stopwatch.elapsedMilliseconds,
            if (context != null) ...context.toLogFields(),
          },
        );

        return response;
      } catch (error, stackTrace) {
        stopwatch.stop();
        appLog.error(
          'HTTP ${request.method} $path завершился исключением',
          fields: {
            'method': request.method,
            'route': context?.route ?? path,
            'duration_ms': stopwatch.elapsedMilliseconds,
            if (context != null) ...context.toLogFields(),
          },
          error: error,
          stackTrace: stackTrace,
        );
        rethrow;
      }
    };
  };
}
