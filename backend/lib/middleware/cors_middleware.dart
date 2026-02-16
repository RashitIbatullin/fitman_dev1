import 'package:shelf/shelf.dart';

Middleware corsMiddleware() {
  return (Handler innerHandler) {
    return (Request request) async {
      final corsHeaders = {
        'Access-Control-Allow-Origin': '*',
        'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE, OPTIONS',
        'Access-Control-Allow-Headers': 'Origin, Content-Type, Authorization, Accept',
        'Access-Control-Allow-Credentials': 'true',
      };

      if (request.method == 'OPTIONS') {
        return Response.ok('', headers: corsHeaders);
      }

      final response = await innerHandler(request);
      return response.change(headers: {
        ...response.headers,
        ...corsHeaders,
      });
    };
  };
}