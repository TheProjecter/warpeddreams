
world
	view = 6

	New()
		SIDESCROLLER_DEBUG = 1
		..()

atom
	icon = 'icons.dmi'

mob
	base_state = "mob"

	var
		invulnerable = 0

	Login()
		..()

		pwidth = 24
		pheight = 24

		src << "Use the arrow keys to move and the space bar to jump. Press X to interact with objects."

	movement()
		..()

		// check if you hit an enemy
		if(client)
			// if you're still temporarily invulnerable then just make the
			// player flicker.
			if(world.time < invulnerable)
				invisibility = !invisibility
			else
				invisibility = 0

				for(var/mob/enemy/e in oview(1,src))
					if(e.inside(src))

						// knock the player away from the enemy.
						knockback(e)

						// make the player invulnerable for one second
						invulnerable = world.time + 10
						break

	key_down(k)
		if(k == "x")
			interact()
		..()

	proc
		interact()
			// front(4) returns a list of all atoms within 4 pixels
			// of your mob in the direction you're facing.
			var/list/f = front(6)

			for(var/mob/m in f)
				m.vel_y += 5

			for(var/turf/door/d in f)
				d.open()

turf
	icon_state = "white"

	ladder
		icon_state = "ladder"
		ladder = 1

	wall
		density = 1
		icon_state = "wall"

		New()
			..()
			if(type == /turf/wall)
				var/n = 0
				var/turf/t = locate(x,y+1,z)
				if(t && istype(t,type)) n += 1
				t = locate(x+1,y,z)
				if(t && istype(t,type)) n += 2
				t = locate(x,y-1,z)
				if(t && istype(t,type)) n += 4
				t = locate(x-1,y,z)
				if(t && istype(t,type)) n += 8
				icon_state = "wall-[n]"

	door
		density = 1
		icon_state = "door-closed"
		var
			// 0 = closed, 1 = transition, 2 = open
			state = 0

		proc
			open()
				// open() can only work if the door is closed to begin with
				if(state != 0) return

				// switch to the transition state, play an animation,
				// and change the door's density.
				state = 1
				flick("door-opening", src)
				icon_state = "door-open"

				spawn(6 * world.tick_lag)
					state = 2
					density = 0

				spawn(20)
					close()

			close()
				// close() can only work if the door is open to begin with
				if(state != 2) return

				// If there's a mob in the doorway it can't close. Wait one
				// second and try again.
				if(locate(/mob) in inside())
					spawn(10) close()
					return

				// switch to the transition state, play an animation,
				// and change the door's density.
				state = 1
				density = 1
				flick("door-closing", src)
				icon_state = "door-closed"

				spawn(6 * world.tick_lag)
					state = 0