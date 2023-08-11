//Simple borg hand.
//Limited use.
/obj/item/gripper
	name = "magnetic gripper"
	desc = "A simple grasping tool for synthetic assets."
	icon = 'icons/obj/device.dmi'
	icon_state = "gripper"

	//Has a list of items that it can hold.
	var/list/can_hold = list(
		/obj/item/firealarm_electronics,
		/obj/item/airalarm_electronics,
		/obj/item/airlock_electronics,
		/obj/item/firelock_electronics,
		/obj/item/intercom_electronics,
		/obj/item/apc_electronics,
		/obj/item/tracker_electronics,
		/obj/item/access_control,
		/obj/item/stock_parts,
		/obj/item/vending_refill,
		/obj/item/mounted/frame/light_fixture,
		/obj/item/mounted/frame/apc_frame,
		/obj/item/mounted/frame/alarm_frame,
		/obj/item/mounted/frame/firealarm,
		/obj/item/mounted/frame/newscaster_frame,
		/obj/item/mounted/frame/intercom,
		/obj/item/mounted/frame/extinguisher,
		/obj/item/mounted/frame/light_switch,
		/obj/item/mounted/frame/door_control,
		/obj/item/rack_parts,
		/obj/item/camera_assembly,
		/obj/item/tank,
		/obj/item/circuitboard,
		/obj/item/stack/tile/light,
		/obj/item/stack/ore/bluespace_crystal
	)

	//Item currently being held.
	var/obj/item/gripped_item = null

/obj/item/gripper/medical
	name = "medical gripper"
	desc = "A grasping tool used to hold organs and help patients up once surgery is complete."
	can_hold = list(/obj/item/organ,
					/obj/item/reagent_containers/iv_bag,
					/obj/item/robot_parts/head,
					/obj/item/robot_parts/l_arm,
					/obj/item/robot_parts/r_arm,
					/obj/item/robot_parts/l_leg,
					/obj/item/robot_parts/r_leg,
					/obj/item/robot_parts/chest,
					/obj/item/stack/sheet/mineral/plasma) //for repair plasmamans

/obj/item/gripper/medical/attack_self(mob/user)
	return

/obj/item/gripper/medical/afterattack(atom/target, mob/living/user, proximity, params)
	var/mob/living/carbon/human/H
	if(!gripped_item && proximity && target && ishuman(target))
		H = target
		if(H.lying)
			H.AdjustSleeping(-10 SECONDS)
			if(!H.IsSleeping())
				H.StopResting()
			H.AdjustParalysis(-6 SECONDS)
			H.AdjustStunned(-6 SECONDS)
			H.AdjustWeakened(-6 SECONDS)
			playsound(user.loc, 'sound/weapons/thudswoosh.ogg', 50, 1, -1)
			user.visible_message( \
				"<span class='notice'>[user] shakes [H] trying to wake [H.p_them()] up!</span>",\
				"<span class='notice'>You shake [H] trying to wake [H.p_them()] up!</span>",\
				)
		return
	..()

/obj/item/gripper/service
	name = "Card gripper"
	desc = "A grasping tool used to take IDs for paying taxes and waking up drunken crewmates"
	can_hold = list(/obj/item/card,
					/obj/item/camera_film,
					/obj/item/paper,
					/obj/item/photo,
					/obj/item/toy/plushie)

/obj/item/gripper/service/afterattack(atom/target, mob/living/user, proximity, params)
	if(!gripped_item && proximity && target && ishuman(target))
		var/mob/living/carbon/human/H = target
		if(H.lying)
			H.AdjustSleeping(-10 SECONDS)
			if(!H.IsSleeping())
				H.StopResting()
			H.AdjustParalysis(-6 SECONDS)
			H.AdjustStunned(-6 SECONDS)
			H.AdjustWeakened(-6 SECONDS)
			playsound(user.loc, 'sound/weapons/thudswoosh.ogg', 50, 1, -1)
			user.visible_message( \
				"<span class='notice'>[user] shakes [H] trying to wake [H.p_them()] up!</span>",\
				"<span class='notice'>You shake [H] trying to wake [H.p_them()] up!</span>",\
				)
		return
	..()

/obj/item/gripper/cogscarab
	name = "ancient gripper"
	desc = "A brass grasping tool for supporting workmates."
	icon = 'icons/obj/device.dmi'
	icon_state = "clock_gripper"

