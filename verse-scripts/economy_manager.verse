# Economy Manager
# Управление валютой игрока (Gold Coins)

using { /Fortnite.com/Devices }
using { /UnrealEngine.com/Transient }

class EconomyManager:
    var PlayerGold: int = 50
    var MaxGold: int = 999999
    var BankSlots: int = 1
    var MaxBankSlots: int = 10
    var BankedGold: int = 0

    # Инициализация новой сессии игрока
    public Init() -> void:
        PlayerGold = 50
        BankedGold = 0
        BankSlots = 1

    # Добавить золото
    public AddGold(Amount: int) -> void:
        if Amount <= 0:
            return
        var NewGold = PlayerGold + Amount
        PlayerGold = Min(NewGold, MaxGold)
        Print("Added {Amount} gold. Total: {PlayerGold}")

    # Потратить золото
    public SpendGold(Amount: int) -> bool:
        if Amount <= 0:
            return false
        if PlayerGold >= Amount:
            PlayerGold -= Amount
            Print("Spent {Amount} gold. Remaining: {PlayerGold}")
            return true
        Print("Not enough gold. Need: {Amount}, Have: {PlayerGold}")
        return false

    # Получить текущее количество золота
    public GetGold() -> int:
        return PlayerGold

    # Положить золото в банк
    public DepositGold(Amount: int) -> bool:
        if Amount <= 0:
            return false
        if not SpendGold(Amount):
            return false
        BankedGold += Amount
        return true

    # Снять золото из банка
    public WithdrawGold(Amount: int) -> bool:
        if Amount <= 0:
            return false
        if BankedGold >= Amount:
            BankedGold -= Amount
            AddGold(Amount)
            return true
        return false

    # Потеря золота при смерти (% от текущего)
    public LoseGoldOnDeath() -> void:
        var LossPercent = 10
        var GoldToLose = (PlayerGold * LossPercent) / 100
        if GoldToLose > 0:
            SpendGold(GoldToLose)
            Print("Lost {GoldToLose} gold on death")

    # Потеря золота в PvP при поражении
    public LoseGoldPvP(StakeAmount: int) -> void:
        SpendGold(StakeAmount)
        Print("Lost {StakeAmount} gold in PvP")

    # Получить золото в PvP при победе
    public WinGoldPvP(StakeAmount: int) -> void:
        var WinAmount = (StakeAmount * 30) / 100  # 30% ставки
        AddGold(WinAmount)
        Print("Won {WinAmount} gold in PvP")

    # Проверка достаточности золота
    public HasEnoughGold(Amount: int) -> bool:
        return PlayerGold >= Amount

    # Полная перезагрузка статов (затратное)
    public ResetStats(Cost: int) -> bool:
        return SpendGold(Cost)
