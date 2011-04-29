mob
	enemy
		pwidth = 24
		pheight = 24
		icon_state = "enemy"

		vel_x = 1
		dir = RIGHT

		bump(atom/a, d)
			// when the enemy bumps into a wall, make them turn around
			if(d == LEFT || d == RIGHT)
				turn_around()

		set_state()
			icon_state = "enemy"

		movement()

			// if the enemy is at the edge of a platform make them turn around
			if(at_edge())
				turn_around()

			..()
