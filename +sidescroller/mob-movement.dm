
// File:    mob-movement.dm
// Library: Forum_account.Sidescroller
// Author:  Forum_account
//
// Contents:
//   This file contains the mob's default behavior for our
//   sidescrolling pixel movement system. The pixel movement
//   itself (how collisions are detected and handled) is
//   handled in pixel-movement.dm. This file handles the
//   default behavior for a mob's movement (how they
//   accelerate, how keyboard input is handled, etc.)

var
	const
		// used to reference keyboard keys
		K_RIGHT = "d"
		K_LEFT = "a"
		K_UP = "w"
		K_DOWN = "s"
		K_JUMP = "space"

		// before v1.8 the values used to be:
		// K_RIGHT = "right"
		// K_LEFT = "left"
		// K_UP = "up"
		// K_DOWN = "down"

		// used to set icon states
		STANDING = "standing"
		MOVING = "moving"
		CLIMBING = "climbing"
		JUMPING = "jumping"

		RIGHT = EAST
		LEFT = WEST

mob
	icon_state = "mob"

	var
		on_left = 0
		on_right = 0
		on_ceiling = 0
		on_ground = 0
		on_ladder = 0

		mob/platform/platform
		base_state = ""

		move_speed = 5
		climb_speed = 5
		fall_speed = 20

		last_x = -1
		last_y = -1
		last_z = -1

	proc
		// a is the atom you're bumping and d is the direction you were
		// moving (UP, DOWN, LEFT, or RIGHT). The default behavior is
		// to set your directional velocity to zero when you bump something.
		bump(atom/a, d)
			if(d == LEFT || d == RIGHT)
				vel_x = 0

				// if the mob is following a path and they bump something,
				// jumping will make them try to jump over it.
				if(destination || path)
					if(can_jump())
						jump()
			else
				vel_y = 0

		// Your icon_state depends on your current situation, like this:
		// if you're on a ladder you're climbing
		// if you're not on the ground (and not on a ladder) you're jumping
		// if you're not moving (and are on the ground and not on a ladder) you're standing
		// otherwise you're moving (walking)
		set_state()
			var/base = base_state ? "[base_state]-" : ""

			if(on_ladder)
				icon_state = base + CLIMBING
			else if(!on_ground)
				icon_state = base + JUMPING
			else if(vel_x == 0)
				icon_state = base + STANDING
			else
				icon_state = base + MOVING

			if(keys[K_RIGHT])
				dir = EAST
			else if(keys[K_LEFT])
				dir = WEST

		can_jump()
			if(on_ladder)
				return 0

			// If the mob is following a path, we limit how frequently
			// they can jump (from the same tile). The reason we do this
			// is because if they get stuck (the pathing isn't perfect!)
			// they might jump repeatedly. With no delay it looks silly.
			if(path || destination)
				if(__last_jump_loc == loc)
					if(__jump_delay > 0)
						__jump_delay -= 1
						return 0

			return on_ground

		jump()
			vel_y = 10

		drop()
			dropped = 1
			// py -= 1

		// this is called when the player is moving and is not on a ladder
		move(d)
			// we want to keep the mob's velocity between -5 and 5.
			if(d == RIGHT)
				if(vel_x < move_speed)
					vel_x += 1
			else if(d == LEFT)
				if(vel_x > -move_speed)
					vel_x -= 1

		// this is called when the mob is moving while hanging on a ladder
		// so we need to consider all four directions.
		climb(d)
			if(d == RIGHT)
				if(vel_x < climb_speed)
					vel_x += 1
			else if(d == LEFT)
				if(vel_x > -climb_speed)
					vel_x -= 1
			else if(d == UP)
				if(vel_y < climb_speed)
					vel_y += 1
			else if(d == DOWN)
				if(vel_y > -climb_speed)
					vel_y -= 1

		gravity()
			if(on_ladder || on_ground) return

			vel_y -= 1
			if(vel_y < -fall_speed)
				vel_y = -fall_speed

		// The action proc is called by the mob's default movement proc. It doesn't do
		// anything new, it just splits up the code that was in the movement proc. This
		// is useful because the movement proc was quite long and this also lets you
		// override part of the mob's movement behavior without overriding it all. The
		// movement proc's default behavior calls gravity, set_flags, action, set_state,
		// and pixel_move. If you want to change just the part that is now action, you
		// used to have to override movement and remember to call gravity, set_flags,
		// set_state, and pixel_move. Now you can just override action.
		//
		// To be clear, there are still cases where you'd want to override movement. If
		// you want to create a bullet which travels in a straight line (isn't affected
		// by gravity) and doesn't change icon states, you can just override movement.
		// If you want to change how keyboard input is handled or you want to change the
		// mob's AI, you can override action() but leave movement() alone.
		action()
			// Calling mob.move_to or mob.move_towards will set either the path
			// or destination variables. If either is set, we want to make the
			// mob move as those commands specify, not as the keyboard input specifies.
			// The follow_path proc is defined in mob-pathing.dm.
			if(path || destination)
				follow_path()

			// if the mob's movement isn't controlled by a call to move_to or
			// move_towards, we use the client's keyboard input to control the mob.
			else if(client)
				var/turf/t = loc

				if(t.ladder)
					if(keys[K_UP] || keys[K_DOWN])
						if(!on_ladder)
							vel_y = 0
						on_ladder = 1
				else
					on_ladder = 0

				// If we're on a ladder we want the arrow keys to move us in
				// all directions. Gravity will not affect you.
				if(on_ladder)
					if(keys[K_RIGHT])
						if(!on_right)
							climb(RIGHT)

					if(keys[K_LEFT])
						if(!on_left)
							climb(LEFT)

					if(keys[K_UP])
						if(!on_ceiling)
							climb(UP)

					if(keys[K_DOWN])
						if(!on_ground)
							climb(DOWN)

				// If you're not on a ladder, movement is normal.
				else
					if(keys[K_RIGHT])
						if(!on_right)
							move(RIGHT)

					if(keys[K_LEFT])
						if(!on_left)
							move(LEFT)

					if(keys[K_UP])
						if(!on_ceiling)
							move(UP)

					if(keys[K_DOWN])
						if(!on_ground)
							move(DOWN)

				// by default the jumped var is set to 1 when you press the space bar
				if(jumped)
					jumped = 0
					if(can_jump())
						jump()

				// the slow_down proc will decrease the mob's movement speed if
				// they're not pressing the key to move in their current direction.
				slow_down()

			// end of action()

		// This proc is automatically called every tick. It checks the
		// mob's current situation and keyboard input and calls a proc
		// to take the appropriate action (jump, move, climb).
		movement()

			// if your x, y, or z coordinate does not match last_x/y/z then
			// the mob's loc was changed elsewhere in the code. This is ok, we
			// just need to call set_pos to update the mob's px and py vars.
			if(x != last_x || y != last_y || z != last_z)
				set_pos(x * 32 - offset_x, y * 32, z)

			var/turf/t = loc

			// if you don't have a location you're not on the map so we don't
			// need to worry about movement.
			if(!t) return

			// This sets the on_ground, on_ceiling, on_left, and on_right flags.
			set_flags()

			// apply the effect of gravity
			gravity()

			// handle the movement action. This will handle the automatic behavior
			// that is triggered by calling move_to or move_towards. If the mob has
			// a client connected (and neither move_to/towards was called) keyboard
			// input will be processed.
			action()

			// we remove the player from the platform's riders list. If we are
			// still on the platform at the end of this iteration we'll bump
			// the platform again and get added back to the list.
			if(platform)
				platform.riders -= src
				platform = null

			// set the mob's icon state
			set_state()

			// perform the movement
			pixel_move(vel_x, vel_y)

		slow_down()
			// if you're moving faster than your move_speed, slow down
			// whether you're pressing an arrow key or not.
			if(vel_x > move_speed)
				vel_x -= 1
			else if(vel_x < -move_speed)
				vel_x += 1

			// if you're not pressing left or right, slow down.
			// we want this to happen whether you're on a ladder or not
			else if(!keys[K_RIGHT] && !keys[K_LEFT])
				if(abs(vel_x) < 1)
					vel_x = 0
				else if(vel_x > 0)
					vel_x -= 1
				else if(vel_x < 0)
					vel_x += 1

			// if you are on a ladder also slow down in the y direction.
			if(on_ladder && !keys[K_UP] && !keys[K_DOWN])
				if(abs(vel_y) < 1)
					vel_y = 0
				else if(vel_y > 0)
					vel_y -= 1
				else if(vel_y < 0)
					vel_y += 1

		// This proc is called every tick by the default movement proc. It sets
		// the on_ground, on_ceiling, on_left, and on_right flags so you can
		// easily check if the mob is next to a wall or on the ground.
		set_flags()
			on_ground = 0
			on_ceiling = 0
			on_left = 0
			on_right = 0

			for(var/atom/a in oview(2,src))
				if(!can_bump(a)) continue

				while(1)
					if(a.pleft == a.pright)
						if(py != a.py + a.pheight) break
					else
						if(py != a.height(px,py,pwidth,pheight)) break

					// If you're not lined up horizontally we can also ignore the object
					if(px >= a.px + a.pwidth) break
					if(px + pwidth <= a.px) break

					on_ground |= (1 | a.flags)
					// on_ground = 1
					break

				while(1)
					if(py + pheight != a.py) break

					// If you're not lined up horizontally we can also ignore the object
					if(px >= a.px + a.pwidth) break
					if(px + pwidth <= a.px) break

					on_ceiling |= (1 | a.flags)
					// on_ceiling = 1
					break

				while(1)
					if(px + pwidth != a.px) break

					if(a.pleft != a.pright)
						if(py >= a.py + a.pleft) break
						if(py + pheight <= a.py) break

					else
						// If you're not lined up vertically we can also ignore the object
						if(py >= a.py + a.pheight) break
						if(py + pheight <= a.py) break

					on_right |= (1 | a.flags)
					// on_right = 1
					break

				while(1)
					if(px != a.px + a.pwidth) break

					if(a.pleft != a.pright)
						if(py >= a.py + a.pright) break
						if(py + pheight <= a.py) break

					else
						if(py >= a.py + a.pheight) break
						if(py + pheight <= a.py) break

					on_left |= (1 | a.flags)
					// on_left = 1
					break

/*
// For efficiency's sake these procs were replaced by the
// set_flags proc. If you need to get a list of atoms on
// the mob's left, right, top, or bottom sides you can call
// the left, right, top, or bottom procs defined in procs.dm.
// Keep in mind that get_gound returned a list of bumpable
// atoms while bottom(1) will return all atoms (bumpable or
// not) within 1 pixel of the mob's bottom (hehe, bottom).

		get_ground()
			// This proc was removed in version 1.7

		get_ceiling()
			// This proc was removed in version 1.7

		get_right()
			// This proc was removed in version 1.7

		get_left()
			// This proc was removed in version 1.7
*/

client

	// Previously these procs displayed an error message. The reason
	// for doing that was because if client.North was called, it was
	// probably because macros weren't properly defined. The error
	// messages were sometimes shown when they shouldn't have been shown,
	// so the error message was removed.
	// We still want to override these procs so that they do nothing.
	// Input is handled by keyboard.dm, we don't need to use these procs.
	North() return 0
	South() return 0
	East() return 0
	West() return 0
	Southeast() return 0
	Southwest() return 0
	Northeast() return 0
	Northwest() return 0
