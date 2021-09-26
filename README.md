# RovaFramework
##### Documentation V 0.1; Written by Dr_K4rma

## Introduction
Originally, Rova was developed as a personal 3-am project to see what kind of sketchy things I could pull off with the ROBLOX environment. The idea was simple, to be able to inject keywords into the function environment in order to make ROBLOX Lua look and act like Java.

The project has since evolved from a mad-science project into something that is not only usable, but developer-friendly.

The idea for the way that the framework actually works was derived from two sources: devSparkle's [Overture](https://github.com/SparkplugInteractive/Overture) and sleitnick's [Aero Game Framework](https://sleitnick.github.io/AeroGameFramework/).

Having used both systems in the past, I formed some opinions on the two systems. 
Overture, while exceedingly easy to use, didn't provide enough structure to enforce good coding practices. Code could be found virtually anywhere, and it was entirely up to the developers to make sure it was properly organized.
The Aero Game Framework was the exact flipside of that. AGF was extremely structured and made for some very nice code. However, it was so structured, that I ended up jumping through hoops set by the framework rather than working on the code that I actually needed to get done.

And thus, the birth of Rova, or "Roblox Java". 
Rova is a framework/library manager that is designed to provide easy access to modules, while still enforcing some structure in the way the code is built.

## Installation
Initial setup for the Framework is very straightforward:
1. From this repository, download the RovaFramework.rbxm file.
2. Drag and drop the file into the target studio session.
3. Move the imported file (should be called 'RovaFramework') to ServerScriptService
4. You're done with the installation. All that's left is to add your own code.

## Hierarchy Setup
Rova works based off of specific files located in the various primary directories under the RovaFramework folder. Those files are called '.Manifest' (case-sensitive).
These manifest files define where the primary directory they're in goes, and what loading order the modules have (if any).

Manifest file content consists of two types of data: tags, and strings.
Tags in manifest files are always preceded by two underscores, kind-of like metamethods.
And strings are... well.. strings.

---

### Manifest Tags
Tags serve specific functions within the manifest file. At the current moment, two kinds of tags exist:
> **\_\_location= <Instance\>**: Defines where the primary directory will be moved. If set to null, the directory will not be moved anywhere
> **\_\_tags: String[]**: Table of strings. This is primarily used by the framework, and doesn't have a lot of use for developers (Or maybe not, prove me wrong).

Manifest tags should almost **ALWAYS** go before Manifest strings. Doing otherwise may lead to untested effects and framework tomfoolery.

---

### Manifest Strings
Strings in the manifest file define the loading order of the sub modules. It will henceforth be refered to as 'pre-loading'.

Pre-loading is not always necessary, as Rova takes advantage of lazy loading. However, if you do have a module (such as a service) that needs to be loaded first, second, third, etc. The option is there for you.

In the Manifest string, you must define the path to the module that you're trying to load.

---

I know some of this may be confusing, which is why I've provided some basic modules in the framework to use as a template.

But for additional effect, let me break down one right here.

### Manifest Example
If you look under `RovaFramework > Client > .Manifest`, you will find the following:

```lua
return {
	__location = game:GetService("ReplicatedStorage"),
	__tags = {"ServerIgnore"},
	"Client.Controllers.LocalGameSetupController", -- Responsible for initial setup of the game on the client. This is the first thing that should be called.
	"Client.Controllers.PlayerController", -- Controller that manages localside player setup and controls
}
```

The first two things to note are the tags.
First, the `__location` tag is set to the game's ReplicatedStorage. This means that, upon loading, Rova will put the primary directory into `Game.ReplicatedStorage`. In this case, the directory is the parent of the manifest file, aka `RovaFramework.Client`.

Second, the `__tags` tag. In this case, the directory that we're looking at will be exclusively executed on the client. This means that we do not want the server to attempt to load the manifest file, as that would just lead to some weird effects that have no business being on the server.

Next, we have the two controllers that we want to load in. Because LocalGameSetupController is located at `RovaFramework.Client.Controllers.LocalGameSetupController`, we need to define that path. The same is true for PlayerController.

Now, why does the manifest file exist in the first place? Wouldn't it be easier to just name the files we want to run a certain way? True, you could do that, but the point of the manifest files it to essentially have control over what is being run. By having the load queue in one place, we're able to always see what's running. And even better, if you want to disable something temporarily, you can just comment the line out without having to remove the entire module.

## Directories
Alright, you've heard me talk about directories and manifest files for several minutes. Now, let's put it to practice.

First off, primary directories are the folders located directly under the RovaFramework folder. In the clean install of this framework, there are four primary directories:
- Client
- ClientInitializer
- Server
- Shared

It should be noted that these directories **can be called anything you want**. They're only named what they are for organizational purposes.

So, let's say we want to create a new primary directory that will be put into lighting. As such, let's call it 'LightScripting'. Additionally, let's put a `.Manifest` file in there as well. Now, our framework directory looks something like this:
>RovaFramework (Folder)
>>Client (Folder)
>>ClientInitialize (Folder)
>>Server (Folder)
>>Shared (Folder)
>>LightScripting (Folder)
>>>.Manifest (ModuleScript)

And our empty `.Manifest` file looks like this:

```lua
return {
	
}
```

First, we want to define where our 'LightScripting' primary directory will go. In our example, it will go under `Game.Lighting`.

```lua
return {
	__location = game:GetService("Lighting"),
	
}
```

Good. Next, we consider, do we want to have any other tags? Probably not, so we can just not define `__tags`.

Next, lets add a module that we want to run on framework startup. Our hierarchy now looks something like this:
>RovaFramework (Folder)
>>Client (Folder)
>>ClientInitialize (Folder)
>>Server (Folder)
>>Shared (Folder)
>>LightScripting (Folder)
>>>.Manifest (ModuleScript)
>>>Startup (Folder)
>>>>StartupScript (ModuleScript)

Let's have that file run as soon as the directory is initialized!

```lua
return {
	__location = game:GetService("Lighting"),
	"LightScripting.Startup.StartupScript", -- Starts up some lighting effects
}
```

And we're done!

Now, let's move onto how to actually use these files.

## Calling Modules
We'll be using `RovaFramework.Client.Controller.PlayerController` as an example of how to call use modules.

First thing that you need to remember, you **MUST** call `_G()` at the start of every module where you intent to call another module. My recommendation is to call `_G()` right after the file header.

Anyway, as you can see on line 15, there's something that doesn't look quite right:

```lua
----------------------------------
-- 		DEPENDENCIES
----------------------------------
import "EventUtils"
```

Assuming you've coded in Lua for long enough, you'll know that there's no such thing as an import statement. However, because of the way the framework operates, that function now exists in the environment.

Right after, on line 20, you can see EventUtils being used:

```lua
----------------------------------
-- 		DEPENDENCIES
----------------------------------
import "EventUtils"

----------------------------------
-- SERVICES & PRIMARY OBJECTS
----------------------------------
local REM = EventUtils.GetRemoteEvent("PlayersREM")
```

And indeed, this does work, The `GetRemoteEvent` function is indeed called.
And yes, ROBLOX's intellisense will be angry at this, not much I can do about that unfortunately...

That's pretty much the basics on using the framework. If you wish to find out some more information about operation of the framework, you can keep reading. Otherwise, happy coding! :^)

## Theory Of Operation
Here's me doing my best to explain what exactly is going on here, and why it works.

Essentially, Lua operates on a sort-of table system. When I say function environment, imagine a table where all globals are stored. Things like `game`, `_G`, `math`, etc. This function environment is unique to every script/module, so changing it does not affect other scripts.

As you may have guessed by now, the framework works by altering the function environment in order to inject methods such as `import` and other modules you've imported.

Wait, import is a function?

Yep.

Have you ever seen people use `print "Hello World"`?

The concept is exactly the same here.
Just as `print "Hello World"` is shorthand for `print("Hello World")`, `import "EventUtils"` is shorthand for `import("EventUtils")`. 

And when you import a module, that module also gets injected into the function environment. 

Is it cursed? A little bit, but it works.

Those of you that have done your research though, will have caught onto a flaw in this logic, which will be discussed in the following section.

## WARNINGS
ROBLOX Lua reaaaaallly doesn't like people altering the function environment. As such, when someone alters the function environment, they tend to disable some optimisations in the game engine -- mainly things to do with looping.

While this can certainly be detrimental in some cases, it you're writing good and efficient code, you'll be completely fine.

However, if you decide you'd rather do without the function environment injections, you can always disable them. Simply go to the Rova framework mode (located in `RovaFramework.Shared`), and set the `USE_INJECTED_METHODS` variable to false.

Once you do this, you'll be able to utilize a different approach.
Using that same PlayerController module, it would look something like this:

```lua
local Rova = _G.Rova

local REM = Rova:LoadLibrary("PlayersREM")
```

Easy as pie, and still very much usable! (Just make sure you do this for every module).

## Additional Notes
This framework is still in pretty early stages.
Bugs will probably rear their ugly heads, and when they do, please feel free to message me on Discord at `Karma#8747`.

Happy Coding!