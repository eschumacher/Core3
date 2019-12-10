/*
				Copyright <SWGEmu>
		See file COPYING for copying conditions.*/

/**
 * \file LuaResourceContainer.h
 * \author Erik Schumacher
 * \date 12-16-19
 */

#ifndef LUARESOURCECONTAINER_H_
#define LUARESOURCECONTAINER_H_

#include "engine/engine.h"

#include "server/zone/objects/tangible/LuaTangibleObject.h"

namespace server {
namespace zone {
namespace objects {
namespace resource {
    class ResourceContainer;

	class LuaResourceContainer : public LuaTangibleObject {
	public:
		static const char className[];
		static Luna<LuaResourceContainer>::RegType Register[];

		LuaResourceContainer(lua_State *L);
		~LuaResourceContainer();

		int _setObject(lua_State* L);
        int getSpawnName(lua_State* L);
        int getQuantity(lua_State* L);
		int setQuantity(lua_State* L);

	private:
		Reference<ResourceContainer*> realObject;
	};
}
}
}
}

using namespace server::zone::objects::resource;

#endif /* LUARESOURCECONTAINER_H_ */
