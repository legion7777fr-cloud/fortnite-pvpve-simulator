using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }

# Сохраняемые данные прогрессии игрока
progression_save_data := class(save_game):
    var Level : int = 1
    var XP : int = 0
    var StatPoints : int = 0
    var Attack : int = 0
    var Defense : int = 0
    var HealthBonus : int = 0
    var Luck : int = 0

# Система прогрессии (уровни, опыт, статы)
Progression := class(creative_device):
    
    @editable
    var Economy : economy_manager = economy_manager{}
    
    @editable
    var GoldPerLevelUp : int = 50
    
    var PlayerData : [agent]progression_save_data = map{}
    
    # Запуск при старте игры
    OnBegin<override>()<suspends>:
        Print("Progression System started")
        GetPlayspace().PlayerJoinedEvent.Subscribe(OnPlayerJoined)
    
    # Когда игрок заходит
    OnPlayerJoined(Player : agent) : void =
        Saved := GetSaveData(Player)
        if Saved = false:
            Data := progression_save_data{}
            PlayerData[Player] = Data
            Print("New player created. Level 1")
        else:
            PlayerData[Player] = Saved
            Print("Player loaded. Level: " + Saved.Level)
    
    # Загрузить сохранение
    GetSaveData(Player : agent) : ?progression_save_data =
        Data := progression_save_data{}
        if Data.Load(Player):
            return Data
        return false
    
    # Сохранить данные
    SavePlayerData(Player : agent) : void =
        Data := PlayerData[Player]
        if Data <> false:
            Data.Save(Player)
    
    # Опыт для следующего уровня
    GetXPForNextLevel(CurrentLevel : int) : int =
        if CurrentLevel <= 10:
            return 100 * CurrentLevel
        else if CurrentLevel <= 50:
            return 500 * CurrentLevel
        else:
            return 1000 * CurrentLevel
    
    # Добавить опыт
    AddXP(Player : agent, Amount : int) : void =
        Data := PlayerData[Player]
        if Data = false:
            return
        
        Data.XP += Amount
        Print("+" + Amount + " XP. Total: " + Data.XP)
        
        # Проверка повышения уровня
        loop:
            NeedXP := GetXPForNextLevel(Data.Level)
            if Data.XP >= NeedXP:
                Data.XP -= NeedXP
                Data.Level += 1
                Data.StatPoints += 5
                
                if (Economy <> false):
                    Economy.AddGold(Player, GoldPerLevelUp)
                
                Print("LEVEL UP! Now level " + Data.Level)
                Print("Gained 5 stat points and " + GoldPerLevelUp + " gold")
            else:
                break
        
        SavePlayerData(Player)
    
    # Получить уровень
    GetLevel(Player : agent) : int =
        Data := PlayerData[Player]
        return if Data = false then 1 else Data.Level
    
    # Получить опыт
    GetXP(Player : agent) : int =
        Data := PlayerData[Player]
        return if Data = false then 0 else Data.XP
    
    # Улучшить характеристику
    UpgradeStat(Player : agent, StatName : string) : bool =
        Data := PlayerData[Player]
        if Data = false:
            return false
        
        if Data.StatPoints <= 0:
            Print("No stat points available")
            return false
        
        if StatName = "attack":
            Data.Attack += 1
        else if StatName = "defense":
            Data.Defense += 1
        else if StatName = "health":
            Data.HealthBonus += 1
        else if StatName = "luck":
            Data.Luck += 1
        else:
            return false
        
        Data.StatPoints -= 1
        SavePlayerData(Player)
        Print("Upgraded " + StatName + "! Remaining points: " + Data.StatPoints)
        return true
    
    # Получить атаку
    GetAttack(Player : agent) : int =
        Data := PlayerData[Player]
        return if Data = false then 0 else Data.Attack
    
    # Получить защиту
    GetDefense(Player : agent) : int =
        Data := PlayerData[Player]
        return if Data = false then 0 else Data.Defense
    
    # Получить бонус здоровья
    GetHealthBonus(Player : agent) : int =
        Data := PlayerData[Player]
        return if Data = false then 0 else Data.HealthBonus
    
    # Получить удачу
    GetLuck(Player : agent) : int =
        Data := PlayerData[Player]
        return if Data = false then 0 else Data.Luck
    
    # Получить очки статов
    GetStatPoints(Player : agent) : int =
        Data := PlayerData[Player]
        return if Data = false then 0 else Data.StatPoints
