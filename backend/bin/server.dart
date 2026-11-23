import 'dart:io';

import 'package:fitman_backend/config/app_config.dart';
import 'package:fitman_backend/config/database.dart';
import 'package:fitman_backend/logging/app_logger.dart';
import 'package:fitman_backend/middleware/access_log_middleware.dart';
import 'package:fitman_backend/middleware/cors_middleware.dart';
import 'package:fitman_backend/middleware/error_handler_middleware.dart';
import 'package:fitman_backend/middleware/request_id_middleware.dart';
import 'package:fitman_backend/routes/router.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as io;
import 'package:shelf_helmet/shelf_helmet.dart';
import 'package:shelf_static/shelf_static.dart';
import 'package:path/path.dart' as path;
import 'package:shelf_router/shelf_router.dart';

Future<void> main(List<String> args) async {
  // Конфигурация загружается лениво при первом обращении; она же
  // настраивает AppLogger.
  final config = AppConfig.instance;

  // Формируем абсолютный путь к директории uploads
  final scriptPath = Platform.script.toFilePath(windows: Platform.isWindows);
  final projectRoot = path.normalize(path.join(path.dirname(scriptPath), '..', '..'));
  final uploadPath = path.join(projectRoot, 'uploads');


  // Создаем директорию для загрузок, если она не существует
  final uploadDir = Directory(uploadPath);
  if (!await uploadDir.exists()) {
    await uploadDir.create(recursive: true);
  }

  // Создаем router для статических файлов
  final staticRouter = Router();
  staticRouter.mount('/uploads/', createStaticHandler(uploadPath, listDirectories: false).call);

  // Создаем каскад для объединения роутеров
  final cascade = Cascade()
      .add(staticRouter.call) // Сначала проверяем статику
      .add(router.call);      // Потом API

  final handler = const Pipeline()
      .addMiddleware(requestIdMiddleware())
      .addMiddleware(accessLogMiddleware())
      .addMiddleware(errorHandlerMiddleware())
      .addMiddleware(helmet())
      .addMiddleware(corsMiddleware())
      .addHandler(cascade.handler);

  // Запускаем сервер
  final server = await io.serve(
    handler,
    config.serverHost,
    config.serverPort,
  );

  appLog.info(
    'FitMan backend запущен',
    fields: {
      'host': server.address.host,
      'port': server.port,
      'env': Platform.environment['DART_ENV'] ?? 'dev',
    },
  );

  // Обработка graceful shutdown
  ProcessSignal.sigint.watch().listen((_) async {
    appLog.info('Остановка сервера');
    await server.close();
    await Database().disconnect();
    await AppLogger.instance.close();
    exit(0);
  });
}