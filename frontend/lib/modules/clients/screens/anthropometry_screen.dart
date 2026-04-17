import 'package:fitman_app/modules/clients/screens/anthropometry_edit_screen.dart';
import 'package:fitman_app/modules/clients/widgets/fixed_values_view.dart';
import 'package:fitman_app/modules/clients/screens/anthropometry_list_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fitman_app/providers/auth_provider.dart';

class AnthropometryScreen extends ConsumerStatefulWidget {
  final String? clientId;
  const AnthropometryScreen({super.key, this.clientId});

  @override
  ConsumerState<AnthropometryScreen> createState() =>
      _AnthropometryScreenState();
}

class _AnthropometryScreenState extends ConsumerState<AnthropometryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _showFab = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (mounted) {
        setState(() {
          _showFab = _tabController.index == 1;
        });
      }
    });
  }

  @override
  void dispose() {
    _tabController.removeListener(() {});
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final user = authState.asData?.value.user;
    final currentUserId = user?.id;
    final targetClientId = widget.clientId ?? currentUserId;

    if (targetClientId == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Антропометрия')),
        body: const Center(child: Text('Не удалось определить ID клиента.')),
      );
    }

    final roles = user?.roles.map((r) => r.name).toSet() ?? {};
    final canEdit = roles.contains('admin') ||
        roles.contains('trainer') ||
        roles.contains('instructor') ||
        roles.contains('manager');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Антропометрия'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Постоянные данные'),
            Tab(text: 'Периодические замеры'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          FixedValuesView(clientId: targetClientId),
          AnthropometryListScreen(clientId: targetClientId),
        ],
      ),
      floatingActionButton: _showFab && canEdit
          ? FloatingActionButton(
              heroTag: 'add_periodic_measurement',
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) =>
                        AnthropometryEditScreen(clientId: targetClientId)));
              },
              child: const Icon(Icons.add),
            )
          : null,
    );
  }
}
