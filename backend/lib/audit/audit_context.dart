import 'package:fitman_common/fitman_common.dart';
import 'package:shelf/shelf.dart';

import '../middleware/request_context.dart';

/// Явный контекст актора для записи аудита.
///
/// Передаётся из контроллера в сервис и репозиторий; не вычисляется
/// из общего соединения с БД.
class AuditContext {
  const AuditContext({
    this.actorId,
    this.actorRole,
    this.requestId,
    this.source = 'api',
  });

  final String? actorId;
  final String? actorRole;
  final String? requestId;
  final String source;

  factory AuditContext.fromRequest(Request request, {required User? user}) {
    return AuditContext(
      actorId: user?.id,
      actorRole: user == null
          ? null
          : user.roles.map((role) => role.name).join(','),
      requestId: RequestContext.of(request)?.requestId,
      source: 'api',
    );
  }

  factory AuditContext.system({String? requestId}) {
    return AuditContext(requestId: requestId, source: 'system');
  }
}
