
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

	// These verbs are called by the macros defined in common/keyboard.dmf
	verb
		KeyDown(k as text)
			set hidden = 1
			set instant = 1
			if(input_lock) return

			keys[k] = 1
			key_down(k)

		KeyUp(k as text)
			set hidden = 1
			set instant = 1

			keys[k] = 0
			if(input_lock) return

			key_up(k)

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
			var/windows = winget(src, null, "windows")
			var/macros = params2list(winget(src, windows, "macro"))

			var/list/keys = list("0","1","2","3","4","5","6","7","8","9","q","w","e","r","t","y","u","i","o","p","a","s","d","f","g","h","j","k","l","z","x","c","v","b","n","m","west","east","north","south","space","escape")
			for(var/m in macros)
				for(var/k in keys)
					winset(src, "[k]Down", "parent=[m];name=[k];command=KeyDown+\"[k]\"")
					winset(src, "[k]Up", "parent=[m];name=[k]+UP;command=KeyUp+\"[k]\"")