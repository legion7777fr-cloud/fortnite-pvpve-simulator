using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }

ZoneManager := class(creative_device):
    
    @editable
    var Economy : economy_manager = economy_manager{}
    
    @editable
    var SafeZoneArea : trigger_device = trigger_device{}
    
    @editable
    var ForestArea : trigger_device = trigger_device{}
    
    @editable
    var DungeonArea : trigger_device = trigger_device{}
    
    @editable
    var ForestMultiplier : float = 1.5
    
    @editable
    var DungeonMultiplier : float = 2.5
    
    var CurrentMultiplier : [agent]float = map{}
    
    OnBegin<override>()<suspends>:
        Print("Zone Manager started")
        
        if (SafeZoneArea <> false):
            SafeZoneArea.InteractedWithEvent.Subscribe(OnEnterSafeZone)
        if (ForestArea <> false):
            ForestArea.InteractedWithEvent.Subscribe(OnEnterForest)
        if (DungeonArea <> false):
            DungeonArea.InteractedWithEvent.Subscribe(OnEnterDungeon)
    
    OnEnterSafeZone(Player : agent, Trigger : trigger_device) : void =
        CurrentMultiplier[Player] = 1.0
        Print("Entered Safe Zone. Multiplier: 1.0")
    
    OnEnterForest(Player : agent, Trigger : trigger_device) : void =
        CurrentMultiplier[Player] = ForestMultiplier
        Print("Entered Forest. Multiplier: " + ForestMultiplier)
    
    OnEnterDungeon(Player : agent, Trigger : trigger_device) : void =
        CurrentMultiplier[Player] = DungeonMultiplier
        Print("Entered Dungeon. Multiplier: " + DungeonMultiplier)
    
    GetMultiplier(Player : agent) : float =
        Mult := CurrentMultiplier[Player]
        return if Mult = false then 1.0 else Mult
    
    GetRewardWithMultiplier(Player : agent, BaseReward : int) : int =
        Mult := GetMultiplier(Player)
        return Floor(BaseReward * Mult)
