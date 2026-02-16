// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, implicit_dynamic_list_literal

import 'dart:io';

import 'package:dart_frog/dart_frog.dart';


import '../routes/api/chat/ws.dart' as api_chat_ws;
import '../routes/api/auth/login.dart' as api_auth_login;


void main() async {
  final address = InternetAddress.tryParse('') ?? InternetAddress.anyIPv6;
  final port = int.tryParse(Platform.environment['PORT'] ?? '8080') ?? 8080;
  hotReload(() => createServer(address, port));
}

Future<HttpServer> createServer(InternetAddress address, int port) {
  final handler = Cascade().add(buildRootHandler()).handler;
  return serve(handler, address, port);
}

Handler buildRootHandler() {
  final pipeline = const Pipeline();
  final router = Router()
    ..mount('/api/auth', (context) => buildApiAuthHandler()(context))
    ..mount('/api/chat', (context) => buildApiChatHandler()(context));
  return pipeline.addHandler(router);
}

Handler buildApiAuthHandler() {
  final pipeline = const Pipeline();
  final router = Router()
    ..all('/login', (context) => api_auth_login.onRequest(context,));
  return pipeline.addHandler(router);
}

Handler buildApiChatHandler() {
  final pipeline = const Pipeline();
  final router = Router()
    ..all('/ws', (context) => api_chat_ws.onRequest(context,));
  return pipeline.addHandler(router);
}

