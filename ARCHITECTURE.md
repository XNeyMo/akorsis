# Akorsis - Estructura del Proyecto

## 📂 Estructura Completa de Directorios

```
akorsis/
├── android/                              # Configuración nativa de Android
├── ios/                                  # Configuración nativa de iOS
├── lib/
│   ├── core/                            # Código compartido y utilidades
│   │   ├── error/
│   │   │   ├── exceptions.dart          # Excepciones personalizadas
│   │   │   └── failures.dart            # Clases de fallo
│   │   └── utils/
│   │       ├── constants.dart           # Constantes de la aplicación
│   │       └── typedef.dart             # Type aliases comunes
│   │
│   ├── domain/                          # CAPA DE DOMINIO (Lógica de negocio)
│   │   ├── entities/                    # Modelos de negocio puros
│   │   │   ├── goal.dart               # Entidad principal Goal
│   │   │   ├── milestone.dart          # Entidad Milestone
│   │   │   ├── level.dart              # Entidad Level
│   │   │   ├── progress_entry.dart     # Entidad ProgressEntry
│   │   │   └── achievement.dart        # Entidad Achievement
│   │   │
│   │   ├── repositories/               # Interfaces de repositorios
│   │   │   └── goal_repository.dart    # Contrato del repositorio
│   │   │
│   │   └── usecases/                   # Casos de uso (lógica de negocio)
│   │       ├── create_goal.dart        # UC: Crear meta
│   │       ├── get_all_goals.dart      # UC: Obtener todas las metas
│   │       ├── update_goal.dart        # UC: Actualizar meta
│   │       ├── delete_goal.dart        # UC: Eliminar meta
│   │       ├── update_progress.dart    # UC: Actualizar progreso
│   │       ├── complete_habit_for_today.dart  # UC: Completar hábito
│   │       ├── complete_milestone.dart # UC: Completar milestone
│   │       ├── complete_level.dart     # UC: Completar nivel
│   │       ├── export_goals.dart       # UC: Exportar datos
│   │       └── import_goals.dart       # UC: Importar datos
│   │
│   ├── data/                           # CAPA DE DATOS
│   │   ├── models/                     # Modelos de datos (con serialización)
│   │   │   ├── goal_model.dart        # Modelo Goal con JSON
│   │   │   ├── milestone_model.dart   # Modelo Milestone con JSON
│   │   │   ├── level_model.dart       # Modelo Level con JSON
│   │   │   └── progress_entry_model.dart  # Modelo ProgressEntry con JSON
│   │   │
│   │   ├── datasources/               # Fuentes de datos
│   │   │   └── local_data_source.dart # Acceso a SharedPreferences
│   │   │
│   │   └── repositories/              # Implementaciones de repositorios
│   │       └── goal_repository_impl.dart  # Implementación concreta
│   │
│   ├── presentation/                   # CAPA DE PRESENTACIÓN (UI)
│   │   ├── bloc/                      # Gestión de estado con BLoC
│   │   │   ├── goal_bloc.dart        # Lógica del BLoC
│   │   │   ├── goal_event.dart       # Eventos
│   │   │   └── goal_state.dart       # Estados
│   │   │
│   │   ├── screens/                   # Pantallas de la aplicación
│   │   │   ├── home_screen.dart      # Pantalla principal
│   │   │   ├── stats_screen.dart     # Pantalla de estadísticas
│   │   │   ├── settings_screen.dart  # Pantalla de configuración
│   │   │   └── create_goal_screen.dart   # Pantalla crear meta
│   │   │
│   │   ├── widgets/                   # Widgets reutilizables
│   │   │   ├── goal_card.dart        # Tarjeta de meta
│   │   │   └── stats_summary.dart    # Resumen de estadísticas
│   │   │
│   │   └── main_navigation.dart       # Navegación principal con BottomNav
│   │
│   ├── injection_container.dart        # Configuración de GetIt (DI)
│   └── main.dart                       # Punto de entrada de la app
│
├── test/                               # Tests unitarios e integración
│   └── widget_test.dart
│
├── pubspec.yaml                        # Dependencias y configuración
├── analysis_options.yaml               # Reglas de linting
└── README.md                           # Documentación del proyecto
```

## 🔄 Flujo de Datos (Clean Architecture)

```
┌─────────────────────────────────────────────────────────────┐
│                    PRESENTATION LAYER                        │
│  ┌──────────────┐     ┌──────────────┐     ┌─────────────┐ │
│  │   Screens    │────▶│     BLoC     │────▶│   Widgets   │ │
│  │              │     │  (Events &   │     │             │ │
│  │ - Home       │     │   States)    │     │ - GoalCard  │ │
│  │ - Stats      │     │              │     │ - Summary   │ │
│  │ - Settings   │     └──────┬───────┘     └─────────────┘ │
│  └──────────────┘            │                              │
└──────────────────────────────┼──────────────────────────────┘
                               │
                               ▼
┌─────────────────────────────────────────────────────────────┐
│                      DOMAIN LAYER                            │
│  ┌──────────────┐     ┌──────────────┐     ┌─────────────┐ │
│  │   Use Cases  │────▶│ Repositories │────▶│  Entities   │ │
│  │              │     │  (Interface) │     │             │ │
│  │ - CreateGoal │     │              │     │ - Goal      │ │
│  │ - UpdateGoal │     │ Repository   │     │ - Milestone │ │
│  │ - DeleteGoal │     │              │     │ - Level     │ │
│  └──────────────┘     └──────────────┘     └─────────────┘ │
└──────────────────────────────────────────────────────────────┘
                               │
                               ▼
┌─────────────────────────────────────────────────────────────┐
│                       DATA LAYER                             │
│  ┌──────────────┐     ┌──────────────┐     ┌─────────────┐ │
│  │ Repository   │────▶│  Data Source │────▶│   Models    │ │
│  │ Impl         │     │              │     │             │ │
│  │              │     │ SharedPrefs  │     │ - GoalModel │ │
│  │ (Concrete)   │     │              │     │ + toJson()  │ │
│  └──────────────┘     └──────────────┘     │ + fromJson()│ │
│                                             └─────────────┘ │
└─────────────────────────────────────────────────────────────┘
```

