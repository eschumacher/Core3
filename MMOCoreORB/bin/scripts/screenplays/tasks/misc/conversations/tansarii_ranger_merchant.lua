tansarii_ranger_merchant = ScreenPlay:new {
  numberOfActs = 1,
  questString = "tansarii_ranger_merchant_task",
  states = {},
	scriptName = "tansarii_ranger_merchant",
  questTime = 10080, --amount of time in minutes player has to complete quest
  baseResourceAmount = 50000, --base number of resources required prior to applying multiplier
  baseRewardAmountMultiplier = 5 --multiplied with the baseResourceAmount to calculate reward
}

registerScreenPlay("tansarii_ranger_merchant", true)
function tansarii_ranger_merchant:start()
  local pMerchant = spawnMobile("naboo", "tansarii_ranger_merchant", 1, -4881, 6.0, 4150, 35, 0 )
end


local ObjectManager = require("managers.object.object_manager")


tansarii_ranger_merchant_convo_handler = Object:new {
  tstring = "myconversaton"
}

function tansarii_ranger_merchant_convo_handler:chooseWeeklyResource()  
  local resourceManager = LuaResourceManager()
  
  -- results[1] will be the final resource name, results[2] will be the multiplier due to resource scarcity
  local results = resourceManager:getWeeklyRangerResource("creature_resources")
  
  if (results == nil or results[1] == "" or results[2] <= 0) then
    Logger:log("No weekly ranger quest resource found!", LT_ERROR)
    return nil
  end
  
  return results
end

function tansarii_ranger_merchant_convo_handler:sellResource(pPlayer)
	local player = LuaCreatureObject(pPlayer)
	local pInventory = player:getSlottedObject("inventory")
	local inventory = LuaSceneObject(pInventory)
	local containerSize = inventory:getContainerObjectsSize()
  local resource = readScreenPlayData(pPlayer, "tansarii_ranger_merchant", "resource")
  local amount = tonumber(readScreenPlayData(pPlayer, "tansarii_ranger_merchant", "amount"))
	local reward = tansarii_ranger_merchant.baseResourceAmount * tansarii_ranger_merchant.baseRewardAmountMultiplier;


	for i = 0, containerSize - 1, 1 do
		local pInvObj = inventory:getContainerObject(i)
		local InvObj = LuaSceneObject(pInvObj)
    
    if (InvObj:isResourceContainer()) then
      local resCon = LuaResourceContainer(pInvObj)
      if (resCon:getSpawnName() == resource) then
        -- Found the correct resource...now check quantity
        if (resCon:getQuantity() >= amount) then
          -- Quest criteria met, destroy resources and give reward
          if (resCon:getQuantity() > amount) then
            -- Player has more than necessary amount - only delete the required amount
            local newQuantity = resCon:getQuantity() - amount
            resCon:setQuantity(newQuantity)
          else
            -- Destroy entire stack
            InvObj:destroyObjectFromWorld()
          end
          -- Fork over the money
          player:addCashCredits(reward, true)
          player:sendSystemMessage("You have sold " .. amount .. " units of " .. resource ..
            " for a total of " .. reward .. " credits.")
          return true
        end
      end
    end
	end
  
	return false
end

function tansarii_ranger_merchant_convo_handler:getInitialScreen(pPlayer, pConvTemplate)
	local convTemplate = LuaConversationTemplate(pConvTemplate)
  
  local startTime = tonumber(readScreenPlayData(pPlayer, "tansarii_ranger_merchant", "startTime"))
  local resource = readScreenPlayData(pPlayer, "tansarii_ranger_merchant", "resource")
  
  if (resource == nil or resource == "" or startTime == nil) then
    --No active quest or partial/corrupted data, show intro scene
    return convTemplate:getInitialScreen()
  end
  
  local timeLeftSeconds = tansarii_ranger_merchant.questTime * 60 - (os.time() - startTime)
  if (timeLeftSeconds < 0) then
    --Out of time for this quest - clear active resource & show the failure scene
    clearScreenPlayData(pPlayer, "tansarii_ranger_merchant")
    return convTemplate:getScreen("failed")
  end
  
  --Quest is active, show the time_left scene
  return convTemplate:getScreen("time_left")
  
end

