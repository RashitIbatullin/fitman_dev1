import 'package:fitman_app/modules/clients/screens/client_dashboard.dart';
import 'package:fitman_app/modules/employees/screens/edit_employee_screen.dart';
import 'package:fitman_app/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:fitman_common/fitman_common.dart';

class GroupMemberList extends StatelessWidget {
  final List<User> members;
  final VoidCallback onAdd;
  final void Function(String userId, String reason) onRemove;
  final ValueChanged<String> onMove;

  const GroupMemberList({
    super.key,
    required this.members,
    required this.onAdd,
    required this.onRemove,
    required this.onMove,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (members.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8.0),
            child: Text('В этой группе пока нет участников.'),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: members.length,
            itemBuilder: (context, index) {
              final member = members[index];
              return _MemberListItem(
                member: member,
                onRemove: (reason) => onRemove(member.id, reason),
                onMove: () => onMove(member.id),
              );
            },
          ),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton.icon(
            icon: const Icon(Icons.add),
            label: const Text('Добавить участника'),
            onPressed: onAdd,
          ),
        ),
      ],
    );
  }
}

class _MemberListItem extends StatefulWidget {
  final User member;
  final void Function(String reason) onRemove;
  final VoidCallback onMove;

  const _MemberListItem({
    required this.member,
    required this.onRemove,
    required this.onMove,
  });

  @override
  State<_MemberListItem> createState() => _MemberListItemState();
}


class _MemberListItemState extends State<_MemberListItem> {
  bool _isHovering = false;

  Future<void> _confirmRemoveMember(BuildContext context) async {
    final reasonController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Подтверждение'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Удалить участника '${widget.member.fullName}' из группы?"),
              TextFormField(
                controller: reasonController,
                decoration: const InputDecoration(labelText: 'Причина удаления'),
                validator: (value) {
                  if (value == null || value.length < 5) {
                    return 'Причина не менее 5 символов';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                Navigator.of(context).pop(true);
              }
            },
            child: const Text('Удалить'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      widget.onRemove(reasonController.text);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovering = true),
      onExit: (_) => setState(() => _isHovering = false),
      child: ListTile(
        tileColor: _isHovering ? colorScheme.primary.withAlpha(25) : null,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  ClientDashboard(client: widget.member, showBackButton: true),
            ),
          );
        },
        leading: CircleAvatar(
          radius: 20,
          backgroundImage: widget.member.photoUrl != null
              ? NetworkImage(Uri.parse(ApiService.baseUrl)
                  .replace(path: widget.member.photoUrl!)
                  .toString())
              : null,
          child: widget.member.photoUrl == null
              ? Text(widget.member.firstName.isNotEmpty
                  ? widget.member.firstName[0]
                  : '?')
              : null,
        ),
        title: Text(
          widget.member.fullName,
          style: Theme.of(context).textTheme.bodySmall,
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            if (value == 'edit') {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      EditEmployeeScreen(user: widget.member),
                ),
              );
            } else if (value == 'delete') {
              _confirmRemoveMember(context);
            } else if (value == 'move') {
              widget.onMove();
            }
          },
          itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
            const PopupMenuItem<String>(
              value: 'edit',
              child: Text('Редактировать'),
            ),
            const PopupMenuItem<String>(
              value: 'move',
              child: Text('Переместить'),
            ),
            const PopupMenuDivider(),
            const PopupMenuItem<String>(
              value: 'delete',
              child: Text('Удалить'),
            ),
          ],
        ),
      ),
    );
  }
}