## 🎯 Principios de Clean Architecture Aplicados

### 1. **Dependency Rule (Regla de Dependencia)**
- Las capas externas dependen de las capas internas
- Las capas internas NO conocen las capas externas
- `Presentation → Domain ← Data`

### 2. **Separation of Concerns (Separación de Responsabilidades)**
- **Domain**: Lógica de negocio pura (sin dependencias externas)
- **Data**: Implementación de acceso a datos (SharedPreferences, APIs futuras)
- **Presentation**: UI y gestión de estado (BLoC)

### 3. **Dependency Injection (Inyección de Dependencias)**
- Uso de GetIt para inyección de dependencias
- Registro de servicios en `injection_container.dart`
- Facilita testing y mantenimiento

### 4. **Single Responsibility (Responsabilidad Única)**
- Cada Use Case tiene una única responsabilidad
- Cada widget/screen tiene un propósito específico
- Cada BLoC maneja un dominio específico

## 📊 Patrones de Diseño Utilizados

### 1. **Repository Pattern**
```dart
// Interface en Domain
abstract class GoalRepository {
  ResultFuture<List<Goal>> getAllGoals();
  ResultFuture<void> createGoal(Goal goal);
}

// Implementación en Data
class GoalRepositoryImpl implements GoalRepository {
  final LocalDataSource _localDataSource;
  // ... implementación
}
```

### 2. **BLoC Pattern (Business Logic Component)**
```dart
// Events
abstract class GoalEvent {}
class LoadGoals extends GoalEvent {}

// States
abstract class GoalState {}
class GoalsLoaded extends GoalState {
  final List<Goal> goals;
}

// BLoC
class GoalBloc extends Bloc<GoalEvent, GoalState> {
  // ... lógica
}
```

### 3. **Use Case Pattern**
```dart
class CreateGoal {
  final GoalRepository _repository;
  
  ResultVoid call(Goal goal) async {
    return _repository.createGoal(goal);
  }
}
```

### 4. **Dependency Injection Container**
```dart
final sl = GetIt.instance;

Future<void> init() async {
  // Registrar dependencias
  sl.registerFactory(() => GoalBloc(...));
  sl.registerLazySingleton(() => CreateGoal(sl()));
  sl.registerLazySingleton<GoalRepository>(() => GoalRepositoryImpl(sl()));
}
```

## 🔐 Gestión de Estado con BLoC

```
User Action → Event → BLoC → Use Case → Repository → Data Source
                ↓
            State Change
                ↓
             UI Update
```

## 📱 Navegación

```
MainNavigation (BottomNavigationBar)
├── HomeScreen (index 0)
│   └── FloatingActionButton → CreateGoalScreen
├── StatsScreen (index 1)
└── SettingsScreen (index 2)
```

## 💾 Persistencia de Datos

```
SharedPreferences
├── Key: "goals"
│   └── Value: JSON array de GoalModel
├── Key: "progress_entries"
│   └── Value: JSON array de ProgressEntryModel
└── Key: "achievements"
    └── Value: JSON array de AchievementModel
```

## 🧪 Testing Strategy

```
lib/                        test/
├── domain/                 ├── domain/
│   ├── entities/          │   ├── entities/
│   ├── usecases/          │   └── usecases/
│   └── repositories/      │
├── data/                   ├── data/
│   ├── models/            │   ├── models/
│   ├── datasources/       │   ├── datasources/
│   └── repositories/      │   └── repositories/
└── presentation/           └── presentation/
    ├── bloc/                  └── bloc/
    └── widgets/
```

## 🚀 Comandos Útiles

```bash
# Instalar dependencias
flutter pub get

# Ejecutar aplicación
flutter run

# Ejecutar en modo release
flutter run --release

# Ejecutar tests
flutter test

# Generar coverage
flutter test --coverage

# Analizar código
flutter analyze

# Formatear código
flutter format lib/

# Limpiar build
flutter clean

# Construir APK
flutter build apk --release

# Construir para iOS
flutter build ios --release
```

## 📚 Recursos Adicionales

- [Flutter Clean Architecture Guide](https://resocoder.com/flutter-clean-architecture-tdd/)
- [BLoC Pattern Documentation](https://bloclibrary.dev/)
- [GetIt Documentation](https://pub.dev/packages/get_it)
- [Dartz Functional Programming](https://pub.dev/packages/dartz)

---

**Última actualización**: Enero 2, 2026
