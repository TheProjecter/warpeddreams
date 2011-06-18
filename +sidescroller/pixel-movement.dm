
// File:    pixel-movement.dm
// Library: Forum_account.Sidescroller
// Author:  Forum_account
//
// Contents:
//   This file contains the code to handle the actual
//   pixel movement (the pixel_move proc). It also has
//   some related functions: camera handling, density
//   checking, etc.

turf
	var
		ladder = 0

atom
	// we need these vars for turfs and mobs at least. We probably don't
	// need them for areas, but it's easy to define them for all atoms.
	var
		// px/py is your position on the map in pixels
		px = -1
		py = -1

		// pwidth/pheight determine the dimensions of your bounding box
		pwidth = 32
		pheight = 32

		// used for sloped objects, pleft is the height of the object's
		// left side and pright is the height of its right side.
		pleft = 0
		pright = 0

		// offset_x/y are used to offset the object's icon to make the
		// image appear within the bounding box.
		offset_x = 0
		offset_y = 0

		// This replaces the "platform" var for turfs. Set scaffold = 1
		// to create objects that you can walk in front of and stand on
		// top of.
		scaffold = 0

		// This is used to define properties of the object that get
		// stored in the mob's on_ground, on_left, on_right, and
		// on_ceiling vars.
		flags = 0

		// These are flags for individual sides of the atom.
		flags_right = 0
		flags_left = 0
		flags_top = 0
		flags_bottom = 0

	New()
		..()

		if(pleft == 0 && pright == 0)
			pleft = pheight
			pright = pheight
		else
			pheight = max(pleft, pright)

		if(x && y)
			px = world.icon_size * x
			py = world.icon_size * y

	proc
		// Calculates the height of a sloped tile for a given bounding
		// box. The height is the largest py value that the slope has
		// underneath the specified bounding box. You can also think of
		// the height as being the y-value of the point where contact
		// would first be made if you moved the bounding box straight down.
		height(qx,qy,qw,qh)
			if(pright > pleft)
				. = min(32, qx + qw - px)
				. = py + pleft + (.) * (pright - pleft) / pwidth
				. = min(., py + pright)
			else
				. = max(0, qx - px)
				if(. > px + pwidth) return -100
				. = py + pleft + (.) * (pright - pleft) / pwidth
				. = min(., py + pleft)

		// This is called when a movable steps on the atom.
		stepped_on(mob/m)

		stepping_on(mob/m, time)

		stepped_off(mob/m)

mob/mechanism

mob
	platform
		var
			list/riders = list()

