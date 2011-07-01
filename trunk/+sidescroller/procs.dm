
// File:    procs.dm
// Library: Forum_account.Sidescroller
// Author:  Forum_account
//
// Contents:
//   This file contains helper procs. These procs aren't
//   as essential as other procs in the library (the library
//   will run without most of them) but they're useful to
//   people who will use the library.

atom
	proc
		// This proc is used by pixel-movement.dm to check a potential move
		// without actually performing it. For instance, when checking if a
		// mob can move to the right two pixels, we might call:
		//
		//   obstacle.inside(mob.px + 2, mob.py, mob.pwidth, mob.pheight)
		//
		// This way we check if the mob would hit the obstacle without having
		// to modify the mob's px and py variables.
		inside4(qx,qy,qw,qh)
			if(qx <= px - qw) return 0
			if(qx >= px + pwidth) return 0
			if(qy <= py - qh) return 0
			if(qy >= py + pheight) return 0
			return 1

		// The inside proc has multiple behaviors that depend on the arguments
		// passed to it:
		//
		// No args: Returns a list of all atoms that overlap src.
		// 1 arg:   Returns 1 if the arg is an atom inside src, returns 0 otherwise.
		// 4 args:  Returns 1 if src overlaps the box defined by the 4 args, returns 0 otherwise.
		//
		// The inside4 helper proc is called to handle the last case.
		inside()
			if(!args || args.len == 0)
				. = list()
				for(var/atom/a in view(1,src))
					if(a == src) continue
					if(a.inside4(px, py, pwidth, pheight))
						. += a
			else if(args.len == 4)
				return inside4(arglist(args))
			else if(args.len == 1)
				var/atom/a = args[1]
				if(!istype(a)) return 0
				return a.inside4(px, py, pwidth, pheight)

	proc
		// Calls left, right, top, or bottom based on src's direction.
		front(d)
			if(dir == NORTH)
				return top(d)
			else if(dir == SOUTH)
				return bottom(d)
			else if(dir == EAST)
				return right(d)
			else if(dir == WEST)
				return left(d)
			else
				CRASH("Invalid direction")

		// The left proc returns a list of all atoms
		// within w pixels of src's left side.
		//
		//     +---------+-----------+
		//     |         |           |
		//     |<-- w -->|           |
		//     |         |    src    |
		//     |         |           |
		//     |         |           |
		//     |         |           |
		//     +---------+-----------+
		left(w)
			. = list()
			for(var/atom/a in oview(1,src))
				if(a.inside(px - w, py, w, pheight))
					. += a

		// Returns a list of atoms within w pixels of src's right side.
		right(w)
			. = list()
			for(var/atom/a in oview(1,src))
				if(a.inside(px + pwidth, py, w, pheight))
					. += a

		// Returns a list of atoms within h pixels of src's top side.
		top(h)
			. = list()
			for(var/atom/a in oview(1,src))
				if(a.inside(px, py + pheight, pwidth, h))
					. += a

		// Returns a list of atoms within h pixels of src's bottom side.
		bottom(h)
			. = list()
			for(var/atom/a in oview(1,src))
				if(a.inside(px, py - h, pwidth, h))
					. += a

		// Returns a list of all atoms within one tile of src. The
		// contents of your loc are listed first, next are tiles in
		// the cardinal directions (up, down, left, right), last are
		// the diagonals.
		nearby()
			. = list()
			. += loc
			. += loc.contents

			var/turf/t = locate(x,y-1,z)
			if(t) { . += t; . += t.contents }

			t = locate(x-1,y,z)
			if(t) { . += t; . += t.contents }

			t = locate(x+1,y,z)
			if(t) { . += t; . += t.contents }

			t = locate(x,y+1,z)
			if(t) { . += t; . += t.contents }

			t = locate(x-1,y-1,z)
			if(t) { . += t; . += t.contents }

			t = locate(x+1,y-1,z)
			if(t) { . += t; . += t.contents }

			t = locate(x-1,y+1,z)
			if(t) { . += t; . += t.contents }

			t = locate(x+1,y+1,z)
			if(t) { . += t; . += t.contents }

			. -= src

mob
	proc
		// Returns 1 if a list of atoms contains a single bumpable atom
		// and returns 0 otherwise.
		dense(list/l)
			for(var/atom/a in l)
				if(can_bump(a))
					return 1
			return 0

		// Returns 1 if the mob is within d pixels of the edge it is facing and
		// returns 0 otherwise.
		// For example:
		//
		//     m1       m2
		// ###############
		//
		// m1 is not at the edge of the platform. If m2 is facing right then it is
		// at the edge. The "edge" can be loosely defined by saying "if the mob keeps
		// moving, pretty soon it'll fall". More technically, being within d pixels
		// of the edge means that the mob's side that is closest to the edge is less
		// than (or equal to) d.
		at_edge(d = 0)
			var/turf/t
			if(dir == RIGHT)
				/*
				// the old method (which didn't support the parameter d):
				if((px + pwidth) % 32 == 0)
				*/
				if(x * icon_width + icon_width - (px + pwidth) <= d)
					t = locate(x+1, y-1, z)

			else if(dir == LEFT)
				/*
				// the old method (which didn't support the parameter d):
				// if(px % 32 <= d)
				*/
				if(px - (x * icon_width) <= d)
					t = locate(x-1, y-1, z)

			if(t)
				if(!can_bump(t))
					return 1
			return 0

		// Makes src turn to face the specified atom
		face(atom/a)
			// if you're to the left of a
			if(px + pwidth / 2 < a.px + a.pwidth / 2)
				dir = RIGHT
			// otherwise you're to the right of a
			else
				dir = LEFT

		turn_around()
			vel_x = -vel_x
			dir = turn(dir, 180)

		knockback(atom/a, magnitude = 4)
			// if you're to the left of a
			if(px + pwidth / 2 < a.px + a.pwidth / 2)
				vel_x = -magnitude
			// otherwise you're to the right of a
			else
				vel_x = magnitude

			// if you're below a
			if(py + pheight < a.py)
				vel_y = -magnitude
			// otherwise you're above a
			else
				vel_y = magnitude