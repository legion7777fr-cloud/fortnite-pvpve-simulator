# 🏗️ Архитектура проекта

## 📋 Оглавление
1. [Обзор острова](#обзор-острова)
2. [Зоны и структура](#зоны-и-структура)
3. [Система прогрессии](#система-прогрессии)
4. [Экономика](#экономика)
5. [PvE система](#pve-система)
6. [PvP система](#pvp-система)
7. [Магазин и монетизация](#магазин-и-монетизация)
8. [Техническая реализация](#техническая-реализация)

---

## 🌍 Обзор острова

**Название острова**: *Economic Arena*  
**Максимум игроков**: 16  
**Время сессии**: 15-30 минут  
**Целевая аудитория**: 10+ лет

### Основная концепция
Остров работает как **виртуальная экономика с риском**:
- Фармим монеты в PvE
- Тратим в магазине на улучшения
- Конкурируем в PvP с ставками
- Теряем при смерти
- Развиваемся через прогрессию

---

## 🏰 Зоны и структура

### Зона 1: Таверна (Безопасная)
**Размер**: 200x200м  
**Враги**: Нет  
**Функции**: Спавн, магазин, банк, квесты

### Зона 2: Лесной фарм (Новичок)
**Размер**: 500x400м  
**Враги**: Goblin, Orc  
**Награда**: 10-20 Gold + 5 опыта

### Зона 3: Подземелье (Продвинутое)
**Размер**: 800x600м  
**Враги**: Skeletal, Mage, Demon Boss  
**5 волн**, вход 100/50 Gold, выход 500 Gold + 100 XP

### Зона 4: PvP Арена
**Размер**: 400x300м  
**Ставка**: 50-500 Gold, победитель +30%, проигравший -100%

### Зона 5: Лобби/Хаб
**Размер**: 400x400м  
**Функции**: Статистика, лидеры, выбор зоны

---

## 📊 Система прогрессии

**Опыт для уровня**:
- 1-10: 100 × уровень
- 11-50: 500 × уровень
- 51-100: 1000 × уровень

**Статистика (5 поинтов за уровень)**:
- ATK: +1 урон
- DEF: +1% отскок
- HP: +5 здоровья
- LCK: +1% крит

**Перки**:
- 5: Farmer's Boost (+15% Gold)
- 10: Survivor (+20% HP)
- 15: Lucky (+25% крит)
- 20: Banker (+1 слот банка)
- 25: Warrior (+10% ATK)
- 30: Immortal (-10% урон)

---

## 💰 Экономика

**Начало**: 50 Gold, макс: 999,999

**Источники**: Goblin 10-15, Orc 20-30, Skeletal 40-60, Mage 50-80, Boss 300-500

**Потеря**: смерть 10%, поражение в PvP 100% ставки

---

## 👹 PvE враги

| Враг | HP | ATK | Награда |
|------|-----|-----|---------|
| Goblin | 20 | 3-5 | 10-15 Gold, 5 XP |
| Orc | 40 | 5-8 | 20-30 Gold, 10 XP |
| Skeletal | 60 | 8-12 | 40-60 Gold, 20 XP |
| Dark Mage | 50 | 10-15 | 50-80 Gold, 25 XP |
| Demon Boss | 150 | 15-20 | 300-500 Gold, 100 XP |

---

## ⚔️ PvP система

**Elo**: начало 1000, победа +25, поражение -15

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
    @editable var PvPWinPercent : int = 30
    @editable var BankSlotCost : int = 100
    
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
    
    DepositGold(Player : agent, Amount : int) : bool =
        if Amount <= 0: return false
        if not SpendGold(Player, Amount): return false
        CurrentBanked := BankedGold[Player]
        if CurrentBanked = false: CurrentBanked = 0
        BankedGold[Player] = CurrentBanked + Amount
        SavePlayerData(Player)
        return true
    
    WithdrawGold(Player : agent, Amount : int) : bool =
        if Amount <= 0: return false
        CurrentBanked := BankedGold[Player]
        if CurrentBanked = false: return false
        if CurrentBanked >= Amount:
            BankedGold[Player] = CurrentBanked - Amount
            AddGold(Player, Amount)
            return true
        return false
    
    GetBankedGold(Player : agent) : int =
        Current := BankedGold[Player]
        return if Current = false then 0 else Current
    
    BuyBankSlot(Player : agent) : bool =
        CurrentSlots := BankSlots[Player]
        if CurrentSlots = false: return false
        if CurrentSlots >= MaxBankSlots: return false
        if SpendGold(Player, BankSlotCost):
            BankSlots[Player] = CurrentSlots + 1
            SavePlayerData(Player)
            return true
        return false
    
    LoseGoldOnDeath(Player : agent) : void =
        Current := PlayerGold[Player]
        if Current = false: return
        ToLose := (Current * DeathLossPercent) / 100
        if ToLose > 0: SpendGold(Player, ToLose)
    
    OnPlayerDied(Event : player_died_event) : void = LoseGoldOnDeath(Event.KilledAgent)
    
    HasEnoughGold(Player : agent, Amount : int) : bool =
        Current := PlayerGold[Player]
        return if Current = false then false else Current >= Amount
progression.verse
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
    @editable var BaseXPPerLevel : int = 100
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
    
    GetXPForNextLevel(CurrentLevel : int) : int =
        if CurrentLevel <= 10: return BaseXPPerLevel * CurrentLevel
        else if CurrentLevel <= 50: return 500 * CurrentLevel
        else: return 1000 * CurrentLevel
    
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
    
    UpgradeStat(Player : agent, StatName : string) : bool =
        Data := PlayerData[Player]
        if Data = false: return false
        if Data.StatPoints <= 0: return false
        if StatName = "attack": Data.Attack += 1
        else if StatName = "defense": Data.Defense += 1
        else if StatName = "health": Data.HealthBonus += 1
        else if StatName = "luck": Data.Luck += 1
        else: return false
        Data.StatPoints -= 1
        SavePlayerData(Player)
        return true
    
    GetAttack(Player : agent) : int =
        Data := PlayerData[Player]
        return if Data = false then 0 else Data.Attack
    
    GetDefense(Player : agent) : int =
        Data := PlayerData[Player]
        return if Data = false then 0 else Data.Defense
    
    GetHealthBonus(Player : agent) : int =
        Data := PlayerData[Player]
        return if Data = false then 0 else Data.HealthBonus
    
    GetLuck(Player : agent) : int =
        Data := PlayerData[Player]
        return if Data = false then 0 else Data.Luck
    
    GetStatPoints(Player : agent) : int =
        Data := PlayerData[Player]
        return if Data = false then 0 else Data.StatPoints
pve_system.verse
verse
using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }

PveSystem := class(creative_device):
    @editable var Economy : economy_manager = economy_manager{}
    @editable var Progression : progression = progression{}
    @editable var WaveArea : trigger_device = trigger_device{}
    @editable var EnemySpawner : spawner_device = spawner_device{}
    @editable var EntryCost : int = 100
    @editable var ReentryCost : int = 50
    
    var HasEnteredBefore : [agent]bool = map{}
    
    OnBegin<override>()<suspends>:
        if (WaveArea <> false): WaveArea.InteractedWithEvent.Subscribe(OnPlayerEnterWave)
    
    OnPlayerEnterWave(Player : agent, Trigger : trigger_device) : void =
        if (Economy = false): return
        Entered := HasEnteredBefore[Player]
        Cost := if Entered = false then EntryCost else ReentryCost
        if not Economy.HasEnoughGold(Player, Cost): return
        Economy.SpendGold(Player, Cost)
        HasEnteredBefore[Player] = true
        spawn_loop(Player)
    
    spawn_loop(Player : agent)<suspends>:
        CurrentWave := 0
        loop:
            CurrentWave += 1
            if CurrentWave > 5:
                if (Economy <> false): Economy.AddGold(Player, 500)
                if (Progression <> false): Progression.AddXP(Player, 100)
                break
            EnemyCount := 5 + (CurrentWave * 2)
            for i in 0..EnemyCount - 1:
                if (EnemySpawner <> false): EnemySpawner.Spawn()
                Sleep(1.0)
            Sleep(30.0)
pvp_manager.verse
verse
using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }

pvp_save_data := class(save_game):
    var Elo : int = 1000
    var Wins : int = 0
    var Losses : int = 0

PvpManager := class(creative_device):
    @editable var Economy : economy_manager = economy_manager{}
    @editable var MinStake : int = 50
    @editable var MaxStake : int = 500
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
    
    SavePlayerData(Player : agent) : void =
        Data := PlayerData[Player]
        if Data <> false: Data.Save(Player)
    
    GetElo(Player : agent) : int =
        Data := PlayerData[Player]
        return if Data = false then 1000 else Data.Elo
    
    OnPvPFightEnd(Winner : agent, Loser : agent, Stake : int) : void =
        if (Economy = false): return
        if Stake < MinStake or Stake > MaxStake: return
        if not Economy.HasEnoughGold(Loser, Stake): return
        WinAmount := (Stake * WinPercent) / 100
        Economy.AddGold(Winner, WinAmount)
        Economy.SpendGold(Loser, Stake)
        
        WinnerElo := GetElo(Winner)
        LoserElo := GetElo(Loser)
        ExpectedWinner := 1.0 / (1.0 + 10.0 ** ((LoserElo - WinnerElo) / 400.0))
        EloChange := 25 * (1.0 - ExpectedWinner)
        
        WinnerData := PlayerData[Winner]
        LoserData := PlayerData[Loser]
        if WinnerData <> false:
            WinnerData.Elo += EloChange
            WinnerData.Wins += 1
            SavePlayerData(Winner)
        if LoserData <> false:
            LoserData.Elo -= EloChange
            LoserData.Losses += 1
            SavePlayerData(Loser)
📐 Формулы
Урон: (ATK_игрока - DEF_врага) × (1.0 + LCK/100 если крит)

HP: 100 + (HP_стат × 5)

Награда: база × (1 + сложность/10) × модификатор_бустера

Последнее обновление: 31.05.2026
