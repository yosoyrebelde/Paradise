/obj/item/assembly/control
	/// The control controls things that have matching id tag
	var/id = null
	/// Should it only work on the same z-level
	var/safety_z_check = TRUE

/obj/item/assembly/control/activate()
	// Do nothing if no id
	if(!id)
		return FALSE
	// Cooldown check
	return ..()

/obj/item/assembly/control/poddoor

/obj/item/assembly/control/poddoor/activate()
	if(!..())
		return
	for(var/obj/machinery/door/poddoor/M in GLOB.airlocks)
		if(safety_z_check && M.z != loc.z)
			continue
		if(M.id_tag != id)
			continue
		if(M.density)
			spawn(0)
				M.open()
		else
			spawn(0)
				M.close()

/obj/item/assembly/control/airlock
	/**
	Bitflag, 	1= open
				2= idscan
				4= bolts
				8= shock
				16= door safties
	*/
	var/specialfunctions = OPEN
	var/desiredstate = 0 // Zero is closed, 1 is open.

/obj/item/assembly/control/airlock/activate()
	if(!..())
		return
	for(var/obj/machinery/door/airlock/D in GLOB.airlocks)
		if(safety_z_check && D.z != loc.z)
			continue
		if(D.id_tag != id)
			continue
		if(specialfunctions & OPEN)
			if(D.density)
				spawn(0)
					D.open()
			else
				spawn(0)
					D.close()
		if(desiredstate == 1)
			if(specialfunctions & IDSCAN)
				D.aiDisabledIdScanner = 1
			if(specialfunctions & BOLTS)
				D.lock()
			if(specialfunctions & SHOCK)
				D.electrify(-1)
			if(specialfunctions & SAFE)
				D.safe = 0
		else
			if(specialfunctions & IDSCAN)
				D.aiDisabledIdScanner = 0
			if(specialfunctions & BOLTS)
				D.unlock()
			if(specialfunctions & SHOCK)
				D.electrify(0)
			if(specialfunctions & SAFE)
				D.safe = 1
	desiredstate = !desiredstate

/obj/item/assembly/control/ticket_machine

/obj/item/assembly/control/ticket_machine/activate()
	if(!..())
		return
	for(var/obj/machinery/ticket_machine/M in GLOB.machines)
		if(M.id != id)
			continue
		M.increment()