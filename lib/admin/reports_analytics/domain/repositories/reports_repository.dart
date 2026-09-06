abstract class ReportsRepository {
  /// Returns document counts for every collection dashboards care about.
  /// Collections owned by members whose modules aren't built yet will
  /// simply report 0 until that data starts flowing in.
  Future<Map<String, int>> getCounts();
}
