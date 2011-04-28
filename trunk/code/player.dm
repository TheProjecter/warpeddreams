mob
	player
		bump(atom/a,d)
			if(istype(a,/mob/mechanism/pushable))
				var/mob/m = a
				m.pixel_move(vel_x*2, 0)
			..(a,d)