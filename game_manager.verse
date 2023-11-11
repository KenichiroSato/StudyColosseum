
using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }

# See https://dev.epicgames.com/documentation/en-us/uefn/create-your-own-device-in-verse for how to create a verse device.

# A Verse-authored creative device that can be placed in a level
game_manager := class(creative_device):

    @editable Enemies: []enemy_device = array{}

    var CurrentEnemy: ?enemy_device = false
    var CurrentEnemyIndex<private>: int = 0

    HealthBar : health_bar = health_bar{}

    # Runs when the device is started in a running game
    OnBegin<override>()<suspends>:void=
        AllPlayers := GetPlayspace().GetPlayers()
        if (Player := AllPlayers[0]):
            InitHealthBar(Player)
            EmergeEnemy(Player)


    InitHealthBar<private>(Player: player):void =
            HealthBar.Init("Aknar The Terrible", 1000.0)
            HealthBar.ShowUIForPlayer(Player)

    EmergeEnemy<private>(Player: player)<suspends>:void =
        if (Enemy := Enemies[CurrentEnemyIndex]):
            set CurrentEnemy = option{Enemy}
            Enemy.Emerge()            

    OnCorrectAnswer(): void =
        HealthBar.TakeDamage(250.0)
        CurrentHp := HealthBar.GetCurrentHp()
        if (CurrentHp = 0.0):
            if (Enemy := CurrentEnemy?):
                spawn{Enemy.BackToGround()}
            AllPlayers := GetPlayspace().GetPlayers()
            if (Player := AllPlayers[0]):
                HealthBar.RemoveHealthBar(Player)

