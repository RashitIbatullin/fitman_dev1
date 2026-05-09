import 'package:args/args.dart';
import 'package:fitman_backend/seeding/database_seeder.dart';

Future<void> main(List<String> arguments) async {
  final parser = ArgParser()
    ..addFlag('demo', help: 'Seed with a small set of demo data.', negatable: false)
    ..addFlag('medium', help: 'Seed with a medium set of data for a realistic center.', negatable: false)
    ..addFlag('load', help: 'Seed with a large set of data for load testing.', negatable: false)
    ..addOption('users', abbr: 'u', help: 'Number of users to create for load testing.', defaultsTo: '100')
    ..addFlag('help', abbr: 'h', help: 'Show this help message.', negatable: false);

  final argResults = parser.parse(arguments);

  if (argResults['help'] as bool) {
    print('Database Seeding Tool');
    print(parser.usage);
    return;
  }

  final seeder = DatabaseSeeder();
  await seeder.connect();

  try {
    if (argResults['demo'] as bool) {
      print('Starting to seed database with DEMO data...');
      await seeder.runDemo();
      print('✅ Demo data seeding complete!');
    } else if (argResults['medium'] as bool) {
      print('Starting to seed database with MEDIUM data...');
      await seeder.runMediumCenter();
      print('✅ Medium data seeding complete!');
    } else if (argResults['load'] as bool) {
      final userCount = int.tryParse(argResults['users'] as String) ?? 100;
      print('Starting to seed database with LOAD TEST data ($userCount users)...');
      await seeder.runLoadTest(userCount: userCount);
      print('✅ Load test data seeding complete!');
    } else {
      print('Please specify a mode: --demo, --medium, or --load');
      print(parser.usage);
    }
  } finally {
    await seeder.close();
  }
}
