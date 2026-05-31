using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }

pvp_save_data := class(save_game):
    var Elo : int = 1000
    var Wins : int = 0
    var Losses : int = 0

PvpManager := class(creative_device):
    
    @editable
    var Economy : economy_manager = economy_manager{}
    
    @editable
    var MinStake : int = 50
    
    @editable
    var MaxStake : int = 500
    
    @editable
    var WinPercent : int = 30
    
    var PlayerData : [agent]pvp_save_data = map{}
    
    OnBegin<override>()<suspends>:
        Print("PvP Manager started")
        GetPlayspace().PlayerJoinedEvent.Subscribe(OnPlayerJoined)
    
    OnPlayerJoined(Player : agent) : void =
        Saved := GetSaveData(Player)
        if Saved = false:
            Data := pvp_save_data{}
            PlayerData[Player] = Data
            Print("New PvP player created. Elo: 1000")
        else:
            PlayerData[Player] = Saved
            Print("PvP player loaded. Elo: " + Saved.Elo)
    
    GetSaveData(Player : agent) : ?pvp_save_data =
        Data := pvp_save_data{}
        if Data.Load(Player):
            return Data
        return false
    
    SavePlayerData(Player : agent) : void =
        Data := PlayerData[Player]
        if Data <> false:
            Data.Save(Player)
    
    GetElo(Player : agent) : int =
        Data := PlayerData[Player]
        return if Data = false then 1000 else Data.Elo
    
    GetWins(Player : agent) : int =
        Data := PlayerData[Player]
        return if Data = false then 0 else Data.Wins
    
    GetLosses(Player : agent) : int =
        Data := PlayerData[Player]
        return if Data = false then 0 else Data.Losses
    
    OnPvPFightEnd(Winner : agent, Loser : agent, Stake : int) : void =
        if (Economy = false): return
        
        if Stake < MinStake or Stake > MaxStake:
            Print("Stake out of bounds: " + Stake)
            return
        
        if not Economy.HasEnoughGold(Loser, Stake):
            Print("Loser doesn't have enough gold")
            return
        
        WinAmount := (Stake * WinPercent) / 100
        Economy.AddGold(Winner, WinAmount)
        Economy.SpendGold(Loser, Stake)
        
        Print("PvP fight ended! Winner +" + WinAmount + " gold")
        
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
            Print("Winner Elo: " + WinnerData.Elo)
        
        if LoserData <> false:
            LoserData.Elo -= EloChange
            LoserData.Losses += 1
            SavePlayerData(Loser)
            Print("Loser Elo: " + LoserData.Elo)
