
import 'package:flutter/material.dart';

class AppTheme {
	static const MaterialColor _greenSwatch = MaterialColor(
		0xFF2E7D32,
		<int, Color>{
			50: Color(0xFFE8F5E9),
			100: Color(0xFFC8E6C9),
			200: Color(0xFFA5D6A7),
			300: Color(0xFF81C784),
			400: Color(0xFF66BB6A),
			500: Color(0xFF4CAF50),
			600: Color(0xFF43A047),
			700: Color(0xFF388E3C),
			800: Color(0xFF2E7D32),
			900: Color(0xFF1B5E20),
		},
	);

	static final ThemeData lightTheme = ThemeData(
		primarySwatch: _greenSwatch,
		primaryColor: _greenSwatch[700],
		scaffoldBackgroundColor: Colors.grey.shade50,
		colorScheme: ColorScheme.fromSwatch(primarySwatch: _greenSwatch).copyWith(
			secondary: _greenSwatch[300],
		),
		appBarTheme: AppBarTheme(
			backgroundColor: _greenSwatch[700],
			foregroundColor: Colors.white,
			elevation: 1,
			centerTitle: true,
			titleTextStyle: _safePoppins(
				fontSize: 18,
				fontWeight: FontWeight.w600,
				color: Colors.white,
			),
		),
		cardTheme: const CardThemeData(
			shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
			elevation: 4,
			margin: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
		),
		elevatedButtonTheme: ElevatedButtonThemeData(
			style: ElevatedButton.styleFrom(
				backgroundColor: _greenSwatch[600],
				shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
				textStyle: _safePoppins(fontWeight: FontWeight.w600),
			),
		),
		textTheme: _safePoppinsTextTheme(ThemeData.light().textTheme).copyWith(
			titleLarge: _safePoppins(fontSize: 18, fontWeight: FontWeight.w600),
			bodyMedium: _safePoppins(fontSize: 14),
			titleMedium: _safePoppins(fontSize: 13, color: Colors.grey[800]),
			bodySmall: _safePoppins(fontSize: 12, color: Colors.grey[600]),
		),
	);

	static final ThemeData darkTheme = ThemeData.dark().copyWith(
		primaryColor: _greenSwatch[700],
		colorScheme: ColorScheme.fromSwatch(brightness: Brightness.dark, primarySwatch: _greenSwatch).copyWith(secondary: _greenSwatch[300]),
		scaffoldBackgroundColor: const Color(0xFF0B0F0A),
		appBarTheme: AppBarTheme(
			backgroundColor: _greenSwatch[900],
			foregroundColor: Colors.white,
			elevation: 1,
			centerTitle: true,
			titleTextStyle: _safePoppins(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white),
		),
		cardTheme: const CardThemeData(
			shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
			elevation: 2,
			margin: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
		),
		textTheme: _safePoppinsTextTheme(ThemeData.dark().textTheme).copyWith(
			titleLarge: _safePoppins(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white),
			bodyMedium: _safePoppins(fontSize: 14, color: Colors.white70),
			titleMedium: _safePoppins(fontSize: 13, color: Colors.white70),
			bodySmall: _safePoppins(fontSize: 12, color: Colors.white60),
		),
	);
}

TextStyle _safePoppins({double? fontSize, FontWeight? fontWeight, Color? color}) {
	return TextStyle(fontSize: fontSize, fontWeight: fontWeight, color: color);
}

TextTheme _safePoppinsTextTheme(TextTheme base) {
	return base;
}

