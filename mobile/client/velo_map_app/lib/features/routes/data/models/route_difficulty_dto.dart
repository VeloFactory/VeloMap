import 'package:velo_map_app/features/routes/domain/entities/route_entity.dart';

extension RouteDifficultyDto on RouteDifficulty {
  String toJson() => name;

  static RouteDifficulty? fromJson(String? value) {
    if (value == null) return null;
    return RouteDifficulty.values.byName(value);
  }
}
