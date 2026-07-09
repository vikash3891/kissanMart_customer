import '../api_models/api_product.dart';
import '../services/recommendation_service.dart';

class RecommendationRepository {
  final RecommendationService _service = RecommendationService();

  Future<List<ApiProduct>> getTrending() => _service.getTrending();
  Future<List<ApiProduct>> getRecommended() => _service.getRecommended();
  Future<List<ApiProduct>> getPopular() => _service.getPopular();
  Future<List<ApiProduct>> getSeasonal() => _service.getSeasonal();
}
