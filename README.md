# Akorsis 🎯

Una aplicación móvil Flutter para el seguimiento de metas personales construida con Clean Architecture.

## 📱 Características

Akorsis te ayuda a rastrear y lograr tus metas de año nuevo con:

- **4 tipos de metas:**
  - **Numéricas**: Rastrea el progreso hacia un número objetivo (ej: leer 12 libros)
  - **Hábitos**: Construye rachas con acciones diarias (ej: meditar diariamente)
  - **Milestones**: Completa fases paso a paso (ej: aprender un idioma por niveles)
  - **Niveles**: Progresa a través de niveles de habilidad (ej: Principiante → Experto)

- **8 categorías:**
  - Salud, Finanzas, Aprendizaje, Carrera
  - Personal, Fitness, Creativo, Social

- **Características principales:**
  - Dashboard con estadísticas en tiempo real
  - Vista de estadísticas detalladas
  - Exportar/Importar datos en formato JSON
  - Almacenamiento local (sin necesidad de cuenta)
  - Interfaz hermosa con degradados teal/purple

## 🏗️ Arquitectura

El proyecto sigue los principios de **Clean Architecture** con tres capas principales:

```
lib/
├── core/
│   ├── error/
│   │   ├── exceptions.dart
│   │   └── failures.dart
│   └── utils/
│       ├── constants.dart
│       └── typedef.dart
├── domain/
│   ├── entities/
│   │   ├── goal.dart
│   │   ├── milestone.dart
│   │   ├── level.dart
│   │   ├── progress_entry.dart
│   │   └── achievement.dart
│   ├── repositories/
│   │   └── goal_repository.dart
│   └── usecases/
│       ├── create_goal.dart
│       ├── get_all_goals.dart
│       ├── update_goal.dart
│       ├── delete_goal.dart
│       ├── update_progress.dart
│       ├── complete_habit_for_today.dart
│       ├── complete_milestone.dart
│       ├── complete_level.dart
│       ├── export_goals.dart
│       └── import_goals.dart
├── data/
│   ├── models/
│   │   ├── goal_model.dart
│   │   ├── milestone_model.dart
│   │   ├── level_model.dart
│   │   └── progress_entry_model.dart
│   ├── datasources/
│   │   └── local_data_source.dart
│   └── repositories/
│       └── goal_repository_impl.dart
├── presentation/
│   ├── bloc/
│   │   ├── goal_bloc.dart
│   │   ├── goal_event.dart
│   │   └── goal_state.dart
│   ├── screens/
│   │   ├── home_screen.dart
│   │   ├── stats_screen.dart
│   │   ├── settings_screen.dart
│   │   └── create_goal_screen.dart
│   ├── widgets/
│   │   ├── goal_card.dart
│   │   └── stats_summary.dart
│   └── main_navigation.dart
├── injection_container.dart
└── main.dart
```

### Capas de la Arquitectura

#### 1. **Domain Layer** (Capa de Dominio)
- **Entities**: Modelos de negocio puros sin dependencias externas
- **Repositories**: Interfaces que definen contratos
- **Use Cases**: Lógica de negocio específica (un caso de uso = una acción)

#### 2. **Data Layer** (Capa de Datos)
- **Models**: Extensiones de entidades con serialización JSON
- **Data Sources**: Acceso a datos locales (SharedPreferences)
- **Repository Implementations**: Implementaciones concretas de las interfaces

#### 3. **Presentation Layer** (Capa de Presentación)
- **BLoC**: Gestión de estado con flutter_bloc
- **Screens**: Pantallas de la aplicación
- **Widgets**: Componentes reutilizables de UI

## 📦 Dependencias Principales

```yaml
dependencies:
  flutter_bloc: ^8.1.6      # State management
  equatable: ^2.0.5         # Value equality
  get_it: ^8.0.2            # Dependency injection
  dartz: ^0.10.1            # Functional programming
  shared_preferences: ^2.3.3 # Local storage
  uuid: ^4.5.1              # UUID generation
  file_picker: ^8.1.4       # File import/export
```

## 🚀 Comenzar

### Requisitos Previos
- Flutter SDK (^3.10.4)
- Android Studio / VS Code
- Dispositivo Android/iOS o Emulador

### Instalación

1. **Clonar el repositorio**
```bash
git clone <repository-url>
cd akorsis
```

2. **Instalar dependencias**
```bash
flutter pub get
```

3. **Ejecutar la aplicación**
```bash
flutter run
```

## 📱 Pantallas

### Home
- Dashboard con estadísticas de resumen
- Lista de metas activas filtradas por tipo
- Botón flotante para crear nuevas metas

### Stats
- Progreso general en gráfico circular
- Total de metas, completadas, rachas activas
- Desglose por tipo de meta
- Desglose por categoría

### Settings
- Modo oscuro (por implementar)
- Exportar datos como JSON
- Importar datos desde archivo JSON
- Limpiar todos los datos
- Información de la aplicación
- Estadísticas de tu viaje

## 🗂️ Almacenamiento de Datos

Los datos se almacenan localmente usando **SharedPreferences**:

```dart
// Estructura de exportación
{
  "version": "1.0.0",
  "exportDate": "2026-01-02T...",
  "goals": [
    {
      "id": "uuid",
      "title": "Leer 12 libros",
      "type": "numeric",
      "category": "learning",
      "targetValue": 12,
      "currentValue": 3,
      ...
    }
  ]
}
```

## 🎨 Paleta de Colores

- **Teal**: `#26C6DA` - Primario
- **Purple**: `#7E57C2` - Secundario
- **Blue**: `#42A5F5` - Acento
- **Orange**: `#FF9800` - Advertencia/Streaks

## 🔄 Casos de Uso Principales

### Crear Meta
```dart
final goal = Goal(
  id: uuid.v4(),
  title: 'Leer 12 libros',
  type: GoalType.numeric,
  category: GoalCategory.learning,
  targetValue: 12,
  currentValue: 0,
  unit: 'libros',
  createdAt: DateTime.now(),
  updatedAt: DateTime.now(),
);

context.read<GoalBloc>().add(CreateGoalEvent(goal));
```

### Actualizar Progreso
```dart
context.read<GoalBloc>().add(
  UpdateProgressEvent(goalId: 'goal-id', value: 3),
);
```

### Completar Hábito Diario
```dart
context.read<GoalBloc>().add(
  CompleteHabitEvent('habit-goal-id'),
);
```

## 🧪 Testing

```bash
# Ejecutar tests unitarios
flutter test

# Ejecutar tests con coverage
flutter test --coverage
```

## 📝 Próximas Características

- [ ] Implementar pantalla de creación de metas completa
- [ ] Pantalla de detalles de meta
- [ ] Modo oscuro
- [ ] Notificaciones push para recordatorios
- [ ] Gráficos de progreso histórico
- [ ] Sistema de logros/badges
- [ ] Sincronización en la nube (opcional)
- [ ] Compartir metas con amigos
- [ ] Widget de inicio para Android/iOS

## 🤝 Contribuciones

Las contribuciones son bienvenidas. Por favor:

1. Fork el proyecto
2. Crea una rama para tu feature (`git checkout -b feature/AmazingFeature`)
3. Commit tus cambios (`git commit -m 'Add some AmazingFeature'`)
4. Push a la rama (`git push origin feature/AmazingFeature`)
5. Abre un Pull Request

## 📄 Licencia

Este proyecto está bajo la Licencia MIT.

## 👨‍💻 Autor

Hecho con ❤️ para soñadores y triunfadores

---

**Versión**: 1.0.0

