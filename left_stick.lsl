integer prev_button_levels = 0;
vector circle_scale;
vector dot_scale;
float scale;
default
{
    state_entry()
    {
        circle_scale =  llList2Vector(llGetLinkPrimitiveParams(1, [PRIM_SIZE]), 0);
        dot_scale = llList2Vector(llGetLinkPrimitiveParams(2, [PRIM_SIZE]), 0);
    }
    changed(integer change)
    {
        if(change & CHANGED_SCALE)
        {
            circle_scale = llList2Vector(llGetLinkPrimitiveParams(1, [PRIM_SIZE]), 0);
            dot_scale = llList2Vector(llGetLinkPrimitiveParams(2, [PRIM_SIZE]), 0);
        }
    }
    game_control(key id, integer button_levels, list axes)
    {
        integer button_edges = button_levels ^ prev_button_levels;
        prev_button_levels = button_levels;

        integer start = button_levels & button_edges;
        integer end = ~button_levels & button_edges;
        integer held = button_levels & ~button_edges;
        integer untouched = ~(button_levels | button_edges);

        //Get left stick input
        float left_stick_x = llList2Float(axes, 0);
        float left_stick_y = llList2Float(axes, 1); 
        vector left_stick_direction = <left_stick_x, left_stick_y, 0>;
        
        float left_stick_mag = llVecMag(left_stick_direction);
        if(left_stick_mag > 1)
            left_stick_mag = 1;

        vector left_stick_norm = llVecNorm(<left_stick_direction.y, left_stick_direction.x, 0>);
        
        float y = circle_scale.x / (3 - (dot_scale.x /100)) * (left_stick_norm.y * left_stick_mag);
        float x = circle_scale.x / (3 - (dot_scale.x /100)) * (left_stick_norm.x * left_stick_mag);

        llSetLinkPrimitiveParamsFast(2, [PRIM_POS_LOCAL, <x, y, 0>]);
    }
}
