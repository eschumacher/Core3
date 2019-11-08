buffomatic_template = ConvoTemplate:new {
    initialScreen = "first_screen",
    templateType = "Lua",
    luaClassHandler = "buffomatic_convo_handler",
    screens = {}
}
buffomatic_first_screen = ConvoScreen:new {
    id = "first_screen",
    leftDialog = "",
    customDialogText = "I AM BUFF-O-MATIC.  WHAT DO YOU REQUIRE?",
    stopConversation = "false",
    options = { 
        {"XP Buff.", "xp_buff"}, 
        {"Nothing.", "nothing_needed"}, 
    }
}
buffomatic_template:addScreen(buffomatic_first_screen);
buffomatic_xp_buff = ConvoScreen:new {    
    id = "xp_buff",
    leftDialog = "",
    customDialogText = "YOUR FIRMWARE HAS BEEN TEMPORARILY UPGRADED FOR ENHANCED LEARNING!",
    stopConversation = "true",
    options = { }
}
buffomatic_template:addScreen(buffomatic_xp_buff);
buffomatic_nothing_needed = ConvoScreen:new {
    id = "nothing_needed",
    leftDialog = "",
    customDialogText = "NO UPGRADE PERFORMED.  YOU REMAIN INFERIOR, HUMAN.",
    stopConversation = "true",
    options = { }
}
buffomatic_template:addScreen(buffomatic_nothing_needed);

addConversationTemplate("buffomatic_template", buffomatic_template);
