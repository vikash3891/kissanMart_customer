import '../api_models/home_data_response.dart';
import 'api_service.dart';

class HomeService {
  final ApiService _apiService = ApiService();

  Future<HomeDataResponse> getHomeData() async {
    try {
      final response = await _apiService.get('/home');
      if (response['success'] == true && response['data'] != null) {
        return HomeDataResponse.fromJson(response['data']);
      }
      throw Exception(response['message'] ?? 'Failed to load home data');
    } catch (e) {
      throw Exception('Failed to load home data: $e');
    }
  }
}
