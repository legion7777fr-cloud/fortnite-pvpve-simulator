using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }

# Управление валютой игрока (Gold Coins)
# Это устройство нужно разместить на карте
EconomyManager := class(creative_device):
    
    # Настраиваемые параметры (видны в редакторе)
    @editable
    var StartingGold : int = 50
    
    @editable
    var MaxGold : int = 999999
    
    @editable
    var MaxBankSlots : int = 10
    
    @editable
    var DeathLossPercent : int = 10  # Потеря 10% при смерти
    
    @editable
    var PvPWinPercent : int = 30    # Выигрыш 30% ставки
    
    # Переменные для каждого игрока
    var PlayerGold : [agent]int = map{}
    var BankedGold : [agent]int = map{}
    var BankSlots : [agent]int = map{}
    
    # Вызывается при старте игры
    OnBegin<override>()<suspends>:
        Print("Economy Manager initialized")
        
        # Подписываемся на события
        GetPlayspace().PlayerJoinedEvent.Subscribe(OnPlayerJoined)
        GetPlayspace().PlayerDiedEvent.Subscribe(OnPlayerDied)
    
    # Когда игрок заходит на остров
    OnPlayerJoined(Player : agent) : void =
        if not PlayerGold[Player]:
            PlayerGold[Player] = StartingGold
            BankedGold[Player] = 0
            BankSlots[Player] = 1
            Print("Player joined. Gold: " + StartingGold)
    
    # Добавить золото
    AddGold(Player : agent, Amount : int) : void =
        if Amount <= 0:
            return
        
        var Current = PlayerGold[Player]
        if Current = false:
            Current = 0
        
        var NewGold := Current + Amount
        if NewGold > MaxGold:
            NewGold = MaxGold
        
        PlayerGold[Player] = NewGold
        Print("Added " + Amount + " gold. Total: " + NewGold)
    
    # Потратить золото
    SpendGold(Player : agent, Amount : int) : bool =
        if Amount <= 0:
            return false
        
        var Current = PlayerGold[Player]
        if Current = false:
            return false
        
        if Current >= Amount:
            PlayerGold[Player] = Current - Amount
            Print("Spent " + Amount + " gold. Remaining: " + (Current - Amount))
            return true
        
        Print("Not enough gold. Need: " + Amount + ", Have: " + Current)
        return false
    
    # Получить текущее золото
    GetGold(Player : agent) : int =
        var Current = PlayerGold[Player]
        if Current = false:
            return 0
        return Current
    
    # Положить в банк
    DepositGold(Player : agent, Amount : int) : bool =
        if Amount <= 0:
            return false
        
        if not SpendGold(Player, Amount):
            return false
        
        var CurrentBanked = BankedGold[Player]
        if CurrentBanked = false:
            CurrentBanked = 0
        
        BankedGold[Player] = CurrentBanked + Amount
        return true
    
    # Снять из банка
    WithdrawGold(Player : agent, Amount : int) : bool =
        if Amount <= 0:
            return false
        
        var CurrentBanked = BankedGold[Player]
        if CurrentBanked = false:
            return false
        
        if CurrentBanked >= Amount:
            BankedGold[Player] = CurrentBanked - Amount
            AddGold(Player, Amount)
            return true
        
        return false
    
    # Потеря при смерти
    LoseGoldOnDeath(Player : agent) : void =
        var Current = PlayerGold[Player]
        if Current = false:
            return
        
        var ToLose := (Current * DeathLossPercent) / 100
        if ToLose > 0:
            SpendGold(Player, ToLose)
            Print("Lost " + ToLose + " gold on death")
    
    # Выигрыш в PvP
    WinGoldPvP(Player : agent, StakeAmount : int) : void =
        var WinAmount := (StakeAmount * PvPWinPercent) / 100
        if WinAmount > 0:
            AddGold(Player, WinAmount)
            Print("Won " + WinAmount + " gold in PvP")
    
    # Проигрыш в PvP
    LoseGoldPvP(Player : agent, StakeAmount : int) : void =
        SpendGold(Player, StakeAmount)
        Print("Lost " + StakeAmount + " gold in PvP")
    
    # Проверка достаточно ли золота
    HasEnoughGold(Player : agent, Amount : int) : bool =
        var Current = PlayerGold[Player]
        if Current = false:
            return false
        return Current >= Amount
    
    # Обработка смерти игрока
    OnPlayerDied(Event : player_died_event) : void =
        LoseGoldOnDeath(Event.KilledAgent)
    
    # Сброс статистики (нужно реализовать отдельно)
    ResetStats(Player : agent, Cost : int) : bool =
        return SpendGold(Player, Cost)
