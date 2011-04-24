
// File:    world.dm
// Library: Forum_account.Sidescroller
// Author:  Forum_account
//
// Contents:
//   This file contains the global movement loop,
//   some other global things (variables), and other
//   stuff.

#define DEBUG

world
	proc
		// This is the global movement loop. It calls world.movement
		// every tick. If you want to change the behavior of the global
		// movement loop, override world.movement, not movement_loop.
		movement_loop()
			movement()
			spawn(world.tick_lag)
				movement_loop()

		movement()
			for(var/mob/m in world)
				m.movement()

world
	// 40 frames per second
	tick_lag = 0.25

	New()
		..()

		spawn(world.tick_lag)
			movement_loop()

var
	// enables the display of some error messages and the debugging statpanel tab
	SIDESCROLLER_DEBUG = 0

mob
	Stat()
		..()

		if(SIDESCROLLER_DEBUG)
			statpanel("Sidescroller Debugging")
			stat("world.cpu", world.cpu)
			stat("")

			stat("px, py", "[px], [py]")
			stat("vel_x, vel_y", "[vel_x], [vel_y]")

			if(dir == NORTH)
				stat("dir", "up")
			else if(dir == SOUTH)
				stat("dir", "down")
			else if(dir == EAST)
				stat("dir", "right")
			else if(dir == WEST)
				stat("dir", "left")
			else
				stat("dir", dir)

			stat("loc", "[x], [y], [z]")
			stat("icon_state", icon_state)
			stat("")
			stat("on_left", on_left)
			stat("on_right", on_right)
			stat("on_ceiling", on_ceiling)
			stat("on_ground", on_ground)
			stat("on_ladder", on_ladder)

			var/key_str = ""
			for(var/k in keys)
				if(keys[k])
					if(key_str)
						key_str += ", [k]"
					else
						key_str = k
			stat("keys pressed", key_str)

// This is just some debugging stuff I was goofing around with.
// It creates a translucent red overlay that represents the
// bounding box defined by the mob's pwidth and pheight.
mob
	var
		var/obj/bounding_box

	proc
		bounding_box(show = 1)
			if(!bounding_box)
				var/icon/I = icon('icons.dmi', "")
				I.DrawBox(rgb(0,0,0,0), 1, 1, 32, 32)
				I.DrawBox(rgb(255, 0, 0, 128), 1, 1, pwidth, pheight)

				bounding_box = new()
				bounding_box.icon = I
				bounding_box.pixel_x = -offset_x
				bounding_box.pixel_y = -offset_y
				bounding_box.layer = layer + 1

			if(show)
				overlays += bounding_box

			else
				overlays -= bounding_box
