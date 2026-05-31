using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }

quantum_effect := enum:
    Superposition
    Entanglement
    Teleportation
    Phasing
    QuantumJump

QuantumManager := class(creative_device):
    
    @editable
    var Economy : economy_manager = economy_manager{}
    
    @editable
    var AudioPlayer : audio_player_device = audio_player_device{}
    
    @editable
    var QuantumChance : int = 20  # 20% шанс квантового эффекта
    
    var ActiveSounds : int = 0
    var MaxConcurrentSounds : int = 10
    
    OnBegin<override>()<suspends>:
        Print("Quantum Manager started")
    
    PlaySound(SoundName : string, Priority : int) : void =
        if ActiveSounds >= MaxConcurrentSounds and Priority < 2:
            return
        
        ActiveSounds += 1
        
        if (AudioPlayer <> false):
            AudioPlayer.PlaySound(SoundName)
        
        spawn:
            Sleep(2.0)
            ActiveSounds -= 1
    
    PlayQuantumEffectSound() : void =
        Effects := array:
            "quantum_superposition"
            "quantum_entanglement"
            "quantum_blink"
            "quantum_phase"
            "quantum_jump"
        
        RandomIndex := GetRandomInt(0, Effects.Length - 1)
        PlaySound(Effects[RandomIndex], 2)
    
    GetRandomEffect() : quantum_effect =
        RandomValue := GetRandomInt(0, 4)
        return quantum_effect[RandomValue]
    
    ApplyQuantumEffect(Enemy : agent, EffectType : quantum_effect) : void =
        PlayQuantumEffectSound()
        
        if EffectType = quantum_effect.Superposition:
            Print("Quantum Superposition: Enemy will clone on death")
            # При смерти создаёт 2 клона с 50% HP
        else if EffectType = quantum_effect.Entanglement:
            Print("Quantum Entanglement: Enemy linked to others")
            # Урон распределяется между 5 связанными врагами
        else if EffectType = quantum_effect.Teleportation:
            Print("Quantum Teleportation: Enemy teleports to player")
            # Телепортация к игроку каждые 5 секунд
        else if EffectType = quantum_effect.Phasing:
            Print("Quantum Phasing: Enemy becomes invulnerable briefly")
            # На 1 секунду неуязвим каждые 10 секунд
        else if EffectType = quantum_effect.QuantumJump:
            Print("Quantum Jump: Enemy leaves portal on death")
            # При смерти создаёт портал с 3 врагами
    
    ShouldApplyQuantumEffect() : bool =
        RandomValue := GetRandomInt(1, 100)
        return RandomValue <= QuantumChance
    
    OnEnemySpawned(Enemy : agent) : void =
        if ShouldApplyQuantumEffect():
            Effect := GetRandomEffect()
            ApplyQuantumEffect(Enemy, Effect)
    
    PlayBossWarning() : void =
        PlaySound("boss_warning", 3)
    
    PlayWaveStart(WaveNumber : int) : void =
        PlaySound("wave_start", 2)
        
        if WaveNumber % 5 = 0:
            PlayBossWarning()
