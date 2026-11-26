import 'package:shelf/shelf.dart';

import '../errors/app_exception.dart';
import '../errors/error_response.dart';
import '../logging/app_logger.dart';
import 'request_context.dart';

/// Ловит необработанные исключения и отдаёт безопасный JSON.
///
/// 5xx логируются со стеком и `request_id`; клиент получает только
/// `{code, message, requestId}`.
Middleware errorHandlerMiddleware() {
  return (Handler innerHandler) {
    return (Request request) async {
      final context = RequestContext.of(request);
      final requestId = RequestContext.requestIdOf(request);
      final path = request.requestedUri.path;

      try {
        return await innerHandler(request);
      } catch (error, stackTrace) {
        final exception = AppException.from(error, stackTrace);
        final fields = <String, Object?>{
          'method': request.method,
          'route': context?.route ?? path,
          'status': exception.statusCode,
          'code': exception.code,
          if (context != null) ...context.toLogFields(),
        };

        if (exception.statusCode >= 500) {
          appLog.error(
            'Необработанная ошибка запроса',
            fields: fields,
            error: exception.cause ?? error,
            stackTrace: exception.stackTrace ?? stackTrace,
          );
        } else {
          appLog.warning('Ошибка запроса', fields: fields);
        }

        return appExceptionResponse(exception, requestId).change(
          headers: {
            requestIdHeader: requestId,
          },
        );
      }
    };
  };
}
