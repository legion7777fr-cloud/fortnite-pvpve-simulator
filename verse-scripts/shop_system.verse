using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }

shop_item := class:
    var ItemId : string = ""
    var ItemName : string = ""
    var Price : int = 0
    var ItemToGrant : string = ""

ShopSystem := class(creative_device):
    
    @editable
    var ShopButton : button_device = button_device{}
    
    @editable
    var ItemGranter : item_granter_device = item_granter_device{}
    
    @editable
    var Economy : economy_manager = economy_manager{}
    
    var Items : []shop_item = array:
        shop_item{ItemId: "sword", ItemName: "Epic Sword", Price: 50, ItemToGrant: "epic_sword"}
        shop_item{ItemId: "health", ItemName: "Health Potion", Price: 20, ItemToGrant: "health_potion"}
        shop_item{ItemId: "shield", ItemName: "Shield Potion", Price: 25, ItemToGrant: "shield_potion"}
        shop_item{ItemId: "speed", ItemName: "Speed Boost", Price: 30, ItemToGrant: "speed_boost"}
        shop_item{ItemId: "damage", ItemName: "Damage Boost", Price: 40, ItemToGrant: "damage_boost"}
    
    OnBegin<override>()<suspends>:
        Print("Shop System started")
        
        if (ShopButton <> false):
            ShopButton.InteractedWithEvent.Subscribe(OnBuyClicked)
    
    OnBuyClicked(Player : agent, Button : button_device) : void =
        if (Items.Length > 0):
            Item := Items[0]
            
            if (Economy <> false) and Economy.HasEnoughGold(Player, Item.Price):
                if Economy.SpendGold(Player, Item.Price):
                    if (ItemGranter <> false):
                        ItemGranter.GrantItem(Player, Item.ItemToGrant)
                        Print("Player bought " + Item.ItemName + " for " + Item.Price + " gold")
            else:
                Print("Not enough gold for " + Item.ItemName + ". Need: " + Item.Price)
