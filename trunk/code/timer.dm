
timer

	var/value

	New(value)
		src.value = value
		spawn while(src)
			value--
			if(value<=0)
				del src
			sleep(1)