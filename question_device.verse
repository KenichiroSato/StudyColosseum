
using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }

# See https://dev.epicgames.com/documentation/en-us/uefn/create-your-own-device-in-verse for how to create a verse device.

# A Verse-authored creative device that can be placed in a level
question_device := class(creative_device):

    @editable Q1Prop : creative_prop = creative_prop{}
    @editable Q2Prop : creative_prop = creative_prop{}


    # Runs when the device is started in a running game
    OnBegin<override>()<suspends>:void=
        Q1Prop.SetMaterial(Assets.q1ng_Mat)
        Q2Prop.SetMaterial(Assets.q1ok_Mat)