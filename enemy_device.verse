
using { /Fortnite.com/Devices }
using { /Fortnite.com/Characters}
using { /Verse.org/Simulation }
using { /Verse.org/Random }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /UnrealEngine.com/Temporary/SpatialMath }

# See https://dev.epicgames.com/documentation/en-us/uefn/create-your-own-device-in-verse for how to create a verse device.

# A Verse-authored creative device that can be placed in a level
enemy_device := class(creative_device):

    @editable var Enemy : creative_prop = creative_prop{}
    @editable var EnemyZone : mutator_zone_device = mutator_zone_device{}
    @editable Button1 :button_device = button_device{}
    @editable PlayerSpawner: player_spawner_device = player_spawner_device{}
    @editable HealthBarColor: string = "ffffff"

    var InitialPosition<private>: vector3 = vector3{X:=0.0, Y:= 0.0, Z:=0.0}
    var InitialRotation<private>: rotation = rotation{}
    var CurrentAgent<private>: ?agent = false

    MaxX :float = 3580.0
    MaxY :float = 5100.0

    # Runs when the device is started in a running game
    OnBegin<override>()<suspends>:void=
        Button1.InteractedWithEvent.Subscribe(OnButton)

    OnPlayerSpawned(Agent: agent):void=
        Print("OnPlayerSpawned")
        spawn{StartChasing(Agent)}
    
    OnButton(Agent: agent):void = 
        spawn{Emerge()}
        spawn{StartChasing(Agent)}

    OnPlayerCaptured(Agent : agent) :void =
        if (FortniteCharacter : fort_character = Agent.GetFortCharacter[]):
            MyCharacterHealth : float = FortniteCharacter.GetHealth()
            FortniteCharacter.Damage(MyCharacterHealth)
            set CurrentAgent = false
            BackToInitialPosition()
            Print("OnPlayerCaptured")

    BackToInitialPosition():void =
        spawn{Enemy.MoveTo(InitialPosition, InitialRotation, 1.0 )}

    StartChasing(Agent: agent)<suspends>:void =
        Print("StartChasing")
        Sleep(3.0) #プレーヤースポーン直後は無敵期間があるようなのでwait
        set CurrentAgent = option{Agent}
        loop:
            race:
                RotateTowardPlayer(Agent)
                Wait()
            if (CurrentAgent = false):
                Print("Break loop1") #Wait中に倒した時のため必要
                break
            Attack(Agent)
            if (CurrentAgent = false):
                Print("Break loop2") #Attack中に倒した時のため必要
                break
            Sleep(1.0)

    Wait()<suspends>:void =
        WaitTime := GetRandomFloat(0.0, 10.0)
        #Print("Wait for {WaitTime} seconds")
        Sleep(WaitTime)

    Emerge()<suspends>:void =
        PlayerSpawner.SpawnedEvent.Subscribe(OnPlayerSpawned)
        EnemyZone.AgentEntersEvent.Subscribe(OnPlayerCaptured)
        PropLocation := Enemy.GetTransform().Translation
        NewLocation := vector3{X := PropLocation.X, Y := PropLocation.Y, Z := PropLocation.Z + 300.0}
        Enemy.MoveTo(NewLocation, Enemy.GetTransform().Rotation, 1.5)
        set InitialPosition = Enemy.GetTransform().Translation
        set InitialRotation = Enemy.GetTransform().Rotation

    BackToGround()<suspends>:void =
        Print("BackToGround")
        set CurrentAgent = false
        PropLocation := Enemy.GetTransform().Translation
        NewLocation := vector3{X := PropLocation.X, Y := PropLocation.Y, Z := PropLocation.Z - 300.0}
        Enemy.MoveTo(NewLocation, Enemy.GetTransform().Rotation, 3.0)

    Attack(Agent: agent)<suspends>:void =
        #Print("Attack")
        if (PlayerCharacter := Agent.GetFortCharacter[]):
            PlayerLocation := PlayerCharacter.GetTransform().Translation
            PropLocation := Enemy.GetTransform().Translation
            Xdiff := PlayerLocation.X - PropLocation.X
            Ydiff := PlayerLocation.Y - PropLocation.Y
            var NewX :float = PropLocation.X + 1.5*Xdiff
            var NewY :float = PropLocation.Y + 1.5*Ydiff
            if (NewX < 0.0):
                set NewX = 0.0
            if (NewX > MaxX):
                set NewX = MaxX
            if (NewY < 0.0):
                set NewY = 0.0
            if (NewY > MaxY):
                set NewY = MaxY
            NewLocation := vector3{X := NewX, Y := NewY, Z := PropLocation.Z}
            Enemy.MoveTo(NewLocation, Enemy.GetTransform().Rotation, 2.0)

    RotateTowardPlayer(Agent : agent)<suspends>:void=
        #Print("RotateTowardPlayer")
        loop:
            if (CurrentAgent = false):
                break
            if (PlayerCharacter := Agent.GetFortCharacter[]):
                PropLocation := Enemy.GetTransform().Translation
                PlayerLocation := PlayerCharacter.GetTransform().Translation
                if (LookDirection := (PropLocation - PlayerLocation).MakeUnitVector[]):
                    Yaw := RadiansToDegrees(ArcTan(LookDirection.Y, LookDirection.X)) #+ 140.0
                    Pitch := 0.0 #RadiansToDegrees(ArcTan(LookDirection.Z, Sqrt((LookDirection.X * LookDirection.X) + (LookDirection.Y * LookDirection.Y))))
                    Roll := 0.0
                    NewRotation := MakeRotationFromYawPitchRollDegrees(Yaw, Pitch, Roll)
                    Enemy.MoveTo(PropLocation, NewRotation, 0.5)
            Sleep(0.0)