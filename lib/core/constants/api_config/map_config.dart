/// ═══════════════════════════════════════════════════════════════════
/// Map Configuration for Right Routes App
/// Centralizes MapTiler API Key and MapLibre Mobile compatible Style URLs.
/// ═══════════════════════════════════════════════════════════════════
class MapConfig {
  static const String mapTilerKey = 'N2YLLvhtmoQzVSf9VfF9';

  /// OpenStreetMap vector style from MapTiler (openmaptiles vector source)
  /// Note: Do NOT use streets-v2 with MapLibre Native mobile SDK because
  /// MapTiler added an empty vector 'maptiler_attribution' source in v2 styles
  /// which causes "ParseStyle: source must have tiles" and blank map rendering.
  static const String mapStyle =
      'https://api.maptiler.com/maps/openstreetmap/style.json?key=$mapTilerKey';

  /// Bright style (alternative compatible style)
  static const String brightStyle =
      'https://api.maptiler.com/maps/bright/style.json?key=$mapTilerKey';
}
