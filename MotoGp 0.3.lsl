string  idle = "680e0bb4-0f8c-5516-7169-f3db938129ce";
string  high = "ccefc6c0-d78a-4099-4ad1-7c4aa7eceba2";
string  offhigh = "35bcf4f0-c295-6176-e219-98f137cf223b";
string  start = "1c819503-d326-7839-f4a8-ae1fa6a7878e";

string  idleAnim = "idle";
string  driveAnim = "drive";
string  leftAnim = "left";
string  rightAnim = "right";
string  currentAnim = "";
string  nextAnim = "";

integer grounded = 1;

integer cameramode = 0;

list    gPrimnames;

integer gChan;

integer     CurDir;
integer     LastDir;

integer SpeedLimit = 0;

vector angular_motor;
        
vector vel;
float speed;
vector SpeedVec;
integer reverse;

integer accel = 0;
integer brake = 0;
float   brakebias = 1.2;

integer     DIR_STOP = 100;
integer     DIR_START = 101;
integer     DIR_NORM = 102;
integer     DIR_LEFT = 103;
integer     DIR_RIGHT = 104;

integer onsound = 0;
integer offsound = 0;
integer Access = 1;
integer Gear = 1;
integer physical = 0;
float forward_power = 0; 
float TurnPower = 20.0;
integer direction;
integer sound;
float volume = 1.0;
float   TrackLimit = 0.0;

float AngXMult = 3.0;
float Banking;
float Z_Modifier = 0.0;

float VLFT_X = 30.0;
float VLFT_Y = 0.1;
float PowerAdj = 0.0;
float       VLMO_X = 0.0;
float       VLMO_Y = 0.0;  
float       VLMO_Z = 0.0;

list    VLMT_Gear = [2.0, 3.0, 4.0, 5.0, 6.0];
list    Power_Gear = [-10.0, -5.0, 0.0, 5.0, 10.0];
list    Setups = ["Accel++", "Accel+", "Balanced", "Speed+", "Speed++"];
integer setup = 2;

float fVEHICLE_ANGULAR_DEFLECTION_EFFICIENCY = 0.5;
float fVEHICLE_LINEAR_DEFLECTION_EFFICIENCY = 1.0;
float fVEHICLE_ANGULAR_DEFLECTION_TIMESCALE = 0.5;
float fVEHICLE_LINEAR_DEFLECTION_TIMESCALE = 0.10;
float VLMT = 4.0;
float fVEHICLE_LINEAR_MOTOR_DECAY_TIMESCALE = 7.0;
float fVEHICLE_ANGULAR_MOTOR_TIMESCALE = 0.15;
float fVEHICLE_ANGULAR_MOTOR_DECAY_TIMESCALE = 0.0;
vector VLFT = <30.0, 0.1, 20.0>;
vector VLFT_Brake = <2.0, 0.1, 20.0>;
vector vVEHICLE_ANGULAR_FRICTION_TIMESCALE = <10.0, 2.1, 0.01> ;
float VVAE = 0.5;
float VVAT = 0.7;
float fVEHICLE_BANKING_EFFICIENCY = 1.0;
float fVEHICLE_BANKING_TIMESCALE = 0.01;
float fVEHICLE_BANKING_MIX = 1.0;
float fVEHICLE_BUOYANCY = -0.1;
string description = "";
list gearList = [-30,0,60]; 
integer listenhandle;
integer method = 3;
key owner;
integer prev_button_levels = 0; 
float x;
float y;


SetupChange()
{
    VLMT = llList2Float(VLMT_Gear, setup);
    PowerAdj = llList2Float(Power_Gear, setup);
    llSetVehicleFloatParam(VEHICLE_LINEAR_MOTOR_TIMESCALE, VLMT);
    llOwnerSay(llList2String(Setups, setup) + " setting selected.");
}

PrimNames()
{
        gPrimnames = [];    
        integer i;    
        for(i=1;i<=llGetNumberOfPrims();++i) 
            {
            gPrimnames += [llGetLinkName(i)];
            }
}

