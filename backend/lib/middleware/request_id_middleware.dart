import 'package:shelf/shelf.dart';
import 'package:uuid/uuid.dart';

import '../errors/error_response.dart';
import 'request_context.dart';

final RegExp _requestIdPattern = RegExp(r'^[A-Za-z0-9._-]{8,128}$');
final Uuid _uuid = Uuid();

/// Принимает `X-Request-ID` клиента или генерирует UUID.
///
/// Идентификатор кладётся в `request.context` и возвращается в ответе.
Middleware requestIdMiddleware() {
  return (Handler innerHandler) {
    return (Request request) async {
      final incoming = request.headers[requestIdHeader.toLowerCase()];
      final requestId = incoming != null && _requestIdPattern.hasMatch(incoming)
          ? incoming
          : _uuid.v4();

      final context = RequestContext(requestId: requestId);
      final updatedRequest = request.change(
        context: {
          requestIdKey: requestId,
          requestContextKey: context,
        },
      );

      final response = await innerHandler(updatedRequest);
      return response.change(
        headers: {
          ...response.headers,
          requestIdHeader: requestId,
        },
      );
    };
  };
}