/obj/item/gripper/cogscarab/New()
	//Has a list of items that it can hold.
	can_hold += list(
		/obj/item/clockwork/integration_cog,
		/obj/item/clockwork/shard,
		/obj/item/stack/sheet,
		/obj/item/mmi/robotic_brain/clockwork
	)
	..()

/obj/item/gripper/nuclear
	name = "Nuclear gripper"
	desc = "Designed for all your nuclear needs."
	icon_state = "diskgripper"
	can_hold = list(/obj/item/disk/nuclear)

/obj/item/gripper/New()
	..()
	can_hold = typecacheof(can_hold)

/obj/item/gripper/verb/drop_item_gripped()
	set name = "Drop Gripped Item"
	set desc = "Release an item from your magnetic gripper."
	set category = "Drone"

	drop_gripped_item()

/obj/item/gripper/attack_self(mob/user)
	if(gripped_item)
		gripped_item.attack_self(user)
	else
		to_chat(user, "<span class='warning'>[src] is empty.</span>")

/obj/item/gripper/tool_act(mob/living/user, obj/item/tool, tool_type)
	if(!gripped_item)
		return
	gripped_item.tool_act(user, tool, tool_type)
	if (QDELETED(gripped_item)) // if item was dissasembled we need to clear the pointer
		drop_gripped_item(TRUE) // silent = TRUE to prevent "You drop X" message from appearing without actually dropping anything

/obj/item/gripper/attackby(obj/item/weapon, mob/user, params)
	if(!gripped_item)
		return
	gripped_item.attackby(weapon, user, params)
	if (QDELETED(gripped_item)) // if item was dissasembled we need to clear the pointer
		drop_gripped_item(TRUE) // silent = TRUE to prevent "You drop X" message from appearing without actually dropping anything

/obj/item/gripper/proc/drop_gripped_item(silent = FALSE)
	if(!gripped_item)
		return
	if(!silent)
		to_chat(loc, "<span class='warning'>You drop [gripped_item].</span>")
	gripped_item.forceMove(get_turf(src))
	gripped_item = null

/obj/item/gripper/attack(mob/living/carbon/M, mob/living/carbon/user)
	return

/// Grippers are snowflakey so this is needed to to prevent forceMoving grippers after `if(!user.drop_from_active_hand())` checks done in certain attackby's.
/obj/item/gripper/forceMove(atom/destination)
	return

/obj/item/gripper/proc/isEmpty()
	return isnull(gripped_item)

/obj/item/gripper/afterattack(atom/target, mob/living/user, proximity, params)

	if(!target || !proximity) //Target is invalid or we are not adjacent.
		return FALSE

	if(gripped_item) //Already have an item.

		//Pass the attack on to the target. This might delete/relocate gripped_item.
		if(!target.attackby(gripped_item, user, params))
			// If the attackby didn't resolve or delete the target or gripped_item, afterattack
			// (Certain things, such as mountable frames, rely on afterattack)
			gripped_item?.afterattack(target, user, 1, params)

		//If gripped_item either didn't get deleted, or it failed to be transfered to its target
		if(!gripped_item && contents.len)
			gripped_item = contents[1]
			return FALSE
		else if(gripped_item && !contents.len)
			gripped_item = null

	else if(istype(target, /obj/item)) //Check that we're not pocketing a mob.
		var/obj/item/I = target
		if(is_type_in_typecache(I, can_hold)) // Make sure the item is something the gripper can hold
			to_chat(user, "<span class='notice'>You collect [I].</span>")
			I.forceMove(src)
			gripped_item = I
		else
			to_chat(user, "<span class='warning'>Your gripper cannot hold [target].</span>")
			return FALSE

	else if(istype(target,/obj/machinery/power/apc))
		var/obj/machinery/power/apc/A = target
		if(A.opened)
			if(A.cell && is_type_in_typecache(A.cell, can_hold))

				gripped_item = A.cell

				A.cell.add_fingerprint(user)
				A.cell.update_icon()
				A.cell.forceMove(src)
				A.cell = null

				A.charging = 0
				A.update_icon()

				user.visible_message("<span class='warning'>[user] removes the power cell from [A]!</span>", "You remove the power cell.")
	return TRUE

//TODO: Matter decompiler.
/obj/item/matter_decompiler

	name = "matter decompiler"
	desc = "Eating trash, bits of glass, or other debris will replenish your stores."
	icon = 'icons/obj/toy.dmi'
	icon_state = "minigibber"

	//Metal, glass, wood, plastic.
	var/list/stored_comms = list(
		"metal" = 0,
		"glass" = 0,
		"wood" = 0
		)

