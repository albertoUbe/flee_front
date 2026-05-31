import '../core/constants/api_constants.dart';
import '../models/plan_model.dart';
import 'api_client.dart';

class PlanService {
  Future<List<PlanModel>> getAllPlans() async {
    final data = await ApiClient.get(ApiConstants.allPlans());
    return (data as List)
        .map((e) => PlanModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
