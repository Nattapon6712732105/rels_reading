import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rels_reading/core/theme/app_theme.dart';
import 'package:rels_reading/providers/bookmark_provider.dart';
import 'package:rels_reading/screens/bookmarks/bookmarks_screen.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('BookmarksScreen renders title and empty state properly', (WidgetTester tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => BookmarkProvider()),
        ],
        child: MaterialApp(
          theme: AppTheme.darkTheme,
          home: const BookmarksScreen(),
        ),
      ),
    );

    await tester.pump();

    expect(find.text('ชั้นหนังสือของฉัน'), findsOneWidget);
    expect(find.text('ยังไม่มีนิยายในชั้นหนังสือ'), findsOneWidget);
  });
}
