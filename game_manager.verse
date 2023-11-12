
using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }

# See https://dev.epicgames.com/documentation/en-us/uefn/create-your-own-device-in-verse for how to create a verse device.

# A Verse-authored creative device that can be placed in a level
game_manager := class(creative_device):

    @editable Enemies: []enemy_device = array{}

    var CurrentEnemy: ?enemy_device = false
    var CurrentEnemyIndex<private>: int = 0
    var CurrentPlayer: ?player = false

    HealthBar : health_bar = health_bar{}

    # Runs when the device is started in a running game
    OnBegin<override>()<suspends>:void=
        AllPlayers := GetPlayspace().GetPlayers()
        if (Player := AllPlayers[0]):
            set CurrentPlayer = option{Player}
            EmergeEnemy()


    InitHealthBar<private>(Color: string):void =
        if (Player := CurrentPlayer?):
            HealthBar.Init("Aknar The Terrible", 1000.0, Color)
            HealthBar.ShowUIForPlayer(Player)

    RemoveHealthBar():void =
        if (Player := CurrentPlayer?):
            HealthBar.RemoveHealthBar(Player)

    EmergeEnemy<private>()<suspends>:void =
        if (Enemy := Enemies[CurrentEnemyIndex]):
            set CurrentEnemy = option{Enemy}
            Enemy.Emerge()
            InitHealthBar(Enemy.HealthBarColor)
            if (Player := CurrentPlayer?):
                Enemy.StartChasing(Player)
        

    OnCorrectAnswer(): void =
        HealthBar.TakeDamage(250.0)
        CurrentHp := HealthBar.GetCurrentHp()
        if (CurrentHp = 0.0):
            spawn{OnEnemyDefeated()}

    OnEnemyDefeated()<suspends>: void =
        if (Enemy := CurrentEnemy?):
            RemoveHealthBar()
            Enemy.BackToGround()
            Sleep(1.0) #次のモンスターが出てくるまでのインターバル
            set CurrentEnemyIndex += 1
            EmergeEnemy()


    
