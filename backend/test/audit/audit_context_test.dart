import 'package:fitman_backend/audit/audit_context.dart';
import 'package:fitman_backend/middleware/request_context.dart';
import 'package:fitman_common/fitman_common.dart';
import 'package:shelf/shelf.dart';
import 'package:test/test.dart';

void main() {
  test('system-контекст имеет источник system', () {
    final context = AuditContext.system(requestId: 'request-1');

    expect(context.actorId, isNull);
    expect(context.source, 'system');
    expect(context.requestId, 'request-1');
  });

  test('fromRequest берёт актора, роли и request_id из контекста', () {
    final requestContext = RequestContext(requestId: 'request-2');
    final request = Request(
      'POST',
      Uri.parse('http://localhost/api/rooms'),
      context: {requestContextKey: requestContext},
    );
    final user = User(
      id: 'user-1',
      passwordHash: '',
      firstName: 'Иван',
      lastName: 'Иванов',
      roles: [Role(id: 'role-1', name: 'admin', title: 'Администратор')],
      createdAt: DateTime(2026),
      updatedAt: DateTime(2026),
    );

    final audit = AuditContext.fromRequest(request, user: user);

    expect(audit.actorId, 'user-1');
    expect(audit.actorRole, 'admin');
    expect(audit.requestId, 'request-2');
    expect(audit.source, 'api');
  });

  test('fromRequest без пользователя оставляет актора пустым', () {
    final request = Request('POST', Uri.parse('http://localhost/api/rooms'));

    final audit = AuditContext.fromRequest(request, user: null);

    expect(audit.actorId, isNull);
    expect(audit.actorRole, isNull);
    expect(audit.requestId, isNull);
  });
}
