class WorkSchedule {
  WorkSchedule({
    required this.id,
    required this.staffId,
    required this.dayOfWeek,
    required this.startTime,
    required this.endTime,
  });

  final String id;
  final String staffId;
  final int dayOfWeek;
  final String startTime; // Using String for TIME type
  final String endTime;   // Using String for TIME type

  factory WorkSchedule.fromMap(Map<String, dynamic> map) {
    return WorkSchedule(
      id: map['id'].toString(),
      staffId: map['staff_id'].toString(),
      dayOfWeek: map['day_of_week'] as int,
      startTime: map['start_time'].toString().substring(0, 8),
      endTime: map['end_time'].toString().substring(0, 8),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'staff_id': staffId,
      'day_of_week': dayOfWeek,
      'start_time': startTime,
      'end_time': endTime,
    };
  }
}
