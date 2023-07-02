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

/obj/machinery/door_control/Initialize(mapload)
	. = ..()
	build_device()

/obj/machinery/door_control/Destroy()
	QDEL_NULL(device)
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

/obj/machinery/door_control/attack_ai(mob/user as mob)
	if(wires & 2)
		return attack_hand(user)
	else
		to_chat(user, "Error, no route to host.")

/obj/machinery/door_control/attackby(obj/item/W, mob/user as mob, params)
	if(istype(W, /obj/item/detective_scanner))
		return
	return ..()

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
	if(stat & (NOPOWER|BROKEN))
		return
	if(device?.cooldown > 0)
		return

	if(!allowed(user) && (wires & 1) && !user.can_advanced_admin_interact())
		to_chat(user, "<span class='warning'>Access Denied.</span>")
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
	if(stat & NOPOWER)
		icon_state = "[initial(icon_state)]-p"
	else
		icon_state = initial(icon_state)