mob
	animate_movement = 0

	// Movable atoms can have velocities.
	var
		vel_x = 0
		vel_y = 0

	proc
		// by default you can only bump into dense turfs and platforms
		can_bump(atom/a)
			. = ..()

			if(.)
				return 1

			if(a.scaffold)
				// we need to handle the scaffold differently
				// if it's a ramp or not.

				// If it's not a ramp...
				if(a.pleft == a.pright)
					if(py >= a.py + a.pheight)
						return !dropped

				// if it is a ramp...
				else
					if(py >= a.height(px, py, pwidth, pheight))
						return !dropped

			if(isturf(a))
				return a.density

			if(istype(a, /mob))
				return a.density

			return 0

		// Note: the can_move proc has been removed. pixel_move now does all of the work directly.

		// The pixel_move proc moves a mob by (dpx, dpy) pixels. If this move is invalid (because a
		// dense atom is in your way) the move may be adjusted so that you don't end up inside that atom.
		pixel_move(dpx, dpy)

			// We'll use this var later to check if we should "stick" to a ramp below us.
			// The reason we declare the variable here is because the value of dpy might
			// change in this proc but we want to use its initial value.
			var/stick_to_ramp = on_ground && (dpy <= 0)

			// We could intelligently look for all nearby tiles that you might hit
			// based on your position and direction of the movement, but instead
			// we'll just check every nearby object.

			// Prior to version 2.0 this loop used the oview() proc. The nearby() proc
			// returns the same set of atoms but lists atoms in cardinal directions first.
			// The order used to cause some problems because oview() would check the bottom
			// left tile before the bottom tile - this means that you might bump the right
			// side of the bottom-left tile when that's technically impossible (because the
			// tile below you is dense).
			for(var/atom/t in nearby())

				// if we're not trying to move anymore, we can stop checking for collisions.
				if(dpx == 0 && dpy == 0) break

				// We use the src object's can_bump proc to determine what it can
				// collide with. We might have more complex rules than just "dense
				// objects collide with dense objects". For example, you might want
				// bullets and other projectiles to pass through walls that players
				// cannot.
				if(!can_bump(t)) continue

				// this handles bumping sloped objects
				if(t.pleft != t.pright)
					if(!t.inside4(px+dpx,py+dpy,pwidth,pheight)) continue

					// check for bumping the sides
					if(px + pwidth < t.px)
						if(t.py + t.pleft > py + 3)
							dpx = t.px - (px + pwidth)
							bump(t, RIGHT)
							continue
					if(px > t.px + t.pwidth)
						if(t.py + t.pright > py + 3)
							dpx = t.px + t.pwidth - px
							bump(t, LEFT)
							continue

					// check for bumping the top and bottom
					var/h = t.height(px+dpx,py+dpy,pwidth,pheight)

					if(py + dpy < h)
						if(py + pheight < t.py)
							vel_y = 0
							dpy = t.py - (py + pheight)
							bump(t, UP)
						else
							// py = h
							dpy = h - py
							bump(t, DOWN)

				// this handles bumping non-sloped objects
				else
					// You cannot be inside t already, so if the move doesn't put you
					// inside t then we can ignore that turf.
					if(!t.inside4(px+dpx,py+dpy,pwidth,pheight)) continue

					// ix and iy measure how far you are inside the turf in each direction.
					var/ix = 0
					var/iy = 0

					// If you draw pictures showing a mob hitting a dense turf from the left
					// side and label px, dpx, pwidth, and t.px it's easy to see how you
					// compute ix. The same can be done for hitting a dense turf from the right.
					if(dpx > 0)
						ix = px + dpx + pwidth - t.px
					else if(dpx < 0)
						ix = (px + dpx) - (t.px + t.pwidth)

					// Same as the ix calculations except we swap y for x and height for width.
					if(dpy > 0)
						iy = py + dpy + pheight - t.py
					else if(dpy < 0)
						iy = (py + dpy) - (t.py + t.pheight)

					// tx and ty measure the fraction of the move (the dpx,dpy move) that it takes
					// for you to hit the turf in each direction.
					var/tx = (abs(dpx) < 0.00001) ? 1000 : ix / dpx
					var/ty = (abs(dpy) < 0.00001) ? 1000 : iy / dpy

					// We use tx and ty to determine if you first hit the object in the x direction
					// or y direction. We modify dpx and dpy based on how you bumped the turf.
					if(ty <= tx)

						// if you're below the object
						if(py + pheight / 2 < t.py + t.pheight / 2)

							// set dpy to the amount that you overlap
							dpy = t.py - (py + pheight)
							bump(t, UP)

						else
							dpy = t.py + t.pheight - py
							bump(t, DOWN)

						// This is the old code. It resolves the collision
						// based on the direction you're moving, not based
						// on whatever direction is easier.
						// dpy -= iy
						// bump(t, (iy > 0) ? UP : DOWN)
					else
						// if you're to the left of the object
						if(px + pwidth / 2 < t.px + t.pwidth / 2)

							// set dpy to the amount that you overlap
							dpx = t.px - (px + pwidth)
							bump(t, RIGHT)

						else
							dpx = t.px + t.pwidth - px
							bump(t, LEFT)

						// This is the old code. It resolves the collision
						// based on the direction you're moving, not based
						// on whatever direction is easier.
						// dpx -= ix
						// bump(t, (ix > 0) ? RIGHT : LEFT)

			// stick_to_ramp will be true if you were on the ground before performing this
			// move and if you're not moving upwards (if you're moving upwards you shouldn't
			// stick to the ground).
			if(stick_to_ramp && dpy <= 0)
				// check all turfs within 8 pixels of your bottom (hehe)...
				for(var/turf/t in bottom(8))
					// only check turfs that you can bump and are ramps
					if(!can_bump(t)) continue
					if(t.pleft == t.pright) continue

					// t.height gives you the height of the top of the turf based on your mob.
					// You can think of it as, "if your mob fell straight down, at what height
					// would you hit the ramp". That's the heigh that t.height returns.
					var/h = t.height(px+dpx,py+dpy,pwidth,pheight)

					// by setting dpy to h - py, we're making you move down just enough that
					// you'll end up on the ramp.
					dpy = h - py

			// At this point we've clipped your move against all nearby tiles, so the
			// move (dpx,dpy) is a valid one at this point (both might be zero) so we
			// can perform the move.
			set_pos(px + dpx, py + dpy)

			if(dpx == 0 && dpy == 0)
				return 0
			else
				return 1

		// set_pos now takes your new px and py values as parameters.
		set_pos(nx,ny, map_z = -1)
			if(map_z == -1) map_z = z

			var/moved = (nx != px || ny != py || map_z != z)

			px = nx
			py = ny

			var/tx = round((px + pwidth / 2) / world.icon_size)
			var/ty = round((py + pheight / 2) / world.icon_size)

			if(moved)
				var/turf/old_loc = loc
				var/turf/new_loc = locate(tx,ty,map_z)

				if(new_loc != old_loc)
					var/area/old_area = old_loc:loc
					Move(new_loc, dir)

					// In case Move failed we need to update your loc anyway.
					// If you want to prevent movement, don't do it through Move()
					loc = new_loc

					if(new_loc)
						var/area/new_area = new_loc.loc

						if(old_area != new_area)
							if(old_area) old_area.Exited(src)
							if(new_area) new_area.Entered(src)

					if(!loc)
						if(SIDESCROLLER_DEBUG)
							CRASH("The atom [src] is not on the map. Objects may \"fall off\" the map if the perimeter of the map does not contain dense turfs.")

				pixel_x = px - x * world.icon_size + offset_x
				pixel_y = py - y * world.icon_size + offset_y

			if(client)
				set_camera()

				client.pixel_x = pixel_x + camera.px - px
				client.pixel_y = pixel_y + camera.py - py

			var/list/_bottom = bottom(1)
			for(var/atom/a in _bottom)
				if(can_bump(a))
					if(a in bottom)
						bottom[a] += 1
						a.stepping_on(src, bottom[a])
					else
						bottom[a] = 1
						a.stepped_on(src)

			for(var/atom/a in bottom)
				if(!(a in _bottom))
					bottom -= a
					a.stepped_off(src)

			last_x = x
			last_y = y
			last_z = z

	var
		list/bottom = list()

