import 'package:redis/redis.dart';

class RedisService {
  static final RedisService _instance = RedisService._internal();
  factory RedisService() => _instance;

  RedisService._internal();

  Command? _pubConnection;
  PubSub? _subConnection;
  RedisConnection? _redisConnectionForPub;
  RedisConnection? _redisConnectionForSub;

  Future<Command> get publisher async {
    if (_pubConnection == null) {
      _redisConnectionForPub = RedisConnection();
      _pubConnection = await _redisConnectionForPub!.connect('localhost', 6379);
    }
    return _pubConnection!;
  }
  
  Future<PubSub> get subscriber async {
    if (_subConnection == null) {
      _redisConnectionForSub = RedisConnection();
      final conn = await _redisConnectionForSub!.connect('localhost', 6379);
      _subConnection = PubSub(conn);
    }
    return _subConnection!;
  }

  Future<void> publish(String channel, String message) async {
    final pub = await publisher;
    await pub.send_object(['PUBLISH', channel, message]);
  }

  void dispose() {
    _redisConnectionForPub?.close();
    _redisConnectionForSub?.close();
  }
}
