# -*- coding: utf-8 -*-
"""Разбивает .docx ТЗ на маленькие .md файлы по разделам + индекс.

Запуск (из папки tz-split):
    python _build/split_tz.py . ../"Требования ТЗ ... часть 1.docx" ...
"""
import os
import re
import sys

from docx import Document
from docx.oxml.ns import qn
from docx.table import Table
from docx.text.paragraph import Paragraph

# ---------- настройки ----------
SPLIT_LEVELS = (3, 4, 5)   # глава -> модуль -> подраздел
MAX_CHARS = 22000          # секцию больше этого дробим глубже
CHARS_PER_TOKEN = 2.6      # грубая оценка для русского текста
MIN_TITLE_CHARS = 20       # титул короче этого не сохраняем отдельным файлом

CODE_LANGS = {
    'sql', 'python', 'py', 'dart', 'json', 'yaml', 'yml', 'bash', 'sh',
    'kotlin', 'java', 'ts', 'js', 'javascript', 'typescript', 'http',
    'xml', 'html', 'css', 'go', 'rust', 'c#', 'csharp', 'php', 'text', 'txt',
}

TRANSLIT = {
    'а': 'a', 'б': 'b', 'в': 'v', 'г': 'g', 'д': 'd', 'е': 'e', 'ё': 'e',
    'ж': 'zh', 'з': 'z', 'и': 'i', 'й': 'y', 'к': 'k', 'л': 'l', 'м': 'm',
    'н': 'n', 'о': 'o', 'п': 'p', 'р': 'r', 'с': 's', 'т': 't', 'у': 'u',
    'ф': 'f', 'х': 'kh', 'ц': 'ts', 'ч': 'ch', 'ш': 'sh', 'щ': 'shch',
    'ъ': '', 'ы': 'y', 'ь': '', 'э': 'e', 'ю': 'yu', 'я': 'ya',
}


def slugify(text, maxlen=48):
    out = []
    for ch in text.lower():
        if ch in TRANSLIT:
            out.append(TRANSLIT[ch])
        elif ch.isascii() and ch.isalnum():
            out.append(ch)
        elif ch in ' -_/.,:':
            out.append('-')
        else:
            out.append('-')
    return re.sub(r'-+', '-', ''.join(out)).strip('-')[:maxlen].rstrip('-') or 'section'


def iter_block(parent):
    for child in parent.element.body.iterchildren():
        if child.tag == qn('w:p'):
            yield Paragraph(child, parent)
        elif child.tag == qn('w:tbl'):
            yield Table(child, parent)


def read_items(path):
    doc = Document(path)
    items = []
    code_mode = False
    for block in iter_block(doc):
        if isinstance(block, Paragraph):
            text = block.text
            style = block.style.name if block.style is not None else 'Normal'
            if style.startswith('Heading'):
                code_mode = False
                m = re.search(r'(\d+)', style)
                level = int(m.group(1)) if m else 1
                items.append(('h', level, text.strip()))
                continue
            stripped = text.strip()
            if code_mode:
                items.append(('pre', text.rstrip()))
                continue
            low = stripped.lower().rstrip(':')
            if len(stripped) <= 12 and low in CODE_LANGS and stripped == stripped.lower():
                code_mode = True
                items.append(('code', low))
                continue
            if style == 'HTML Preformatted':
                items.append(('pre', text.rstrip()))
            elif style == 'List Paragraph':
                level = 0
                pPr = block._p.pPr
                if pPr is not None and pPr.numPr is not None and pPr.numPr.ilvl is not None:
                    level = int(pPr.numPr.ilvl.val)
                if stripped:
                    items.append(('li', level, text.strip()))
            else:
                if stripped and '\t' in stripped and re.search(r'\t\d+$', stripped):
                    continue  # строка оглавления
                items.append(('p', stripped))
        else:
            code_mode = False
            rows = []
            for row in block.rows:
                cells, seen = [], set()
                for cell in row.cells:
                    if id(cell._tc) in seen:
                        continue
                    seen.add(id(cell._tc))
                    cells.append(re.sub(r'\s+', ' ', cell.text).strip())
                if any(cells):
                    rows.append(cells)
            if rows:
                items.append(('tbl', rows))
    return items


def section_chars(items):
    n = 0
    for it in items:
        if it[0] == 'h':
            n += len(it[2])
        elif it[0] == 'tbl':
            n += 120 + sum(len(c) for r in it[1] for c in r)
        else:
            n += len(it[-1])
    return n


def has_heading_level_in_body(items, level):
    return any(it[0] == 'h' and it[1] == level for it in items)


def split_by_level(items, level):
    head, sections, cur = [], [], None
    for it in items:
        if it[0] == 'h' and it[1] == level:
            if not it[2]:           # пустой заголовок — не создаём секцию
                continue
            cur = {'title': it[2], 'level': level, 'items': []}
            sections.append(cur)
        elif cur is None:
            head.append(it)
        else:
            cur['items'].append(it)
    return head, sections


