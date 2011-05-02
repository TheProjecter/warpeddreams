mob
	player
		var/gridlocked=0
		bump(atom/a,d)
			if(istype(a,/mob/mechanism/pushable))
				var/mob/m = a
				m.pixel_move(vel_x*2, 0)
			..(a,d)

		key_down(k)
			if(k == "g")
				manage_grid()
			if(k == "x")
				interact()
			..()

		proc
			manage_grid()
				if(gridlocked)
					remove_grid()
				else
					load_grid()
				gridlocked = !gridlocked

			load_grid()
				//this is probably very inefficient
				for(var/xx=1 to world.maxx)
					for(var/yy=1 to world.maxy)
						var/image/i = new('other.dmi',locate(xx,yy,z),"screen_overlay")
						client.images += i

			remove_grid()
				client.images = new /list()

			interact()
				var/list/f = front(6)

				for(var/mob/mechanism/linkable/door/d in f)
					if(!d.locked)
						d.activate()
