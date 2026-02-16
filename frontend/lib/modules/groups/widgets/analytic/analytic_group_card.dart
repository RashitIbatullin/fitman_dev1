import 'package:flutter/material.dart';
import '../../models/analytic_group.model.dart';
import 'package:intl/intl.dart';

class AnalyticGroupCard extends StatelessWidget {
  final AnalyticGroup group;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const AnalyticGroupCard({
    super.key,
    required this.group,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      group.name,
                      style: Theme.of(context).textTheme.titleLarge,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'edit') {
                        onTap();
                      } else if (value == 'delete') {
                        onDelete();
                      }
                    },
                    itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                      const PopupMenuItem<String>(
                        value: 'edit',
                        child: Text('Редактировать'),
                      ),
                      const PopupMenuItem<String>(
                        value: 'delete',
                        child: Text('Удалить', style: TextStyle(color: Colors.red)),
                      ),
                    ],
                    icon: const Icon(Icons.more_vert),
                  ),
                ],
              ),
              if (group.description != null && group.description!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 4.0),
                  child: Text(
                    group.description!,
                    style: Theme.of(context).textTheme.bodyMedium,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              const SizedBox(height: 8.0),
              _buildInfoRow(context, Icons.category, 'Тип:', _analyticGroupTypeToString(group.type)),
              _buildInfoRow(context, Icons.sync, 'Автообновление:', group.isAutoUpdate ? 'Да' : 'Нет'),
              if (group.lastUpdatedAt != null)
                _buildInfoRow(context, Icons.update, 'Последнее обновление:', DateFormat('dd.MM.yyyy HH:mm').format(group.lastUpdatedAt!)),
            ],
          ),
        ),
      ),
    );
  }

  String _analyticGroupTypeToString(AnalyticGroupType type) {
    switch (type) {
      case AnalyticGroupType.corporate: return 'Корпоративная';
      case AnalyticGroupType.demographic: return 'Демографическая';
      case AnalyticGroupType.financial: return 'Финансовая';
      case AnalyticGroupType.behavioral: return 'Поведенческая';
      case AnalyticGroupType.custom: return 'Произвольная';
    }
  }

  Widget _buildInfoRow(BuildContext context, IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 8),
          Text('$label ', style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold)),
          Expanded(child: Text(value, style: Theme.of(context).textTheme.bodySmall)),
        ],
      ),
    );
  }
}