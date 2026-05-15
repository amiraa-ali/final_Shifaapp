extension StringExtensions on String {
  // ── Validation ──────────────────────────────────────────
  bool get isValidEmail =>
      RegExp(r'^[\w\-\.]+@([\w\-]+\.)+[\w\-]{2,4}$').hasMatch(this);

  bool get isValidEgyptianPhone =>
      RegExp(r'^(010|011|012|015)[0-9]{8}$').hasMatch(this);

  // ── Formatting ──────────────────────────────────────────
  /// First letter upper-cased (removed duplicate "capitalizeFirstLetter")
  String capitalize() {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }

  String capitalizeEachWord() {
    if (isEmpty) return this;
    return split(' ')
        .map((w) => w.isEmpty ? w : '${w[0].toUpperCase()}${w.substring(1)}')
        .join(' ');
  }

  /// Returns up to 2 initials from a full name, safe for single-word names.
  String get initials {
    final trimmed = trim();
    if (trimmed.isEmpty) return '';
    return trimmed
        .split(' ')
        .where((e) => e.isNotEmpty)
        .map((e) => e[0].toUpperCase())
        .take(2)
        .join();
  }

  String get removeExtraSpaces => trim().replaceAll(RegExp(r'\s+'), ' ');
}
