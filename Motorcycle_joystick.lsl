// Originally written by Cory Linden. 
// Then modified and tweaked by Andrew Linden for the script_library.
// Finally tweaked and updated by Leviathan Linden.
//
// Modified and re-built in some parts by Alistar Snook for testing Game coontrol function
//
// Root prim should be oriented such that its local X-, Y- and Z-axes are
// parallel to forward, left, and up respectively.
//
// Sound triggers are commented out but not removed, so if you
// want sounds, just add the sounds to the cycle's contents and uncomment
// the triggers.
//
// Be careful when changing parameters.  Some of them can be very 
// sensitive to change.  I recommend: change only one at a time, and test
// after each modification.
//
// The geometry of the motorcycle itself can have significant impact on 
// whether it in a straight line when not trying to turn.  For best results 
// use a symmetric design with as wide of a base as you can tolerate.
// this will tend to keep the motorcycle upright will avoid spurious banking
// effects when it tilts from collisions.

// These are globals only for convenience (so when you need to modify
// them you need only make a single change).  There are other magic numbers 
// below that have not yet been pulled into globals.  Some of these numbers
// are very sensitive: be careful when modifying them.

// float gMaxTurnSpeed = 12;    commented by Alistar
// float gMaxWheelieSpeed = 5;   commented by Alistar
float gMaxFwdSpeed = 20;  //changed value by Alistar for testing purpose
float gMaxBackSpeed = -10;   
/*  I don't need that for my testings (Alistar)
// float gAngularRamp = 0.17;   
// float gLinearRamp = 0.2; */  

// Alistar addings
float gMaxAngSpeed = 2.5;  
float gStop = 0.0;

// These are true globals whose values are "accumulated" over  multiple control()
// callbacks.  The accumulation behavior interacts with the motor timescale settings
// to produce the ramp-up of vehicle speed and also braking.
/*float gBank = 0.0;
vector gLinearMotor = <0, 0, 0>;
vector gAngularMotor = <0, 0, 0>; Not used by myself (Alistar) */

//Alistar addings

key owner;
float LinearSpeed;  
float AngularSpeed; 
integer prev_button_levels = 0; 
integer options;
integer listen_handle;

