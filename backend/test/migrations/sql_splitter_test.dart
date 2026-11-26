import 'package:fitman_backend/migrations/sql_splitter.dart';
import 'package:test/test.dart';

void main() {
  test('разделяет инструкции по точке с запятой', () {
    final statements = splitSqlStatements('''
      CREATE TABLE a (id int);
      CREATE INDEX idx_a ON a (id);
    ''');

    expect(statements, hasLength(2));
    expect(statements.first, startsWith('CREATE TABLE a'));
  });

  test('не делит тело plpgsql-функции в dollar quotes', () {
    final statements = splitSqlStatements('''
      CREATE OR REPLACE FUNCTION f() RETURNS trigger AS \$\$
      BEGIN
        RAISE EXCEPTION 'no';
      END;
      \$\$ LANGUAGE plpgsql;

      CREATE TRIGGER t BEFORE UPDATE ON a
        FOR EACH ROW EXECUTE FUNCTION f();
    ''');

    expect(statements, hasLength(2));
    expect(statements.first, contains('RAISE EXCEPTION'));
    expect(statements.first, contains('END;'));
    expect(statements.last, startsWith('CREATE TRIGGER'));
  });

  test('не делит точку с запятой внутри строки и комментария', () {
    final statements = splitSqlStatements('''
      -- комментарий; не инструкция
      INSERT INTO a (value) VALUES ('a;b');
      /* блочный; комментарий */
      SELECT 1;
    ''');

    expect(statements, hasLength(2));
    expect(statements.first, contains("'a;b'"));
  });
}
