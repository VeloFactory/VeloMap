import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

/// Service for exporting routes and stages to GPX format
class GpxExporter {
  /// Export coordinates to GPX format and share the file
  /// 
  /// [coordinates] - List of [lng, lat, elevation] coordinates
  /// [name] - Name of the route/stage for the GPX file
  /// [description] - Optional description for the GPX metadata
  Future<void> exportAndShare({
    required List<List<double>> coordinates,
    required String name,
    String? description,
  }) async {
    // Generate GPX content
    final gpxContent = _generateGpx(
      coordinates: coordinates,
      name: name,
      description: description,
    );

    // Save to temporary file
    final tempDir = await getTemporaryDirectory();
    final fileName = _sanitizeFileName(name);
    final file = File('${tempDir.path}/$fileName.gpx');
    await file.writeAsString(gpxContent);

    // Share the file
    await Share.shareXFiles(
      [XFile(file.path)],
      subject: '$name - GPX Track',
    );
  }

  /// Generate GPX XML content from coordinates
  String _generateGpx({
    required List<List<double>> coordinates,
    required String name,
    String? description,
  }) {
    final buffer = StringBuffer();
    
    // GPX header
    buffer.writeln('<?xml version="1.0" encoding="UTF-8"?>');
    buffer.writeln('<gpx version="1.1" creator="VeloMap App"');
    buffer.writeln('  xmlns="http://www.topografix.com/GPX/1/1"');
    buffer.writeln('  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"');
    buffer.writeln('  xsi:schemaLocation="http://www.topografix.com/GPX/1/1 http://www.topografix.com/GPX/1/1/gpx.xsd">');
    
    // Metadata
    buffer.writeln('  <metadata>');
    buffer.writeln('    <name>${_escapeXml(name)}</name>');
    if (description != null && description.isNotEmpty) {
      buffer.writeln('    <desc>${_escapeXml(description)}</desc>');
    }
    buffer.writeln('    <time>${DateTime.now().toUtc().toIso8601String()}</time>');
    buffer.writeln('  </metadata>');
    
    // Track
    buffer.writeln('  <trk>');
    buffer.writeln('    <name>${_escapeXml(name)}</name>');
    if (description != null && description.isNotEmpty) {
      buffer.writeln('    <desc>${_escapeXml(description)}</desc>');
    }
    buffer.writeln('    <trkseg>');
    
    // Track points
    for (final coord in coordinates) {
      if (coord.length < 2) continue;
      
      final lon = coord[0];
      final lat = coord[1];
      final hasElevation = coord.length >= 3;
      
      if (hasElevation) {
        final ele = coord[2];
        buffer.writeln('      <trkpt lat="$lat" lon="$lon">');
        buffer.writeln('        <ele>$ele</ele>');
        buffer.writeln('      </trkpt>');
      } else {
        buffer.writeln('      <trkpt lat="$lat" lon="$lon"/>');
      }
    }
    
    buffer.writeln('    </trkseg>');
    buffer.writeln('  </trk>');
    buffer.writeln('</gpx>');
    
    return buffer.toString();
  }

  /// Sanitize file name to remove invalid characters
  String _sanitizeFileName(String name) {
    return name
        .replaceAll(RegExp(r'[<>:"/\\|?*]'), '_')
        .replaceAll(RegExp(r'\s+'), '_')
        .trim();
  }

  /// Escape special XML characters
  String _escapeXml(String text) {
    return _sanitizeForGpx(text)
        .replaceAll('&', '&amp;')
        .replaceAll('<', '&lt;')
        .replaceAll('>', '&gt;')
        .replaceAll('"', '&quot;')
        .replaceAll("'", '&apos;');
  }

  /// Sanitize text for GPX compatibility
  /// Replaces Unicode dashes and other problematic characters
  String _sanitizeForGpx(String text) {
    return text
        // Replace various Unicode dashes with regular hyphen
        .replaceAll('–', '-') // en-dash
        .replaceAll('—', '-') // em-dash
        .replaceAll('−', '-') // minus sign
        .replaceAll('‐', '-') // hyphen
        .replaceAll('‑', '-') // non-breaking hyphen
        .replaceAll('‒', '-') // figure dash
        // Replace other potentially problematic Unicode
        .replaceAll(''', "'") // left single quote
        .replaceAll(''', "'") // right single quote
        .replaceAll('"', '"') // left double quote
        .replaceAll('"', '"') // right double quote
        .replaceAll('…', '...'); // ellipsis
  }
}
