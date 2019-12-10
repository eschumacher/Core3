/*
				Copyright <SWGEmu>
		See file COPYING for copying conditions.*/

/**
 * \file LuaResourceManager.cpp
 * \author Erik Schumacher
 * \date 11-27-19
 */

#include "server/ServerCore.h"
#include "server/zone/managers/resource/ResourceManager.h"
#include "server/zone/objects/resource/ResourceSpawn.h"
#include "LuaResourceManager.h"

const char LuaResourceManager::className[] = "LuaResourceManager";

Luna<LuaResourceManager>::RegType LuaResourceManager::Register[] = {
        { "getWeeklyRangerResource", &LuaResourceManager::getWeeklyRangerResource },
		{ 0, 0 }
};

LuaResourceManager::LuaResourceManager(lua_State* L) {
    ZoneServer* server = ServerCore::getZoneServer();
    if (server == nullptr)
        throw Exception();
    
    realObject = server->getResourceManager();
    if (realObject == nullptr)
        throw Exception();
}

LuaResourceManager::~LuaResourceManager(){
}

int LuaResourceManager::getWeeklyRangerResource(lua_State* L) {
	if (lua_gettop(L) - 1 != 1) {
		Logger::console.error("incorrect number of arguments for LuaResourceManager::getWeeklyRangerResource");
		return 0;
	}

    Vector<ManagedReference<ResourceSpawn*> > candidates;
    String queryName = lua_tostring(L, -1);
    uint64_t spawnedSince = time(0);

    while (candidates.size() < 1) {
        // search for resources in the last day.  If not found,
        // next while loop iteration will search within the last
        // 2 days...3 days...etc, until a spawn is found.
        spawnedSince -= 86400;
        realObject->getResourceListSpawnedSince(candidates, queryName, spawnedSince);
    }

    // we have at least one resource that matches our criteria -
    // grab a random resource out of it.
    int key = System::random(candidates.size() - 1);
    ManagedReference<ResourceSpawn*> resource = candidates.get(key);
    if (resource == nullptr)
        throw Exception();
    
    String resName = resource->getName();
    if (resName == "")
        throw Exception();

    // some resources are harder to come by, so a multiplier is passed back to lua
    float multiplier = 1;
    if(resource->isType("seafood") ||
            resource->isType("milk") ||
            resource->isType("meat_egg") ||
            resource->isType("bone_horn") ||
            resource->isType("meat_insect")) {
		multiplier = 0.1;
	}

    lua_newtable(L);
    lua_pushstring(L, resName.toCharArray());
    lua_pushnumber(L, multiplier);
    lua_rawseti(L, -3, 2);
    lua_rawseti(L, -2, 1);

	return (resName != "");
}