var
	const
		SCROLL_X = 1
		SCROLL_Y = 2

// The /Background object contains the actual object
// and image that are the visual background display, it
// also contains size and position info. To move the
// background you change the px and py vars and the
// set_camera proc adjusts the background accordingly.
Background
	var
		obj/object
		image/image

		width
		height

		px = 0
		py = 0

		mob/owner

	New(mob/m, i, scroll_mode)

		owner = m

		var/icon/I = new(i)

		width = I.Width()
		height = I.Height()

		object = new()
		object.animate_movement = 0
		object.layer = 0

		image = new(i, object)
		image.layer = 0

		// depending on the scroll_mode we need to create
		// overlays to cover additional area:

		// none:     X:      Y:    X + Y:
		// +---+ +---+---+ +---+ +---+---+
		// |   | |   |   | |   | |   |   |
		// +---+ +---+---+ +---+ +---+---+
		//                 |   | |   |   |
		//                 +---+ +---+---+
		if(scroll_mode & SCROLL_X)
			var/obj/o = new()
			o.layer = 0
			o.icon = I
			o.pixel_x = width
			image.overlays += o

		if(scroll_mode & SCROLL_Y)
			var/obj/o = new()
			o.layer = 0
			o.icon = I
			o.pixel_y = height
			image.overlays += o

			if(scroll_mode & SCROLL_X)
				var/obj/o2 = new()
				o2.layer = 0
				o2.icon = I
				o2.pixel_x = width
				o2.pixel_y = height
				image.overlays += o2

	proc
		show()
			if(owner && owner.client)
				owner.client.images += image
				owner.backgrounds += src

		hide()
			if(owner && owner.client)
				owner.client.images -= image
				owner.backgrounds -= src

mob
	var
		list/backgrounds = list()

	proc
		// This creates and returns a new /Background object.
		background(i, scroll_mode = 0)
			if(!client) return

			if(scroll_mode == 0 || scroll_mode == SCROLL_X || scroll_mode == SCROLL_Y || scroll_mode == SCROLL_X | SCROLL_Y)
				return new /Background(src, i, scroll_mode)
			else
				CRASH("[scroll_mode] is an invalid value for scroll_mode. Use zero or the SCROLL_X and SCROLL_Y constants.")

		// This proc exists to be overridden. By default it does
		// nothing but it's called from set_camera to give you a
		// chance to adjust the px/py of backgrounds every time
		// the camera moves.
		set_background()