default
{

    on_rez(integer rez)
    {
        llResetScript();
    }

    state_entry()
    {
        // init stuff that never changes
        owner = llGetOwner();
        llSetSitText("Ride");
        llCollisionSound("", 0.0);
        llSitTarget(<0.6, 0.05, 0.20>, ZERO_ROTATION);
        llSetCameraEyeOffset(<-6.0, 0.0, 1.0>);
        llSetCameraAtOffset(<3.0, 0.0, 1.0>);
    
        // create the vehicle
        // Using VEHICLE_TYPE_CAR sets some default flags and parameters,
        // but we customize them below.
        llSetVehicleType(VEHICLE_TYPE_CAR);
        
        // VEHICLE_FLAG_LIMIT_MOTOR_UP = linear motor cannot have non-zero world-frame UP component
        //    (e.g. it is a "ground vehicle" that should not "fly into the sky").
        // VEHICLE_FLAG_LIMIT_ROLL_ONLY = modifies the behavior of the vertidal attractor
        //    (see VEHICLE_VERTICAL_ATTRACTION fields below) to only limit the vehicle's "roll"
        //    (e.g. rotation about the forward axis) and not pitch.
               llSetVehicleFlags(VEHICLE_FLAG_NO_DEFLECTION_UP | VEHICLE_FLAG_LIMIT_ROLL_ONLY | VEHICLE_FLAG_LIMIT_MOTOR_UP | VEHICLE_FLAG_BLOCK_INTERFERENCE); //anti-cheater feature too
        
        // LINEAR_DEFLECTION coefficients determine the ability of the vehicle to divert
        //    sideways velocity into forward velocity.  For simplest tuning: always set the
        // DEFLECTION_EFFICIENCY to 1.0 and only adjust the timescale. Short timescales
        //     make the deflection strong and long timescales make it weak.
        llSetVehicleFloatParam(VEHICLE_LINEAR_DEFLECTION_EFFICIENCY, 1.0);
        llSetVehicleFloatParam(VEHICLE_LINEAR_DEFLECTION_TIMESCALE, 0.5);
        
        // Similarly, the ANGULAR_DEFLECTION coefficients determine the ability of the
        // vehicle to reorient itself to point forward in whatever direction it is moving.
        // In other words: is the vehicle a "dart" with fins that help it point forward
        // or is it a round ball with no orientation preference to its world-frame linear
        // velocity?
        // For simplest tuning: always set the DEFLECTION_EFFICIENCY to 1.0
        // and only adjust the timescale.  Short timescales make the deflection
        // strong and long timescales make it weak.
        llSetVehicleFloatParam(VEHICLE_ANGULAR_DEFLECTION_EFFICIENCY, 1.0);  
        llSetVehicleFloatParam(VEHICLE_ANGULAR_DEFLECTION_TIMESCALE, 1.4);
        
        // Motor timescales determine how quickly the motor achieves the desired
        // velocity.  Short timescales make it ramp up very quickly, long timescales
        // make it slow.  As a rule of thumb: estimate the time you'd like the motor
        // to achieve its full speed then set the timescale to 1/3 of that.
        llSetVehicleFloatParam(VEHICLE_LINEAR_MOTOR_TIMESCALE, 0.8);
        llSetVehicleFloatParam(VEHICLE_ANGULAR_MOTOR_TIMESCALE, 0.01);        
        
        // Motor decay timescales determine how quickly the motor's desired speed
        // decays toward zero.  This timescale cannot be set longer than 120 seconds,
        // the idea being: you can't just set a vehicle's velocity and expect it to
        // move forward forever; you must continually poke it in order to keep it going.
        // This to prevent a trivial runaway vehicle.  Here we use relatively short
        // timescales to help the vehicle brake when controls stop.
        llSetVehicleFloatParam(VEHICLE_ANGULAR_MOTOR_DECAY_TIMESCALE, 0.35);
        llSetVehicleFloatParam(VEHICLE_LINEAR_MOTOR_DECAY_TIMESCALE, 0.4);

        // Long timescales make friction weak; short timescales make it strong.
        // The friction can be asymmetric: different values for local X, Y, and Z axes
        // (e.g. forward, left, and up).
        llSetVehicleVectorParam(VEHICLE_LINEAR_FRICTION_TIMESCALE, <1000, 100, 1000>);
        llSetVehicleVectorParam(VEHICLE_ANGULAR_FRICTION_TIMESCALE, <100, 20, 100>);

        // The "vertial attractor" is a spring-like behavior that keeps the vehicle upright.
        llSetVehicleFloatParam(VEHICLE_VERTICAL_ATTRACTION_EFFICIENCY, 1.0);
        llSetVehicleFloatParam(VEHICLE_VERTICAL_ATTRACTION_TIMESCALE, 0.44);

        // The banking behavior introduces a torque about the world-frame UP axis when the
        // vehicle "rolls" about its forward axis..
        //
        // The VEHICLE_BANKING_EFFICIENCY is a multiplier on this effect, and can be > 1.0.
        //    VEHICLE_BANKING_EFFICIENCY = 0.0 --> no banking
        //    VEHICLE_BANKING_EFFICIENCY = 1.0 --> yes banking        
        llSetVehicleFloatParam(VEHICLE_BANKING_EFFICIENCY, 1.0);
        
        // Short VEHICLE_BANKING_TIMESCALE makes banking very effective,
        // long values makes it weak.
        llSetVehicleFloatParam(VEHICLE_BANKING_TIMESCALE, 0.01);      
        
        // VEHICLE_BANKING_MIX is a sliding weight on the banking effect which was
        // supposed to work as follows:
        //    mix=0.0 --> always on (just tilt the vehicle and it will magically turn)
        //    mix=1.0 --> only effective when there is a non-zero forward velocity 
        //    (e.g. unable to turn by banking when vehicle is at rest).    
        llSetVehicleFloatParam(VEHICLE_BANKING_MIX, 0.9);
        
        // This motorcycle doesn't use the "hover" feature, but here is some code
        // for experimentation.
        //llSetVehicleFloatParam(VEHICLE_HOVER_HEIGHT, 2.0);
        //llSetVehicleFloatParam(VEHICLE_HOVER_TIMESCALE, 1.0);
        //llSetVehicleFloatParam(VEHICLE_HOVER_EFFICIENCY, 0.5);
    }

     touch_start (integer n) {
    
     key agent = llAvatarOnSitTarget();
      if (agent == NULL_KEY)
                {
            llSay(0,"Please sit in your vehicle");
            llListenRemove(listen_handle);
            llSetStatus(STATUS_PHYSICS, FALSE);
            llSetTimerEvent(0.0);
            }
            
     else  {
    listen_handle = llListen(-470278,"",owner,"");
    llDialog(owner, "\nChoose control method",
    ["Joystick Left","Joystick Right", "D Pad", "Keyboard"], -470278);    
     llSetTimerEvent(0.1);    
        }
    
    }

    changed(integer change)
    {
        if (change & CHANGED_LINK)
        {
         if (llGetNumberOfPrims() != llGetObjectPrimCount(llGetKey()));
            key agent = llAvatarOnSitTarget();
            if (agent)
            {
                if (agent != llGetOwner())
                {
                    // not the owner ==> boot off
                    llSay(0, "You aren't the owner");
                    llUnSit(agent);
                    llPushObject(agent, <0,0,100>, ZERO_VECTOR, FALSE);
                }
                else
                {
                    // owner has mounted
                    llRequestPermissions(agent, PERMISSION_TRIGGER_ANIMATION | PERMISSION_TAKE_CONTROLS);
                    llPlaySound("start", 0.40);
                    listen_handle = llListen(-470278,"",owner,"");
                    llDialog(owner, "\nChoose control method",
                    ["Joystick Left","Joystick Right", "D Pad", "Keyboard"], -470278);
                    llSetStatus(STATUS_PHYSICS, TRUE);
                    llSetTimerEvent(0.1);
                }
            }
            else
            {
                // dismount
                llStopSound();
                llSetStatus(STATUS_PHYSICS, FALSE);
                llReleaseControls();
                llStopAnimation("motorcycle_sit");
                llPlaySound("off", 0.4);
            }
        }

    }

        listen(integer channel, string name, key id, string message)
    {
        if (message == "Joystick Left") options = 0;
        else if (message == "Joystick Right") options = 1;
        else if (message == "D Pad") options = 2;
        else if (message == "Keyboard") options = 3;
        llWhisper(0,"Option selected: " + message);
        llListenRemove(listen_handle);
    }

    run_time_permissions(integer perm)
    {
        if (perm & PERMISSION_TAKE_CONTROLS)
        {
            llTakeControls(CONTROL_FWD | CONTROL_BACK | CONTROL_RIGHT | CONTROL_LEFT 
                           | CONTROL_ROT_RIGHT | CONTROL_ROT_LEFT | CONTROL_UP, TRUE, FALSE);
            llLoopSound("on", 1.0);
            llSetStatus(STATUS_PHYSICS, TRUE);
            // reset the global accumulators (commented by Alistar)
            // gAngularMotor = <0, 0, 0>;
            //gLinearMotor = <0, 0, 0>;
           // gBank = 0.0;
        }
        if (perm & PERMISSION_TRIGGER_ANIMATION)
        {
            llStartAnimation("motorcycle_sit");
        }
    }
    
    control(key id, integer level, integer edge)
    {
  
        // I've rebuilt the whole control event in a simply way, same behavior as Game_Control function. (Alistar)

        if (options != 3) return;
        integer start = level & edge;
        integer end = ~level & edge;
        
        if (start & CONTROL_FWD) LinearSpeed = gMaxFwdSpeed;
        if (start & CONTROL_BACK) LinearSpeed = gMaxBackSpeed;
        if ((end & CONTROL_FWD)||(end & CONTROL_BACK)) LinearSpeed = gStop;
        if (start & CONTROL_ROT_LEFT)
        {
            if (LinearSpeed >= gStop) AngularSpeed = gMaxAngSpeed;
            else AngularSpeed -= gMaxAngSpeed;
        }
        if (start & CONTROL_ROT_RIGHT)
        {
            if (LinearSpeed >= gStop) AngularSpeed -= gMaxAngSpeed;
            else AngularSpeed += gMaxAngSpeed;
        }
        if ((end & CONTROL_ROT_LEFT)||(end & CONTROL_ROT_RIGHT))
            AngularSpeed = gStop; 

       
    }

     game_control(key id, integer button_levels, list axes)
 
    {
        // we don't have edges button like in llTakeControl() function, so we need to find them
        integer button_edges = button_levels ^ prev_button_levels;    // we use bitwise XOR operator (true if either A or B is true but not both): It sets the bits for those that disagree.
        prev_button_levels = button_levels;
        
        //start - end or even hold / untouched like llTakeControls() check the Wiki
          integer start = button_levels & button_edges;
          integer end = ~button_levels & button_edges;

 if (options < 2) // we exclude keyboard
        {
            float stick_x;
            float stick_y;
            if (options == 0) //joystick 1 (left)
            {
                stick_x = llList2Float(axes, 0);  //axes 0 is for angle of left stick
                stick_y = llList2Float(axes, 1); //axes 1 is for fwd left stick
                // axes 2 & 3 is for right stick, axes 4 for triggerLeft and axes 5 for triggerRight
            }
             else //method == 1 which is joystick 2 (right)
            {
                stick_x = llList2Float(axes, 2);
                stick_y = llList2Float(axes, 3);
            }

            if (llFabs(stick_x) <= 0.2) stick_x = 0;  // this is how I handle the dead zone steering using the llFabs function, you can modify the 0.2 to your best float. 
            if (llFabs(stick_y) <= 0.2) stick_y = 0;  //fwd speed dead zone
            LinearSpeed = stick_y * gMaxFwdSpeed;
            AngularSpeed = stick_x * gMaxAngSpeed;
        }
      
        else if (options == 2) //D Pad
        {
            if (start & GAME_CONTROL_BUTTON_DPAD_UP) LinearSpeed = gMaxFwdSpeed;
            if (start & GAME_CONTROL_BUTTON_DPAD_DOWN) LinearSpeed = gMaxBackSpeed;
            if ((end & GAME_CONTROL_BUTTON_DPAD_UP)||(end & GAME_CONTROL_BUTTON_DPAD_DOWN)) LinearSpeed = gStop;
            if (start & GAME_CONTROL_BUTTON_DPAD_LEFT) LinearSpeed = gMaxAngSpeed;
            if (start & GAME_CONTROL_BUTTON_DPAD_RIGHT) AngularSpeed -= gMaxAngSpeed;
            if ((end & GAME_CONTROL_BUTTON_DPAD_LEFT)||(end & GAME_CONTROL_BUTTON_DPAD_RIGHT)) AngularSpeed = gStop;
        }
        if (LinearSpeed < -gStop) AngularSpeed -= AngularSpeed; //reversing so negate ang_vel
      
    }

  // timer, to set the correct speed.
    timer()
    {
        llSetVelocity(<LinearSpeed, 0.0,0.0>, TRUE);
        llSetAngularVelocity(<0.0,0.0, AngularSpeed>, TRUE);
    }
}
