// Refino 2: ordem dos menus (cartão / "⋮" do título) e ícones do player.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:plezy/cgflix/cgflix_icones.dart';
import 'package:plezy/cgflix/cgflix_menus.dart';
import 'package:plezy/widgets/app_menu.dart';

AppMenuItem<String> _item(String value) => AppMenuItem<String>(value: value, label: value, icon: Symbols.info_rounded);

List<String> _shape(List<AppMenuEntry<String>> entries) => [
  for (final e in entries)
    if (e is AppMenuItem<String>) e.value else '—',
];

void main() {
  test('menu do título: assistir, guardar, marcar, técnico, admin e apagar no fim', () {
    // Ordem em que o Plezy monta o menu de um filme no Continuar assistindo, com admin.
    final plezy = [
      'play_from_beginning',
      'play_trailer',
      'watch',
      'remove_from_continue_watching',
      'details',
      'rate',
      'edit_metadata',
      'play_version',
      'fileinfo',
      'download',
      'toggle_watchlist',
      'delete_media',
    ].map(_item).toList();

    expect(_shape(cgflixArrangeTitleMenu(plezy)), [
      'details',
      'play_from_beginning',
      'play_trailer',
      '—',
      'download',
      'toggle_watchlist',
      '—',
      'watch',
      'remove_from_continue_watching',
      'rate',
      '—',
      'play_version',
      'fileinfo',
      '—',
      'edit_metadata',
      '—',
      'delete_media',
    ]);
  });

  test('nada some nem repete', () {
    final values = [for (final g in cgflixTitleMenuGroups) ...g];
    expect(values.toSet().length, values.length, reason: 'item repetido em dois grupos');
    final plezy = values.reversed.map(_item).toList();
    final out = _shape(cgflixArrangeTitleMenu(plezy)).where((v) => v != '—').toList();
    expect(out.toSet(), values.toSet());
    expect(out.length, values.length);
  });

  test('itens extras de uma tela ficam antes do Apagar', () {
    final out = _shape(cgflixArrangeTitleMenu([_item('delete_media'), _item('extra_0'), _item('watch')]));
    expect(out, ['watch', '—', 'extra_0', '—', 'delete_media']);
  });

  test('menu de música e de coleção ficam como o Plezy montou', () {
    final music = [_item('music_play'), _item('download'), _item('music_album')];
    expect(_shape(cgflixArrangeTitleMenu(music)), ['music_play', 'download', 'music_album']);
    final list = [_item('play'), _item('shuffle'), _item('delete')];
    expect(_shape(cgflixArrangeTitleMenu(list)), ['play', 'shuffle', 'delete']);
  });

  test('player: ícones mais claros e contorno quando a chave está desligada', () {
    expect(cgflixPlayerIcon(Symbols.tune_rounded), Symbols.settings_rounded);
    expect(cgflixPlayerIcon(Symbols.audiotrack_rounded), Symbols.voice_selection_rounded);
    expect(cgflixPlayerIcon(Symbols.bookmarks_rounded), Symbols.toc_rounded);
    expect(cgflixPlayerIcon(Symbols.queue_rounded), Symbols.playlist_play_rounded);
    expect(cgflixPlayerIcon(Symbols.subtitles_rounded), Symbols.subtitles_rounded);
    expect(cgflixPlayerIconFill(checked: false, isActive: false), 0);
    expect(cgflixPlayerIconFill(checked: true, isActive: false), 1);
    expect(cgflixPlayerIconFill(checked: null, isActive: false), 1);
  });

  testWidgets('player no celular: 48 dp de toque; com foco de controle remoto, o do upstream', (tester) async {
    late bool toque;
    late bool remoto;
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(platform: TargetPlatform.android),
        home: Builder(
          builder: (context) {
            toque = cgflixPlayerTouchSized(context, hasFocusNode: false);
            remoto = cgflixPlayerTouchSized(context, hasFocusNode: true);
            return const SizedBox();
          },
        ),
      ),
    );
    expect(toque, isTrue);
    expect(remoto, isFalse);
  });
}
