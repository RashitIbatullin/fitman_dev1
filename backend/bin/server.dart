import 'dart:io';

import 'package:fitman_backend/config/app_config.dart';
import 'package:fitman_backend/config/database.dart';
import 'package:fitman_backend/middleware/cors_middleware.dart';
import 'package:fitman_backend/routes/router.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as io;
import 'package:shelf_helmet/shelf_helmet.dart';
import 'package:shelf_static/shelf_static.dart';
import 'package:path/path.dart' as p;
import 'package:shelf_router/shelf_router.dart';

void main(List<String> args) async {
  // Конфигурация теперь загружается лениво при первом вызове AppConfig.instance
  
  // Формируем абсолютный путь к директории uploads
  final uploadPath = p.normalize(p.join(Directory.current.path, '..', 'uploads'));


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
      .addMiddleware(helmet())
      .addMiddleware(corsMiddleware())
      .addMiddleware(logRequests())
      .addHandler(cascade.handler);

  // Запускаем сервер
  final server = await io.serve(
      handler,
      AppConfig.instance.serverHost,
      AppConfig.instance.serverPort
  );

  print('🚀 FitMan Dart backend MVP2 running on http://${server.address.host}:${server.port}');

  // Обработка graceful shutdown
  ProcessSignal.sigint.watch().listen((_) async {
    print('\n🛑 Shutting down server...');
    await server.close();
    await Database().disconnect();
    exit(0);
  });
}