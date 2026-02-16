// Base command class, assuming a Result type exists
abstract class Command<T> {
  Future<T> execute();
}

class AddGroupMemberCommand implements Command<void> {
  AddGroupMemberCommand(this.groupId, this.clientId);
  final String groupId;
  final String clientId;

  @override
  Future<void> execute() async {
    // TODO: Implement API call to add a member
    print('Executing AddGroupMemberCommand for group $groupId, client $clientId');
  }
}

class RemoveGroupMemberCommand implements Command<void> {
  RemoveGroupMemberCommand(this.groupId, this.clientId);
  final String groupId;
  final String clientId;

  @override
  Future<void> execute() async {
    // TODO: Implement API call to remove a member
    print('Executing RemoveGroupMemberCommand for group $groupId, client $clientId');
  }
}
