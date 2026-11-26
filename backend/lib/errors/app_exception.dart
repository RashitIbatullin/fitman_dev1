/// Стабильные машинные коды ошибок.
class ErrorCodes {
  const ErrorCodes._();

  static const String validation = 'VALIDATION_ERROR';
  static const String unauthorized = 'UNAUTHORIZED';
  static const String forbidden = 'FORBIDDEN';
  static const String notFound = 'NOT_FOUND';
  static const String conflict = 'CONFLICT';
  static const String internal = 'INTERNAL_ERROR';
}

/// Базовое исключение приложения.
///
/// [message] — безопасный текст для клиента: без SQL, стека и имён таблиц.
/// Внутренние детали передаются через [cause] и попадают только в лог.
abstract class AppException implements Exception {
  const AppException({
    required this.code,
    required this.message,
    required this.statusCode,
    this.cause,
    this.stackTrace,
  });

  final String code;
  final String message;
  final int statusCode;
  final Object? cause;
  final StackTrace? stackTrace;

  /// Преобразует любое исключение в [AppException].
  ///
  /// Неизвестные ошибки считаются внутренними: их текст не должен попасть
  /// в ответ клиенту.
  static AppException from(Object error, [StackTrace? stackTrace]) {
    if (error is AppException) {
      return error;
    }
    return InternalException(cause: error, stackTrace: stackTrace);
  }

  @override
  String toString() => '$runtimeType($code): $message';
}

/// Ошибка валидации входных данных (400).
class ValidationException extends AppException {
  const ValidationException(
    String message, {
    String code = ErrorCodes.validation,
    Object? cause,
    StackTrace? stackTrace,
  }) : super(
          code: code,
          message: message,
          statusCode: 400,
          cause: cause,
          stackTrace: stackTrace,
        );
}

/// Требуется аутентификация (401).
class UnauthorizedException extends AppException {
  const UnauthorizedException(
    String message, {
    String code = ErrorCodes.unauthorized,
    Object? cause,
    StackTrace? stackTrace,
  }) : super(
          code: code,
          message: message,
          statusCode: 401,
          cause: cause,
          stackTrace: stackTrace,
        );
}

/// Недостаточно прав (403).
class ForbiddenException extends AppException {
  const ForbiddenException(
    String message, {
    String code = ErrorCodes.forbidden,
    Object? cause,
    StackTrace? stackTrace,
  }) : super(
          code: code,
          message: message,
          statusCode: 403,
          cause: cause,
          stackTrace: stackTrace,
        );
}

/// Ресурс не найден (404).
class NotFoundException extends AppException {
  const NotFoundException(
    String message, {
    String code = ErrorCodes.notFound,
    Object? cause,
    StackTrace? stackTrace,
  }) : super(
          code: code,
          message: message,
          statusCode: 404,
          cause: cause,
          stackTrace: stackTrace,
        );
}

/// Конфликт состояния (409).
class ConflictException extends AppException {
  const ConflictException(
    String message, {
    String code = ErrorCodes.conflict,
    Object? cause,
    StackTrace? stackTrace,
  }) : super(
          code: code,
          message: message,
          statusCode: 409,
          cause: cause,
          stackTrace: stackTrace,
        );
}

/// Внутренняя ошибка сервера (500).
///
/// Клиент всегда получает общий текст; [cause] и [stackTrace] пишутся в лог.
class InternalException extends AppException {
  InternalException({
    Object? cause,
    StackTrace? stackTrace,
  }) : super(
          code: ErrorCodes.internal,
          message: 'Внутренняя ошибка сервера',
          statusCode: 500,
          cause: cause,
          stackTrace: stackTrace,
        );
}
