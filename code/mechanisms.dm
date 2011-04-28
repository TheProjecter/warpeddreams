
mob
	mechanism

		density=1
		icon='other.dmi'
		set_state()

		pushable
			box
				icon='icons.dmi'
				icon_state="box"

				pwidth=16
				pheight=16

		linkable
			button
				pheight=4
				pwidth=16
				stepped_on(mob/m)
					//button, button_pressed

		spring
			pheight=1
			pwidth=16
			offset_x=8
			pixel_x =8
			icon_state="spring"

			stepped_on(mob/m)
				//make it trig on entered, so it can be level with the ground
				//figure out why downard velocity is 0 sometimes
				//check library for hardcoded gravity stuff
				icon_state="spring_pressed"
				spawn(2)
					icon_state="spring"
				if(m.vel_y)
					m.vel_y = -m.vel_y

				else
					m.vel_y = 10
