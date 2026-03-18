import 'package:flutter/material.dart';
import '../widgets/competency_view.dart';

class CompetencyScreen extends StatelessWidget {
  final String employeeId;
  final String employeeName;

  const CompetencyScreen({
    super.key,
    required this.employeeId,
    required this.employeeName,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Компетенции: $employeeName'),
      ),
      body: SingleChildScrollView(
        child: CompetencyView(employeeId: employeeId),
      ),
    );
  }
}
