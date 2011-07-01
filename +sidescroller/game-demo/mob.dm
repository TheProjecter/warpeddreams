
world
	view = 6

	New()
		SIDESCROLLER_DEBUG = 1
		..()

mob
	base_state = "mob"
	var
		turf/saved_location
		dead = 0

	Login()
		..()

		loc = locate(2,2,1)
		saved_location = loc

		pwidth = 24
		pheight = 24

	proc
		die()
			if(dead) return

			src << "You died! You will respawn shortly."
			dead = 1
			clear_input()
			lock_input()

			spawn(20)
				set_pos(32 * saved_location.x, 32 * saved_location.y)

				clear_input()
				unlock_input()
				dead = 0