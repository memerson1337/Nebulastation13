/obj/machinery/door/poddoor
	name = "blast door"
	desc = "A heavy duty blast door that opens mechanically."
	icon = 'icons/obj/doors/blastdoor.dmi' //ICON OVERRIDEN IN SKYRAT AESTHETICS - SEE MODULE
	icon_state = "closed"
	var/id = 1
	layer = BLASTDOOR_LAYER
	closingLayer = CLOSED_BLASTDOOR_LAYER
	sub_door = TRUE
	explosion_block = 3
	heat_proof = TRUE
	safe = FALSE
	max_integrity = 600
	armor = list(MELEE = 50, BULLET = 100, LASER = 100, ENERGY = 100, BOMB = 50, BIO = 100, RAD = 100, FIRE = 100, ACID = 70)
	resistance_flags = FIRE_PROOF
	damage_deflection = 70
	var/datum/crafting_recipe/recipe_type = /datum/crafting_recipe/blast_doors
	var/deconstruction = BLASTDOOR_FINISHED // deconstruction step

/obj/machinery/door/poddoor/attackby(obj/item/W, mob/user, params)
	. = ..()

	if(W.tool_behaviour == TOOL_SCREWDRIVER)
		if(density)
			balloon_alert(user, "open the door first!")
			return
		else if(default_deconstruction_screwdriver(user, icon_state, icon_state, W))
			return TRUE

	if(panel_open)
		if(W.tool_behaviour == TOOL_MULTITOOL && deconstruction == BLASTDOOR_FINISHED)
			var/change_id = input("Set the shutters/blast door/blast door controllers ID. It must be a number between 1 and 100.", "ID", id) as num|null
			if(change_id)
				id = clamp(round(change_id, 1), 1, 100)
				to_chat(user, span_notice("You change the ID to [id]."))
				balloon_alert(user, "ID changed")

		else if(W.tool_behaviour == TOOL_CROWBAR && deconstruction == BLASTDOOR_FINISHED)
			balloon_alert(user, "removing airlock electronics...")
			if(W.use_tool(src, user, 100, volume=50))
				new /obj/item/electronics/airlock(loc)
				id = null
				deconstruction = BLASTDOOR_NEEDS_ELECTRONICS
				balloon_alert(user, "removed airlock electronics")
			return TRUE

		else if(W.tool_behaviour == TOOL_WIRECUTTER && deconstruction == BLASTDOOR_NEEDS_ELECTRONICS)
			balloon_alert(user, "removing internal cables...")
			if(W.use_tool(src, user, 100, volume=50))
				var/datum/crafting_recipe/recipe = locate(recipe_type) in GLOB.crafting_recipes
				var/amount = recipe.reqs[/obj/item/stack/cable_coil]
				new /obj/item/stack/cable_coil(loc, amount)
				deconstruction = BLASTDOOR_NEEDS_WIRES
				balloon_alert(user, "removed internal cables")
			return TRUE

		else if(W.tool_behaviour == TOOL_WELDER && deconstruction == BLASTDOOR_NEEDS_WIRES)
			if(!W.tool_start_check(user, amount=0))
				return

			balloon_alert(user, "tearing apart...") //You're tearing me apart, Lisa!
			if(W.use_tool(src, user, 150, volume=50))
				var/datum/crafting_recipe/recipe = locate(recipe_type) in GLOB.crafting_recipes
				var/amount = recipe.reqs[/obj/item/stack/sheet/plasteel]
				new /obj/item/stack/sheet/plasteel(loc, amount)
				user.balloon_alert(user, "torn apart")
				qdel(src)
			return TRUE

/obj/machinery/door/poddoor/examine(mob/user)
	. = ..()
	if(panel_open)
		if(deconstruction == BLASTDOOR_FINISHED)
			. += span_notice("The maintenance panel is opened and the electronics could be <b>pried</b> out.")
		else if(deconstruction == BLASTDOOR_NEEDS_ELECTRONICS)
			. += span_notice("The <i>electronics</i> are missing and there are some <b>wires</b> sticking out.")
		else if(deconstruction == BLASTDOOR_NEEDS_WIRES)
			. += span_notice("The <i>wires</i> have been removed and it's ready to be <b>sliced apart</b>.")

/obj/machinery/door/poddoor/connect_to_shuttle(obj/docking_port/mobile/port, obj/docking_port/stationary/dock)
	id = "[port.id]_[id]"

/obj/machinery/door/poddoor/preopen
	icon_state = "open"
	density = FALSE
	opacity = FALSE

