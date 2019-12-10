tansarii_ranger_merchant_template = ConvoTemplate:new {
	initialScreen = "intro",
	templateType = "Lua",
	luaClassHandler = "tansarii_ranger_merchant_convo_handler",
	screens = {}
}


--Intro First
tansarii_ranger_merchant_intro = ConvoScreen:new {
	id = "intro",
	leftDialog = "",
	customDialogText = "Welcome, ranger. I hear you like to hunt! "..
      "I am looking for a large amount of a very specific resource. "..
      "I need it within one week's time...can you help me out?",
	stopConversation = "false",
	options = {
		{"Count me in!", "accept"},
		{"What resource are you looking for?", "what_resource"},
		{"Maybe later.", "end_convo"}
	}
}
tansarii_ranger_merchant_template:addScreen(tansarii_ranger_merchant_intro);

--accepted quest
tansarii_ranger_merchant_accept = ConvoScreen:new {
	id = "accept",
	leftDialog = "",
	customDialogText = "",
	stopConversation = "false",
	options = {
		{"I'm on it!", "end_convo"}
	}
}
tansarii_ranger_merchant_template:addScreen(tansarii_ranger_merchant_accept);

--what resource are you looking for?
tansarii_ranger_merchant_what_resource = ConvoScreen:new {
	id = "what_resource",
	leftDialog = "",
	customDialogText = "My employer appreciates keeping things discrete..."..
      "I can't let you know until you agree to complete the contract. "..
      "But, you will be rewarded with many riches. Do we have an agreement?",
	stopConversation = "false",
	options = {
		{"Count me in!", "accept"},
		{"Maybe later.", "end_convo"}
	}
}
tansarii_ranger_merchant_template:addScreen(tansarii_ranger_merchant_what_resource);

--time left
tansarii_ranger_merchant_time_left = ConvoScreen:new {
	id = "time_left",
	leftDialog = "",
	customDialogText = "",
	stopConversation = "false",
	options = {
		{"I have the resources you're looking for.", "sell_resource"},
		{"Back to the grind...", "end_convo"}
	}
}
tansarii_ranger_merchant_template:addScreen(tansarii_ranger_merchant_time_left);

--sell items
tansarii_ranger_merchant_sell_resource = ConvoScreen:new {
	id = "sell_resource",
	leftDialog = "",
	customDialogText = "",
	stopConversation = "true",
	options = {
	}
}
tansarii_ranger_merchant_template:addScreen(tansarii_ranger_merchant_sell_resource);

--end conversation
tansarii_ranger_merchant_end_convo = ConvoScreen:new {
	id = "end_convo",
	leftDialog = "",
	customDialogText = "Thanks for stopping by, see you later.",
	stopConversation = "true",
	options = {
	}
}
tansarii_ranger_merchant_template:addScreen(tansarii_ranger_merchant_end_convo);

--quest failed - time expired
tansarii_ranger_merchant_failed = ConvoScreen:new {
	id = "failed",
	leftDialog = "",
	customDialogText = "Time is up, friend. Maybe we can work together once " ..
      "your ranger skills have improved.",
	stopConversation = "true",
	options = {
	}
}
tansarii_ranger_merchant_template:addScreen(tansarii_ranger_merchant_failed);

addConversationTemplate("tansarii_ranger_merchant_template", tansarii_ranger_merchant_template);
