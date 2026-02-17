# Tests - Akorsis

Este directorio contiene todos los tests de la aplicación Akorsis, organizados según la arquitectura Clean Architecture.

## Estructura de Tests

```
test/
├── domain/
│   ├── entities/         # Tests de entidades
│   │   └── goal_test.dart
│   └── usecases/        # Tests de casos de uso
│       └── goal_usecases_test.dart
├── data/
│   ├── models/          # Tests de modelos de datos
│   │   └── goal_model_test.dart
│   └── repositories/    # Tests de repositorios
│       └── goal_repository_impl_test.dart
├── presentation/
│   └── bloc/           # Tests de BLoC/Cubit
│       └── goal_bloc_test.dart
└── widget_test.dart    # Tests de integración
```

## Cobertura de Tests

### 1. **Tests de Entidades (domain/entities/)**
- Creación de entidades Goal, Milestone, Level
- Validación de propiedades
- Funcionalidad copyWith
- Igualdad con Equatable
- Todos los tipos de metas (numeric, habit, milestone, levels)

### 2. **Tests de Casos de Uso (domain/usecases/)**
- CreateGoal: Crear nuevas metas
- UpdateGoal: Actualizar metas existentes
- DeleteGoal: Eliminar metas
- GetAllGoals: Obtener todas las metas
- GetGoalById: Obtener meta por ID
- UpdateProgress: Actualizar progreso de metas numéricas
- CompleteHabitForToday: Completar hábito del día
- CompleteMilestone: Completar milestone
- CompleteLevel: Completar nivel

### 3. **Tests de Modelos (data/models/)**
- Conversión de/a JSON
- Conversión de/a entidades
- Serialización de todos los tipos de metas
- Manejo de datos opcionales
- Validación de copyWith

### 4. **Tests de Repositorio (data/repositories/)**
- Operaciones CRUD de metas
- Actualización de progreso con auto-completado
- Cálculo de streaks de hábitos
- Prevención de duplicados en hábitos
- Completitud automática de milestone goals
- Actualización de índice de niveles
- Manejo de errores y excepciones

### 5. **Tests de BLoC (presentation/bloc/)**
- Todos los eventos del GoalBloc
- Transiciones de estados
- Manejo de errores
- Carga de datos
- Exportación/Importación
- Limpieza de datos

## Ejecutar Tests

### Todos los tests
```bash
flutter test
```

### Tests específicos
```bash
# Tests de entidades
flutter test test/domain/entities/

# Tests de casos de uso
flutter test test/domain/usecases/

# Tests de modelos
flutter test test/data/models/

# Tests de repositorio
flutter test test/data/repositories/

# Tests de BLoC
flutter test test/presentation/bloc/

# Un archivo específico
flutter test test/domain/entities/goal_test.dart
```

### Tests con cobertura
```bash
flutter test --coverage
```

### Ver reporte de cobertura (requiere lcov)
```bash
# Generar reporte HTML
genhtml coverage/lcov.info -o coverage/html

# Abrir en navegador (Windows)
start coverage/html/index.html
```

## Dependencias de Testing

- **flutter_test**: Framework de testing de Flutter
- **mocktail**: Librería de mocking moderna
- **bloc_test**: Testing específico para BLoCs
- **equatable**: Para comparación de objetos

## Buenas Prácticas

1. **Nomenclatura**: Los archivos de test deben terminar en `_test.dart`
2. **Organización**: Seguir la misma estructura que `lib/`
3. **AAA Pattern**: Arrange, Act, Assert
4. **Mocking**: Usar mocktail para dependencias externas
5. **Aislamiento**: Cada test debe ser independiente
6. **Descriptividad**: Nombres de tests claros y descriptivos

## Ejemplo de Test

```dart
test('should create a numeric goal with correct properties', () {
  // Arrange
  final goal = Goal(
    id: '1',
    title: 'Save Money',
    type: GoalType.numeric,
    category: GoalCategory.finance,
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
    targetValue: 10000,
    currentValue: 5000,
  );

  // Act & Assert
  expect(goal.id, '1');
  expect(goal.title, 'Save Money');
  expect(goal.type, GoalType.numeric);
});
```

## Tests Futuros

- [ ] Tests de widgets específicos
- [ ] Tests de integración completos
- [ ] Tests de UI automatizados
- [ ] Tests de rendimiento
- [ ] Tests de accesibilidad
