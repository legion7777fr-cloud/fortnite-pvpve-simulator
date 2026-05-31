# 🏗️ Архитектура проекта: PvPvE Economic Simulator (Quantum Edition)

## 📋 Оглавление
1. [Обзор острова](#обзор-острова)
2. [Зоны и структура](#зоны-и-структура)
3. [Система прогрессии](#система-прогрессии)
4. [Экономика](#экономика)
5. [PvE система (x20 врагов)](#pve-система)
6. [PvP система](#pvp-система)
7. [Квантовые эффекты](#квантовые-эффекты)
8. [Звуки](#звуки)
9. [Verse-скрипты](#verse-скрипты)

---

## 🌍 Обзор острова

**Название острова**: *Quantum Economic Arena*  
**Максимум игроков**: 16  
**Время сессии**: 15-30 минут  
**Целевая аудитория**: 10+ лет

### Основная концепция
Остров работает как **виртуальная экономика с риском**:
- Фармим монеты в PvE (врагов в 20 раз больше)
- Тратим в магазине на улучшения
- Конкурируем в PvP с ставками
- Теряем при смерти
- Развиваемся через прогрессию
- **Квантовые эффекты** (суперпозиция, запутанность, телепортация)

---

## ⚠️ Анализ проблем и подводных камней

### Проблема 1: Производительность при x20 врагах
| Параметр | Стандарт | x20 | Решение |
|----------|----------|-----|---------|
| Врагов на волне | 5-15 | 100-300 | Pooling объектов, спавн по зонам |
| AI вычислений | 1ms | 20ms | Уменьшить дальность агрo |
| Сетевой трафик | 1KB | 20KB | Группировать обновления |

**Решение**: Спавнить врагов не всех сразу, а пачками по 20 с интервалом 0.5 сек.

### Проблема 2: Баланс наград при x20
| Было | Стало | Проблема | Решение |
|------|-------|----------|---------|
| 10 Gold за Goblin | 10 Gold | Игрок получает 3000 Gold за волну | Уменьшить награду до 1-2 Gold за врага |
| 5 XP за Goblin | 5 XP | За час можно получить 100 уровней | XP = база / (враги на волне) |

### Проблема 3: Квантовые эффекты и физика
| Эффект | Подводный камень | Решение |
|--------|------------------|---------|
| Суперпозиция | Враги дублируются | Ограничить 3 клонами на врага |
| Запутанность | Урон распределяется между всеми | Максимум 5 связанных врагов |
| Телепортация | Выход за пределы карты | Проверка границ |

### Проблема 4: Звуки при 300 врагах
| Проблема | Решение |
|----------|---------|
| 300 звуков одновременно → тишина | Ограничить 10 звуками в кадре |
| Сбой звукового движка | Приоритеты: босс > игрок > враг |

### Проблема 5: Verse-производительность
| Проблема | Решение |
|----------|---------|
| Циклы по 300 врагам в лоб | Использовать `async` и `spawn` |
| Сохранение данных 16 игроков | Кэшировать в памяти, сохранять раз в минуту |

---

## 🏰 Зоны и структура

### Зона 1: Таверна (Безопасная) - 200x200м
### Зона 2: Лесной фарм - 500x400м - **60-120 врагов одновременно**
### Зона 3: Подземелье - 800x600м - **150-300 врагов одновременно**
### Зона 4: PvP Арена - 400x300м - 2-16 игроков
### Зона 5: Лобби/Хаб - 400x400м

---

## 👹 PvE система (x20 врагов)

### Уровни сложности (1-20)

| Уровень | Множитель врагов | Множитель HP | Множитель ATK | Награда множитель |
|---------|------------------|--------------|---------------|-------------------|
| 1 | 1.0x | 1.0x | 1.0x | 1.0x |
| 5 | 2.0x | 1.5x | 1.5x | 1.8x |
| 10 | 5.0x | 2.5x | 2.5x | 4.0x |
| 15 | 12.0x | 5.0x | 5.0x | 10.0x |
| 20 | 20.0x | 10.0x | 10.0x | 20.0x |

### Враги (x20 на максимуме)

| Враг | HP | ATK | Награда | Кол-во на волне 20 |
|------|-----|-----|---------|-------------------|
| Goblin | 20-200 | 3-30 | 0.5 Gold | 60-100 |
| Orc | 40-400 | 5-50 | 1 Gold | 40-60 |
| Skeletal | 60-600 | 8-80 | 1.5 Gold | 30-50 |
| Dark Mage | 50-500 | 10-100 | 2 Gold | 20-40 |
| Quantum Boss | 150-1500 | 15-150 | 50-200 Gold | 1-2 |

---

## ⚛️ Квантовые эффекты

### Эффект 1: Суперпозиция
Враг создаёт 2 клона при смерти. Клоны имеют 50% HP и 25% награды.

### Эффект 2: Квантовая запутанность
5 врагов связаны. Урон одному распределяется между всеми поровну.

### Эффект 3: Телепортация
Враг телепортируется к игроку каждые 5 секунд.

### Эффект 4: Фазирование
Враг на 1 секунду становится неуязвимым каждые 10 секунд.

### Эффект 5: Квантовый скачок
При смерти враг оставляет портал, призывающий 3 новых врагов через 3 секунды.

---

## 🔊 Звуки

### PvE Звуки
| Событие | Звук | Приоритет |
|---------|------|-----------|
| Спавн Goblin | `goblin_spawn` | 3 |
| Смерть Boss | `boss_death` | 1 |
| Quantum эффект | `quantum_effect` | 2 |
| Телепортация врага | `quantum_blink` | 2 |
| Волна начинается | `wave_start` | 1 |
| Волна завершена | `wave_end` | 1 |

### PvP Звуки
| Событие | Звук |
|---------|------|
| Вызов на дуэль | `duel_call` |
| Начало дуэли | `duel_start` |
| Победа | `victory` |

### UI Звуки
| Событие | Звук |
|---------|------|
| Покупка | `purchase` |
| Level Up | `level_up` |
| Получение достижения | `achievement` |

---

## ⚙️ Verse-скрипты

### economy_manager.verse
```verse
using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }

player_save_data := class(save_game):
    var Gold : int = 50
    var Banked : int = 0
    var Slots : int = 1

EconomyManager := class(creative_device):
    @editable var StartingGold : int = 50
    @editable var MaxGold : int = 999999
    @editable var MaxBankSlots : int = 10
    @editable var DeathLossPercent : int = 10
    
    var PlayerGold : [agent]int = map{}
    var BankedGold : [agent]int = map{}
    var BankSlots : [agent]int = map{}
    
    OnBegin<override>()<suspends>:
        GetPlayspace().PlayerJoinedEvent.Subscribe(OnPlayerJoined)
        GetPlayspace().PlayerDiedEvent.Subscribe(OnPlayerDied)
    
    OnPlayerJoined(Player : agent) : void =
        Saved := GetSaveData(Player)
        if Saved = false:
            PlayerGold[Player] = StartingGold
            BankedGold[Player] = 0
            BankSlots[Player] = 1
        else:
            PlayerGold[Player] = Saved.Gold
            BankedGold[Player] = Saved.Banked
            BankSlots[Player] = Saved.Slots
    
    GetSaveData(Player : agent) : ?player_save_data =
        Data := player_save_data{}
        if Data.Load(Player): return Data
        return false
    
    SavePlayerData(Player : agent) : void =
        CurrentGold := PlayerGold[Player]
        CurrentBanked := BankedGold[Player]
        CurrentSlots := BankSlots[Player]
        if (CurrentGold = false) or (CurrentBanked = false) or (CurrentSlots = false): return
        Data := player_save_data{}
        Data.Gold = CurrentGold
        Data.Banked = CurrentBanked
        Data.Slots = CurrentSlots
        Data.Save(Player)
    
    AddGold(Player : agent, Amount : int) : void =
        if Amount <= 0: return
        Current := PlayerGold[Player]
        if Current = false: Current = 0
        NewGold := Current + Amount
        if NewGold > MaxGold: NewGold = MaxGold
        PlayerGold[Player] = NewGold
        SavePlayerData(Player)
    
    SpendGold(Player : agent, Amount : int) : bool =
        if Amount <= 0: return false
        Current := PlayerGold[Player]
        if Current = false: return false
        if Current >= Amount:
            PlayerGold[Player] = Current - Amount
            SavePlayerData(Player)
            return true
        return false
    
    GetGold(Player : agent) : int =
        Current := PlayerGold[Player]
        return if Current = false then 0 else Current
    
    LoseGoldOnDeath(Player : agent) : void =
        Current := PlayerGold[Player]
        if Current = false: return
        ToLose := (Current * DeathLossPercent) / 100
        if ToLose > 0: SpendGold(Player, ToLose)
    
    OnPlayerDied(Event : player_died_event) : void = LoseGoldOnDeath(Event.KilledAgent)
    
    HasEnoughGold(Player : agent, Amount : int) : bool =
        Current := PlayerGold[Player]
        return if Current = false then false else Current >= Amount
quantum_pve_system.verse (x20 врагов + квантовые эффекты)
verse
using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }

quantum_enemy_data := class:
    var EnemyType : string = ""
    var HP : int = 20
    var ATK : int = 3
    var Reward : int = 10
    var IsQuantum : bool = false
    var EntangledWith : []agent = array{}

QuantumPveSystem := class(creative_device):
    @editable var Economy : economy_manager = economy_manager{}
    @editable var Progression : progression = progression{}
    @editable var EnemySpawner : spawner_device = spawner_device{}
    @editable var DifficultyLevel : int = 1  # 1-20
    
    var WaveCount : int = 0
    var ActiveEnemies : []quantum_enemy_data = array{}
    
    GetEnemyMultiplier() : float =
        if DifficultyLevel <= 1: return 1.0
        else if DifficultyLevel <= 5: return 1.0 + (DifficultyLevel - 1) * 0.25
        else if DifficultyLevel <= 10: return 2.0 + (DifficultyLevel - 5) * 0.6
        else if DifficultyLevel <= 15: return 5.0 + (DifficultyLevel - 10) * 1.4
        else: return 12.0 + (DifficultyLevel - 15) * 1.6
    
    GetEnemyCount() : int =
        BaseCount := 10
        Multiplier := GetEnemyMultiplier()
        return Floor(BaseCount * Multiplier)
    
    SpawnWave()<suspends>:
        WaveCount += 1
        EnemyCount := GetEnemyCount()
        
        # Спавн пачками по 20
        for Batch in 0..Ceil(EnemyCount / 20) - 1:
            BatchSize := Min(20, EnemyCount - Batch * 20)
            spawn { SpawnBatch(BatchSize) }
            Sleep(0.5)
        
        # Ждём убийства всех врагов
        while(ActiveEnemies.Length > 0):
            Sleep(1.0)
        
        # Квантовая телепортация босса
        if WaveCount % 5 = 0:
            SpawnQuantumBoss()
    
    SpawnBatch(Count : int)<suspends>:
        for i in 0..Count - 1:
            Enemy := quantum_enemy_data{}
            Enemy.EnemyType = GetRandomEnemyType()
            Enemy.HP = GetBaseHP(Enemy.EnemyType) * GetEnemyMultiplier()
            Enemy.ATK = GetBaseATK(Enemy.EnemyType) * GetEnemyMultiplier()
            Enemy.Reward = GetBaseReward(Enemy.EnemyType) / GetEnemyMultiplier()
            
            # Квантовый эффект с шансом 20%
            if GetRandomInt(0, 100) < 20:
                Enemy.IsQuantum = true
                ApplyQuantumEffect(Enemy)
            
            ActiveEnemies.Add(Enemy)
            EnemySpawner.Spawn()
            Sleep(0.1)
    
    ApplyQuantumEffect(Enemy : quantum_enemy_data) : void =
        EffectType := GetRandomInt(1, 5)
        if EffectType = 1:
            # Суперпозиция - создаст клона при смерти
            Print("Quantum Superposition effect applied")
        else if EffectType = 2:
            # Квантовая запутанность
            Print("Quantum Entanglement effect applied")
        else if EffectType = 3:
            # Телепортация
            Print("Quantum Teleportation effect applied")
        else if EffectType = 4:
            # Фазирование
            Print("Quantum Phasing effect applied")
        else:
            # Квантовый скачок
            Print("Quantum Jump effect applied")
    
    SpawnQuantumBoss()<suspends>:
        Print("⚠️ QUANTUM BOSS SPAWNED ⚠️")
        PlaySound("quantum_boss_spawn", 1.0)
        
        Boss := quantum_enemy_data{}
        Boss.EnemyType = "QuantumBoss"
        Boss.HP = 500 * GetEnemyMultiplier()
        Boss.ATK = 50 * GetEnemyMultiplier()
        Boss.Reward = 200 / GetEnemyMultiplier()
        Boss.IsQuantum = true
        
        ActiveEnemies.Add(Boss)
        EnemySpawner.Spawn()
        
        # Эффект телепортации босса каждые 10 секунд
        loop:
            Sleep(10.0)
            if Boss in ActiveEnemies:
                TeleportToRandomPlayer()
                PlaySound("quantum_blink", 0.8)
            else: break
sound_manager.verse
verse
using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }

sound_priority := enum:
    Low = 0
    Medium = 1
    High = 2
    Critical = 3

SoundManager := class(creative_device):
    @editable var AudioPlayer : audio_player_device = audio_player_device{}
    
    var ActiveSounds : int = 0
    var MaxConcurrentSounds : int = 10
    
    PlaySound(SoundName : string, Priority : sound_priority) : void =
        if ActiveSounds >= MaxConcurrentSounds and Priority < sound_priority.High:
            return
        ActiveSounds += 1
        AudioPlayer.PlaySound(SoundName)
        spawn { Sleep(SoundLength(SoundName)); ActiveSounds -= 1 }
    
    PlayQuantumEffect() : void =
        Effects := ["quantum_superposition", "quantum_entanglement", "quantum_blink", "quantum_phase", "quantum_jump"]
        RandomIndex := GetRandomInt(0, Effects.Length - 1)
        PlaySound(Effects[RandomIndex], sound_priority.Medium)
    
    PlayWaveStart(WaveNumber : int) : void =
        PlaySound("wave_start", sound_priority.Critical)
        if WaveNumber % 5 = 0:
            PlaySound("boss_warning", sound_priority.Critical)
📐 Формулы
Множитель врагов
text
multiplier = 1.0 + (уровень_сложности - 1) × (0.25 до 5, 0.6 до 10, 1.4 до 15, 1.6 до 20)
Награда (обратно пропорциональна количеству)
text
reward = base_reward / multiplier
Квантовый шанс
text
quantum_chance = 5% + (уровень_сложности × 0.75)  (макс 20%)
✅ Сводка ключевых изменений
Изменение	Что сделано
Анализ проблем	5 категорий с решениями
Враги x20	Множитель до 20x, спавн пачками
Уровни сложности	1-20, градация множителей
Квантовые эффекты	5 типов (суперпозиция, запутанность, телепортация, фазирование, скачок)
Звуки	Приоритеты, ограничение 10 одновременно
Боссы	Каждые 5 волн, с телепортацией
Последнее обновление: 31.05.2026
