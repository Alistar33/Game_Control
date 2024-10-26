integer prev_button_levels = 0;
vector circle_scale;
vector dot_scale;
float scale;

integer find(string name)
{
    integer link;
    for(link = 0; link != llGetNumberOfPrims() + 1; link++)
        if(llGetLinkName(link) == name) return link;
    return 257;
}
integer link_a;
integer link_b;
integer link_x; 
integer link_y;

vector color_down = <.08,.08,.08>;
vector color_up = <.78,.78,.78>;

default
{
    state_entry()
    {
        link_a = find("A");
        link_b = find("B");
        link_x = find("X");
        link_y = find("Y");
        llSetLinkPrimitiveParamsFast(link_a, [PRIM_COLOR, ALL_SIDES, color_up, 1]);
        llSetLinkPrimitiveParamsFast(link_b, [PRIM_COLOR, ALL_SIDES, color_up, 1]);
        llSetLinkPrimitiveParamsFast(link_x, [PRIM_COLOR, ALL_SIDES, color_up, 1]);
        llSetLinkPrimitiveParamsFast(link_y, [PRIM_COLOR, ALL_SIDES, color_up, 1]);
    }
    game_control(key id, integer button_levels, list axes)
    {
        integer button_edges = button_levels ^ prev_button_levels;
        prev_button_levels = button_levels;

        integer start = button_levels & button_edges;
        integer end = ~button_levels & button_edges;
        integer held = button_levels & ~button_edges;
        integer untouched = ~(button_levels | button_edges);

        if(start & GAME_CONTROL_BUTTON_A)
            llSetLinkPrimitiveParamsFast(link_a, [PRIM_COLOR, ALL_SIDES, color_down, 1]);
        if(start & GAME_CONTROL_BUTTON_B)
            llSetLinkPrimitiveParamsFast(link_b, [PRIM_COLOR, ALL_SIDES, color_down, 1]);
        if(start & GAME_CONTROL_BUTTON_X)
            llSetLinkPrimitiveParamsFast(link_x, [PRIM_COLOR, ALL_SIDES, color_down, 1]);
        if(start & GAME_CONTROL_BUTTON_Y)
            llSetLinkPrimitiveParamsFast(link_y, [PRIM_COLOR, ALL_SIDES, color_down, 1]);

        if(end & GAME_CONTROL_BUTTON_A)
            llSetLinkPrimitiveParamsFast(link_a, [PRIM_COLOR, ALL_SIDES, color_up, 1]);
        if(end & GAME_CONTROL_BUTTON_B)
            llSetLinkPrimitiveParamsFast(link_b, [PRIM_COLOR, ALL_SIDES, color_up, 1]);
        if(end & GAME_CONTROL_BUTTON_X)
            llSetLinkPrimitiveParamsFast(link_x, [PRIM_COLOR, ALL_SIDES, color_up, 1]);
        if(end & GAME_CONTROL_BUTTON_Y)
            llSetLinkPrimitiveParamsFast(link_y, [PRIM_COLOR, ALL_SIDES, color_up, 1]);

        //llSetLinkPrimitiveParamsFast(2, [PRIM_POS_LOCAL, <x, y, 0>]);
    }
}
