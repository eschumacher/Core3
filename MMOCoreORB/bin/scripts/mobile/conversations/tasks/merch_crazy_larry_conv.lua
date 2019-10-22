crazylarry_template = ConvoTemplate:new {
    initialScreen = "first_screen",
    templateType = "Lua",
    luaClassHandler = "crazylarry_convo_handler",
    screens = {}
}
crazylarry_first_screen = ConvoScreen:new {
    id = "first_screen",
    leftDialog = "",
    customDialogText = "Welcome to Crazy Larry's Cheap As Dirt Landspeeders! Would you like to buy a vehicle?",
    stopConversation = "false",
    options = { 
        {"Speederbike - 1", "speederbike"}, 
        {"No thank you.", "deny_purchase"}, 
    }
}
crazylarry_template:addScreen(crazylarry_first_screen);
crazylarry_purchase_speederbike = ConvoScreen:new {    
    id = "speederbike",
    leftDialog = "",
    customDialogText = "Enjoy that Speederbike!",
    stopConversation = "true",
    options = { }
}
crazylarry_template:addScreen(crazylarry_purchase_speederbike);
crazylarry_deny_purchase = ConvoScreen:new {
    id = "deny_purchase",
    leftDialog = "",
    customDialogText = "Psh your loss, man.",
    stopConversation = "true",
    options = { }
}
crazylarry_template:addScreen(crazylarry_deny_purchase);
crazylarry_insufficient_funds = ConvoScreen:new {
    id = "insufficient_funds",  
    leftDialog = "", 
    customDialogText = "Really? You can't afford 1 credit?  Get a job!",
    stopConversation = "true",
    options = { }
}
crazylarry_template:addScreen(crazylarry_insufficient_funds);
crazylarry_insufficient_space = ConvoScreen:new {
    id = "insufficient_space",
    leftDialog = "", 
    customDialogText = "Sorry, but you don't have enough space in your inventory to accept the item. Please make some space and try again.",    
    stopConversation = "true",  
    options = { }
}
crazylarry_template:addScreen(crazylarry_insufficient_space);
addConversationTemplate("crazylarry_template", crazylarry_template);