function tansarii_ranger_merchant_convo_handler:getNextConversationScreen(conversationTemplate, conversingPlayer, selectedOption)
  local creature = LuaCreatureObject(conversingPlayer)
  local convoSession = creature:getConversationSession()
  
  local lastConvScreen = nil
  
  local conversation = LuaConversationTemplate(conversationTemplate)
  local nextConversationScreen = nil
  
  if ( conversation ~= nil ) then
    if ( convoSession ~= nil ) then
      local session = LuaConversationSession(convoSession)
      if ( session ~= nil ) then
        lastConvScreen = session:getLastConversationScreen()
      end
    end
    
    if ( lastConvScreen == nil ) then
      nextConversationScreen = self:getInitialScreen(conversingPlayer, conversationTemplate)
    else
      local luaLastConversationScreen = LuaConversationScreen(lastConvScreen)
      
      local optionLink = luaLastConversationScreen:getOptionLink(selectedOption)
      nextConversationScreen = conversation:getScreen(optionLink)
    end
  end
  
  return nextConversationScreen
end

function tansarii_ranger_merchant_convo_handler:runScreenHandlers(pConvTemplate, pPlayer, pNpc, selectedOption, pConvScreen)
  local screen = LuaConversationScreen(pConvScreen)
	local pClonedConvScreen = screen:cloneScreen()
	local clonedConversation = LuaConversationScreen(pClonedConvScreen)
	local screenID = screen:getScreenID()
	
	if (screenID == "accept") then
    local results = self:chooseWeeklyResource()
    local resource = results[1]
    local multiplier = results[2]
    local amount = math.floor(tansarii_ranger_merchant.baseResourceAmount * multiplier)
    local startTime = os.time()
    
    --Save this specific player's quest state  
    writeScreenPlayData(pPlayer, "tansarii_ranger_merchant", "resource", resource)
    writeScreenPlayData(pPlayer, "tansarii_ranger_merchant", "amount", amount)
    writeScreenPlayData(pPlayer, "tansarii_ranger_merchant", "startTime", startTime)
    
		local customDialogText = "Excellent!  I need " .. amount .. " units of " .. resource ..
        " within one week.  Report back to me when you have it!"
		clonedConversation:setCustomDialogText(customDialogText)
	end
	
  
	if (screenID == "time_left") then
    local playerID = SceneObject(pPlayer):getObjectID()
    local startTime = tonumber(readScreenPlayData(pPlayer, "tansarii_ranger_merchant", "startTime"))
    local resource = readScreenPlayData(pPlayer, "tansarii_ranger_merchant", "resource")
    local amount = tonumber(readScreenPlayData(pPlayer, "tansarii_ranger_merchant", "amount"))
    local timeLeftSeconds = tansarii_ranger_merchant.questTime * 60 - (os.time() - startTime)
    
    if (timeLeftSeconds >= 0) then
      --quest is still active, format time left as a string
      local timeLeftMinutes = math.floor(timeLeftSeconds / 60)
      local timeLeftHours = math.floor(timeLeftMinutes / 60)
      local timeLeftDays = math.floor(timeLeftHours / 24)
      timeLeftSeconds = timeLeftSeconds % 60
      
      local timeLeftString = ""
      if (timeLeftDays > 0) then
        timeLeftString = "" .. timeLeftDays .. " day(s)."
      elseif (timeLeftHours > 0) then
        timeLeftString = "" .. timeLeftHours .. " hour(s)."
      elseif (timeLeftMinutes > 0) then
        timeLeftString = "" .. timeLeftMinutes .. " minute(s)."
      else
        timeLeftString = "" .. timeLeftSeconds .. " second(s)."
      end
      
      local customDialogText = "I need those " .. amount .. " units of " ..
          resource .. " within the next " .. timeLeftString ..
          "...otherwise the deal is off."
			clonedConversation:setCustomDialogText(customDialogText)
		end
	end
  
  if (screenID == "sell_resource") then
		if (tansarii_ranger_merchant_convo_handler:sellResource(pPlayer)) then
      clearScreenPlayData(pPlayer, "tansarii_ranger_merchant")
      local customDialogText = "Well done, friend! Let me know when you are ready for more work."
      clonedConversation:setCustomDialogText(customDialogText)
		else
			local customDialogText = "You are a little short on resources...come back when you've gathered the full amount."
			clonedConversation:setCustomDialogText(customDialogText)
		end
	end
	
	return pClonedConvScreen
end
