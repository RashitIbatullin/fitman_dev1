import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AiPromptView extends StatelessWidget {
  final String simplePrompt;
  final String professionalPrompt;
  final bool isStaff;

  const AiPromptView({
    super.key,
    required this.simplePrompt,
    required this.professionalPrompt,
    required this.isStaff,
  });

  @override
  Widget build(BuildContext context) {
    if (isStaff) {
      // Staff view with tabs
      return DefaultTabController(
        length: 2,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 24),
            Text(
              'Промпт для ИИ',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            const TabBar(
              tabs: [
                Tab(text: 'Для клиента'),
                Tab(text: 'Для сотрудника'),
              ],
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 350,
              child: TabBarView(
                children: [
                  _PromptTab(prompt: simplePrompt),
                  _PromptTab(prompt: professionalPrompt),
                ],
              ),
            ),
          ],
        ),
      );
    } else {
      // Client view without tabs
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 24),
          Text(
            'Промпт для ИИ',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 350,
            child: _PromptTab(prompt: simplePrompt),
          ),
        ],
      );
    }
  }
}

class _PromptTab extends StatelessWidget {
  final String prompt;

  const _PromptTab({required this.prompt});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0).copyWith(right: 48),
            child: SingleChildScrollView(
              child: SelectableText(prompt),
            ),
          ),
          Positioned(
            top: 8,
            right: 8,
            child: IconButton(
              icon: const Icon(Icons.copy),
              onPressed: () {
                Clipboard.setData(ClipboardData(text: prompt));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Промпт скопирован в буфер обмена.'),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
              tooltip: 'Копировать промпт',
            ),
          ),
        ],
      ),
    );
  }
}
