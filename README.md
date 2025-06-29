# ReviewsApp - iOS Application

## Описание проекта

ReviewsApp - это iOS приложение для отображения отзывов пользователей

## Запуск проекта

Для выполнения задания был развернут локальный сервер, для полной имитации работы с сетью.

### Клонировать backend сервер: 
   ```bash
    https://github.com/artem-krisanovv/ReviewServer.git
    ```

1. Перейдите в терминале в папку сервера:
   ```bash
   cd ReviewServer
   ```

2. Запустите сервер:
   ```bash
   swift run
   ```

3. Дождитесь сообщения:
   ```
   Running at 8080
   ```

4. Сервер готов


### Приложение

1. Откройте `Test.xcodeproj` в Xcode

2. Выберите симулятор или устройство

3. Нажмите `Cmd + R` для запуска. На этот момент должен быть включен сервер (шаги выше)

## Архитектура проекта

### Основные принципы архитектуры

Проект построен на основе **MVVM (Model-View-ViewModel)** архитектуры с дополнительными паттернами:

- **MVVM** - для разделения логики и интерфейса
- **Dependency Injection** - для управления зависимостями
- **Protocol-Oriented Programming** - для обеспечения тестируемости и гибкости


## Технические решения

### 1. Сетевой слой

Использование `async/await` для асинхронных запросов, протокол-ориентированный подход для тестируемости, обработка ошибок через `NetworkError` enum.

```swift
protocol NetworkServiceProtocol {
    func request<T: Decodable>(_ endpoint: String) async throws -> T
}
```

### 2. Система кэширования изображений

Адаптивный размер кэша на основе доступной памяти устройства, thread-safe операции с использованием `DispatchQueue`, умная очистка при нехватке памяти.

```swift
let physicalMemory = ProcessInfo.processInfo.physicalMemory
let maxCacheSize = min(50 * 1024 * 1024, Int(Double(physicalMemory) * 0.25))
```

### 3. Dependency Injection

Централизованное управление зависимостями:

```swift
final class DIContainer {
    static let shared = DIContainer()
    
    lazy var networkService: NetworkServiceProtocol = {
        NetworkService()
    }()
    
    lazy var imageService: ImageServiceProtocol = {
        ImageService(cache: imageCache)
    }()
}
```

### 4. MVVM реализация

**ViewModel** - централизованное управление состоянием, асинхронная загрузка, оптимизация производительности.

**View** - программное создание UI с Auto Layout, поддержка pull-to-refresh.

**Controller** - обработка пользовательских действий, управление состоянием UI.

## Backend Server

### Технологии

- Swift + Swifter framework
- REST API с поддержкой фильтрации
- JSON формат данных

## Производительность

### Оптимизации

1. Кэширование изображений с адаптивным размером
2. Загрузка данных по требованию
3. Автоматическая очистка неиспользуемых ресурсов
4. Асинхронная загрузка в фоне

## Демонстрация навыков

Этот проект показывает, что я умею:

- Работать с современными архитектурными паттернами в iOS (MVVM, DI)
- Писать асинхронный код с использованием async/await
- Оптимизировать производительность приложений
- Правильно управлять памятью и избегать утечек
- Создавать масштабируемый и поддерживаемый код
- Разрабатывать backend на Swift
- Проектировать REST API
- Думать о пользовательском опыте

