// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ecohelper/main.dart';
import 'package:ecohelper/screens/splash_screen.dart';
import 'package:ecohelper/screens/main_nav.dart';
import 'package:ecohelper/screens/home_screen.dart';
import 'package:ecohelper/bloc/article_bloc.dart';
import 'package:ecohelper/bloc/article_event.dart';
import 'package:ecohelper/bloc/article_state.dart';
import 'package:ecohelper/services/api_service.dart';
import 'package:ecohelper/models/article_model.dart';

void main() {
  group('EcoHelper App Tests', () {
    testWidgets('App builds correctly with MaterialApp', (WidgetTester tester) async {
      await tester.pumpWidget(const EcoHelperApp());
      expect(find.byType(MaterialApp), findsOneWidget);
    });

    testWidgets('App starts with SplashScreen', (WidgetTester tester) async {
      await tester.pumpWidget(const EcoHelperApp());
      await tester.pump();
      expect(find.byType(SplashScreen), findsOneWidget);
      expect(find.text('EcoHelper'), findsOneWidget);
    });

    testWidgets('MainNav has 5 bottom navigation items', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: MainNav(),
        ),
      );

      expect(find.byType(BottomNavigationBar), findsOneWidget);
      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Articles'), findsOneWidget);
      expect(find.text('Pohon'), findsOneWidget);
      expect(find.text('Bookmark'), findsOneWidget);
      expect(find.text('Profile'), findsOneWidget);
    });

    testWidgets('HomeScreen renders hero banner', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: HomeScreen(),
        ),
      );

      expect(find.text('Selamat Datang!'), findsOneWidget);
      expect(find.text('Belajar. Beraksi. Berbagi.'), findsOneWidget);
      expect(find.byIcon(Icons.eco), findsOneWidget);
    });

    testWidgets('HomeScreen has challenge section', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: HomeScreen(),
        ),
      );

      expect(find.text('Tantangan Hari Ini'), findsOneWidget);
      expect(find.byIcon(Icons.emoji_events), findsOneWidget);
    });
  });

  group('Article BLoC Tests', () {
    late ArticleBloc articleBloc;
    late ApiService apiService;

    setUp(() {
      apiService = ApiService();
      articleBloc = ArticleBloc(apiService: apiService);
    });

    tearDown(() {
      articleBloc.close();
    });

    test('Initial state is ArticleInitial', () {
      expect(articleBloc.state, isA<ArticleInitial>());
    });

    test('LoadArticlesEvent emits ArticleLoaded with articles', () async {
      final expectedStates = [
        isA<ArticleLoading>(),
        isA<ArticleLoaded>(),
      ];

      expectLater(
        articleBloc.stream,
        emitsInOrder(expectedStates),
      );

      articleBloc.add(const LoadArticlesEvent());

      await Future.delayed(const Duration(seconds: 1));
      
      expect(articleBloc.state, isA<ArticleLoaded>());
      final loadedState = articleBloc.state as ArticleLoaded;
      expect(loadedState.articles.isNotEmpty, true);
    });

    test('SearchArticlesEvent filters articles correctly', () async {
      articleBloc.add(const SearchArticlesEvent('plastik'));

      await Future.delayed(const Duration(seconds: 1));

      expect(articleBloc.state, isA<ArticleLoaded>());
      final loadedState = articleBloc.state as ArticleLoaded;
      expect(loadedState.searchQuery, 'plastik');
      expect(loadedState.articles.isNotEmpty, true);
    });

    test('LoadArticlesByCategoryEvent filters by category', () async {
      articleBloc.add(const LoadArticlesByCategoryEvent('Sampah'));

      await Future.delayed(const Duration(seconds: 1));

      expect(articleBloc.state, isA<ArticleLoaded>());
      final loadedState = articleBloc.state as ArticleLoaded;
      expect(loadedState.activeCategory, 'Sampah');
      expect(loadedState.articles.isNotEmpty, true);
      
      for (var article in loadedState.articles) {
        expect(article.category.toLowerCase(), 'sampah');
      }
    });
  });

  group('ApiService Tests', () {
    late ApiService apiService;

    setUp(() {
      apiService = ApiService();
    });

    test('fetchArticles returns list of articles', () async {
      final articles = await apiService.fetchArticles();
      expect(articles, isA<List<Article>>());
      expect(articles.isNotEmpty, true);
    });

    test('fetchArticlesByCategory returns filtered articles', () async {
      final articles = await apiService.fetchArticlesByCategory('Energi');
      expect(articles.isNotEmpty, true);
      
      for (var article in articles) {
        expect(article.category.toLowerCase(), 'energi');
      }
    });

    test('searchArticles returns matching articles', () async {
      final articles = await apiService.searchArticles('hemat');
      expect(articles.isNotEmpty, true);
    });

    test('fetchArticleById returns correct article', () async {
      final article = await apiService.fetchArticleById('a1');
      expect(article, isNotNull);
      expect(article?.id, 'a1');
    });

    test('fetchArticleById with invalid id returns null', () async {
      final article = await apiService.fetchArticleById('invalid_id');
      expect(article, isNull);
    });
  });

  group('Article Model Tests', () {
    test('Article model creates correctly', () {
      final article = Article(
        id: 'test1',
        title: 'Test Title',
        subtitle: 'Test Subtitle',
        content: 'Test Content',
        category: 'Test',
        date: DateTime(2025, 1, 1),
      );

      expect(article.id, 'test1');
      expect(article.title, 'Test Title');
      expect(article.subtitle, 'Test Subtitle');
      expect(article.content, 'Test Content');
      expect(article.category, 'Test');
      expect(article.imageUrl, isNull);
    });
  });

  group('Integration Tests', () {
    testWidgets('Navigation between tabs works', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: MainNav(),
        ),
      );

      // Tap Articles tab
      await tester.tap(find.text('Articles'));
      await tester.pumpAndSettle();

      // Should render articles screen (or content)
      expect(find.byType(BottomNavigationBar), findsOneWidget);

      // Tap Home tab
      await tester.tap(find.text('Home'));
      await tester.pumpAndSettle();

      expect(find.byType(BottomNavigationBar), findsOneWidget);
    });
  });
}

