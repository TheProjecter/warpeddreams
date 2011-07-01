
// File:    camera.dm
// Library: Forum_account.Sidescroller
// Author:  Forum_account
//
// Contents:
//   This file handles all camera-related functionality. It
//   defines the Camera object, which contains all variables
//   needed to manage the mob's camera. This file also contains
//   the set_camera proc, which used to be in pixel-movement.dm.

Camera
	var
		const
			FOLLOW = 1
			SLIDE = 2

		// These are vars that you can freely modify
		px = 0
		py = 0
		lag = 0
		mode = FOLLOW

		minx = 0
		maxx = 320000
		miny = 0
		maxy = 320000

		// These are used by the default set_camera proc
		// because the user might modify px and py directly
		// which would otherwise interfere with the calculations
		// when mode = SLIDE. For example, suppose the user
		// overrides set_camera to move the camera up 100 pixels.
		// The next time set_camera's default behavior runs, it'll
		// try to move the camera down because the camera's py is
		// greater than the mob's.
		_px = 0
		_py = 0

		// These are used when mode = SLIDE, you shouldn't need
		// to modify these directly. In fact, doing so will most
		// likely cause problems.
		vel_x = 0
		vel_y = 0

mob
	var
		Camera/camera = new()

	proc
		// This sets the position of the client's eye and background image.
		set_camera()
			if(!client) return

			// (dx,dy) is the desired camera location, this is how we allow
			// for camera lag. The desired location can be up to camera.lag
			// pixels away from the player's coordinates.
			var/dx = px
			var/dy = py

			if(camera.lag)
				if(camera._px < px - camera.lag)
					dx = px - camera.lag
				else if(camera._px > px + camera.lag)
					dx = px + camera.lag
				else
					dx = camera._px

				if(camera._py < py - camera.lag)
					dy = py - camera.lag
				else if(camera._py > py + camera.lag)
					dy = py + camera.lag
				else
					dy = camera._py

			// We also use dx and dy to enforce the camera bounds. If dx or dy
			// are outside of the bounds, place them on the edge of the bounds.
			if(dx < camera.minx)
				dx = camera.minx
			else if(dx > camera.maxx)
				dx = camera.maxx

			if(dy < camera.miny)
				dy = camera.miny
			else if(dy > camera.maxy)
				dy = camera.maxy

			// if the camera is too far from the player, jump to the player's location
			if(abs(camera._px - px) > icon_width * 10 || abs(camera._py - py) > icon_height * 10)

				camera._px = dx
				camera._py = dy

			// otherwise, use whatever camera rules are selected
			else

				// follow mode is the default mode, it makes the
				// camera stick to the player's position
				if(camera.mode == camera.FOLLOW)

					camera._px = dx
					camera._py = dy

				// slide mode makes the camera follow the player, but
				// not as strictly as follow mode. The camera accelerates
				// and decelerates so it lags behind the player a little.
				else if(camera.mode == camera.SLIDE)

					if(camera._px < dx - 1)
						if(camera.vel_x < sqrt(dx - camera._px))
							camera.vel_x += 1
						else
							camera.vel_x -= 1

					else if(camera._px > dx + 1)
						if(camera.vel_x > -sqrt(camera._px - dx))
							camera.vel_x -= 1
						else
							camera.vel_x += 1

					else
						camera._px = dx
						camera.vel_x = 0

					if(camera._py < dy - 1)
						if(camera.vel_y < sqrt(dy - camera._py))
							camera.vel_y += 1
						else
							camera.vel_y -= 1

					else if(camera._py > dy + 1)
						if(camera.vel_y > -sqrt(camera._py - dy))
							camera.vel_y -= 1
						else
							camera.vel_y += 1

					else
						camera._py = dy
						camera.vel_y = 0

					camera._px += camera.vel_x
					camera._py += camera.vel_y

			// At this point we're done enforcing camera rules
			// so we can set the camera's px and py.
			camera.px = camera._px
			camera.py = camera._py

			// set_background is a proc the developer can override to
			// define custom background logic.
			set_background()

			// position all the backgrounds accordingly.
			for(var/Background/bg in backgrounds)

				if(!(bg.image in client.images))
					client.images += bg.image

				bg.object.loc = loc

				// position the background image so that
				var/bx = pixel_x + bg.px
				var/by = pixel_y + bg.py

				while(bx < -bg.width * 1.5)
					bx += bg.width
				while(bx > bg.width * -0.5)
					bx -= bg.width

				while(by < -bg.height * 1.5)
					by += bg.height
				while(by > bg.height * -0.5)
					by -= bg.height

				bg.object.pixel_x = bx + 16
				bg.object.pixel_y = by + 16