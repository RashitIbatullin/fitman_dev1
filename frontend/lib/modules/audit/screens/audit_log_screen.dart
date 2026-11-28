import 'dart:convert';

import 'package:fitman_common/fitman_common.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../services/api/audit_api.dart';

/// Журнал аудита для администратора.
class AuditLogScreen extends StatefulWidget {
  const AuditLogScreen({super.key});

  @override
  State<AuditLogScreen> createState() => _AuditLogScreenState();
}

class _AuditLogScreenState extends State<AuditLogScreen> {
  static const int _pageSize = 50;
  static const List<String> _actions = [
    'INSERT',
    'UPDATE',
    'DELETE',
    'ARCHIVE',
    'RESTORE',
  ];

  final AuditApiService _api = AuditApiService();
  final TextEditingController _tableController = TextEditingController();
  final DateFormat _dateFormat = DateFormat('dd.MM.yyyy HH:mm');
  final DateFormat _filterDateFormat = DateFormat('dd.MM.yyyy');

  String? _action;
  DateTime? _from;
  DateTime? _to;

  List<AuditRecord> _items = const [];
  int _total = 0;
  bool _loading = true;
  bool _loadingMore = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  @override
  void dispose() {
    _tableController.dispose();
    super.dispose();
  }

  Future<void> _reload() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final page = await _api.getRecords(
        tableName: _tableController.text.trim(),
        action: _action,
        from: _from,
        to: _to,
        limit: _pageSize,
      );
      if (!mounted) return;
      setState(() {
        _items = page.items;
        _total = page.total;
        _loading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = '$error';
      });
    }
  }

  Future<void> _loadMore() async {
    if (_loadingMore || _items.length >= _total) {
      return;
    }
    setState(() => _loadingMore = true);
    try {
      final page = await _api.getRecords(
        tableName: _tableController.text.trim(),
        action: _action,
        from: _from,
        to: _to,
        limit: _pageSize,
        offset: _items.length,
      );
      if (!mounted) return;
      setState(() {
        _items = [..._items, ...page.items];
        _total = page.total;
        _loadingMore = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() => _loadingMore = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Не удалось загрузить ещё: $error')),
      );
    }
  }

  Future<void> _pickDate({required bool isFrom}) async {
    final initial = (isFrom ? _from : _to) ?? DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2024),
      lastDate: DateTime.now().add(const Duration(days: 1)),
    );
    if (picked == null) {
      return;
    }
    setState(() {
      if (isFrom) {
        _from = picked;
      } else {
        _to = picked.add(const Duration(days: 1));
      }
    });
  }

  void _resetFilters() {
    _tableController.clear();
    setState(() {
      _action = null;
      _from = null;
      _to = null;
    });
    _reload();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Аудит'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Обновить',
            onPressed: _loading ? null : _reload,
          ),
        ],
      ),
      body: Column(
        children: [
          _buildFilters(),
          Expanded(child: _buildBody()),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    return Card(
      margin: const EdgeInsets.fromLTRB(8, 8, 8, 4),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          children: [
            TextField(
              controller: _tableController,
              decoration: const InputDecoration(
                isDense: true,
                labelText: 'Таблица',
                hintText: 'users, service_purchases…',
                prefixIcon: Icon(Icons.table_chart_outlined),
                border: OutlineInputBorder(),
              ),
              onSubmitted: (_) => _reload(),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue: _action,
                    isExpanded: true,
                    decoration: const InputDecoration(
                      isDense: true,
                      labelText: 'Действие',
                      border: OutlineInputBorder(),
                    ),
                    items: [
                      const DropdownMenuItem<String>(
                        value: null,
                        child: Text('Все действия'),
                      ),
                      ..._actions.map(
                        (action) => DropdownMenuItem<String>(
                          value: action,
                          child: Text(_actionLabel(action)),
                        ),
                      ),
                    ],
                    onChanged: (value) => setState(() => _action = value),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _pickDate(isFrom: true),
                    icon: const Icon(Icons.event, size: 18),
                    label: Text(
                      _from == null
                          ? 'С даты'
                          : _filterDateFormat.format(_from!),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _pickDate(isFrom: false),
                    icon: const Icon(Icons.event, size: 18),
                    label: Text(
                      _to == null
                          ? 'По дату'
                          : _filterDateFormat.format(
                              _to!.subtract(const Duration(days: 1)),
                            ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                FilledButton.icon(
                  onPressed: _loading ? null : _reload,
                  icon: const Icon(Icons.search),
                  label: const Text('Применить'),
                ),
                const SizedBox(width: 8),
                TextButton(
                  onPressed: _loading ? null : _resetFilters,
                  child: const Text('Сбросить'),
                ),
                const Spacer(),
                Text(
                  'Найдено: $_total',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 56, color: Colors.redAccent),
              const SizedBox(height: 12),
              Text('Не удалось загрузить аудит: $_error', textAlign: TextAlign.center),
              const SizedBox(height: 12),
              FilledButton(onPressed: _reload, child: const Text('Повторить')),
            ],
          ),
        ),
      );
    }
    if (_items.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            'Записей аудита не найдено',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey),
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _reload,
      child: ListView.builder(
        padding: const EdgeInsets.all(8),
        itemCount: _items.length + (_items.length < _total ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == _items.length) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Center(
                child: _loadingMore
                    ? const CircularProgressIndicator()
                    : OutlinedButton(
                        onPressed: _loadMore,
                        child: Text('Показать ещё (${_total - _items.length})'),
                      ),
              ),
            );
          }
          return _AuditCard(
            record: _items[index],
            dateFormat: _dateFormat,
          );
        },
      ),
    );
  }

  String _actionLabel(String action) {
    switch (action) {
      case 'INSERT':
        return 'Создание';
      case 'UPDATE':
        return 'Изменение';
      case 'DELETE':
        return 'Удаление';
      case 'ARCHIVE':
        return 'Архивация';
      case 'RESTORE':
        return 'Восстановление';
      default:
        return action;
    }
  }
}

