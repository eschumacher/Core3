/*
				Copyright <SWGEmu>
		See file COPYING for copying conditions.*/

/**
 * \file LuaResourceManager.h
 * \author Erik Schumacher
 * \date 11-27-19
 */

#ifndef LUARESOURCEMANAGER_H_
#define LUARESOURCEMANAGER_H_

#include "engine/engine.h"

namespace server {
namespace zone {
namespace managers {
namespace resource {
    class ResourceManager;

	class LuaResourceManager {
	public:
		static const char className[];
		static Luna<LuaResourceManager>::RegType Register[];

		LuaResourceManager(lua_State *L);
		~LuaResourceManager();

        /**
         * Returns (via lua stack) a string representing a valid resource
         * candidate for the weekly ranger quest.
         */
        int getWeeklyRangerResource(lua_State* L);

	private:
		Reference<ResourceManager*> realObject;
	};
}
}
}
}

using namespace server::zone::managers::resource;

#endif /* LUARESOURCEMANAGER_H_ */
