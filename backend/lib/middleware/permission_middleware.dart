import 'dart:convert';

import 'package:fitman_backend/security/access_policy.dart';
import 'package:fitman_common/fitman_common.dart';
import 'package:shelf/shelf.dart';

/// Пропускает запрос только при наличии права у текущего пользователя.
///
/// Используется после `requireAuth()`: пользователь уже лежит в
/// `request.context['user']`.
Middleware requirePermission(String permission) {
  return (Handler innerHandler) {
    return (Request request) {
      final user = request.context['user'] as User?;
      if (user == null) {
        return Response(
          401,
          body: jsonEncode({'error': 'Требуется авторизация'}),
          headers: {'Content-Type': 'application/json'},
        );
      }
      if (!AccessPolicy.allows(user, permission)) {
        return Response.forbidden(
          jsonEncode({'error': 'Недостаточно прав'}),
          headers: {'Content-Type': 'application/json'},
        );
      }
      return innerHandler(request);
    };
  };
}
