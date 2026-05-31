using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }

# Сохраняемые данные игрока
player_save_data := class(save_game):
    var Gold : int = 50
    var Banked : int = 0
    var Slots : int = 1

# Управление валютой игрока
EconomyManager := class(creative_device):
    
    @editable
    var StartingGold : int = 50
    
    @editable
    var MaxGold : int = 999999
    
    @editable
    var MaxBankSlots : int = 10
    
    @editable
    var DeathLossPercent : int = 10
    
    @editable
    var PvPWinPercent : int = 30
    
    @editable
    var BankSlotCost : int = 100  # Стоимость одного слота
    
    # Кэш в памяти (для быстрого доступа)
    var PlayerGold : [agent]int = map{}
    var BankedGold : [agent]int = map{}
    var BankSlots : [agent]int = map{}
    
    OnBegin<override>()<suspends>:
        Print("Economy Manager started")
        GetPlayspace().PlayerJoinedEvent.Subscribe(OnPlayerJoined)
        GetPlayspace().PlayerDiedEvent.Subscribe(OnPlayerDied)
    
    # Загрузка или создание данных игрока
    OnPlayerJoined(Player : agent) : void =
        Saved := GetSaveData(Player)
        
        if (Saved = false):
            # Новый игрок
            PlayerGold[Player] = StartingGold
            BankedGold[Player] = 0
            BankSlots[Player] = 1
            Print("New player joined. Gold: " + StartingGold)
        else:
            # Загружаем сохранение
            PlayerGold[Player] = Saved.Gold
            BankedGold[Player] = Saved.Banked
            BankSlots[Player] = Saved.Slots
            Print("Player rejoined. Gold: " + Saved.Gold)
    
    # Сохранение данных
    SavePlayerData(Player : agent) : void =
        CurrentGold := PlayerGold[Player]
        CurrentBanked := BankedGold[Player]
        CurrentSlots := BankSlots[Player]
        
        if (CurrentGold = false) or (CurrentBanked = false) or (CurrentSlots = false):
            return
        
        Data := player_save_data{}
        Data.Gold = CurrentGold
        Data.Banked = CurrentBanked
        Data.Slots = CurrentSlots
        Data.Save(Player)
    
    # Добавить золото
    AddGold(Player : agent, Amount : int) : void =
        if Amount <= 0: return
        
        Current := PlayerGold[Player]
        if Current = false: Current = 0
        
        NewGold := Current + Amount
        if NewGold > MaxGold: NewGold = MaxGold
        
        PlayerGold[Player] = NewGold
        SavePlayerData(Player)
        Print("+" + Amount + " gold. Total: " + NewGold)
    
    # Потратить золото
    SpendGold(Player : agent, Amount : int) : bool =
        if Amount <= 0: return false
        
        Current := PlayerGold[Player]
        if Current = false: return false
        
        if Current >= Amount:
            PlayerGold[Player] = Current - Amount
            SavePlayerData(Player)
            Print("-" + Amount + " gold. Remaining: " + (Current - Amount))
            return true
        
        Print("Need " + Amount + ", have " + Current)
        return false
    
    # Получить золото
    GetGold(Player : agent) : int =
        Current := PlayerGold[Player]
        return if Current = false then 0 else Current
    
    # Положить в банк
    DepositGold(Player : agent, Amount : int) : bool =
        if Amount <= 0: return false
        if not SpendGold(Player, Amount): return false
        
        CurrentBanked := BankedGold[Player]
        if CurrentBanked = false: CurrentBanked = 0
        
        BankedGold[Player] = CurrentBanked + Amount
        SavePlayerData(Player)
        return true
    
    # Снять из банка
    WithdrawGold(Player : agent, Amount : int) : bool =
        if Amount <= 0: return false
        
        CurrentBanked := BankedGold[Player]
        if CurrentBanked = false: return false
        
        if CurrentBanked >= Amount:
            BankedGold[Player] = CurrentBanked - Amount
            AddGold(Player, Amount)
            SavePlayerData(Player)
            return true
        
        return false
    
    # Получить банковское золото
    GetBankedGold(Player : agent) : int =
        Current := BankedGold[Player]
        return if Current = false then 0 else Current
    
    # Купить слот в банке
    BuyBankSlot(Player : agent) : bool =
        CurrentSlots := BankSlots[Player]
        if CurrentSlots = false: return false
        
        if CurrentSlots >= MaxBankSlots:
            Print("Max bank slots reached: " + MaxBankSlots)
            return false
        
        if SpendGold(Player, BankSlotCost):
            BankSlots[Player] = CurrentSlots + 1
            SavePlayerData(Player)
            Print("Bank slot purchased! Now: " + (CurrentSlots + 1))
            return true
        
        Print("Not enough gold for bank slot. Cost: " + BankSlotCost)
        return false
    
    # Потеря при смерти
    LoseGoldOnDeath(Player : agent) : void =
        Current := PlayerGold[Player]
        if Current = false: return
        
        ToLose := (Current * DeathLossPercent) / 100
        if ToLose > 0:
            SpendGold(Player, ToLose)
            Print("Lost " + ToLose + " gold on death")
    
    # Обработчик смерти
    OnPlayerDied(Event : player_died_event) : void =
        LoseGoldOnDeath(Event.KilledAgent)
    
    # PvP выигрыш
    WinGoldPvP(Player : agent, StakeAmount : int) : void =
        WinAmount := (StakeAmount * PvPWinPercent) / 100
        if WinAmount > 0:
            AddGold(Player, WinAmount)
            Print("Won " + WinAmount + " gold in PvP")
    
    # PvP проигрыш
    LoseGoldPvP(Player : agent, StakeAmount : int) : void =
        SpendGold(Player, StakeAmount)
        Print("Lost " + StakeAmount + " gold in PvP")
    
    # Проверка достаточно ли золота
    HasEnoughGold(Player : agent, Amount : int) : bool =
        Current := PlayerGold[Player]
        return if Current = false then false else Current >= Amount
    
    # Сброс статистики
    ResetStats(Player : agent, Cost : int) : bool =
        return SpendGold(Player, Cost)
