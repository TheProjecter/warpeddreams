mob

	var/health=100
	can_bump(atom/a)
		if(istype(a,/mob/mechanism))
			return a.density
		return ..()

	player
		var/gridlocked=0
		var/damaged
		bump(atom/a,d)
			if(istype(a,/mob/mechanism))
				var/mob/mechanism/m = a
				if(istype(a,/mob/mechanism/pushable))
					m.pixel_move(vel_x*2, 0)
				if(m.damage)
					hurt(m)
			..(a,d)

		key_down(k)
			switch(k)
				if("g")
					manage_grid()
				if("x")
					interact()
			..()
/*		stepped_on(mob/a)
			if(istype(a,/mob/mechanism))
				var/mob/mechanism/m = a
				if(m.damage)
					hurt(m)
			..(a)*/

		proc
			manage_grid()
				if(gridlocked)
					remove_grid()
				else
					load_grid()
				gridlocked = !gridlocked

			load_grid()
				//this is probably very inefficient, but for now, it works
				for(var/xx=1 to world.maxx)
					for(var/yy=1 to world.maxy)
						var/turf/t = locate(xx,yy,z)
						if(!istype(t,/turf/wall) || !t.is_portalable)
							var/image/i = new('other.dmi',t,"target",10)
							client.images += i

			remove_grid()
				client.images = new /list()

			interact()
				var/list/f = front(6)

				for(var/mob/mechanism/linkable/door/d in f)
					if(!d.locked)
						d.activate()
			hurt(var/mob/mechanism/a)
				if(damaged) return
				damaged++
				var/harm = (abs(a.vel_x)+abs(a.vel_y))*a.damage
				if(harm==0)
					damaged = 0
					return
				health-=harm
				for(var/turf/x in view(src,20))
					var/image/red = new('other.dmi',x,"red",20)
					client.images+=red
					spawn(5) client.images-=red
				spawn(10)damaged--
				die()
