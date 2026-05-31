# 📅 План разработки (Quantum Edition)

## 🎯 Основные вехи

| Фаза | Название | Сроки | Статус |
|------|----------|-------|--------|
| **Фаза 1** | MVP (Минимальный продукт) | 7 дней | 🟡 В разработке |
| **Фаза 2** | Версия 1.0 (Полный релиз) | 14 дней | 🔴 Планируется |
| **Фаза 3** | Релиз и маркетинг | 30 дней | 🔴 Планируется |

---

## ⚠️ Анализ проблем и подводных камней (до начала разработки)

### Проблема 1: Производительность при x20 врагах
| Параметр | Стандарт | x20 | Решение |
|----------|----------|-----|---------|
| Врагов на волне | 5-15 | 100-300 | Спавн пачками по 20, Pooling |
| AI вычислений | 1ms | 20ms | Уменьшить дальность агро |
| Сетевой трафик | 1KB | 20KB | Группировать обновления |

**Решение**: Спавнить врагов пачками по 20 с интервалом 0.5 сек.

### Проблема 2: Баланс наград при x20
| Было | Стало | Решение |
|------|-------|---------|
| 10 Gold за Goblin | 0.5-1 Gold | Награда обратно пропорциональна множителю |
| 5 XP за Goblin | 0.25-0.5 XP | XP = база / (враги на волне) |

### Проблема 3: Квантовые эффекты
| Эффект | Подводный камень | Решение |
|--------|------------------|---------|
| Суперпозиция | Враги дублируются бесконечно | Ограничить 3 клонами |
| Запутанность | Урон распределяется между всеми | Максимум 5 связанных врагов |
| Телепортация | Выход за пределы карты | Проверка границ |

### Проблема 4: Звуки при 300 врагах
| Проблема | Решение |
|----------|---------|
| 300 звуков одновременно | Ограничить 10 звуками в кадре |
| Сбой звукового движка | Приоритеты: босс > игрок > враг |

### Проблема 5: Verse-производительность
| Проблема | Решение |
|----------|---------|
| Циклы по 300 врагам | Использовать `async` и `spawn` |
| Сохранение данных | Кэшировать в памяти, сохранять раз в минуту |

---

## 📊 ФАЗА 1: MVP (7 дней)

**Цель**: Функциональный остров с базовыми механиками.

### День 1: Структура и подготовка
**Задачи**:
- [ ] Создать основную структуру острова в UEFN
- [ ] Спланировать 3 основные зоны (Таверна, Лес, Лобби)
- [ ] Установить спауны игроков

**Время**: 4-6 часов

---

### День 2: Система монет
**Задачи**:
- [ ] Система отслеживания Gold
- [ ] 50 Gold при входе
- [ ] HUD для отображения Gold

