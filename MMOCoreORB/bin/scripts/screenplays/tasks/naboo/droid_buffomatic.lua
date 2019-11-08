Buffomatic = ScreenPlay:new {                
    numberOfActs = 1,                
    questString = "buffomatic_task",                   
    states = {}, 
}
registerScreenPlay("Buffomatic", true)
function Buffomatic:start()     
    -- Spawn our character into the world, setting pBuffomatic a pointer variable we can use to check or change his state.       
    local pBuffomatic = spawnMobile("naboo", "droid_buffomatic", 1, -4881, 6.0, 4120, 35, 0 )
end
buffomatic_convo_handler = Object:new {
    tstring = "myconversation" 
}
function buffomatic_convo_handler:getNextConversationScreen(conversationTemplate, conversingPlayer, selectedOption)            
        -- Assign the player to variable creature for use inside this function.
        local creature = LuaCreatureObject(conversingPlayer)
        -- Get the last conversation to determine whether or not we’re on the first screen      
        local convosession = creature:getConversationSession()  
        local lastConversation = nil
	local lastConversationScreen = nil
        local conversation = LuaConversationTemplate(conversationTemplate)  
        local nextConversationScreen = nil
        -- If there is a conversation open, do stuff with it        
        if ( conversation ~= nil ) then  -- check to see if we have a next screen   
            if ( convosession ~= nil ) then             
                local session = LuaConversationSession(convosession)
                if ( session ~= nil ) then                  
                    lastConversationScreen = session:getLastConversationScreen()
                end
            end         
            -- Last conversation was nil, so get the first screen
            if ( lastConversationScreen == nil ) then          
                nextConversationScreen = conversation:getInitialScreen()
            else
                -- Start playing the rest of the conversation based on user input               
                local luaLastConversationScreen = LuaConversationScreen(lastConversationScreen) 
                -- Set variable to track what option the player picked and get the option picked                
                local optionLink = luaLastConversationScreen:getOptionLink(selectedOption)
                nextConversationScreen = conversation:getScreen(optionLink)
                if (optionLink == "xp_buff") then
                    creature:addBotExpBuff()
                end
            end
        end
        -- end of the conversation logic.
        return nextConversationScreen
    end
    function buffomatic_convo_handler:runScreenHandlers(conversationTemplate, conversingPlayer, conversingNPC, selectedOption, conversationScreen)
    -- Plays the screens of the conversation.
    return conversationScreen
end
