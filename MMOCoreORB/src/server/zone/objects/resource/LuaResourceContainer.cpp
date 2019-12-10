/*
				Copyright <SWGEmu>
		See file COPYING for copying conditions.*/

/**
 * \file LuaResourceContainer.cpp
 * \author Erik Schumacher
 * \date 12-16-19
 */

#include "server/ServerCore.h"
#include "server/zone/objects/resource/ResourceContainer.h"
#include "LuaResourceContainer.h"

const char LuaResourceContainer::className[] = "LuaResourceContainer";

Luna<LuaResourceContainer>::RegType LuaResourceContainer::Register[] = {
        { "_setObject", &LuaResourceContainer::_setObject },
		{ "_getObject", &LuaSceneObject::_getObject },
        { "getSpawnName", &LuaResourceContainer::getSpawnName },
        { "getQuantity", &LuaResourceContainer::getQuantity },
        { "setQuantity", &LuaResourceContainer::setQuantity },
		{ 0, 0 }
};

LuaResourceContainer::LuaResourceContainer(lua_State *L) : LuaTangibleObject(L) {
#ifdef DYNAMIC_CAST_LUAOBJECTS
	realObject = dynamic_cast<ResourceContainer*>(_getRealSceneObject());

	assert(!_getRealSceneObject() || realObject != nullptr);
#else
	realObject = reinterpret_cast<ResourceContainer*>(lua_touserdata(L, 1));
#endif
}

LuaResourceContainer::~LuaResourceContainer(){
}

int LuaResourceContainer::_setObject(lua_State* L) {
	LuaTangibleObject::_setObject(L);

#ifdef DYNAMIC_CAST_LUAOBJECTS
	realObject = dynamic_cast<ResourceContainer*>(_getRealSceneObject());

	assert(!_getRealSceneObject() || realObject != nullptr);
#else
	realObject = reinterpret_cast<ResourceContainer*>(lua_touserdata(L, -1));
#endif

	return 0;
}

int LuaResourceContainer::getSpawnName(lua_State* L) {
    if (realObject == nullptr) {
        // Invalid ResourceContainer* passed to LuaResourceContainer constructor
        return 0;
    }

    String text = realObject->getSpawnName();
    lua_pushstring(L, text.toCharArray());

    return 1;
}

int LuaResourceContainer::getQuantity(lua_State* L) {
    if (realObject == nullptr) {
        // Invalid ResourceContainer* passed to LuaResourceContainer constructor
        return 0;
    }

    lua_pushinteger(L, realObject->getQuantity());

    return 1;
}

int LuaResourceContainer::setQuantity(lua_State* L) {
    if (realObject == nullptr) {
        // Invalid ResourceContainer* passed to LuaResourceContainer constructor
        return 0;
    }

    uint32_t newQuantity = lua_tointeger(L, -1);
    realObject->setQuantity(newQuantity);

    return 1;
}

