# 📖 Гайд по использованию Fortnite Creative UEFN

## 🎯 Что такое UEFN?

**UEFN** = Unreal Editor For Fortnite  
Это редактор для создания карт и логики в Fortnite Creative.

---

## 🚀 Быстрый старт

### 1. Установка UEFN
```bash
# Скачайте Epic Games Launcher
# Зайдите в Fortnite Creative
# Нажмите "Откройте в UEFN"
```

### 2. Открыть редактор
```
Fortnite Creative → Выбрать остров → Открыть в UEFN
```

### 3. Главный интерфейс
```
┌─────────────────────────────┐
│ Меню (File, Edit, View)     │
├─────────┬──────────┬────────┤
│ Assets  │ Viewport │ Details│
│ (слева) │ (центр)  │(справа)│
└─────────┴──────────┴────────┘
```

---

## 🎮 Основные устройства

### Spawn Pad (спавн)
**Функция**: Место где спаунятся игроки  
**Как использовать**:
1. Drag & Drop Spawn Pad с Assets
2. Поставьте на нужное место
3. Настройте параметры в Details

```
Properties:
- Team: None / Team 1 / Team 2
- Initial Spawn: Checked (первый спавн)
```

---

### Teleporter (телепортер)
**Функция**: Телепортирует игрока в другую локацию  
**Как использовать**:
1. Поставьте 2 Teleporter'а
2. Первый = вход
3. Второй = выход
4. Привяжите их друг к другу

```
Device Settings:
- Teleport Target: Выбрать другой телепортер
- Enable Teleport Volume: True
- Teleport Animation: True
```

---

### Stat Manager (управление статистикой)
**Функция**: Отслеживает переменные игрока (Gold, Level, etc.)  
**Как использовать**:
1. Поставьте Stat Manager
2. Создайте переменную "Gold"
3. Установите начальное значение 50

```
Creating Variable:
- Click "Add" in Stats
- Name: "Gold"
- Type: Integer
- Initial Value: 50
```

---

### Item Granter (выдача предметов)
**Функция**: Выдает предметы игроку  
**Как использовать**:
1. Поставьте Item Granter
2. Выберите предмет (например, Shotgun)
3. Настройте триггер (кнопка, зона, etc.)

```
Settings:
- Grant Item On: Button Pressed / Timer / etc.
- Item Type: Weapon / Item / Resource
- Quantity: 1
```

---

### Conditional Button (условная кнопка)
**Функция**: Кнопка с условиями (проверяет статистику)  
**Как использовать**:
1. Поставьте Conditional Button
2. Установите условие "If Gold >= 100"
3. При нажатии → выполнить действие

```
Conditions:
- Check Stat: Gold >= 100
- On Success: Output pulse → Item Granter
- On Failure: Show message "Not enough gold"
```

---

### AI Spawner (спавн врагов)
**Функция**: Спаунит и управляет врагами  
**Как использовать**:
1. Поставьте AI Spawner
2. Выберите тип врага (Zombie, Husk, etc.)
3. Установите волны

```
Settings:
- AI Type: Select from library
- Spawn Count: 5
- Wave Count: 5
- Wave Duration: 60 seconds
- Spawn on Event: Timer / Player Near / etc.
```

---

### Prop Mover (движение пропсов)
**Функция**: Двигает объекты (двери, платформы, враги)  
**Как использовать**:
1. Выберите объект
2. Поставьте Prop Mover device
3. Укажите путь движения

```
Settings:
- Move Target: Select prop
- Move Position: End location
- Move Duration: 2 seconds
- Loop: True/False
```

---

### Damage Volume (зона урона)
**Функция**: Область которая наносит урон  
**Как использовать**:
1. Поставьте Damage Volume
2. Установите размер коробки (сколько урона)
3. Настройте триггер (враг войдет = урон)

```
Settings:
- Damage Per Second: 10
- Enable Damage: True
- Team Damage: False (врагам не навредить друг другу)
```

---

