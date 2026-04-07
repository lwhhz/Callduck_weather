import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:callduck_weather/features/weather/data/services/hitokoto_api_service.dart';

final hitokotoProvider = FutureProvider<Hitokoto>((ref) {
  return HitokotoApiService().getHitokoto();
});
