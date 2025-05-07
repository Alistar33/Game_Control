
integer listener;  

integer mainMenuChannel;
integer tuningMenuChannel;
integer paintChannel;
integer GameControlChannel;


integer BodyLink;
integer PartsLink;
integer RFWheel;
integer RRWheel;
integer LFWheel;
integer LRWheel;
list    gPrimnames;

key currentUser;
key owner;

//Game Control Menu
GameControlMenu(key id) {

GameControlChannel = randomNumber();
 menu(id,GameControlChannel,"Game Control - Choose between Keyboard, left stick, right stick or Gamepad.\n\n",["Joystick Left","Joystick Right", "D Pad", "Keyboard"]);
}

tuningMenu(key id)
{
    tuningMenuChannel = randomNumber();
    menu(id,tuningMenuChannel,"Engine Tuning - Choose between higher top speed, or faster acceleration.\n\n",["Speed++","Speed+","Balanced","Accel+","Accel++"]);
}


integer randomNumber()
{
    return((integer)(llFrand(99999.0)*-1));
}

menu(key id, integer channel, string title, list buttons) 
{
    llListenRemove(listener);
    listener = llListen(channel,"",id,"");
    llDialog(id,title,buttons,channel);
    llSetTimerEvent(20.0);   
}

mainMenu(key id) 
{
    mainMenuChannel = randomNumber();
    paintChannel = mainMenuChannel + 1;
    
    menu(id,mainMenuChannel,"Main Menu.\n\nTuning: Engine performance settings.\nCamera: Switch camera view.\nGame Control: Use Joystick or Keyboard.", ["Tuning","Camera","Game Control"]);
}

PrimNames()
{
        gPrimnames = [];    
        integer i;    
        for(i=1;i<=llGetNumberOfPrims();++i) 
            {
            gPrimnames += [llGetLinkName(i)];
            }
        
        BodyLink = llListFindList(gPrimnames, ["Body"]) + 1;
        PartsLink = llListFindList(gPrimnames, ["Parts"]) + 1;
        RFWheel = llListFindList(gPrimnames, ["RFWheel"]) + 1;
        LFWheel = llListFindList(gPrimnames, ["LFWheel"]) + 1;
        RRWheel = llListFindList(gPrimnames, ["RRWheel"]) + 1;
        LRWheel = llListFindList(gPrimnames, ["LRWheel"]) + 1;
}

default
{

    on_rez(integer start_param)
    {
        llResetScript();
    }
    
    touch_start(integer num)
    {
        owner = llGetOwner();
        currentUser = llDetectedKey(0);
        if(currentUser == owner)
        {
            PrimNames();
            mainMenu(currentUser);
        }
    }

    listen (integer channel, string name, key id, string message)
    {
        
        if (channel == mainMenuChannel)
        {
            if (message == "Camera")
            {
                llMessageLinked(LINK_ROOT, 409, "Camera", NULL_KEY);
            }
            
            if (message == "Tuning")
            {
                tuningMenu(id);
             }
            
            if (message == "Game Control")
            {
              GameControlMenu(id);
            }
        }
         if (channel == tuningMenuChannel)
        {
            llMessageLinked(LINK_ROOT, 409, message, NULL_KEY);
        }
       else if (channel == GameControlChannel)
        {
            llMessageLinked(LINK_ROOT, 409, message, NULL_KEY);
        }
    }

    timer()
    {
        llListenRemove(listener); 
        llSetTimerEvent(0.0); 
    }
}