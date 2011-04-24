mob
	player
		bump(atom/a,d)
			if(istype(a,/mob/pushable))
				var/mob/m = a
				m.pixel_move(vel_x*2, 0)
			..(a,d)
			/*
			if(istype(a,/mob/portal))
				var/mob/portal/e = a
				world << 1
				if(e.linked && e!=last_portal)
					world << 2
					loc = e.linked.loc
					last_portal = e.linked
					..(a,d)
			*/