CameraChange()
{
    
    
    if(cameramode == 0)
    {
        llClearCameraParams();
        llSetCameraParams([
                CAMERA_ACTIVE, 1, 
                CAMERA_BEHINDNESS_ANGLE, 1.0, 
                CAMERA_BEHINDNESS_LAG, 0.1,  
                CAMERA_DISTANCE, 5.0, 
              
                CAMERA_FOCUS_LAG, 0.001 , 
                CAMERA_FOCUS_LOCKED, FALSE, 
                CAMERA_FOCUS_THRESHOLD, 0.001, 
                CAMERA_PITCH, 5.0, 
              
                CAMERA_POSITION_LAG, 0.001, 
                CAMERA_POSITION_LOCKED, FALSE, 
                CAMERA_POSITION_THRESHOLD, 0.001, 
                CAMERA_FOCUS_OFFSET, <0.0, 0.0, 0.0> 
            ]);
    }  
    
    if(cameramode == 1)
    {
        llClearCameraParams();
        llSetCameraParams([
                CAMERA_ACTIVE, 1, 
                CAMERA_BEHINDNESS_ANGLE, 1.0, 
                CAMERA_BEHINDNESS_LAG, 0.1, 
                CAMERA_DISTANCE, 3.0, 
              
                CAMERA_FOCUS_LAG, 0.1 , 
                CAMERA_FOCUS_LOCKED, FALSE, 
                CAMERA_FOCUS_THRESHOLD, 0.5, 
                CAMERA_PITCH, 20.0, 
              
                CAMERA_POSITION_LAG, 0.1, 
                CAMERA_POSITION_LOCKED, FALSE, 
                CAMERA_POSITION_THRESHOLD, 0.5, 
                CAMERA_FOCUS_OFFSET, <0.0, 0.0, 1.0> 
            ]);
    }
    

}





default
{
    state_entry()
    {
        owner = llGetOwner();
        Gear = 1;
        forward_power = 0;
        llStopSound();
        llCollisionSound("", 0.0);
        llMessageLinked(LINK_SET , DIR_STOP, "", NULL_KEY);
        llSetObjectDesc( description );
        llSetSitText("Drive!");
        llSitTarget(<-0.36752, 0.00000, 1.11535>, <0.00000, 0.00000, 0.00000, 1.00000>);
        PrimNames();
        llMessageLinked(LINK_SET, 0, "", "fw_reset");
        
        
        
    }
    
    on_rez(integer param)
    {    
        llResetScript();        
    }
    

touch_start(integer total_number)
    {
        if(llDetectedKey(0) == llGetOwner())
        {
              llResetScript();  
        }
    }    
    
        link_message(integer sender_num, integer num, string message, key id)
    {
        if(num == 409)
        {

                
                if(message == "Camera")
                {
                    cameramode += 1;
                    if(cameramode > 1){cameramode = 0;}
                    CameraChange();
                }
                
                if(message == "Speed++")
                {
                    setup = 4;
                    SetupChange();
                }
                
                if(message == "Speed+")
                {
                    setup = 3;
                    SetupChange();
                }
                
                if(message == "Balanced")
                {
                    setup = 2;
                    SetupChange();
                }
                
                if(message == "Accel+")
                {
                    setup = 1;
                    SetupChange();
                }
                
                if(message == "Accel++")
                {
                    setup = 0;
                    SetupChange();
                }
                if(message == "Joystick 1") {
                     method = 0;
                llOwnerSay("Joystick Left");
                     }
                if (message == "Joystick 2"){
                     method = 1;
                llOwnerSay("Joystick Right");
                     }
                if (message == "D Pad") {
                     method = 2;
                llOwnerSay("D Pad");
                     }
                if (message == "Keyboard"){
                     method = 3;
                llOwnerSay("Keyboard");
                     }
                
        }
    
    }

    
    changed(integer change)
    {
       
        
        if(change & CHANGED_OWNER)
        {
            llResetScript();
        }
        
        if (change & CHANGED_LINK)
        {
            CurDir = DIR_NORM;
            LastDir = DIR_NORM;
            method = 3;  //Keyboard as default
            
            key agent = llAvatarOnSitTarget();
            if (agent)
            {
                gChan = (integer) ( "0xF" + llGetSubString(agent,0,6 ) );
                
                if(Access == 1)
                {
                    if (agent != llGetOwner())
                    {
                        llOwnerSay( "You do not have access to Drive this bike");
                        llUnSit(agent);
                        llPushObject(agent, <0,0,50>, ZERO_VECTOR, FALSE);
                    }
                    else
                    {
                        state drive;
                    }
                }
                else if (Access == 2)
                {
                    if (llSameGroup( agent ))
                    {
                        state drive;
                    }
                    else
                    {
                        llOwnerSay( "You do not have access to Drive this bike");
                        llUnSit(agent);
                        llPushObject(agent, <0,0,50>, ZERO_VECTOR, FALSE);
                    }

                }
                else if (Access == 3)
                {
                    state drive;
                }
            }
        }  
    }

}

