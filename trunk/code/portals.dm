turf/LeftClick(mob/player/m)
	if(is_portalable)
		m.set_up_portals(1,new /mob/portal(src))

turf/RightClick(mob/player/m)
	if(is_portalable)
		m.set_up_portals(2,new /mob/portal(src))

turf/LeftShiftClick(mob/player/m)
	RightClick(m)

turf/var/is_portalable=1
turf/wall/is_portalable=0

mob
	var/mob/portal/last_portal

	player
		bump(atom/a,d)
			if(istype(a,/mob/pushable))
				var/mob/m = a
				m.pixel_move(vel_x*2, 0)
			..(a,d)

		move(direction)
			..(direction)
			for(var/mob/portal/e in oview(1,src))
				if(!e.inside(src) && e==last_portal)
					last_portal=null
					break

		gravity()
			if(vel_y<-20)vel_y=-20
			if(vel_y>20) vel_y=20
			..()

		var/mob/portal
			portal1
			portal2

		proc
			set_up_portals(num, mob/portal/p)
				if(vars["portal[num]"]) del vars["portal[num]"]
				vars["portal[num]"] = p

				//set up links
				if(portal1 && portal2)
					portal1.linked = portal2
					portal2.linked = portal1
				else if(portal1)
					portal1.linked=null
				else if(portal2)
					portal2.linked=null

				//set up icons
				if(portal1)
					portal1.icon_state="red[portal1.linked?"-motion":""]"

				if(portal2)
					portal2.icon_state="blue[portal2.linked?"-motion":""]"

	portal
		icon='portals.dmi'
		density=1
		movement()
		pheight=32
		pwidth=32
		var/mob/portal/linked

	movement()
		..()

		for(var/mob/portal/e in oview(1,src))
			if(e.inside(src) && e.linked && e!=last_portal)
				loc = e.linked.loc
				last_portal = e.linked
				break

world/mob = /mob/player