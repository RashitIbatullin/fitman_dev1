import 'package:shelf/shelf.dart';

/// Ключ контекста запроса с [RequestContext].
const String requestContextKey = 'requestContext';

/// Ключ контекста запроса с идентификатором запроса.
const String requestIdKey = 'requestId';

/// Данные запроса, доступные middleware и логгеру.
class RequestContext {
  RequestContext({required this.requestId});

  final String requestId;

  /// Заполняется auth-middleware после проверки токена.
  String? userId;

  /// Заполняется auth-middleware после проверки токена.
  String? userRole;

  /// Шаблон маршрута; если не задан, используется путь запроса.
  String? route;

  static RequestContext? of(Request request) {
    return request.context[requestContextKey] as RequestContext?;
  }

  static String requestIdOf(Request request) {
    return request.context[requestIdKey] as String? ??
        of(request)?.requestId ??
        '-';
  }

  Map<String, Object?> toLogFields() {
    return {
      'request_id': requestId,
      if (userId != null) 'user_id': userId,
      if (userRole != null) 'role': userRole,
      if (route != null) 'route': route,
    };
  }
}
