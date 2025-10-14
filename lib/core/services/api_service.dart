import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;

class ApiService {
  final String baseUrl = "http://192.168.0.111:8080/api";

  Future<Map<String, dynamic>> post(
    String endpoint,
    Map<String, dynamic> data,
  ) async {
    // ⚙️ Configuration: Set the desired timeout duration
    const Duration timeoutDuration = Duration(seconds: 10);

    log("called post method with 10s timeout");
    final url = Uri.parse('$baseUrl$endpoint');

    try {
      final response = await http
          .post(
            url,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(data),
          )
          // ⏱️ The key addition: applying the timeout to the Future
          .timeout(
            timeoutDuration,
            onTimeout: () {
              // You can throw a custom error or return a specific response here.
              // Throwing an exception is usually the best approach for network calls.
              throw TimeoutException(
                'The server did not respond within $timeoutDuration. Please check your network connection.',
              );
            },
          );

      // --- Original success/error handling logic remains the same ---
      final responseBody = jsonDecode(response.body);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return responseBody;
      } else {
        // Use the error message from the API if available
        throw Exception(responseBody['error'] ?? 'Failed to process request');
      }
      // await Future.delayed(const Duration(seconds: 1));
      // return {"token": "blablatoken"};
    } on TimeoutException catch (e) {
      // 🚫 Catch the specific TimeoutException
      log("Timeout Error: ${e.message}");
      // Re-throw the error to be handled by the caller
      throw Exception('Request timed out: ${e.message}');
    } catch (e) {
      log(e.toString());
      // Handle other network errors or exceptions during the request
      throw Exception('An error occurred: $e');
    }
  }
}
