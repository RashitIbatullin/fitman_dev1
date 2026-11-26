/// Разбивает SQL-файл миграции на отдельные инструкции.
///
/// Учитывает строки, кавычки, комментарии и dollar-quoted блоки
/// (`$$ ... $$` / `$tag$ ... $tag$`), внутри которых `;` не является
/// разделителем.
List<String> splitSqlStatements(String sql) {
  final statements = <String>[];
  final buffer = StringBuffer();

  var inSingleQuote = false;
  var inDoubleQuote = false;
  var inLineComment = false;
  var inBlockComment = false;
  String? dollarTag;
  var index = 0;

  void flush() {
    final statement = buffer.toString().trim();
    if (statement.isNotEmpty) {
      statements.add(statement);
    }
    buffer.clear();
  }

  while (index < sql.length) {
    final char = sql[index];

    if (inLineComment) {
      buffer.write(char);
      if (char == '\n') {
        inLineComment = false;
      }
      index++;
      continue;
    }

    if (inBlockComment) {
      if (char == '*' &&
          index + 1 < sql.length &&
          sql[index + 1] == '/') {
        buffer.write('*/');
        index += 2;
        inBlockComment = false;
      } else {
        buffer.write(char);
        index++;
      }
      continue;
    }

    if (dollarTag != null) {
      if (sql.startsWith(dollarTag, index)) {
        buffer.write(dollarTag);
        index += dollarTag.length;
        dollarTag = null;
      } else {
        buffer.write(char);
        index++;
      }
      continue;
    }

    if (inSingleQuote) {
      buffer.write(char);
      if (char == "'") {
        if (index + 1 < sql.length && sql[index + 1] == "'") {
          buffer.write("'");
          index += 2;
        } else {
          inSingleQuote = false;
          index++;
        }
      } else {
        index++;
      }
      continue;
    }

    if (inDoubleQuote) {
      buffer.write(char);
      if (char == '"') {
        inDoubleQuote = false;
      }
      index++;
      continue;
    }

    if (char == '-' && index + 1 < sql.length && sql[index + 1] == '-') {
      buffer.write('--');
      inLineComment = true;
      index += 2;
      continue;
    }

    if (char == '/' && index + 1 < sql.length && sql[index + 1] == '*') {
      buffer.write('/*');
      inBlockComment = true;
      index += 2;
      continue;
    }

    if (char == "'") {
      buffer.write(char);
      inSingleQuote = true;
      index++;
      continue;
    }

    if (char == '"') {
      buffer.write(char);
      inDoubleQuote = true;
      index++;
      continue;
    }

    if (char == r'$') {
      final match =
          RegExp(r'^\$[A-Za-z0-9_]*\$').firstMatch(sql.substring(index));
      if (match != null) {
        dollarTag = match.group(0);
        buffer.write(dollarTag);
        index += dollarTag!.length;
        continue;
      }
    }

    if (char == ';') {
      flush();
      index++;
      continue;
    }

    buffer.write(char);
    index++;
  }

  flush();
  return statements;
}
