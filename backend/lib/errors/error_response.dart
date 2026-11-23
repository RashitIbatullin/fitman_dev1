import 'dart:convert';

import 'package:shelf/shelf.dart';

import 'app_exception.dart';

/// Заголовок с идентификатором запроса.
const String requestIdHeader = 'X-Request-ID';

/// Формирует безопасный ответ об ошибке по контракту
/// `{"error":{"code","message","requestId"}}`.
Response appExceptionResponse(AppException exception, String requestId) {
  final isServerError = exception.statusCode >= 500;
  final message = isServerError || exception.message.isEmpty
      ? 'Внутренняя ошибка сервера'
      : exception.message;

  return Response(
    exception.statusCode,
    body: jsonEncode({
      'error': {
        'code': exception.code,
        'message': message,
        'requestId': requestId,
      },
    }),
    headers: {
      'content-type': 'application/json; charset=utf-8',
      requestIdHeader: requestId,
    },
  );
}
