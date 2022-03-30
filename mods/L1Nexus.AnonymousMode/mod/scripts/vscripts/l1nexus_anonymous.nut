global function l1nexus_anonymous_init

const int P = 41
const int MOD = 9997

struct{
string mode
string placeholder
string prefix
bool HidePermanentCockpitRui
} file

global struct l1nexus_anonymous_globals{
   array<void functionref( ObitStringData )> onPrintObituary
   array<string functionref( string )> onPrintObituaryLocalized
   array<array<string> functionref( entity, entity, array<string> )> onObituary
} 
global l1nexus_anonymous_globals l1nexus_anonymous_global


// Waiting for the end to come. Wishing I had strength to stand.
void function l1nexus_anonymous_init()
{
    // Digital|Fill|Apexlike
    file.mode = GetConVarString("mode")
    file.placeholder = GetConVarString("placeholder")
    file.prefix = GetConVarString("prefix")
    file.HidePermanentCockpitRui = GetConVarBool("HidePermanentCockpitRui")

    thread main()
}

void function main()
{
    WaitFrame()
    srand(rand())
    AddCallback_OnReceivedSayTextMessage(MyChatFilter)
    AddCallback_Obituary(ObituaryReplacer)
    SetScoreboardUpdateCallback(ScoreboardReplacer)
    clGlobal.onLocalPlayerDidDamageCallback.append(doSth)
    AddCreatePilotCockpitCallback( lol )
}

void function lol(entity cockpit, entity player)
{
    print("cockpit " + cockpit)
    print(typeof(cockpit) )
}

void function doSth( entity attacker, entity victim, vector position, int damagetype)
{
    // Tracker_PlayerAttackedTarget( attacker, victim ) nothing happen

    print(attacker.GetPlayerName() + " " + victim.GetPlayerName() + " " + damagetype)
}

// replace the kills
array<string> function ObituaryReplacer(entity attacker, entity victim, array<string> obit)
{
    switch(file.mode)
    {
        case "Digital":
            obit[0] = attacker.IsPlayer() ? Rand(obit[0]) : obit[0]
            obit[2] = victim.IsPlayer() ? Rand(obit[2]) : obit[2]
            break
        case "Fill":
            obit[0] = attacker.IsPlayer() ? file.placeholder : obit[0]
            obit[2] = victim.IsPlayer() ? file.placeholder : obit[2]
            break
        case "Apexlike":
            obit[0] = attacker.IsPlayer() ? HashToApexlike(attacker) : obit[0]
            obit[2] = victim.IsPlayer() ? HashToApexlike(victim) : obit[2]
            break
    }
    return obit
}

void function HideCrosshairNamesAll(array<entity> players)
{
    foreach(player in players)
        player.HideCrosshairNames()
}

// replace the sb
void function ScoreboardReplacer(entity e, var rui)
{
    // HideFriendlyIndicatorAndCrosshairNames() // Not work
    if(file.HidePermanentCockpitRui)
        HidePermanentCockpitRui() // Enemy health bar is a permanentcockpitrui.
    if (!e.IsPlayer())
        return
    // e.HideCrosshairNames() // not work
    entity player = GetLocalClientPlayer()
    string name = e.GetPlayerName()

    switch(file.mode)
    {
        case "Digital":
            name = Rand(name)
            break
        case "Fill":
            name = file.placeholder
            break
        case "Apexlike":
            name = HashToApexlike(e)
            break
    }
    RuiSetString(rui, "playerName", name)
    // Patch
    RuiSetImage( rui, "playerCard", CallsignIcon_GetSmallImage( PlayerCallsignIcon_GetActive( player ) ) )
}

ClClient_MessageStruct function MyChatFilter(ClClient_MessageStruct message)
{
    if (!message.player.IsPlayer())
        return message
    switch(file.mode)
    {
        case "Digital":
            message.playerName = Rand(message.playerName)
            break
        case "Fill":
            message.playerName = file.placeholder
            break
        case "Apexlike":
            message.playerName = HashToApexlike(message.player)
            break
    }
    return message
}

// rand int
string function Rand(string name)
{
    return string(rand())
}

// broken func. Cast from int to int raise error(tointeger() not work also). 
// string function Hash(string name)
string function Hash(entity p)
{

    string name = p.GetPlayerName()
    int hash = 42
    int i = 0
    array<int> chars 
    for(i=0;i<name.len();i++)
    {
        // print(typeof(name[i]) + " " + name[i]) // int
        hash *= P
        // print(name.tointeger())// 0
        hash += p.GetGen()
        hash = hash << p.GetTeam()
        hash += p.GetLevel()
        // hash += int(name[i])// error
        hash= hash%MOD
    }
    if(hash<0)
        hash = 0 - hash
    return string(hash)
}

string function HashToApexlike(entity player)
{
    return file.prefix + Hash(player)
}