/obj/item/matter_decompiler/attack(mob/living/carbon/M as mob, mob/living/carbon/user as mob)
	return

/obj/item/matter_decompiler/afterattack(atom/target, mob/living/user, proximity, params)
	if(!proximity) return //Not adjacent.

	//We only want to deal with using this on turfs. Specific items aren't important.
	var/turf/T = get_turf(target)
	if(!istype(T))
		return

	//Used to give the right message.
	var/grabbed_something = FALSE

	for(var/atom/movable/A in T)
		if(A.decompile_act(src, user)) // Each decompileable mob or obj needs to have this defined
			grabbed_something = TRUE

	if(grabbed_something)
		to_chat(user, "<span class='notice'>You deploy your decompiler and clear out the contents of \the [T].</span>")
	else
		to_chat(user, "<span class='warning'>Nothing on \the [T] is useful to you.</span>")
	return

//PRETTIER TOOL LIST.
/mob/living/silicon/robot/drone/installed_modules()

	if(weapon_lock)
		to_chat(src, "<span class='warning'>Weapon lock active, unable to use modules! Count:[weaponlock_time]</span>")
		return

	if(!module)
		module = new /obj/item/robot_module/drone(src)

	var/dat = {"<meta charset="UTF-8"><HEAD><TITLE>Drone modules</TITLE><META HTTP-EQUIV='Refresh' CONTENT='10'></HEAD><BODY>\n"}
	dat += {"<A HREF='?src=[UID()];mach_close=robotmod'>Close</A>
	<BR>
	<BR>
	<B>Activated Modules</B>
	<BR>
	Module 1: [module_state_1 ? "<A HREF=?src=[UID()];mod=\ref[module_state_1]>[module_state_1]<A>" : "No Module"]<BR>
	Module 2: [module_state_2 ? "<A HREF=?src=[UID()];mod=\ref[module_state_2]>[module_state_2]<A>" : "No Module"]<BR>
	Module 3: [module_state_3 ? "<A HREF=?src=[UID()];mod=\ref[module_state_3]>[module_state_3]<A>" : "No Module"]<BR>
	<BR>
	<B>Installed Modules</B><BR><BR>"}


	var/tools = "<B>Tools and devices</B><BR>"
	var/resources = "<BR><B>Resources</B><BR>"

	for(var/O in module.modules)

		var/module_string = ""

		if(!O)
			module_string += text("<B>Resource depleted</B><BR>")
		else if(activated(O))
			module_string += text("[O]: <B>Activated</B><BR>")
		else
			module_string += text("[O]: <A HREF=?src=[UID()];act=\ref[O]>Activate</A><BR>")

		if((istype(O,/obj/item) || istype(O,/obj/item)) && !(istype(O,/obj/item/stack/cable_coil)))
			tools += module_string
		else
			resources += module_string

	dat += tools

	if(emagged)
		if(!module.emag)
			dat += text("<B>Resource depleted</B><BR>")
		else if(activated(module.emag))
			dat += text("[module.emag]: <B>Activated</B><BR>")
		else
			dat += text("[module.emag]: <A HREF=?src=[UID()];act=\ref[module.emag]>Activate</A><BR>")

	dat += resources

	src << browse(dat, "window=robotmod&can_close=0")

//Putting the decompiler here to avoid doing list checks every tick.
/mob/living/silicon/robot/drone/use_power()

	..()
	if(low_power_mode || !decompiler)
		return

	//The decompiler replenishes drone stores from hoovered-up junk each tick.
	for(var/type in decompiler.stored_comms)
		if(decompiler.stored_comms[type] > 0)
			var/obj/item/stack/sheet/stack
			switch(type)
				if("metal")
					if(!stack_metal)
						stack_metal = new /obj/item/stack/sheet/metal/cyborg(src.module)
					stack = stack_metal
				if("glass")
					if(!stack_glass)
						stack_glass = new /obj/item/stack/sheet/glass/cyborg(src.module)
					stack = stack_glass
				if("wood")
					if(!stack_wood)
						stack_wood = new /obj/item/stack/sheet/wood/cyborg(src.module)
					stack = stack_wood
				if("plastic")
					if(!stack_plastic)
						stack_plastic = new /obj/item/stack/sheet/plastic(src.module)
					stack = stack_plastic

			stack.add(1)
			decompiler.stored_comms[type]--
