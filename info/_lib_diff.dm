/*
platforms.dm:
19			start_px = px
20			end_px = px + 80
->
19			if(!start_px)start_px = px
20			if(!end_px)end_px = px + 80


mob-movement.dm:
17		K_RIGHT = "east"
18		K_LEFT = "west"
19		K_UP = "north"
20		K_DOWN = "south"
->
17		K_RIGHT = "d"
18		K_LEFT = "a"
19		K_UP = "w"
20		K_DOWN = "s"

pixel-movement.dm:
->
124			if(istype(a, /mob/mechanism))
125				return a.density

anywhere:
->
mob/mechanism
*/