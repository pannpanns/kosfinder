import 'package:flutter_test/flutter_test.dart';
import 'package:kosfinder/main.dart';
import 'package:kosfinder/repositories/kos_repository.dart';

void main() {
  testWidgets('KosFinderApp menampilkan beranda Cari Kos', (tester) async {
    final repo = KosRepository(fetchRowsOverride: () async => []);

    await tester.pumpWidget(KosFinderApp(kosRepository: repo));
    await tester.pumpAndSettle();

    expect(find.text('Cari Kos'), findsOneWidget);
    expect(find.text('Kos Saya'), findsOneWidget);
  });
}
