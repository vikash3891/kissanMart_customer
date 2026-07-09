import '../api_models/home_data_response.dart';
import '../services/home_service.dart';

class HomeRepository {
  final HomeService _service = HomeService();

  Future<HomeDataResponse> getHomeData() => _service.getHomeData();
}
