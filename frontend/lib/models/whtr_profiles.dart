import 'whtr_profile.dart';

class WhtrProfiles {
  final WhtrProfile start;
  final WhtrProfile finish;

  WhtrProfiles({required this.start, required this.finish});

  factory WhtrProfiles.fromJson(Map<String, dynamic> json) {
    return WhtrProfiles(
      start: WhtrProfile.fromJson(json['start']),
      finish: WhtrProfile.fromJson(json['finish']),
    );
  }
}
