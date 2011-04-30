
mob
	mechanism

		var/activated

		density=1
		icon='other.dmi'
		set_state()
		New()
			..()
			px += offset_x
			pixel_x = offset_x
			py += offset_y
			pixel_y = offset_y

		pushable
			box
				icon='icons.dmi'
				icon_state="box"

				pwidth=16
				pheight=16

		linkable
			var/mob/mechanism/linkable/link
			proc
				activate(mob/m)
				deactivate(mob/m)
			New()
				..()
				for(var/mob/mechanism/linkable/o in world)
					if(o!=src && o.link == link)
						o.link = src
						link = o
			button
				pheight=4
				pwidth=16
				offset_x = 8

				//this is a test link, normally you would set it to a unique value in the map editor
				link=1


				icon_state="button"
				set_state()
				stepped_on(mob/m)
					pheight=1
					icon_state="button_pressed"
					if(link)
						var/mob/mechanism/linkable/linked = link
						linked.activate(m)
						//link.activate(m)
				stepped_off(mob/m)
					pheight=4
					icon_state="button"
					if(link)
						var/mob/mechanism/linkable/linked = link
						linked.deactivate(m)

			door
				var/locked = 0

				icon_state = "door-unlocked-closed"
				var
					// 0 = closed, 1 = transition, 2 = open
					state = 0

				activate(mob/m)
					if(state != 0) return

					state = 1
					flick("door-[locked?"locked-":"unlocked-"]opening", src)
					icon_state = "door-[locked?"locked-":"unlocked-"]open"

					spawn(6 * world.tick_lag)
						state = 2
						density = 0

					if(!locked)
						spawn(20)
							deactivate()

				deactivate()
					if(state != 2) return

					if(locate(/mob) in inside())
						spawn(10) deactivate()
						return

					state = 1
					density = 1
					flick("door-[locked?"locked-":"unlocked-"]closing", src)
					icon_state = "door-[locked?"locked-":"unlocked-"]closed"

					spawn(6 * world.tick_lag)
						state = 0

				locked
					//this is a test link, normally you would set it to a unique value in the map editor
					link=1

					locked=1
					icon_state="door-locked-closed"

		spring
			spring_pretty
				icon_state="spring"
				pheight=1
				density=0
			pheight=32
			pwidth=32
			density=1
			icon_state="wall"

			var/boost = 15

			stepped_on(mob/m)
				if(istype(m,/mob/mechanism/spring)) return
				spawn for(var/atom/o in top(5))
					if(istype(o,/mob/mechanism/spring))
						o.icon_state="spring_pressed"
						spawn(2)
							o.icon_state="spring"

				if(m.vel_y && m.vel_y < 0)
					m.vel_y = -m.vel_y

				else
					m.vel_y = boost