state drive
{
    
    state_entry()
    {
        llOwnerSay("I'm in Drive!");
        owner = llGetOwner();
        forward_power = llList2Float(gearList,Gear);
        llTriggerSound(start,volume);
        llSleep(.5);
        llRequestPermissions(llAvatarOnSitTarget(), PERMISSION_TRIGGER_ANIMATION | PERMISSION_TAKE_CONTROLS | PERMISSION_CONTROL_CAMERA);
        llSetTimerEvent(0.1);
        
        llLoopSound(idle,volume);
        llMessageLinked(LINK_SET, DIR_START, "", NULL_KEY);
        llMessageLinked(LINK_SET, DIR_NORM, "", NULL_KEY);
        
        
        
        VLFT = <VLFT_X, VLFT_Y, 20.0> ;
        VLFT_Brake = <2.0, VLFT_Y, 20.0> ;
        
        llSetVehicleType(VEHICLE_TYPE_CAR);
        llSetVehicleFloatParam(VEHICLE_ANGULAR_DEFLECTION_EFFICIENCY, fVEHICLE_ANGULAR_DEFLECTION_EFFICIENCY);
        llSetVehicleFloatParam(VEHICLE_LINEAR_DEFLECTION_EFFICIENCY, fVEHICLE_LINEAR_DEFLECTION_EFFICIENCY);
        llSetVehicleFloatParam(VEHICLE_ANGULAR_DEFLECTION_TIMESCALE, fVEHICLE_ANGULAR_DEFLECTION_TIMESCALE);
        llSetVehicleFloatParam(VEHICLE_LINEAR_DEFLECTION_TIMESCALE, fVEHICLE_LINEAR_DEFLECTION_TIMESCALE);
        llSetVehicleFloatParam(VEHICLE_LINEAR_MOTOR_TIMESCALE, VLMT);
        llSetVehicleFloatParam(VEHICLE_LINEAR_MOTOR_DECAY_TIMESCALE, fVEHICLE_LINEAR_MOTOR_DECAY_TIMESCALE);
        llSetVehicleFloatParam(VEHICLE_ANGULAR_MOTOR_TIMESCALE, fVEHICLE_ANGULAR_MOTOR_TIMESCALE);
        llSetVehicleFloatParam(VEHICLE_ANGULAR_MOTOR_DECAY_TIMESCALE, fVEHICLE_ANGULAR_MOTOR_DECAY_TIMESCALE);
        llSetVehicleVectorParam(VEHICLE_LINEAR_FRICTION_TIMESCALE, VLFT );
        llSetVehicleVectorParam(VEHICLE_ANGULAR_FRICTION_TIMESCALE, vVEHICLE_ANGULAR_FRICTION_TIMESCALE );
        llSetVehicleFloatParam(VEHICLE_VERTICAL_ATTRACTION_EFFICIENCY, VVAE);
        llSetVehicleFloatParam(VEHICLE_VERTICAL_ATTRACTION_TIMESCALE, VVAT);
        llSetVehicleFloatParam(VEHICLE_BANKING_EFFICIENCY, fVEHICLE_BANKING_EFFICIENCY);
        llSetVehicleFloatParam(VEHICLE_BANKING_TIMESCALE, fVEHICLE_BANKING_TIMESCALE);
        llSetVehicleFloatParam(VEHICLE_BANKING_MIX, fVEHICLE_BANKING_MIX);
        llSetVehicleFloatParam(VEHICLE_BUOYANCY, fVEHICLE_BUOYANCY);
        llSetVehicleVectorParam(VEHICLE_LINEAR_MOTOR_OFFSET, <VLMO_X, VLMO_Y, VLMO_Z>);
        
        
        
        
        llRemoveVehicleFlags(VEHICLE_FLAG_HOVER_WATER_ONLY | VEHICLE_FLAG_HOVER_UP_ONLY | VEHICLE_FLAG_LIMIT_ROLL_ONLY
       | VEHICLE_FLAG_HOVER_TERRAIN_ONLY);
    llSetVehicleFlags(VEHICLE_FLAG_NO_DEFLECTION_UP | VEHICLE_FLAG_LIMIT_ROLL_ONLY| VEHICLE_FLAG_LIMIT_MOTOR_UP| VEHICLE_FLAG_BLOCK_INTERFERENCE); //anti-cheating added

        

    }
 

    
    

touch_start(integer total_number)
    {
        if(llDetectedKey(0) == llGetOwner())
        {
             
        }
    } 
    
    
    link_message(integer sender_num, integer num, string message, key id)
    {

        
        if(num == 409)
        {


                
                if(message == "Camera")
                {
                    cameramode += 1;
                    if(cameramode > 1){cameramode = 0;}
                    CameraChange();
                }
                
                if(message == "Speed++")
                {
                    setup = 4;
                    SetupChange();
                }
                
                if(message == "Speed+")
                {
                    setup = 3;
                    SetupChange();
                }
                
                if(message == "Balanced")
                {
                    setup = 2;
                    SetupChange();
                }
                
                if(message == "Accel+")
                {
                    setup = 1;
                    SetupChange();
                }
                
                if(message == "Accel++")
                {
                    setup = 0;
                    SetupChange();
                }
                if(message == "Joystick 1") {
                     method = 0;
                llOwnerSay("Joystick Left");
                     }
                if (message == "Joystick 2"){
                     method = 1;
                llOwnerSay("Joystick Right");
                     }
                if (message == "D Pad") {
                     method = 2;
                llOwnerSay("D Pad");
                     }
                if (message == "Keyboard"){
                     method = 3;
                llOwnerSay("Keyboard");
                     }
                
            if(message == "draft")
                {
                    VLFT = <45.0, 0.1, 20.0>;
                    if(TrackLimit < 0.0){TrackLimit++;}
                    if(TrackLimit > 0.0){TrackLimit = 0.0;}
                }
                
            if(message == "nodraft")
                {
                    VLFT = <30.0, 0.1, 20.0>;
                    if(TrackLimit < 0.0){TrackLimit++;}
                    if(TrackLimit > 0.0){TrackLimit = 0.0;}
                }
                
                if(message == "TrackLimit")
                {
                    TrackLimit = -5.0;
                    
                }
        }
    
    }
    

    
    collision_end(integer total_number)
    {
        if(grounded == 1)
        {
            grounded = 0;
        }
    }
    
    collision(integer num_detected)
    {
        if(num_detected != 0)
        {
            if(grounded == 0)
            {
                grounded = 1;
            }
        }
    }
    
    changed(integer change)
    {

        if (change & CHANGED_LINK)
        {
            key agent = llAvatarOnSitTarget();
            if (agent)
            {
            }
            else
            {
                llSetTimerEvent(0);
                llStopSound();
                llSetStatus(STATUS_PHYSICS, FALSE);
                
                physical = 0;
                llSleep(0.5);
                llReleaseControls();
                llStopAnimation(currentAnim);
                llSetText("",<1,1,1>,1);
                
                state default;
            }
        }  
    } 
    
    run_time_permissions(integer perm)
    {
        if (perm & PERMISSION_TRIGGER_ANIMATION)
        {
            nextAnim = idleAnim;
            currentAnim = idleAnim;
            llStartAnimation(currentAnim);
            SetupChange();
        }
        if (perm)
        {
            llTakeControls(CONTROL_FWD | CONTROL_BACK | CONTROL_DOWN | CONTROL_UP | CONTROL_RIGHT | 
                            CONTROL_LEFT | CONTROL_ROT_RIGHT | CONTROL_ROT_LEFT | CONTROL_ML_LBUTTON, TRUE, FALSE);
        }
        
        if ( perm & PERMISSION_CONTROL_CAMERA )
        {
            llClearCameraParams(); 
            CameraChange();
        }
    }
    
    control(key id, integer level, integer edge)
    {
        if (method != 3) return;
        integer reverse=1;
        
        
        if(level & edge & CONTROL_UP)
        {
            if(Gear < 2 )
            {
                Gear++;
                forward_power = llList2Float(gearList,Gear);
                if(Gear == 0)
                {
                    llOwnerSay("Reverse");
                }
                if(Gear == 1)
                {
                    llOwnerSay("Neutral");
                }
                if(Gear == 2)
                {
                    llOwnerSay("Drive");
                }
                
            }
            
            else if(Gear == 2 & angular_motor.z == 0)
            {
                angular_motor.y = -75;
            }
        }
        
        if(~level & edge & CONTROL_UP)
        {
            if(angular_motor.y != 0)
            {
                angular_motor.y = 0;
            }
        }
        
        if(level & edge & CONTROL_DOWN)
        {
            if(Gear > 0 )
            {
                Gear--;
                forward_power = llList2Float(gearList,Gear);
                if(Gear == 0)
                {
                    llOwnerSay("Reverse");
                }
                if(Gear == 1)
                {
                    llOwnerSay("Neutral");
                }
                if(Gear == 2)
                {
                    llOwnerSay("Drive");
                }
                
            }
        }

        if(forward_power < 0)
        {
            reverse = -1;
            direction = -1;
        }
        else
        {
            reverse=1;
            direction = 1;  
        }
        
        if(level & CONTROL_FWD)
        {
            accel = 1;
            offsound = 0;
            
            if(speed > 2 & onsound != 1)
                {
                    onsound = 1;
                    llStopSound();
                    llLoopSound(high, volume);
                }
                
        }
        
        
        
        if(~level & CONTROL_FWD)
        {
            
            
            accel = 0;
            onsound = 0;
            
            if(speed < 2 & offsound != 1)
                {
                    offsound = 1;
                    llStopSound();
                    llLoopSound(idle, volume);
                }
                
            if(speed >= 2 & offsound != 2)
                {
                    offsound = 2;
                    llStopSound();
                    llLoopSound(offhigh, volume);
                }
                            
        }
        
        
        
        if(level & CONTROL_BACK)
        {
            if(brake == 0)
            {
                brake = 1;
            }
            if(SpeedLimit == 1 & Gear > 1)
            {
                llSetVehicleVectorParam(VEHICLE_LINEAR_FRICTION_TIMESCALE, <1.5, 0.0, 20.0>);
            }
            else{llSetVehicleVectorParam(VEHICLE_LINEAR_FRICTION_TIMESCALE, VLFT_Brake );}
            
            
        }
        
        if(~level & CONTROL_BACK)
        {
            
            if(SpeedLimit == 1 & Gear > 1)
            {
                llSetVehicleVectorParam(VEHICLE_LINEAR_FRICTION_TIMESCALE, <1.5, 0.0, 20.0>);
            }
            
            else
            {
                if(brake == 1)
                {
                    brake = 0;
                }
                    
                llSetVehicleVectorParam(VEHICLE_LINEAR_FRICTION_TIMESCALE, VLFT );
            }
            
        }

        if(level & CONTROL_ROT_RIGHT)
        {
            CurDir = DIR_RIGHT;          
            angular_motor.z = -((TurnPower) * reverse);
            angular_motor.x = (llFabs(SpeedVec.x) * AngXMult);
            angular_motor.y = 0.0;
        }
        
        else if(level & CONTROL_ROT_LEFT)
        {
            CurDir = DIR_LEFT;
            angular_motor.z = (TurnPower) * reverse;
            angular_motor.x = (llFabs(SpeedVec.x) * -AngXMult);
            angular_motor.y = 0.0;
            
        }
        
        else if((~level & CONTROL_ROT_LEFT) || (~level & CONTROL_ROT_RIGHT))
        {
            CurDir = DIR_NORM;   
            angular_motor.z = 0;
            angular_motor.x = 0;
        }
        
        
        
        if(angular_motor != <0.0, 0.0, 0.0>)
        {
            if(brake == 0 & grounded == 1)
            {
                llSetVehicleVectorParam(VEHICLE_ANGULAR_MOTOR_DIRECTION, angular_motor);
            }
            if(brake == 1 & grounded == 1)
            {
                llSetVehicleVectorParam(VEHICLE_ANGULAR_MOTOR_DIRECTION, angular_motor * brakebias);    
            }
        }
        

         
    }    
    // Game Control feauture

   game_control(key id, integer button_levels, list axes)
 
    {
         integer button_edges = button_levels ^ prev_button_levels;   
        prev_button_levels = button_levels;
         integer reverse=1;
          integer start = button_levels & button_edges;
          integer end = ~button_levels & button_edges;
          integer held = button_levels & ~button_edges;
          integer untouched = ~(button_levels | button_edges);

 if (method < 2) // we exclude keyboard
        {
            if (method == 0) //joystick 1 (left)
            {
                x = llList2Float(axes, 0);  //axes 0 is for angle of left stick
                y = llList2Float(axes, 1); //axes 1 is for fwd left stick
            
            }
                else //method == 1 which is joystick 2 (right)
            {
                x = llList2Float(axes, 2);
                y = llList2Float(axes, 3);
            }
            if (llFabs(x) <= 0.1) x = 0; 
            if (llFabs(y) <= 0.1) y = 0;  //fwd speed dead zone
        }
         else if (method == 2) //D Pad
        {
        
          
        if(start & GAME_CONTROL_BUTTON_DPAD_UP)
        {
            accel = 1;
            offsound = 0;
            
            if(speed > 2 & onsound != 1)
                {
                    onsound = 1;
                    llStopSound();
                    llLoopSound(high, volume);
                }
                
        }
        
        
        
        if(end & GAME_CONTROL_BUTTON_DPAD_UP)
        {            
            accel = 0;
            onsound = 0;
            
            if(speed < 2 & offsound != 1)
                {
                    offsound = 1;
                    llStopSound();
                    llLoopSound(idle, volume);
                }
                
            if(speed >= 2 & offsound != 2)
                {
                    offsound = 2;
                    llStopSound();
                    llLoopSound(offhigh, volume);
                }
                            
        }
        
        if(start & GAME_CONTROL_BUTTON_DPAD_DOWN)
        {
            if(brake == 0)
            {
                brake = 1;
            }
            if(SpeedLimit == 1 & Gear > 1)
            {
                llSetVehicleVectorParam(VEHICLE_LINEAR_FRICTION_TIMESCALE, <1.5, 0.0, 20.0>);
            }
            else{llSetVehicleVectorParam(VEHICLE_LINEAR_FRICTION_TIMESCALE, VLFT_Brake );}
            
            
        }
        
        if(end & GAME_CONTROL_BUTTON_DPAD_DOWN)
        {
            
            if(SpeedLimit == 1 & Gear > 1)
            {
                llSetVehicleVectorParam(VEHICLE_LINEAR_FRICTION_TIMESCALE, <1.5, 0.0, 20.0>);
            }
            
            else
            {
                if(brake == 1)
                {
                    brake = 0;
                }
                    
                llSetVehicleVectorParam(VEHICLE_LINEAR_FRICTION_TIMESCALE, VLFT );
            }
            
        }

        if(start & GAME_CONTROL_BUTTON_DPAD_RIGHT)
        {
            CurDir = DIR_RIGHT;          
            angular_motor.z = -((TurnPower) * reverse);
            angular_motor.x = (llFabs(SpeedVec.x) * AngXMult);
            angular_motor.y = 0.0;
        }
        
        else if(start & GAME_CONTROL_BUTTON_DPAD_LEFT)
        {
            CurDir = DIR_LEFT;
            angular_motor.z = (TurnPower) * reverse;
            angular_motor.x = (llFabs(SpeedVec.x) * -AngXMult);
            angular_motor.y = 0.0;
            
        }
        
        else if((end & GAME_CONTROL_BUTTON_DPAD_LEFT) || (end & GAME_CONTROL_BUTTON_DPAD_RIGHT))
        {
            CurDir = DIR_NORM;   
            angular_motor.z = 0;
            angular_motor.x = 0;
        }
        
        if(angular_motor != <0.0, 0.0, 0.0>)
        {
            if(brake == 0 & grounded == 1)
            {
                llSetVehicleVectorParam(VEHICLE_ANGULAR_MOTOR_DIRECTION, angular_motor);
            }
            if(brake == 1 & grounded == 1)
            {
                llSetVehicleVectorParam(VEHICLE_ANGULAR_MOTOR_DIRECTION, angular_motor * brakebias);    
            }
        }
          
    
        }
        


        if(start & GAME_CONTROL_BUTTON_LEFTSHOULDER)
        {
            if(Gear < 2 )
            {
                Gear++;
                forward_power = llList2Float(gearList,Gear);
                if(Gear == 0)
                {
                    llOwnerSay("Reverse");
                }
                if(Gear == 1)
                {
                    llOwnerSay("Neutral");
                }
                if(Gear == 2)
                {
                    llOwnerSay("Drive");
                }
                
            }
            
            else if(Gear == 2 & angular_motor.z == 0)
            {
                angular_motor.y = -75;
            }
        }
        
        if(end & GAME_CONTROL_BUTTON_LEFTSHOULDER)
        {
            
            if(angular_motor.y != 0)
            {
                angular_motor.y = 0;
            }
        }
        
        if(start & GAME_CONTROL_BUTTON_RIGHTSHOULDER)
        {
            if(Gear > 0 )
            {
                Gear--;
                forward_power = llList2Float(gearList,Gear);
                if(Gear == 0)
                {
                    llOwnerSay("Reverse");
                }
                if(Gear == 1)
                {
                    llOwnerSay("Neutral");
                }
                if(Gear == 2)
                {
                    llOwnerSay("Drive");
                }
                
            }
        }

        if(forward_power < 0)
        {
            reverse = -1;
            direction = -1;
        }
        else
        {
            reverse=1;
            direction = 1;  
        }
        
        if(method < 2) //Joystick
        {
        
        if(y>=0.1)
        {
            accel = 1;
            offsound = 0;
            
            if(speed > 2 & onsound != 1)
                {
                    onsound = 1;
                    llStopSound();
                    llLoopSound(high, volume);
                }
                
        }
        
        
        
        if(y==0)
        {
            
            
            accel = 0;
            onsound = 0;
            
            if(speed < 2 & offsound != 1)
                {
                    offsound = 1;
                    llStopSound();
                    llLoopSound(idle, volume);
                }
                
            if(speed >= 2 & offsound != 2)
                {
                    offsound = 2;
                    llStopSound();
                    llLoopSound(offhigh, volume);
                }
                            
        }
        
        
        
        if(y<0)
        {
            if(brake == 0)
            {
                brake = 1;
            }
            if(SpeedLimit == 1 & Gear > 1)
            {
                llSetVehicleVectorParam(VEHICLE_LINEAR_FRICTION_TIMESCALE, <1.5, 0.0, 20.0>);
            }
            else{//llSetVehicleVectorParam(VEHICLE_LINEAR_FRICTION_TIMESCALE, VLFT_Brake );
            }
            
            
        }
        
        if(x<0)
        {
            CurDir = DIR_RIGHT;          
            angular_motor.z = -((TurnPower) * reverse);
            angular_motor.x = (llFabs(SpeedVec.x) * AngXMult);
            angular_motor.y = 0.0;
        }
        
        else if(x>0)
        {
            CurDir = DIR_LEFT;
            angular_motor.z = (TurnPower) * reverse;
            angular_motor.x = (llFabs(SpeedVec.x) * -AngXMult);
            angular_motor.y = 0.0;
            
        }
        
        else if(x==0)
        {
            CurDir = DIR_NORM;   
            angular_motor.z = 0;
            angular_motor.x = 0;
        }
        
        
        
        if(angular_motor != <0.0, 0.0, 0.0>)
        {
            if(brake == 0 & grounded == 1)
            {
                llSetVehicleVectorParam(VEHICLE_ANGULAR_MOTOR_DIRECTION, angular_motor);
            }
            if(brake == 1 & grounded == 1)
            {
                llSetVehicleVectorParam(VEHICLE_ANGULAR_MOTOR_DIRECTION, angular_motor * brakebias);    
            }
        }
        
    }
}      
    
    timer()
    {
        vel = llGetVel();
        speed = llVecMag(vel);
        SpeedVec = llGetVel() / llGetRot();
        float Power = forward_power;
        vector rot = (llRot2Euler(llGetLocalRot()) * RAD_TO_DEG);
        Banking = llSqrt((rot.x * rot.x) + (rot.y * rot.y));
        
        if(grounded == 0)
        {
            llApplyImpulse(llGetMass() * <0, 0, -1.0>, FALSE);
        }
       
        if(accel == 0)
        {
            llSetVehicleVectorParam(VEHICLE_LINEAR_MOTOR_DIRECTION, <0,0,(speed * Z_Modifier)> );
            if(speed < 2)
            {
                llSetStatus(STATUS_PHYSICS, FALSE);
                physical = 0;
            }
        }
        
        else if(accel == 1)
        {
            if(physical == 0 & Gear != 1){llSetStatus(STATUS_PHYSICS, TRUE); physical = 1;}
            if(physical == 1 & grounded == 1){llSetVehicleVectorParam(VEHICLE_LINEAR_MOTOR_DIRECTION, <(Power + PowerAdj + (TrackLimit / 2)),0,(speed * Z_Modifier)> );}
            if(physical == 1 & grounded == 0){llSetVehicleVectorParam(VEHICLE_LINEAR_MOTOR_DIRECTION, <0,0,(speed * Z_Modifier)> );}

            
        }
        
        
        
        if(CurDir != LastDir)
        {
            llMessageLinked(LINK_SET, CurDir, "", NULL_KEY);
            LastDir = CurDir;
        }
        
        if(SpeedVec.x > 2.0)
        {   
            if(CurDir == DIR_NORM)
            {
                if (Banking <= 15){nextAnim =  driveAnim;}
            }
            
            else if(CurDir == DIR_LEFT)
            {
                if (Banking > 15){nextAnim = leftAnim;}
            }
            
            else if(CurDir == DIR_RIGHT)
            {
                if (Banking > 15){nextAnim = rightAnim;}
            } 
        }
        else 
        {   
            nextAnim = idleAnim; 
        }
        
        if (currentAnim != nextAnim)                
            {   if (currentAnim != "")
                {   llStopAnimation(currentAnim);
                    currentAnim = "";
                }      
                if (nextAnim != "")
                {   llStartAnimation(nextAnim); }
                currentAnim = nextAnim;
            }
        
        string speed_text = (string)llRound(SpeedVec.x * 3.6) + "kmh";
        
        vector text_color = <1,1,1>;
        
        string hud_text = 
        
        speed_text + "\n" +
        
        
        
        
        
        
        "\n \n \n \n \n \n\n \n \n \n \n \n\n \n \n \n \n \n.";  
        
        llSetText(hud_text,text_color,1); 
        

        
    }               
    

 
 
}
