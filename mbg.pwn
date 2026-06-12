//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////                         FILTERSCRIPTS MBG                         ////////////////////////
////////////////////////     BY DELFIN GANTENG ATAU UCOK GAMING     ////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

//NOTE : JANGAN UBAH CREDITS / DONT REMOVE/EDIT CREDITS

#include <a_samp>
#include <zcmd>
#include <streamer>

#define MAX_MBG 10

new PegangMbg[MAX_PLAYERS];
new bool:LagiMbg[MAX_PLAYERS];
new bool:LagiMasak[MAX_PLAYERS];
new SkinLama[MAX_PLAYERS];
new MBGLevel[MAX_PLAYERS];

new CookingCP[MAX_PLAYERS];

new Float:CookPos[4][3] = {
    {2444.10, -2138.46, 13.54},
    {2454.10, -2138.46, 13.54},
    {2464.10, -2138.46, 13.54},
    {2474.10, -2138.46, 13.54}
};

new Float:DeliverPos[3][3] = {
    {2438.52, -2086.52, 13.54},
    {2420.00, -2075.00, 13.54},
    {2410.50, -2090.00, 13.54}
};

forward FinishCooking(playerid);

stock SendMsg(playerid, color, text[])
{
    return SendClientMessage(playerid, color, text);
}

public OnFilterScriptInit()
{
    print("[MBG PRO] Loaded successfully");
    return 1;
}

public OnPlayerDisconnect(playerid, reason)
{
    LagiMbg[playerid] = false;
    LagiMasak[playerid] = false;
    PegangMbg[playerid] = 0;
    MBGLevel[playerid] = 0;
    return 1;
}

/* ===================== JOB START ===================== */

CMD:mbg(playerid)
{
    if(!IsPlayerInRangeOfPoint(playerid, 3.0, 2448.62, -2119.31, 13.54))
        return SendMsg(playerid, 0xFF0000FF, "[MBG] Kamu tidak di lokasi kerja.");

    if(!LagiMbg[playerid])
    {
        LagiMbg[playerid] = true;
        SkinLama[playerid] = GetPlayerSkin(playerid);
        SetPlayerSkin(playerid, 176);

        SendMsg(playerid, 0x00FFFFFF, "[MBG] Kamu mulai kerja. Masuk dapur!");
    }
    else
    {
        LagiMbg[playerid] = false;
        SetPlayerSkin(playerid, SkinLama[playerid]);

        SendMsg(playerid, 0xFFFFFFFF, "[MBG] Kamu berhenti kerja.");
    }
    return 1;
}

/* ===================== COOK SYSTEM ===================== */

CMD:masakmbg(playerid)
{
    if(!LagiMbg[playerid])
        return SendMsg(playerid, 0xFF0000FF, "[ERROR] Kamu belum duty.");

    if(LagiMasak[playerid])
        return SendMsg(playerid, 0xFF0000FF, "[ERROR] Kamu sedang memasak.");

    if(PegangMbg[playerid] >= MAX_MBG)
        return SendMsg(playerid, 0xFF0000FF, "[ERROR] Tas penuh.");

    new found = -1;

    for(new i = 0; i < 4; i++)
    {
        if(IsPlayerInRangeOfPoint(playerid, 2.5, CookPos[i][0], CookPos[i][1], CookPos[i][2]))
        {
            found = i;
            break;
        }
    }

    if(found == -1)
        return SendMsg(playerid, 0xFF0000FF, "[ERROR] Tidak di tempat masak.");

    CookingCP[playerid] = found;
    LagiMasak[playerid] = true;

    TogglePlayerControllable(playerid, 0);
    SendMsg(playerid, 0x00FFFFFF, "[MBG] Memasak...");

    SetTimerEx("FinishCooking", 7000, false, "i", playerid);
    return 1;
}

public FinishCooking(playerid)
{
    if(!IsPlayerConnected(playerid)) return 0;

    LagiMasak[playerid] = false;
    PegangMbg[playerid]++;

    TogglePlayerControllable(playerid, 1);

    SendMsg(playerid, 0x00FF00FF, "[MBG] Masakan selesai +1 MBG.");

    return 1;
}

/* ===================== DELIVERY SYSTEM ===================== */

CMD:antarmbg(playerid)
{
    if(!LagiMbg[playerid])
        return SendMsg(playerid, 0xFF0000FF, "[ERROR] Kamu bukan pekerja MBG.");

    if(PegangMbg[playerid] <= 0)
        return SendMsg(playerid, 0xFF0000FF, "[ERROR] Tidak ada barang.");

    new rand = random(sizeof(DeliverPos));

    SetPlayerCheckpoint(playerid,
        DeliverPos[rand][0],
        DeliverPos[rand][1],
        DeliverPos[rand][2],
        3.0
    );

    SendMsg(playerid, 0x00FFFFFF, "[MBG] Antar ke titik yang ditandai di map.");
    return 1;
}

public OnPlayerEnterCheckpoint(playerid)
{
    if(PegangMbg[playerid] > 0)
    {
        new pay = (60000 + (MBGLevel[playerid] * 5000)) * PegangMbg[playerid];

        GivePlayerMoney(playerid, pay);

        SendMsg(playerid, 0x00FF00FF, "[MBG] Delivery selesai!");

        PegangMbg[playerid] = 0;
        MBGLevel[playerid]++;

        DisablePlayerCheckpoint(playerid);
    }
    return 1;
}