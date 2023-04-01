/obj/item/folder
	name = "folder"
	desc = "A folder."
	icon = 'icons/obj/bureaucracy.dmi'
	icon_state = "folder"
	w_class = WEIGHT_CLASS_SMALL
	pressure_resistance = 2
	resistance_flags = FLAMMABLE

/obj/item/folder/emp_act(severity)
	..()
	for(var/i in contents)
		var/atom/A = i
		A.emp_act(severity)

/obj/item/folder/blue
	desc = "A blue folder."
	icon_state = "folder_blue"

/obj/item/folder/red
	desc = "A red folder."
	icon_state = "folder_red"

/obj/item/folder/yellow
	desc = "A yellow folder."
	icon_state = "folder_yellow"

/obj/item/folder/white
	desc = "A white folder."
	icon_state = "folder_white"

/obj/item/folder/update_icon()
	overlays.Cut()
	if(contents.len)
		overlays += "folder_paper"
	..()

/obj/item/folder/attackby(obj/item/W as obj, mob/user as mob, params)
	if(istype(W, /obj/item/paper) || istype(W, /obj/item/photo) || istype(W, /obj/item/paper_bundle) || istype(W, /obj/item/documents))
		user.drop_item()
		W.loc = src
		to_chat(user, "<span class='notice'>You put the [W] into \the [src].</span>")
		update_icon()
	else if(istype(W, /obj/item/pen))
		rename_interactive(user, W)
	else
		return ..()

/obj/item/folder/attack_self(mob/user as mob)
	ui_interact(user)

/obj/item/folder/ui_interact(mob/user, ui_key = "main", datum/tgui/ui = null, force_open = FALSE, datum/tgui/master_ui = null, datum/ui_state/state = GLOB.default_state)
	ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "Clipboard", name, 300, 300, master_ui, state)
		//ui = new(user, src, ui_key, "KitchenSink", name, 300, 300, master_ui, state)
		ui.set_autoupdate(FALSE)
		ui.open()

/obj/item/folder/ui_data(mob/user)
	var/list/data = list()
	data["pages"] = get_pages()
	return data

/obj/item/folder/ui_act(action, params)
	if(..())
		return
	switch(action)
		if("MSG")
			message_admins("[params["msg"]]")
			. = TRUE
		if("swap")
			var/index1 = text2num(params["index1"]) + 1
			var/index2 = text2num(params["index2"]) + 1
			swap_pages(usr, index1, index2)
			. = TRUE
		if("remove")
			var/index = text2num(params["index"]) + 1
			remove_page(usr, index)
			. = TRUE
		if("open")
			var/index = text2num(params["index"]) + 1
			open_page(usr, index)
			. = TRUE
	update_icon()

/obj/item/folder/proc/get_pages()
	var/list/data = list()

	for(var/page in src)
		if(!is_page_type(page))
			continue
		data.Add(list(get_page_data(page)))

	return data

/obj/item/folder/proc/get_page_data(obj/page)
	var/list/page_data = list()

	page_data["name"] = page.name
	page_data["description"] = page.desc //examine()

	if(istype(page, /obj/item/paper))
		page_data["type"] = "paper"
		page_data["preview_text"] = get_preview_text(page)
		// add language check
		// add stamps info

	else if(istype(page, /obj/item/photo))
		page_data["type"] = "foto"

	else if(istype(page, /obj/item/paper_bundle))
		page_data["type"] = "paper_bundle"

	else if(istype(page, /obj/item/documents))
		page_data["type"] = "documents"

	return page_data

/obj/item/folder/proc/get_preview_text(obj/item/paper/paper)
	if(!istype(paper))
		return
	if(!paper.info)
		return
	var/text_no_html = regex(@"[\n\r\t]+", "g").Replace_char(paper.info, "") // remove newlines
	text_no_html = regex(@"<.*?>", "g").Replace_char(text_no_html, "") // remove html tags
	return text_no_html

/obj/item/folder/proc/is_page_type(thing)
	if( istype(thing, /obj/item/paper) \
		|| istype(thing, /obj/item/photo) \
		|| istype(thing, /obj/item/paper_bundle) \
		|| istype(thing, /obj/item/documents))
		return TRUE
	return FALSE

