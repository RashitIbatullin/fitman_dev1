import 'dart:convert';
import 'dart:io';

import 'package:fitman_backend/errors/app_exception.dart';
import 'package:fitman_backend/logging/app_logger.dart';
import 'package:fitman_backend/logging/log_config.dart';
import 'package:fitman_backend/middleware/access_log_middleware.dart';
import 'package:fitman_backend/middleware/error_handler_middleware.dart';
import 'package:fitman_backend/middleware/request_context.dart';
import 'package:fitman_backend/middleware/request_id_middleware.dart';
import 'package:path/path.dart' as p;
import 'package:shelf/shelf.dart';
import 'package:test/test.dart';

void main() {
  late Directory tempDir;

  Handler pipeline(Handler inner) {
    return const Pipeline()
        .addMiddleware(requestIdMiddleware())
        .addMiddleware(accessLogMiddleware())
        .addMiddleware(errorHandlerMiddleware())
        .addHandler(inner);
  }

  Request request([String path = '/api/test']) {
    return Request('GET', Uri.parse('http://localhost$path'));
  }

  String readLog() {
    final files = tempDir
        .listSync()
        .whereType<File>()
        .where((file) => p.basename(file.path).startsWith('fitman_backend_'))
        .toList();
    expect(files, isNotEmpty);
    return files.first.readAsStringSync();
  }

  List<Map<String, dynamic>> readEntries() {
    return readLog()
        .trim()
        .split('\n')
        .where((line) => line.isNotEmpty)
        .map((line) => jsonDecode(line) as Map<String, dynamic>)
        .toList();
  }

  setUp(() {
    tempDir = Directory.systemTemp.createTempSync('fitman_middleware_test_');
    AppLogger.instance.configure(
      LogConfig(
        level: AppLogLevel.debug,
        directory: tempDir.path,
        format: AppLogFormat.json,
        retentionDays: 30,
        enableConsole: false,
        enableFile: true,
      ),
    );
  });

  tearDown(() async {
    await AppLogger.instance.close();
    if (tempDir.existsSync()) {
      tempDir.deleteSync(recursive: true);
    }
  });

  test('генерирует request_id, кладёт его в контекст и возвращает в ответе',
      () async {
    String? contextRequestId;
    final handler = pipeline((req) {
      contextRequestId = RequestContext.of(req)?.requestId;
      return Response.ok('ok');
    });

    final response = await handler(request());
    final headerRequestId = response.headers['x-request-id'];

    expect(contextRequestId, isNotNull);
    expect(contextRequestId, isNotEmpty);
    expect(headerRequestId, contextRequestId);
  });

  test('принимает валидный X-Request-ID клиента', () async {
    final handler = pipeline((_) => Response.ok('ok'));
    final response = await handler(
      Request(
        'GET',
        Uri.parse('http://localhost/api/test'),
        headers: {'X-Request-ID': 'client-request-123'},
      ),
    );

    expect(response.headers['x-request-id'], 'client-request-123');
  });

  test('5xx не раскрывает внутренние детали, логирует stack и request_id',
      () async {
    const secret = 'relation "users" does not exist';
    final handler = pipeline((_) {
      throw StateError(secret);
    });

    final response = await handler(request('/api/broken'));
    final body = await response.readAsString();
    final payload = jsonDecode(body) as Map<String, dynamic>;
    final error = payload['error'] as Map<String, dynamic>;
    final requestId = response.headers['x-request-id'];

    expect(response.statusCode, 500);
    expect(error['code'], ErrorCodes.internal);
    expect(error['message'], 'Внутренняя ошибка сервера');
    expect(error['requestId'], requestId);
    expect(body, isNot(contains(secret)));
    expect(body, isNot(contains('StateError')));

    final entries = readEntries();
    final errorEntry = entries.firstWhere((e) => e['level'] == 'ERROR');
    expect(errorEntry['request_id'], requestId);
    expect(errorEntry['stack'], contains('request_pipeline_test'));
    expect(errorEntry['error'], contains(secret));

    final accessEntry = entries.firstWhere((e) => e['status'] == 500);
    expect(accessEntry['request_id'], requestId);
    expect(accessEntry['method'], 'GET');
    expect(accessEntry['duration_ms'], isA<int>());
  });

  test('AppException отдаётся по контракту с кодом и статусом', () async {
    final handler = pipeline((_) {
      throw const ConflictException('Занятие пересекается по времени');
    });

    final response = await handler(request('/api/lessons'));
    final payload = jsonDecode(await response.readAsString())
        as Map<String, dynamic>;
    final error = payload['error'] as Map<String, dynamic>;

    expect(response.statusCode, 409);
    expect(error['code'], ErrorCodes.conflict);
    expect(error['message'], 'Занятие пересекается по времени');
    expect(error['requestId'], response.headers['x-request-id']);
  });

  test('access-log пишет method, route, status, duration и request_id',
      () async {
    final handler = pipeline((_) => Response.ok('ok'));

    final response = await handler(request('/api/health'));
    final entries = readEntries();
    final accessEntry = entries.singleWhere((e) => e['status'] == 200);

    expect(accessEntry['request_id'], response.headers['x-request-id']);
    expect(accessEntry['method'], 'GET');
    expect(accessEntry['route'], '/api/health');
    expect(accessEntry['duration_ms'], isA<int>());
  });
}
