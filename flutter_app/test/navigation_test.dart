import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:checklist_voyage_v1/app/app_dependencies.dart';
import 'package:checklist_voyage_v1/app/checklist_app.dart';
import 'package:checklist_voyage_v1/data/local/app_database.dart';

void main() {
  testWidgets('présente les trois destinations et navigue hors ligne', (
    tester,
  ) async {
    final database = AppDatabase(NativeDatabase.memory());
    final dependencies = await AppDependencies.create(database: database);

    await tester.pumpWidget(ChecklistApp(dependencies: dependencies));
    await tester.pumpAndSettle();

    expect(find.text('Voyages'), findsWidgets);
    expect(find.text('Bibliothèque'), findsOneWidget);
    expect(find.text('Listes rapides'), findsOneWidget);
    expect(find.text('Aucun voyage actif'), findsOneWidget);

    await tester.tap(find.text('Bibliothèque'));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('library-root-general')), findsOneWidget);
    expect(find.byKey(const Key('library-root-members')), findsOneWidget);
    expect(find.byKey(const Key('library-root-personal')), findsOneWidget);
    expect(find.text('Mode local-first actif'), findsNothing);
    expect(find.byIcon(Icons.file_download_outlined), findsOneWidget);

    await tester.tap(find.text('Listes rapides'));
    await tester.pumpAndSettle();
    expect(find.text('Aucune liste rapide'), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(milliseconds: 1));
    await dependencies.close();
    await tester.pump(const Duration(milliseconds: 1));
  });
}
