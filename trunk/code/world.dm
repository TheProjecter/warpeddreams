

world
	mob = /mob/player
	name = "Warped Dreams"

atom/icon='other.dmi'

client
	verb
		toggle_windows()
			if(winget(src, "output1","is-visible")=="true")
				winset(src, "output1", "is-visible=false")
				winset(src, "input1", "is-visible=false")
			else
				winset(src, "output1", "is-visible=true")
				winset(src, "input1", "is-visible=true")

		say(text as message)
			world << "[src]: [text]"

	view = 8