class _AuditCard extends StatelessWidget {
  const _AuditCard({required this.record, required this.dateFormat});

  final AuditRecord record;
  final DateFormat dateFormat;

  @override
  Widget build(BuildContext context) {
    final color = _actionColor(record.action);
    final actor = record.changedByName ??
        (record.changedBy == null
            ? 'система'
            : record.changedBy!.substring(0, 8));

    return Card(
      margin: const EdgeInsets.only(bottom: 6),
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: color,
          child: Icon(_actionIcon(record.action), color: Colors.white, size: 20),
        ),
        title: Text(
          '${_actionLabel(record.action)} · ${record.tableName}',
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(dateFormat.format(record.changedAt.toLocal())),
            Text(
              '$actor${record.actorRole == null ? '' : ' (${record.actorRole})'} · ${record.source}',
              overflow: TextOverflow.ellipsis,
            ),
            if (record.reason != null && record.reason!.isNotEmpty)
              Text(
                'Причина: ${record.reason}',
                overflow: TextOverflow.ellipsis,
              ),
          ],
        ),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        expandedCrossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Запись: ${record.rowPk}'),
          if (record.requestId != null)
            Text('Request ID: ${record.requestId}'),
          if (record.oldValues != null) ...[
            const SizedBox(height: 8),
            _JsonBlock(title: 'Было', values: record.oldValues!),
          ],
          if (record.newValues != null) ...[
            const SizedBox(height: 8),
            _JsonBlock(title: 'Стало', values: record.newValues!),
          ],
        ],
      ),
    );
  }

  String _actionLabel(String action) {
    switch (action) {
      case 'INSERT':
        return 'Создание';
      case 'UPDATE':
        return 'Изменение';
      case 'DELETE':
        return 'Удаление';
      case 'ARCHIVE':
        return 'Архивация';
      case 'RESTORE':
        return 'Восстановление';
      default:
        return action;
    }
  }

  IconData _actionIcon(String action) {
    switch (action) {
      case 'INSERT':
        return Icons.add;
      case 'UPDATE':
        return Icons.edit_outlined;
      case 'DELETE':
        return Icons.delete_outline;
      case 'ARCHIVE':
        return Icons.archive_outlined;
      case 'RESTORE':
        return Icons.unarchive_outlined;
      default:
        return Icons.history;
    }
  }

  Color _actionColor(String action) {
    switch (action) {
      case 'INSERT':
        return Colors.green;
      case 'UPDATE':
        return Colors.blue;
      case 'DELETE':
        return Colors.red;
      case 'ARCHIVE':
        return Colors.brown;
      case 'RESTORE':
        return Colors.teal;
      default:
        return Colors.blueGrey;
    }
  }
}

class _JsonBlock extends StatelessWidget {
  const _JsonBlock({required this.title, required this.values});

  final String title;
  final Map<String, dynamic> values;

  @override
  Widget build(BuildContext context) {
    final text = const JsonEncoder.withIndent('  ').convert(values);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Container(
          width: double.infinity,
          constraints: const BoxConstraints(maxHeight: 240),
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(6),
          ),
          child: SingleChildScrollView(
            child: SelectableText(
              text,
              style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
            ),
          ),
        ),
      ],
    );
  }
}
