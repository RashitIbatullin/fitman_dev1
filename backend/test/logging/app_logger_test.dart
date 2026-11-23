import 'dart:convert';
import 'dart:io';

import 'package:fitman_backend/logging/app_logger.dart';
import 'package:fitman_backend/logging/log_config.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';

void main() {
  late Directory tempDir;
  late AppLogger logger;

  setUp(() {
    tempDir = Directory.systemTemp.createTempSync('fitman_logger_test_');
    logger = AppLogger.instance;
  });

  tearDown(() async {
    await logger.close();
    if (tempDir.existsSync()) {
      tempDir.deleteSync(recursive: true);
    }
  });

  LogConfig config({
    AppLogLevel level = AppLogLevel.debug,
    AppLogFormat format = AppLogFormat.json,
    int retentionDays = 30,
    int maxFileSizeBytes = 50 * 1024 * 1024,
  }) {
    return LogConfig(
      level: level,
      directory: tempDir.path,
      format: format,
      retentionDays: retentionDays,
      maxFileSizeBytes: maxFileSizeBytes,
      enableConsole: false,
      enableFile: true,
    );
  }

  File currentLogFile() {
    final files = tempDir
        .listSync()
        .whereType<File>()
        .where((file) => p.basename(file.path).startsWith('fitman_backend_'))
        .toList()
      ..sort((a, b) => a.path.compareTo(b.path));
    expect(files, isNotEmpty);
    return files.first;
  }

  test('пишет JSON в суточный файл fitman_backend_YYYY_MM_DD.log и маскирует ПДн',
      () {
    logger.configure(config());
    logger.info(
      'Тестовое сообщение',
      fields: {
        'request_id': 'req-1',
        'user_id': 'user-1',
        'phone': '+79990000000',
        'email': 'client@example.com',
      },
    );
    logger.flush();

    final file = currentLogFile();
    expect(
      p.basename(file.path),
      matches(RegExp(r'^fitman_backend_\d{4}_\d{2}_\d{2}\.log$')),
    );

    final entry = jsonDecode(
      file.readAsLinesSync().single,
    ) as Map<String, dynamic>;

    expect(entry['level'], 'INFO');
    expect(entry['msg'], 'Тестовое сообщение');
    expect(entry['request_id'], 'req-1');
    expect(entry['user_id'], 'user-1');
    expect(entry['phone'], '***');
    expect(entry['email'], '***');
    expect(entry['ts'], isA<String>());
  });

  test('уровень из конфига отсекает записи ниже порога', () {
    logger.configure(config(level: AppLogLevel.warning, format: AppLogFormat.text));

    logger.info('Это не должно попасть в файл');
    logger.warning('Предупреждение');
    logger.flush();

    final text = currentLogFile().readAsStringSync();
    expect(text, isNot(contains('Это не должно попасть в файл')));
    expect(text, contains('WARNING'));
    expect(text, contains('Предупреждение'));
  });

  test('ретеншн удаляет старые файлы и оставляет свежие', () {
    final oldFile = File(p.join(tempDir.path, 'fitman_backend_2020_01_01.log'))
      ..writeAsStringSync('old\n');
    final freshFile = File(p.join(tempDir.path, 'fitman_backend_2999_01_01.log'))
      ..writeAsStringSync('fresh\n');

    logger.configure(config(retentionDays: 1));

    expect(oldFile.existsSync(), isFalse);
    expect(freshFile.existsSync(), isTrue);
  });

  test('ротация по размеру создаёт fitman_backend_YYYY_MM_DD.1.log', () {
    logger.configure(config(maxFileSizeBytes: 80));

    final payload = List.filled(100, 'x').join();
    for (var i = 0; i < 4; i++) {
      logger.info('Запись $i', fields: {'payload': payload});
    }
    logger.flush();

    final rotated = tempDir.listSync().whereType<File>().where(
          (file) => RegExp(r'fitman_backend_\d{4}_\d{2}_\d{2}\.1\.log$')
              .hasMatch(p.basename(file.path)),
        );
    expect(rotated, isNotEmpty);
  });
}
