mob
	player
		bump(atom/a,d)
			if(istype(a,/mob/mechanism/pushable))
				var/mob/m = a
				m.pixel_move(vel_x*2, 0)
			..(a,d)
		key_down(k)
			if(k == "x")
				interact()
			..()

		proc
			interact()
				var/list/f = front(6)

				for(var/mob/m in f)
					m.vel_y += 5

				for(var/mob/mechanism/linkable/door/d in f)
					if(!d.locked)
						d.activate()
