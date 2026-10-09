import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plezy/cgflix/cgflix_style.dart';
import 'package:plezy/cgflix/cgflix_theme.dart';

void main() {
  test('tema único do CGFLIX: escuro, fundo OLED #07060a e destaque roxo', () {
    final theme = cgflixAppTheme();
    expect(theme.brightness, Brightness.dark);
    expect(theme.scaffoldBackgroundColor, CgflixColors.background);
    expect(theme.scaffoldBackgroundColor, const Color(0xFF07060A));
    expect(theme.colorScheme.surface, CgflixColors.surface);
    expect(theme.progressIndicatorTheme.color, CgflixColors.accent);
    expect(cgflixMaterialThemeMode, ThemeMode.dark);
  });
}
