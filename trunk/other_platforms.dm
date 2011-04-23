mob/platform
	vertical
		dir=NORTH
		movement()
			if(dir == NORTH)
				pixel_move(0,2)
				for(var/mob/m in riders)
					m.pixel_move(0,2)

				if(py > end_px)
					dir = SOUTH

			else
				pixel_move(0,-2)
				for(var/mob/m in riders)
					m.pixel_move(0,-2)

				if(py <= start_px)
					dir = NORTH

		New()
			..()
			start_px = py
			end_px = py+80