lua-compat-5.2
==============

Compatibility module providing Lua-5.2-style APIs for Lua 5.1.

What is it
----------

This is a small module that aims to make it easier to write Lua code
in a Lua-5.2-style that runs on both Lua 5.1 and Lua 5.2. This does *not*
make Lua 5.1 entirely compatible with Lua 5.2, but it brings the API
closer to that of Lua 5.2.

How to use it
-------------

```lua
require("compat52")
```

You have to launch it like this (instead of the usual idiom of storing
the return of `require` in a local variable) because compat52 needs to
make changes to your global environment.

When run under Lua 5.2, this module does nothing.

When run under Lua 5.1, it replaces some of your standard functions and
adds new ones to bring your environment closer to that of Lua 5.2.

What's implemented
------------------

* table.pack and table.unpack
* `coroutine` functions dealing with the main coroutine 
* return code of os.execute
* bit32 (actually uses bit32 available from LuaRocks as a dependency)
* removes functions that are not available in Lua 5.2, such as
  setfenv and getfenv

What's not implemented
----------------------

* C APIs
* _ENV
* package.loaders vs. package.searchers
* anything else I might have not bumped into yet
* functions that were only deprecated in Lua 5.2 are not removed,
  since they are available in Lua 5.2 when built with LUA_COMPAT_ALL.

See also
--------

* For Lua-5.1-style APIs under Lua 5.0, see [Compat-5.1](http://keplerproject.org/compat/)
* for C support in the opposite direction (ie, loading C code using
Lua-5.1-style APIs under Lua 5.2), see [Twoface](http://corsix.github.io/twoface/)

