/obj/machinery/door_control
	name = "remote door-control"
	desc = "A remote control-switch for a door."
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "doorctrl"
	power_channel = ENVIRON

	anchored = TRUE
	use_power = IDLE_POWER_USE
	idle_power_usage = 2
	active_power_usage = 4

	var/exposedwires = 0
	/**
	Bitflag,	1=checkID
				2=Network Access
	*/
	var/wires = 3

	var/obj/item/assembly/device
	var/obj/item/access_control/access_board
	/// Was it constructed by players or just spawned on the map.
	/// Needed because the button can be spawned without a device and still has to work.
	var/constructed = FALSE
	var/opened = FALSE

	/*
	Variables that are only needed to generate a device object.
	*/
 	/// 0- poddoor control, 1- airlock control
	var/normaldoorcontrol = 0
	/// The button controls things that have matching id tag
	var/id = null
	/// Should it only work on the same z-level
	var/safety_z_check = 1
	/// Zero is closed, 1 is open.
	var/desiredstate = 0
	/// Bitflag, see assembly file
	var/specialfunctions = 1

/obj/machinery/door_control/alt
	icon_state = "altdoorctrl"

/obj/machinery/door_control/Initialize(mapload, direction = null, building = FALSE)
	. = ..()
	if(building)
		opened = TRUE
		setDir(direction)
		set_pixel_offsets_from_dir(26, -26, 26, -26)
		update_icon()

/obj/machinery/door_control/Destroy()
	QDEL_NULL(device)
	QDEL_NULL(access_board)
	return ..()

/obj/machinery/door_control/proc/build_device()
	if(normaldoorcontrol)
		var/obj/item/assembly/control/airlock/airlock_device = new(src)
		airlock_device.specialfunctions = specialfunctions
		airlock_device.desiredstate = desiredstate
		device = airlock_device
	else
		var/obj/item/assembly/control/poddoor/poddoor_device = new(src)
		device = poddoor_device
	var/obj/item/assembly/control/my_device = device
	my_device.id = id
	my_device.safety_z_check = safety_z_check

/obj/machinery/door_control/proc/build_access_board()
	access_board = new /obj/item/access_control(src)
	access_board.selected_accesses = req_access
	access_board.one_access = check_one_access

/obj/machinery/door_control/proc/update_access()
	if(access_board) // TODO: handle emagged board
		req_access = access_board.selected_accesses
		check_one_access = access_board.one_access
	else
		req_access = list()

/obj/machinery/door_control/attack_ai(mob/user as mob)
	if(opened)
		return
	if(wires & 2)
		return attack_hand(user)
	else
		to_chat(user, "Error, no route to host.")

/obj/machinery/door_control/attackby(obj/item/W, mob/user as mob, params)
	if(istype(W, /obj/item/detective_scanner))
		return
	if(opened)
		if(is_pen(W))
			rename_interactive(user, W)
			return

		if(!device && isassembly(W))
			if(user.drop_transfer_item_to_loc(W, src))
				user.visible_message("[user] installs [W] into the button frame.", "You install [W] into the button frame.")
				device = W

				// ignore "readiness" of the assembly to not confuse players with multiple assembly states
				if(!device.secured)
					device.toggle_secure()

				update_icon()
				return
			else
				user.visible_message("[user] tries to install [W] into the button frame.", "You try to install [W] into the button frame.")
				return
		
		if(!access_board && istype(W, /obj/item/access_control))
			if(user.drop_transfer_item_to_loc(W, src))
				user.visible_message("[user] installs [W] into the button frame.", "You install [W] into the button frame.")
				access_board = W
				update_icon()
				return
			else
				user.visible_message("[user] tries to install [W] into the button frame.", "You try to install [W] into the button frame.")
				return
	return ..()

/obj/machinery/door_control/screwdriver_act(mob/living/user, obj/item/I)
	if(!(opened && allowed(user)))
		to_chat(user, span_warning("Access Denied. The cover plate will not open."))
		return
	if(!I.use_tool(src, user, 0, volume = I.tool_volume))
		return
	. = TRUE

	if(opened)
		SCREWDRIVER_CLOSE_PANEL_MESSAGE
		constructed = TRUE
		opened = FALSE
		update_access()
		update_icon()
		return

	// Lazy init
	if(!constructed)
		if(!device)
			build_device()
		if(!access_board)
			build_access_board()
	
	SCREWDRIVER_OPEN_PANEL_MESSAGE
	opened = TRUE
	update_icon()

/obj/machinery/door_control/wrench_act(mob/living/user, obj/item/I)
	if(!opened)
		return
	if(device || access_board)
		to_chat(user, "You must take out the electronics first.")
		return
	. = TRUE
	if(!I.use_tool(src, user, 0, volume = I.tool_volume))
		return
	WRENCH_UNANCHOR_WALL_MESSAGE
	new /obj/item/mounted/frame/door_control(get_turf(user))
	qdel(src)

/obj/machinery/door_control/emag_act(user as mob)
	if(!emagged)
		emagged = 1
		req_access = list()
		playsound(src, "sparks", 100, TRUE, SHORT_RANGE_SOUND_EXTRARANGE)

/obj/machinery/door_control/attack_ghost(mob/user)
	if(user.can_advanced_admin_interact())
		return attack_hand(user)

/obj/machinery/door_control/attack_hand(mob/user as mob)
	add_fingerprint(user)

	if(opened)
		if(!(device || access_board))
			return
		if(device)
			device.forceMove_turf()
			user.put_in_hands(device, ignore_anim = FALSE)
			device.add_fingerprint(user)
			device = null
		if(access_board)
			access_board.forceMove_turf()
			user.put_in_hands(access_board, ignore_anim = FALSE)
			access_board.add_fingerprint(user)
			access_board = null
		user.visible_message("[user] takes out the electronics from the button frame.", "You take out the electronics from the button frame.")
		update_icon()
		return

	if(stat & (NOPOWER|BROKEN))
		return

	// Lazy init
	if(!device && !constructed)
		build_device()

	if(device?.cooldown > 0)
		return

	if(!allowed(user) && (wires & 1) && !user.can_advanced_admin_interact())
		to_chat(user, span_warning("Access Denied."))
		flick("[initial(icon_state)]-denied",src)
		playsound(src, pick('sound/machines/button.ogg', 'sound/machines/button_alternate.ogg', 'sound/machines/button_meloboom.ogg'), 20)
		return

	use_power(5)
	icon_state = "[initial(icon_state)]-inuse"
	addtimer(CALLBACK(src, PROC_REF(update_icon)), 15)

	if(device)
		INVOKE_ASYNC(device, TYPE_PROC_REF(/obj/item/assembly, activate))

/obj/machinery/door_control/power_change()
	..()
	update_icon()

/obj/machinery/door_control/update_icon()
	overlays.Cut()

	// Panel opened
	if(opened)
		icon_state = "doorctrl-open"

		// access_board overlay
		if(access_board)
			overlays += "doorctrl-overlay-board"
		
		// device overlay
		if(issignaler(device))
			overlays += "doorctrl-overlay-signaler"
		else if(device)
			overlays += "doorctrl-overlay-device"
	
	// Panel closed
	else if(stat & NOPOWER)
		icon_state = "[initial(icon_state)]-p"
	else
		icon_state = initial(icon_state)