### Countdown Manager (таймер)
**Функция**: Обратный отсчет с событиями  
**Как использовать**:
1. Поставьте Countdown Manager
2. Установите длительность (60 сек)
3. На finish → выполнить действие

```
Settings:
- Duration: 60 seconds
- Start on: Manual / Automatic / Event
- On Finish: Output → AI Spawner (следующая волна)
```

---

## 🔧 Verse-скрипты

### Где писать код?

1. **Открыть Verse Editor**:
   - Правый клик на Asset
   - Выберите "Create Verse File"

2. **Основной скелет**:
```verse
using { /Fortnite.com/Devices }
using { /UnrealEngine.com/Transient }

class MyScript:
    var player_gold: int = 50
    
    public Init() -> void:
        Print("Game started!")
    
    public AddGold(amount: int) -> void:
        player_gold += amount
        Print("Added gold! Total: {player_gold}")
```

3. **Скомпилировать**:
   - Ctrl + Shift + B
   - Или кнопка "Compile"

---

### Пример: Простая система Gold

```verse
# my_economy.verse
var player_gold: int = 50

func AddGold(amount: int) -> void:
    player_gold += amount
    UpdateHUD()

func SpendGold(amount: int) -> bool:
    if player_gold >= amount:
        player_gold -= amount
        return true
    return false

func UpdateHUD() -> void:
    Print("Gold: {player_gold}")
```

---

### Подключить скрипт к устройству

1. Выберите устройство (например, Conditional Button)
2. В Details найдите "Verse"
3. Выберите ваш скрипт
4. Установите функцию (например, "SpendGold(100)")

---

## 🎨 Основные команды

### Размещение объектов
```
Q + Drag = Move
R + Drag = Rotate
E + Drag = Scale
X/Y/Z = Ось движения
```

### Группировка
```
Ctrl + G = Group
Ctrl + Shift + G = Ungroup
```

### Сохранение
```
Ctrl + S = Save
Ctrl + Shift + S = Save As
```

---

## 🐛 Отладка

### Вывод информации
```verse
Print("Debug message")  # Выводит в консоль
Print("Gold: {player_gold}")  # С переменной
```

### Просмотр логов
```
Window → Output Log
```

### Тестирование
```
Play button (треугольник сверху)
Ctrl + P = Play in Viewport
```

---

## 📊 HUD и текст

### Text Renderer (вывод текста на экран)
```
1. Поставьте Text Renderer device
2. Подключите Stat Manager
3. Текст будет автоматически обновляться
```

### Настройки Text Renderer
```
- Text Size: 30
- Color: White/Red/Blue
- Position: Top Left / Top Right / Center
- Format: "Gold: {stat_name}"
```

---

## 🎬 События и триггеры

### Event on Player Joined
```verse
using { /Fortnite.com/Devices }

class PlayerJoinedDemo:
    public OnPlayerJoined(player: agent) -> void:
        Print("{player} joined the game!")
        # Выдать стартовое золото
```

### Event on Player Eliminated
```verse
public OnPlayerEliminated(player: agent) -> void:
    Print("{player} was eliminated!")
    # Потерять золото
```

---

## 📚 Полезные ссылки

- [Fortnite Creative UEFN Docs](https://dev.epicgames.com/documentation/en-us/uefn/uefn-overview)
- [Verse Language Reference](https://dev.epicgames.com/documentation/en-us/uefn/verse-language-reference)
- [Device Reference](https://dev.epicgames.com/documentation/en-us/uefn/fortnite-creative-devices)
- [Community Discord](https://discord.gg/fortnite)

---

## 💡 Tips & Tricks

✅ Используйте слои (Layers) для организации  
✅ Назначайте осмысленные имена объектам  
✅ Регулярно сохраняйте (Ctrl+S)  
✅ Тестируйте часто (Ctrl+P)  
✅ Используйте Debug Print для отладки  
✅ Не создавайте слишком сложные скрипты сразу  

---

**Последнее обновление**: 31.05.2026  
**Статус**: Полный гайд
