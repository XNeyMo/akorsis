import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'data/datasources/local_data_source.dart';
import 'injection_container.dart' as di;
import 'presentation/bloc/goal_bloc.dart';
import 'presentation/cubit/theme_cubit.dart';
import 'presentation/main_navigation.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Hive for encrypted storage
  await LocalDataSourceImpl.initialize();
  
  await di.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => di.sl<GoalBloc>()),
        BlocProvider(create: (_) => di.sl<ThemeCubit>()),
      ],
      child: BlocBuilder<ThemeCubit, ThemeMode>(
        builder: (context, themeMode) {
          return MaterialApp(
            title: 'Akorsis',
            debugShowCheckedModeBanner: false,
            themeMode: themeMode,
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(
                seedColor: const Color(0xFF1ABC9C),
                brightness: Brightness.light,
              ),
              scaffoldBackgroundColor: const Color(0xFFF5F7FA),
              useMaterial3: true,
              textTheme: GoogleFonts.interTextTheme(),
              fontFamily: GoogleFonts.inter().fontFamily,
            ),
            darkTheme: ThemeData(
              colorScheme: ColorScheme.fromSeed(
                seedColor: const Color(0xFF1ABC9C),
                brightness: Brightness.dark,
              ),
              scaffoldBackgroundColor: const Color(0xFF11131D),
              useMaterial3: true,
              textTheme: GoogleFonts.interTextTheme(),
              fontFamily: GoogleFonts.inter().fontFamily,
            ),
            home: const MainNavigation(),
          );
        },
      ),
    );
  }
}

