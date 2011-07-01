
// File:    keyboard.dm
// Library: Forum_account.Sidescroller
// Author:  Forum_account
//
// Contents:
//   This file handles keyboard input. It adds keyboard macros
//   at runtime which call the KeyUp and KeyDown verbs. These
//   verbs call the key_up and key_down procs which you can
//   override to create new input behavior.

mob
	var
		list/keys = list()
		input_lock = 0
		jumped = 0
		dropped = 0

		holding_left = 0
		holding_right = 0

	proc
		// You can override the key_down and key_up procs
		// to add new commands.
		key_down(k)
			if(k == K_JUMP)
				if(keys[K_DOWN])
					drop()
				else
					jumped = 1

		key_up(k)

			// Unlike jumping, we keep the dropped flag set
			// for the entire time you hold the key. This
			// way you can drop through multiple scaffolds by
			// just holding the keys (down+jump).
			if(k == K_JUMP)
				dropped = 0

			..(k)

		// While input is locked the KeyUp/KeyDown verbs still get called
		// but they don't call the key_up/key_down procs.
		lock_input()
			input_lock += 1

		unlock_input()
			input_lock -= 1
			if(input_lock < 0)
				input_lock = 0

		clear_input(unlock_input = 1)
			if(unlock_input)
				input_lock = 0
			for(var/k in keys)
				keys[k] = 0

	// These verbs are called for all key press and release events,
	// k is the key being pressed or released.
	verb
		KeyDown(k as text)
			set hidden = 1
			set instant = 1
			if(input_lock) return

			if(trace) trace.event("[world.time]: key_down: k = [k]")

			keys[k] = 1
			key_down(k)

			// If you're holding the left key and press right, we want
			// to set keys[K_LEFT] = 0 because, most of the time, you
			// don't want to be holding both. You want to move in the
			// last direction you pressed.
			// We use the holding_left/right vars to remember the key
			// was being pressed, so when you release the other arrow
			// we can restore the value in the keys list.
			if(k == K_RIGHT)
				holding_right = 1
				if(keys[K_LEFT])
					keys[K_LEFT] = 0

			else if(k == K_LEFT)
				holding_left = 1
				if(keys[K_RIGHT])
					keys[K_RIGHT] = 0

		KeyUp(k as text)
			set hidden = 1
			set instant = 1

			if(trace) trace.event("[world.time]: key_up: k = [k]")

			keys[k] = 0
			if(input_lock) return

			key_up(k)

			if(k == K_RIGHT)
				holding_right = 0
				if(holding_left)
					keys[K_LEFT] = 1

			else if(k == K_LEFT)
				holding_left = 0
				if(holding_right)
					keys[K_RIGHT] = 1

client
	New()
		. = ..()
		set_macros()

	proc
		// This proc defines keyboard macros for pressing and releasing
		// the following keys: 0-9, a-z, arrow keys, space bar. These
		// macros take the place of the pre-defined macros in the old
		// common\keyboard.dmf file but they work exactly the same: they
		// call the mob's KeyUp and KeyDown verbs.
		//
		// If you don't like the idea of dynamically creating macros you
		// can hardcode them like they used to be. It'll work the same it's
		// just more tedious. This method makes the library more flexible
		// as you can now use your own interface file without losing the
		// pre-defined macros.
		set_macros()
			// var/windows = winget(src, null, "windows")
			// var/macros = params2list(winget(src, windows, "macro"))

			// This should get us the list of all macro sets that
			// are used by all windows in the interface. We can cut
			// out the first winget call to get the set of windows.
			var/macros = params2list(winget(src, null, "macro"))

			var/list/keys = list("0","1","2","3","4","5","6","7","8","9","q","w","e","r","t","y","u","i","o","p","a","s","d","f","g","h","j","k","l","z","x","c","v","b","n","m","west","east","north","south","northeast","northwest","southeast","southwest","space","escape","return","center","tab","F1","F2","F3","F4","F5","F6","F7","F8","F9","F10","F11","F12",)
			for(var/m in macros)
				for(var/k in keys)
					winset(src, "[m][k]Down", "parent=[m];name=[k];command=KeyDown+\"[k]\"")
					winset(src, "[m][k]Up", "parent=[m];name=[k]+UP;command=KeyUp+\"[k]\"")