def build(items, levels=SPLIT_LEVELS, prefix=None, min_chars=0):
    """Делит поток на секции, самые крупные дробит на следующем уровне."""
    if not levels:
        return [{'title': prefix or 'Раздел', 'items': items}]

    level, rest = levels[0], levels[1:]
    head, sections = split_by_level(items, level)

    if not sections:
        return build(items, rest, prefix, min_chars)

    # текст, идущий до первого подзаголовка, приклеиваем к первой секции,
    # иначе вводные абзацы модуля теряются (титул обрабатывается отдельно)
    if head and level != SPLIT_LEVELS[0]:
        sections[0]['items'] = head + sections[0]['items']

    result = []
    for sec in sections:
        title = f'{prefix} / {sec["title"]}' if prefix else sec['title']
        size = section_chars(sec['items'])
        if rest and size > MAX_CHARS and has_heading_level_in_body(sec['items'], rest[0]):
            result.extend(build(sec['items'], rest, title, min_chars))
        else:
            result.append({'title': title, 'items': sec['items']})

    # мелкие секции склеиваем в разумные куски (только на глубоких уровнях)
    if prefix is not None and min_chars:
        merged = []
        for sec in result:
            if merged and section_chars(merged[-1]['items']) + section_chars(sec['items']) < min_chars \
                    and merged[-1]['title'] == prefix:
                merged[-1]['items'].extend(sec['items'])
            else:
                merged.append(sec)
        result = merged
    return result


def md_table(rows):
    width = max(len(r) for r in rows)
    rows = [r + [''] * (width - len(r)) for r in rows]
    esc = lambda s: s.replace('|', '\\|')
    out = ['| ' + ' | '.join(esc(c) for c in rows[0]) + ' |',
           '| ' + ' | '.join(['---'] * width) + ' |']
    for r in rows[1:]:
        out.append('| ' + ' | '.join(esc(c) for c in r) + ' |')
    return out


def render(items, title, subtitle, base_level):
    lines = [f'# {title}', '', f'*{subtitle}*', '']
    pre_buf, pre_lang = [], None

    def blank():
        if lines and lines[-1] != '':
            lines.append('')

    def flush_pre():
        nonlocal pre_buf, pre_lang
        if pre_buf:
            while pre_buf and not pre_buf[-1].strip():
                pre_buf.pop()
            if pre_buf:
                lines.append('```' + (pre_lang or ''))
                lines.extend(pre_buf)
                lines.append('```')
                blank()
        pre_buf, pre_lang = [], None

    for it in items:
        kind = it[0]
        if kind == 'code':
            flush_pre()
            pre_lang = it[1]
            continue
        if kind == 'pre':
            pre_buf.append(it[1])
            continue
        if kind == 'p' and not it[1] and pre_buf:
            continue                      # пустой абзац внутри блока кода
        flush_pre()
        if kind == 'p':
            if it[1]:
                lines.append(it[1])
                blank()
        elif kind == 'li':
            if it[2]:
                lines.append('  ' * it[1] + '- ' + it[2])
        elif kind == 'h':
            lvl = max(2, min(6, it[1] - base_level + 2))
            lines.append('#' * lvl + ' ' + it[2])
            blank()
        elif kind == 'tbl':
            lines.extend(md_table(it[1]))
            blank()
    flush_pre()
    return '\n'.join(lines).strip() + '\n'


def file_slug(title):
    """Имя файла строим по последнему сегменту: «Глава / Модуль / Экран» -> «ekran»."""
    tail = title.split(' / ')[-1]
    slug = slugify(tail)
    return slug if len(slug) > 12 else slugify(title)


def main():
    out_dir = sys.argv[1]
    sources = sys.argv[2:]
    os.makedirs(out_dir, exist_ok=True)
    index_rows = []

    for part_no, path in enumerate(sources, start=1):
        part_dir_name = f'part-{part_no}'
        part_dir = os.path.join(out_dir, part_dir_name)
        os.makedirs(part_dir, exist_ok=True)
        items = read_items(path)
        head, _ = split_by_level(items, 3)
        doc_title = next((it[2] for it in items if it[0] == 'h' and it[1] == 3), f'Часть {part_no}')

        sections = build(items, SPLIT_LEVELS, None, min_chars=6000)
        if section_chars(head) > MIN_TITLE_CHARS:
            sections.insert(0, {'title': 'Титул и оглавление', 'items': head})

        for idx, sec in enumerate(sections, start=1):
            name = f'{idx:02d}-{file_slug(sec["title"])}.md'
            subtitle = f'Часть {part_no} | источник: {os.path.basename(path)} | [индекс](../INDEX.md)'
            body = render(sec['items'], sec['title'], subtitle, SPLIT_LEVELS[0])
            with open(os.path.join(part_dir, name), 'w', encoding='utf-8') as f:
                f.write(body)
            chars = len(body)
            index_rows.append({
                'part': part_no,
                'file': f'{part_dir_name}/{name}',
                'title': sec['title'],
                'chars': chars,
                'tokens': round(chars / CHARS_PER_TOKEN),
                'lines': body.count('\n'),
            })

    total_tokens = sum(r['tokens'] for r in index_rows)
    out = [
        '# Индекс ТЗ (разбивка по разделам)',
        '',
        f'Всего файлов: **{len(index_rows)}** | суммарно **~{total_tokens}** токенов (оценка).',
        '',
        'Читать целиком не нужно: открой индекс, найди раздел, открой только его файл.',
        'Исходные .docx остались в родительской папке.',
        '',
        '| # | Файл | Раздел | Строк | ~токенов |',
        '| --- | --- | --- | --- | --- |',
    ]
    for i, r in enumerate(index_rows, start=1):
        out.append(f'| {i} | [{r["file"]}]({r["file"]}) | {r["title"]} | {r["lines"]} | ~{r["tokens"]} |')
    with open(os.path.join(out_dir, 'INDEX.md'), 'w', encoding='utf-8') as f:
        f.write('\n'.join(out) + '\n')

    print(f'files: {len(index_rows)}  total ~tokens: {total_tokens}')
    for r in index_rows:
        print(f'  {r["tokens"]:6d}  {r["file"]}  |  {r["title"]}')


if __name__ == '__main__':
    main()
