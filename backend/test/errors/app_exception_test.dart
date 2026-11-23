import 'package:fitman_backend/errors/app_exception.dart';
import 'package:test/test.dart';

void main() {
  test('InternalException не раскрывает причину в message', () {
    final exception = InternalException(
      cause: StateError('SQL: SELECT * FROM users'),
    );

    expect(exception.statusCode, 500);
    expect(exception.message, 'Внутренняя ошибка сервера');
    expect(exception.message, isNot(contains('SELECT')));
    expect(exception.cause, isA<StateError>());
  });

  test('AppException.from оборачивает неизвестную ошибку во внутреннюю', () {
    final exception = AppException.from(StateError('boom'));

    expect(exception, isA<InternalException>());
    expect(exception.statusCode, 500);
    expect(exception.code, ErrorCodes.internal);
  });

  test('AppException.from сохраняет известную ошибку', () {
    const original = ValidationException('Некорректный email');
    final result = AppException.from(original);

    expect(identical(result, original), isTrue);
    expect(result.statusCode, 400);
    expect(result.code, ErrorCodes.validation);
  });
}
