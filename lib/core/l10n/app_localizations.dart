import 'package:flutter/material.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations) ??
        AppLocalizations(const Locale('es'));
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static final Map<String, Map<String, String>> _localizedValues = {
    'es': {
      // Settings Screen
      'settings': 'Ajustes',
      'customize_experience': 'Personaliza tu experiencia',
      'appearance': 'APARIENCIA',
      'dark_mode': 'Modo Oscuro',
      'dark_theme_active': 'Actualmente usando tema oscuro',
      'light_theme_active': 'Actualmente usando tema claro',
      'language': 'IDIOMA',
      'change_language': 'Cambiar Idioma',
      'current_language': 'Idioma actual',
      'spanish': 'Español',
      'english': 'Inglés',
      'data': 'DATOS',
      'export_data': 'Exportar Datos',
      'download_goals': 'Descargar todas tus metas',
      'import_data': 'Importar Datos',
      'import_goals': 'Importar metas',
      'clear_all_data': 'Borrar Todos los Datos',
      'delete_goals_progress': 'Eliminar todas las metas y progreso',
      'about': 'ACERCA DE',
      'version': 'Versión',
      'app_description': 'Tu compañero de crecimiento personal. Rastrea metas, construye hábitos y alcanza logros con una experiencia hermosa y motivadora.',
      'made_with_love': 'Hecho con ❤️ por ZENOEX',
      'journey': 'TU VIAJE',
      'goals_created': 'Metas Creadas',
      'completed': 'Completadas',
      'best_streaks': 'Mejor Racha',
      
      // Dialogs
      'clear_data_title': 'Borrar Todos los Datos',
      'clear_data_message': '¿Estás seguro de que quieres eliminar todas tus metas y progreso? Esta acción no se puede deshacer.',
      'cancel': 'Cancelar',
      'delete': 'Eliminar',
      'all_data_cleared': 'Todos los datos han sido borrados',
      'backup_saved': 'Respaldo guardado en',
      'data_imported': 'Datos importados exitosamente',
      'import_failed': 'Error al importar',
      
      // Home Screen
      'home': 'Inicio',
      'your_goals': 'Tus Metas',
      'no_goals': 'Aún no tienes metas',
      'create_first_goal': 'Toca + para crear tu primera meta',
      'create_goal': 'Crear Meta',
      'add_goal': 'Agregar Meta',
      'good_morning': 'Buenos días',
      'good_afternoon': 'Buenas tardes',
      'good_evening': 'Buenas noches',
      'all_goals': 'Todas',
      
      // Stats Screen
      'stats': 'Estadísticas',
      'statistics': 'Estadísticas',
      'your_progress_overview': 'Tu resumen de progreso',
      'overall_progress': 'PROGRESO GENERAL',
      'goals_completed_of': 'metas completadas de',
      'overview': 'Resumen',
      'total_goals': 'Metas Totales',
      'active': 'Activas',
      'progress': 'Progreso',
      'active_streaks': 'Rachas Activas',
      'best_streak': 'Mejor Racha',
      'goals_by_type': 'Metas por Tipo',
      'goals_by_category': 'Metas por Categoría',
      'no_data_available': 'No hay datos disponibles',
      'goals': 'metas',
      
      // Goal Types
      'numeric': 'Numérica',
      'numeric_goals': 'Metas Numéricas',
      'habit': 'Hábito',
      'habits': 'Hábitos',
      'habit_streaks': 'Rachas de Hábitos',
      'milestone': 'Hitos',
      'milestones': 'Hitos',
      'levels': 'Niveles',
      
      // Categories
      'health': 'Salud',
      'finance': 'Finanzas',
      'learning': 'Aprendizaje',
      'career': 'Carrera',
      'personal': 'Personal',
      'fitness': 'Fitness',
      'creative': 'Creativo',
      'social': 'Social',
      
      // Common
      'save': 'Guardar',
      'edit': 'Editar',
      'close': 'Cerrar',
      'confirm': 'Confirmar',
      'today': 'Hoy',
      'streak': 'Racha',
      'days': 'días',
      'of': 'de',
    },
    'en': {
      // Settings Screen
      'settings': 'Settings',
      'customize_experience': 'Customize your experience',
      'appearance': 'APPEARANCE',
      'dark_mode': 'Dark Mode',
      'dark_theme_active': 'Currently using dark theme',
      'light_theme_active': 'Currently using light theme',
      'language': 'LANGUAGE',
      'change_language': 'Change Language',
      'current_language': 'Current language',
      'spanish': 'Spanish',
      'english': 'English',
      'data': 'DATA',
      'export_data': 'Export Data',
      'download_goals': 'Download all your goals',
      'import_data': 'Import Data',
      'import_goals': 'Import goals',
      'clear_all_data': 'Clear All Data',
      'delete_goals_progress': 'Delete all goals and progress',
      'about': 'ABOUT',
      'version': 'Version',
      'app_description': 'Your personal growth companion. Track goals, build habits, and achieve milestones with a beautiful, motivating experience.',
      'made_with_love': 'Made with ❤️ by ZENOEX',
      'journey': 'YOUR JOURNEY',
      'goals_created': 'Goals Created',
      'completed': 'Completed',
      'best_streaks': 'Best Streak',
      
      // Dialogs
      'clear_data_title': 'Clear All Data',
      'clear_data_message': 'Are you sure you want to delete all your goals and progress? This action cannot be undone.',
      'cancel': 'Cancel',
      'delete': 'Delete',
      'all_data_cleared': 'All data has been cleared',
      'backup_saved': 'Backup saved to',
      'data_imported': 'Data imported successfully',
      'import_failed': 'Import failed',
      
      // Home Screen
      'home': 'Home',
      'your_goals': 'Your Goals',
      'no_goals': 'No goals yet',
      'create_first_goal': 'Tap + to create your first goal',
      'create_goal': 'Create Goal',
      'add_goal': 'Add Goal',
      'good_morning': 'Good morning',
      'good_afternoon': 'Good afternoon',
      'good_evening': 'Good evening',
      'all_goals': 'All Goals',
      
      // Stats Screen
      'stats': 'Stats',
      'statistics': 'Statistics',
      'your_progress_overview': 'Your progress overview',
      'overall_progress': 'OVERALL PROGRESS',
      'goals_completed_of': 'goals completed of',
      'overview': 'Overview',
      'total_goals': 'Total Goals',
      'active': 'Active',
      'progress': 'Progress',
      'active_streaks': 'Active Streaks',
      'best_streak': 'Best Streak',
      'goals_by_type': 'Goals by Type',
      'goals_by_category': 'Goals by Category',
      'no_data_available': 'No data available',
      'goals': 'goals',
      
      // Goal Types
      'numeric': 'Numeric',
      'numeric_goals': 'Numeric Goals',
      'habit': 'Habit',
      'habits': 'Habits',
      'habit_streaks': 'Habit Streaks',
      'milestone': 'Milestone',
      'milestones': 'Milestones',
      'levels': 'Levels',
      
      // Categories
      'health': 'Health',
      'finance': 'Finance',
      'learning': 'Learning',
      'career': 'Career',
      'personal': 'Personal',
      'fitness': 'Fitness',
      'creative': 'Creative',
      'social': 'Social',
      
      // Common
      'save': 'Save',
      'edit': 'Edit',
      'close': 'Close',
      'confirm': 'Confirm',
      'today': 'Today',
      'streak': 'Streak',
      'days': 'days',
      'of': 'of',
    },
  };

  String translate(String key) {
    return _localizedValues[locale.languageCode]?[key] ?? 
           _localizedValues['en']?[key] ?? 
           key;
  }

  // Convenience getters for common translations
  String get settings => translate('settings');
  String get customizeExperience => translate('customize_experience');
  String get appearance => translate('appearance');
  String get darkMode => translate('dark_mode');
  String get darkThemeActive => translate('dark_theme_active');
  String get lightThemeActive => translate('light_theme_active');
  String get language => translate('language');
  String get changeLanguage => translate('change_language');
  String get currentLanguage => translate('current_language');
  String get spanish => translate('spanish');
  String get english => translate('english');
  String get data => translate('data');
  String get exportData => translate('export_data');
  String get downloadGoals => translate('download_goals');
  String get importData => translate('import_data');
  String get importGoals => translate('import_goals');
  String get clearAllData => translate('clear_all_data');
  String get deleteGoalsProgress => translate('delete_goals_progress');
  String get about => translate('about');
  String get version => translate('version');
  String get appDescription => translate('app_description');
  String get madeWithLove => translate('made_with_love');
  String get journey => translate('journey');
  String get goalsCreated => translate('goals_created');
  String get completed => translate('completed');
  String get bestStreaks => translate('best_streaks');
  String get clearDataTitle => translate('clear_data_title');
  String get clearDataMessage => translate('clear_data_message');
  String get cancel => translate('cancel');
  String get delete => translate('delete');
  String get allDataCleared => translate('all_data_cleared');
  String get backupSaved => translate('backup_saved');
  String get dataImported => translate('data_imported');
  String get importFailed => translate('import_failed');
  String get home => translate('home');
  String get yourGoals => translate('your_goals');
  String get noGoals => translate('no_goals');
  String get createFirstGoal => translate('create_first_goal');
  String get createGoal => translate('create_goal');
  String get addGoal => translate('add_goal');
  String get stats => translate('stats');
  String get overview => translate('overview');
  String get totalGoals => translate('total_goals');
  String get active => translate('active');
  String get progress => translate('progress');
  
  // Home Screen
  String get goodMorning => translate('good_morning');
  String get goodAfternoon => translate('good_afternoon');
  String get goodEvening => translate('good_evening');
  String get allGoals => translate('all_goals');
  
  // Stats Screen
  String get statistics => translate('statistics');
  String get yourProgressOverview => translate('your_progress_overview');
  String get overallProgress => translate('overall_progress');
  String get goalsCompletedOf => translate('goals_completed_of');
  String get activeStreaks => translate('active_streaks');
  String get bestStreak => translate('best_streak');
  String get goalsByType => translate('goals_by_type');
  String get goalsByCategory => translate('goals_by_category');
  String get noDataAvailable => translate('no_data_available');
  String get goals => translate('goals');
  
  // Goal Types
  String get numeric => translate('numeric');
  String get numericGoals => translate('numeric_goals');
  String get habit => translate('habit');
  String get habits => translate('habits');
  String get habitStreaks => translate('habit_streaks');
  String get milestone => translate('milestone');
  String get milestones => translate('milestones');
  String get levels => translate('levels');
  
  // Categories
  String get health => translate('health');
  String get finance => translate('finance');
  String get learning => translate('learning');
  String get career => translate('career');
  String get personal => translate('personal');
  String get fitness => translate('fitness');
  String get creative => translate('creative');
  String get social => translate('social');
  
  // Common
  String get save => translate('save');
  String get edit => translate('edit');
  String get close => translate('close');
  String get confirm => translate('confirm');
  String get today => translate('today');
  String get streak => translate('streak');
  String get days => translate('days');
  String get ofWord => translate('of');
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['en', 'es'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