/obj/item/folder/proc/swap_pages(mob/user, index1, index2)
	var/list/new_contents = contents.Copy()
	new_contents.Swap(index1, index2)
	contents = new_contents

/obj/item/folder/proc/remove_page(mob/user, index)
	var/obj/item/page = contents[index]
	page.loc = usr.loc
	user.put_in_hands(page)

/obj/item/folder/proc/open_page(mob/user, index)
	var/page = contents[index]

	if(istype(page, /obj/item/paper))
		var/obj/item/paper/page_paper = page
		page_paper.show_content(user) // checks

	else if(istype(page, /obj/item/photo))
		var/obj/item/photo/page_photo = page
		page_photo.show(user)

	else if(istype(page, /obj/item/paper_bundle))
		var/obj/item/paper_bundle/page_bundle = page
		page_bundle.show_content(user) // checks


/* TODEL
/obj/item/folder/attack_self(mob/user as mob)
	var/dat = {"<meta charset="UTF-8"><title>[name]</title>"}

	for(var/obj/item/paper/P in src)
		dat += "<A href='?src=[UID()];remove=\ref[P]'>Remove</A> - <A href='?src=[UID()];read=\ref[P]'>[P.name]</A><BR>"
	for(var/obj/item/photo/Ph in src)
		dat += "<A href='?src=[UID()];remove=\ref[Ph]'>Remove</A> - <A href='?src=[UID()];look=\ref[Ph]'>[Ph.name]</A><BR>"
	for(var/obj/item/paper_bundle/Pa in src)
		dat += "<A href='?src=[UID()];remove=\ref[Pa]'>Remove</A> - <A href='?src=[UID()];look=\ref[Pa]'>[Pa.name]</A><BR>"
	for(var/obj/item/documents/doc in src)
		dat += "<A href='?src=[UID()];remove=\ref[doc]'>Remove</A> - <A href='?src=[UID()];look=\ref[doc]'>[doc.name]</A><BR>"
	user << browse(dat, "window=folder")
	onclose(user, "folder")
	add_fingerprint(usr)
	return

/obj/item/folder/Topic(href, href_list)
	..()
	if((usr.stat || usr.restrained()))
		return

	if(src.loc == usr)

		if(href_list["remove"])
			var/obj/item/P = locate(href_list["remove"])
			if(P && (P.loc == src) && istype(P))
				P.loc = usr.loc
				usr.put_in_hands(P)

		else if(href_list["read"])
			var/obj/item/paper/P = locate(href_list["read"])
			if(P && (P.loc == src) && istype(P))
				P.show_content(usr)
		else if(href_list["look"])
			var/obj/item/photo/P = locate(href_list["look"])
			if(P && (P.loc == src) && istype(P))
				P.show(usr)
		else if(href_list["browse"])
			var/obj/item/paper_bundle/P = locate(href_list["browse"])
			if(P && (P.loc == src) && istype(P))
				P.attack_self(usr)
				onclose(usr, "[P.name]")

		//Update everything
		attack_self(usr)
		update_icon()
	return
*/

/obj/item/folder/documents
	name = "folder- 'TOP SECRET'"
	desc = "A folder stamped \"Top Secret - Property of Nanotrasen Corporation. Unauthorized distribution is punishable by death.\""

/obj/item/folder/documents/New()
	..()
	new /obj/item/documents/nanotrasen(src)
	update_icon()

/obj/item/folder/syndicate
	name = "folder- 'TOP SECRET'"
	desc = "A folder stamped \"Top Secret - Property of The Syndicate.\""

/obj/item/folder/syndicate/red
	icon_state = "folder_sred"

/obj/item/folder/syndicate/red/New()
	..()
	new /obj/item/documents/syndicate/red(src)
	update_icon()

/obj/item/folder/syndicate/blue
	icon_state = "folder_sblue"

/obj/item/folder/syndicate/blue/New()
	..()
	new /obj/item/documents/syndicate/blue(src)
	update_icon()

/obj/item/folder/syndicate/yellow
	icon_state = "folder_syellow"

/obj/item/folder/syndicate/yellow/full/New()
	..()
	new /obj/item/documents/syndicate/yellow(src)
	update_icon()

/obj/item/folder/syndicate/mining/New()
	. = ..()
	new /obj/item/documents/syndicate/mining(src)
	update_icon()


