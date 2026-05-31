using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }

utils := class:
    
    @Public
    ShowMessage(Player : agent, Text : string, Duration : float = 3.0) : void =
        Msg := message_device{}
        Msg.SetText(Text)
        Msg.Show(Player, Duration)
    
    @Public
    RandomInt(Min : int, Max : int) : int =
        return Min + GetRandomInt(Max - Min + 1)
    
    @Public
    Log(Tag : string, Message : string) : void =
        Print("[" + Tag + "] " + Message)
    
    @Public
    Clamp(Value : int, MinVal : int, MaxVal : int) : int =
        if Value < MinVal: return MinVal
        if Value > MaxVal: return MaxVal
        return Value

GOLD_MAX : int = 999999
GOLD_START : int = 50
LEVEL_BASE_XP : int = 100
