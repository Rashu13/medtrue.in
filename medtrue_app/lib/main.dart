import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/master_provider.dart';
import 'providers/product_provider.dart';
import 'screens/masters/company_list_screen.dart';

void main() {
  runApp(const MedTrueApp());
}

class MedTrueApp extends StatelessWidget {
  const MedTrueApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MasterProvider()),
        ChangeNotifierProvider(create: (_) => ProductProvider()),
      ],
      child: MaterialApp(
        title: 'MedTrue ERP',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          // Modern color scheme based on Teal/Blue
          primarySwatch: Colors.teal,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal, secondary: Colors.amber),
          useMaterial3: true,
          appBarTheme: const AppBarTheme(
            centerTitle: true,
            elevation: 2,
          ),
        ),
        home: const CompanyListScreen(),
      ),
    );
  }
}