/obj/machinery/door/poddoor/ert
	name = "hardened blast door"
	desc = "A heavy duty blast door that only opens for dire emergencies."
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF

//special poddoors that open when emergency shuttle docks at centcom
/obj/machinery/door/poddoor/shuttledock
	var/checkdir = 4 //door won't open if turf in this dir is `turftype`
	var/turftype = /turf/open/space

/obj/machinery/door/poddoor/shuttledock/proc/check()
	var/turf/T = get_step(src, checkdir)
	if(!istype(T, turftype))
		INVOKE_ASYNC(src, .proc/open)
	else
		INVOKE_ASYNC(src, .proc/close)

/obj/machinery/door/poddoor/incinerator_ordmix
	name = "combustion chamber vent"
	id = INCINERATOR_ORDMIX_VENT

/obj/machinery/door/poddoor/incinerator_atmos_main
	name = "turbine vent"
	id = INCINERATOR_ATMOS_MAINVENT

/obj/machinery/door/poddoor/incinerator_atmos_aux
	name = "combustion chamber vent"
	id = INCINERATOR_ATMOS_AUXVENT

/obj/machinery/door/poddoor/atmos_test_room_mainvent_1
	name = "test chamber 1 vent"
	id = TEST_ROOM_ATMOS_MAINVENT_1

/obj/machinery/door/poddoor/atmos_test_room_mainvent_2
	name = "test chamber 2 vent"
	id = TEST_ROOM_ATMOS_MAINVENT_2

/obj/machinery/door/poddoor/incinerator_syndicatelava_main
	name = "turbine vent"
	id = INCINERATOR_SYNDICATELAVA_MAINVENT

/obj/machinery/door/poddoor/incinerator_syndicatelava_aux
	name = "combustion chamber vent"
	id = INCINERATOR_SYNDICATELAVA_AUXVENT

/obj/machinery/door/poddoor/massdriver_ordnance
	name = "Ordnance Launcher Bay Door"
	id = MASSDRIVER_ORDNANCE

/obj/machinery/door/poddoor/massdriver_chapel
	name = "Chapel Launcher Bay Door"
	id = MASSDRIVER_CHAPEL

/obj/machinery/door/poddoor/massdriver_trash
	name = "Disposals Launcher Bay Door"
	id = MASSDRIVER_DISPOSALS

/obj/machinery/door/poddoor/Bumped(atom/movable/AM)
	if(density)
		return FALSE
	else
		return ..()

//"BLAST" doors are obviously stronger than regular doors when it comes to BLASTS.
/obj/machinery/door/poddoor/ex_act(severity, target)
	if(severity <= EXPLODE_LIGHT)
		return FALSE
	return ..()

/obj/machinery/door/poddoor/do_animate(animation)
	switch(animation)
		if("opening")
			flick("opening", src)
			//playsound(src, 'sound/machines/blastdoor.ogg', 30, TRUE) ORIGINAL
			playsound(src, door_sound, 30, TRUE) //SKYRAT EDIT CHANGE - AESTHETICS
		if("closing")
			flick("closing", src)
			//playsound(src, 'sound/machines/blastdoor.ogg', 30, TRUE) ORIGINAL
			playsound(src, door_sound, 30, TRUE) //SKYRAT EDIT CHANGE - AESTHETICS

/obj/machinery/door/poddoor/update_icon_state()
	. = ..()
	icon_state = density ? "closed" : "open"

/obj/machinery/door/poddoor/try_to_activate_door(mob/user)
	return

/obj/machinery/door/poddoor/try_to_crowbar(obj/item/I, mob/user)
	if(machine_stat & NOPOWER)
		open(TRUE)

/obj/machinery/door/poddoor/attack_alien(mob/living/carbon/alien/humanoid/user, list/modifiers)
	if(density & !(resistance_flags & INDESTRUCTIBLE))
		add_fingerprint(user)
		user.visible_message(span_warning("[user] begins prying open [src]."),\
					span_noticealien("You begin digging your claws into [src] with all your might!"),\
					span_warning("You hear groaning metal..."))
		playsound(src, 'sound/machines/airlock_alien_prying.ogg', 100, TRUE)

		var/time_to_open = 5 SECONDS
		if(hasPower())
			time_to_open = 15 SECONDS

		if(do_after(user, time_to_open, src))
			if(density && !open(TRUE)) //The airlock is still closed, but something prevented it opening. (Another player noticed and bolted/welded the airlock in time!)
				to_chat(user, span_warning("Despite your efforts, [src] managed to resist your attempts to open it!"))

	else
		return ..()