**Verse-код** (`economy_manager.verse`):
```verse
using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }

player_save_data := class(save_game):
    var Gold : int = 50
    var Banked : int = 0

EconomyManager := class(creative_device):
    @editable var StartingGold : int = 50
    @editable var MaxGold : int = 999999
    @editable var DeathLossPercent : int = 10
    
    var PlayerGold : [agent]int = map{}
    var BankedGold : [agent]int = map{}
    
    OnBegin<override>()<suspends>:
        GetPlayspace().PlayerJoinedEvent.Subscribe(OnPlayerJoined)
        GetPlayspace().PlayerDiedEvent.Subscribe(OnPlayerDied)
    
    OnPlayerJoined(Player : agent) : void =
        Saved := GetSaveData(Player)
        if Saved = false:
            PlayerGold[Player] = StartingGold
            BankedGold[Player] = 0
        else:
            PlayerGold[Player] = Saved.Gold
            BankedGold[Player] = Saved.Banked
    
    GetSaveData(Player : agent) : ?player_save_data =
        Data := player_save_data{}
        if Data.Load(Player): return Data
        return false
    
    SavePlayerData(Player : agent) : void =
        CurrentGold := PlayerGold[Player]
        CurrentBanked := BankedGold[Player]
        if (CurrentGold = false) or (CurrentBanked = false): return
        Data := player_save_data{}
        Data.Gold = CurrentGold
        Data.Banked = CurrentBanked
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
Время: 3-4 часа

День 3: PvE враги (x20 подготовка)
Задачи:

Создать AI Spawner для волн

Система спавна пачками (по 20 врагов)

Убитый враг дает награду (обратно пропорционально количеству)

Verse-код (pve_system.verse):

verse
using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }

PveSystem := class(creative_device):
    @editable var Economy : economy_manager = economy_manager{}
    @editable var EnemySpawner : spawner_device = spawner_device{}
    @editable var KillTrigger : trigger_device = trigger_device{}
    @editable var DifficultyLevel : int = 1  # 1-20
    
    var ActiveEnemies : int = 0
    var WaveNumber : int = 0
    
    GetEnemyMultiplier() : float =
        if DifficultyLevel <= 1: return 1.0
        else if DifficultyLevel <= 5: return 1.0 + (DifficultyLevel - 1) * 0.25
        else if DifficultyLevel <= 10: return 2.0 + (DifficultyLevel - 5) * 0.6
        else if DifficultyLevel <= 15: return 5.0 + (DifficultyLevel - 10) * 1.4
        else: return 12.0 + (DifficultyLevel - 15) * 1.6
    
    GetRewardMultiplier() : float = 1.0 / GetEnemyMultiplier()
    
    GetEnemyCount() : int =
        BaseCount := 10
        return Floor(BaseCount * GetEnemyMultiplier())
    
    OnBegin<override>()<suspends>:
        if (KillTrigger <> false):
            KillTrigger.InteractedWithEvent.Subscribe(OnEnemyKilled)
        StartWaves()
    
    StartWaves()<suspends>:
        loop:
            WaveNumber += 1
            EnemyCount := GetEnemyCount()
            
            # Спавн пачками по 20
            for Batch in 0..Ceil(EnemyCount / 20) - 1:
                BatchSize := Min(20, EnemyCount - Batch * 20)
                SpawnBatch(BatchSize)
                Sleep(0.5)
            
            # Ждём убийства всех врагов
            while ActiveEnemies > 0:
                Sleep(1.0)
            
            Sleep(5.0)  # Пауза между волнами
    
    SpawnBatch(Count : int) : void =
        for i in 0..Count - 1:
            ActiveEnemies += 1
            EnemySpawner.Spawn()
            Sleep(0.1)
    
    OnEnemyKilled(Player : agent, Trigger : trigger_device) : void =
        ActiveEnemies -= 1
        if (Economy <> false):
            Reward := Floor(15 * GetRewardMultiplier())
            if Reward < 1: Reward = 1
            Economy.AddGold(Player, Reward)
Время: 5-6 часов

День 4: Магазин
Verse-код (shop_system.verse):

verse
using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }

ShopSystem := class(creative_device):
    @editable var Economy : economy_manager = economy_manager{}
    @editable var ShopButton : button_device = button_device{}
    @editable var ItemGranter : item_granter_device = item_granter_device{}
    @editable var ItemPrice : int = 150
    @editable var ItemToGrant : string = "cosmetic_skin"
    
    OnBegin<override>()<suspends>:
        if (ShopButton <> false):
            ShopButton.InteractedWithEvent.Subscribe(OnBuy)
    
    OnBuy(Player : agent, Button : button_device) : void =
        if (Economy <> false) and Economy.HasEnoughGold(Player, ItemPrice):
            if Economy.SpendGold(Player, ItemPrice):
                if (ItemGranter <> false): ItemGranter.GrantItem(Player, ItemToGrant)
Время: 3-4 часа

День 5: Система прогрессии
Verse-код (progression.verse):

verse
using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }

progression_save_data := class(save_game):
    var Level : int = 1
    var XP : int = 0
    var StatPoints : int = 0
    var Attack : int = 0
    var Defense : int = 0
    var HealthBonus : int = 0
    var Luck : int = 0

Progression := class(creative_device):
    @editable var Economy : economy_manager = economy_manager{}
    @editable var GoldPerLevelUp : int = 50
    
    var PlayerData : [agent]progression_save_data = map{}
    
    OnBegin<override>()<suspends>:
        GetPlayspace().PlayerJoinedEvent.Subscribe(OnPlayerJoined)
    
    OnPlayerJoined(Player : agent) : void =
        Saved := GetSaveData(Player)
        if Saved = false:
            PlayerData[Player] = progression_save_data{}
        else:
            PlayerData[Player] = Saved
    
    GetSaveData(Player : agent) : ?progression_save_data =
        Data := progression_save_data{}
        if Data.Load(Player): return Data
        return false
    
    SavePlayerData(Player : agent) : void =
        Data := PlayerData[Player]
        if Data <> false: Data.Save(Player)
    
    GetXPForNextLevel(CurrentLevel : int) : int = CurrentLevel * 100
    
    AddXP(Player : agent, Amount : int) : void =
        Data := PlayerData[Player]
        if Data = false: return
        Data.XP += Amount
        loop:
            NeedXP := GetXPForNextLevel(Data.Level)
            if Data.XP >= NeedXP:
                Data.XP -= NeedXP
                Data.Level += 1
                Data.StatPoints += 5
                if (Economy <> false): Economy.AddGold(Player, GoldPerLevelUp)
            else: break
        SavePlayerData(Player)
    
    GetLevel(Player : agent) : int =
        Data := PlayerData[Player]
        return if Data = false then 1 else Data.Level
Время: 4-5 часов

День 6: PvP система
Verse-код (pvp_manager.verse):

verse
using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }

pvp_save_data := class(save_game):
    var Elo : int = 1000

PvpManager := class(creative_device):
    @editable var Economy : economy_manager = economy_manager{}
    @editable var WinPercent : int = 30
    
    var PlayerData : [agent]pvp_save_data = map{}
    
    OnBegin<override>()<suspends>:
        GetPlayspace().PlayerJoinedEvent.Subscribe(OnPlayerJoined)
    
    OnPlayerJoined(Player : agent) : void =
        Saved := GetSaveData(Player)
        if Saved = false: PlayerData[Player] = pvp_save_data{}
        else: PlayerData[Player] = Saved
    
    GetSaveData(Player : agent) : ?pvp_save_data =
        Data := pvp_save_data{}
        if Data.Load(Player): return Data
        return false
    
    OnPvPFightEnd(Winner : agent, Loser : agent, Stake : int) : void =
        if (Economy = false): return
        if not Economy.HasEnoughGold(Loser, Stake): return
        WinAmount := (Stake * WinPercent) / 100
        Economy.AddGold(Winner, WinAmount)
        Economy.SpendGold(Loser, Stake)
Время: 5-6 часов

День 7: Квантовые эффекты и звуки
Verse-код (quantum_manager.verse):

verse
using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }

QuantumManager := class(creative_device):
    @editable var AudioPlayer : audio_player_device = audio_player_device{}
    
    var ActiveSounds : int = 0
    var MaxConcurrentSounds : int = 10
    
    PlaySound(SoundName : string, Priority : int) : void =
        if ActiveSounds >= MaxConcurrentSounds and Priority < 2: return
        ActiveSounds += 1
        AudioPlayer.PlaySound(SoundName)
        spawn { Sleep(2.0); ActiveSounds -= 1 }
    
    ApplyQuantumEffect(Enemy : agent) : void =
        EffectType := GetRandomInt(1, 5)
        PlaySound("quantum_effect", 2)
        
        if EffectType = 1:
            # Суперпозиция - создание клона
            Print("Quantum Superposition")
        else if EffectType = 2:
            # Запутанность
            Print("Quantum Entanglement")
        else if EffectType = 3:
            # Телепортация
            Print("Quantum Teleportation")
        else if EffectType = 4:
            # Фазирование
            Print("Quantum Phasing")
        else:
            # Квантовый скачок
            Print("Quantum Jump")
Время: 4-5 часов

📊 ФАЗА 2: Версия 1.0 (14 дней)
День 8-10: Подземелье (x20 врагов, квантовые боссы)
Задачи:

Создать дизайн подземелья

Вход 100 Gold

5 волн с множителем x20 на максимуме

Квантовый босс каждые 5 волн

Финальная награда: 500 Gold / множитель + 100 XP

Время: 14-16 часов

День 11-12: Статистика и перки
Задачи:

Распределение поинтов (ATK, DEF, HP, LCK)

Перки на 5, 10, 15, 20, 25, 30 уровне

Время: 8-10 часов

День 13: Квесты и достижения
Задачи:

5 ежедневных квестов

10 достижений

Время: 4-5 часов

День 14: Балансировка
Задачи:

Проверить баланс при x20 врагах

Оптимизация для 16 игроков

Время: 5-6 часов

📊 ФАЗА 3: Релиз (30 дней)
Дни 15-20: Дополнительный контент
VIP-зона (2x монеты)

Boss Hunt

5 новых скинов

Еженедельные ивенты

Дни 21-25: Маркетинг
Трейлер (30 сек)

Описание острова

Скриншоты

Отправка на рецензию

Дни 26-30: Финальный баланс
Тест с 16 игроками

Исправление критических багов

Публикация

🎮 Метрики успеха
MVP (День 7)
✅ Можно убивать врагов (в т.ч. пачками по 20)

✅ Можно зарабатывать Gold

✅ Можно тратить Gold в магазине

✅ 2+ игроков могут играть одновременно

v1.0 (День 14)
✅ x20 врагов работает без лагов

✅ Квантовые эффекты стабильны

✅ Звуки не перегружают движок

✅ 16 игроков без критических багов

Релиз (День 30)
✅ 1000+ игроков

✅ Рейтинг 4.5+ звезд

✅ 100+ игроков ежедневно

📊 Таблица прогресса
День	Фаза	Задача	Статус
1	MVP	Структура	🟡
2	MVP	Экономика	🟡
3	MVP	PvE x20	🟡
4	MVP	Магазин	🔴
5	MVP	Прогрессия	🔴
6	MVP	PvP	🔴
7	MVP	Квант/Звуки	🔴
8-10	v1.0	Подземелье	🔴
11-12	v1.0	Статы/Перки	🔴
13	v1.0	Квесты	🔴
14	v1.0	Баланс	🔴
15-30	Релиз	Маркетинг	🔴
Последнее обновление: 31.05.2026
Фаза: MVP (День 1-7)
