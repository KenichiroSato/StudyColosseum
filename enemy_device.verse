
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

    var InitialPosition<private>: vector3 = vector3{X:=0.0, Y:= 0.0, Z:=0.0}
    var InitialRotation<private>: rotation = rotation{}
    var CurrentAgent<private>: ?agent = false

    # Runs when the device is started in a running game
    OnBegin<override>()<suspends>:void=
        set InitialPosition = Enemy.GetTransform().Translation
        set InitialRotation = Enemy.GetTransform().Rotation
        PlayerSpawner.SpawnedEvent.Subscribe(OnPlayerSpawned)
        EnemyZone.AgentEntersEvent.Subscribe(OnPlayerCaptured)
        Button1.InteractedWithEvent.Subscribe(OnButton)

    OnPlayerSpawned(Agent: agent):void=
        spawn{Start(Agent)}
    
    OnButton(Agent: agent):void = 
        spawn{Start(Agent)}

    OnPlayerCaptured(Agent : agent) :void =
        if (FortniteCharacter : fort_character = Agent.GetFortCharacter[]):
            MyCharacterHealth : float = FortniteCharacter.GetHealth()
            FortniteCharacter.Damage(MyCharacterHealth)
            set CurrentAgent = false
            BackToInitialPosition()
            Print("OnPlayerCaptured")

    BackToInitialPosition():void =
        spawn{Enemy.MoveTo(InitialPosition, InitialRotation, 1.0 )}

    Start(Agent: agent)<suspends>:void =
        loop:
            race:
                FollowPlayer(Agent)
                Wait()
            Attack(Agent)
            Sleep(1.0)
            if (CurrentAgent = false):
                Print("Break loop")
                break

    Wait()<suspends>:void =
        WaitTime := GetRandomFloat(0.0, 10.0)
        Print("Wait for {WaitTime} seconds")
        Sleep(WaitTime)


    Attack(Agent: agent)<suspends>:void =
        Print("Attack")
        if (PlayerCharacter := Agent.GetFortCharacter[]):
            PlayerLocation := PlayerCharacter.GetTransform().Translation
            PropLocation := Enemy.GetTransform().Translation
            Xdiff := PlayerLocation.X - PropLocation.X
            Ydiff := PlayerLocation.Y - PropLocation.Y
            NewLocation := vector3{X := PropLocation.X + 1.5*Xdiff, Y :=  PropLocation.Y + 1.5*Ydiff, Z := PropLocation.Z}
            Enemy.MoveTo(NewLocation, Enemy.GetTransform().Rotation, 2.0)

    FollowPlayer(Agent : agent)<suspends>:void=
        Print("FollowPlayer")
        set CurrentAgent = option{Agent}
        var MoveSpeed :float = 0.1
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
                    # Movement
                    LerpLocation := Lerp(PropLocation, PlayerLocation, MoveSpeed)
                    FinalLocation := vector3{X := LerpLocation.X, Y := LerpLocation.Y, Z := LerpLocation.Z}
                    Enemy.MoveTo(PropLocation, NewRotation, 0.5)
                    set MoveSpeed += 0.2
            Sleep(0.0)