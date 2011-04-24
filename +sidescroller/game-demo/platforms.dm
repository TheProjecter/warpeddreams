mob
	platform
		icon_state = "moving-platform"

		pwidth = 32
		pheight = 16

		dir = EAST

		var
			start_px
			end_px

		New()
			..()
			py += 16

			// start_px and end_bs determine the platform's range of movement
			if(!start_px)start_px = px
			if(!end_px)end_px = px + 80

		movement()

			// move right
			if(dir == EAST)
				pixel_move(2,0)
				for(var/mob/m in riders)
					m.pixel_move(2,0)

				// When we reach end_px, start moving the other way
				if(px >= end_px)
					dir = WEST

			else
				pixel_move(-2,0)
				for(var/mob/m in riders)
					m.pixel_move(-2,0)
				if(px <= start_px)
					dir = EAST

		stepped_on(mob/m)
			if(m.platform == src) return ..()
			if(m.platform)
				m.platform.riders -= m

			riders += m
			m.platform = src

		can_bump(mob/m)
			if(istype(m))
				return m.client

		// We only need to worry about x_bump because the platform only moves horizontally
		bump(mob/m, d)
			// if the platform bumped into a mob, try to move that mob out of the way
			if(istype(m))
				if(d == EAST)
					// if this causes the mob to move
					if(m.pixel_move(2,0))
						// try making the platform move again
						pixel_move(2,0)
				else
					if(m.pixel_move(-2,0))
						pixel_move(-2,0)