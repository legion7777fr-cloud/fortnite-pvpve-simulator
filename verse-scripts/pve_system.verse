using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }

PveSystem := class(creative_device):
    
    @editable
    var Economy : economy_manager = economy_manager{}
    
    @editable
    var Progression : progression = progression{}
    
    @editable
    var WaveArea : trigger_device = trigger_device{}
    
    @editable
    var EnemySpawner : spawner_device = spawner_device{}
    
    @editable
    var KillTrigger : trigger_device = trigger_device{}
    
    @editable
    var EntryCost : int = 100
    
    @editable
    var ReentryCost : int = 50
    
    @editable
    var RewardPerKill : int = 15
    
    var CurrentWave : int = 0
    var HasEnteredBefore : [agent]bool = map{}
    var ActiveEnemies : int = 0
    
    OnBegin<override>()<suspends>:
        Print("PvE System started")
        
        if (WaveArea <> false):
            WaveArea.InteractedWithEvent.Subscribe(OnPlayerEnterWave)
        
        if (KillTrigger <> false):
            KillTrigger.InteractedWithEvent.Subscribe(OnEnemyKilled)
    
    OnPlayerEnterWave(Player : agent, Trigger : trigger_device) : void =
        if (Economy = false): return
        
        Entered := HasEnteredBefore[Player]
        Cost := if Entered = false then EntryCost else ReentryCost
        
        if not Economy.HasEnoughGold(Player, Cost):
            Print("Not enough gold to enter. Need: " + Cost)
            return
        
        Economy.SpendGold(Player, Cost)
        HasEnteredBefore[Player] = true
        
        spawn_loop(Player)
    
    spawn_loop(Player : agent)<suspends>:
        CurrentWave = 0
        loop:
            CurrentWave += 1
            
            if CurrentWave > 5:
                Print("All waves completed!")
                if (Economy <> false):
                    Economy.AddGold(Player, 500)
                if (Progression <> false):
                    Progression.AddXP(Player, 100)
                break
            
            EnemyCount := 5 + (CurrentWave * 2)
            Print("Wave " + CurrentWave + ": " + EnemyCount + " enemies")
            ActiveEnemies = EnemyCount
            
            for i in 0..EnemyCount - 1:
                if (EnemySpawner <> false):
                    EnemySpawner.Spawn()
                Sleep(1.0)
            
            while ActiveEnemies > 0:
                Sleep(1.0)
            
            Sleep(5.0)
    
    OnEnemyKilled(Player : agent, Trigger : trigger_device) : void =
        if ActiveEnemies > 0:
            ActiveEnemies -= 1
        
        if (Economy <> false):
            Economy.AddGold(Player, RewardPerKill)
            Print("Enemy killed! +" + RewardPerKill + " gold")
