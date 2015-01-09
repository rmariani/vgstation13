/mob/dead/observer/DblClickOn(var/atom/A, var/params)
	if(client.buildmode)
		build_click(src, client.buildmode, params, A)
		return
	if(can_reenter_corpse && mind && mind.current)
		if(A == mind.current || (mind.current in A)) // double click your corpse or whatever holds it
			reenter_corpse()						// (cloning scanner, body bag, closet, mech, etc)
			return									// seems legit.

	// Things you might plausibly want to follow
	if((ismob(A) && A != src) || istype(A,/obj/machinery/bot) || istype(A,/obj/machinery/singularity))
		ManualFollow(A)

	// Otherwise jump
	else
		var/turf/targetloc = get_turf(A)
		if(targetloc.holy && ((src.invisibility == 0) || (src.mind in ticker.mode.cult)))
			usr << "<span class='warning'>These are sacred grounds, you cannot go there!</span>"
		else
			loc = targetloc

/mob/dead/observer/ClickOn(var/atom/A, var/params)
	if(client.buildmode)
		build_click(src, client.buildmode, params, A)
		return
	if(attack_delayer.blocked())
		return
	//next_move = world.time + 8

	var/list/modifiers = params2list(params)
	if(modifiers["middle"])
		MiddleClickOn(A)
		return
	if(modifiers["shift"])
		ShiftClickOn(A)
		return
	if(modifiers["alt"])
		AltClickOn(A)
		return
	if(modifiers["ctrl"])
		CtrlClickOn(A)
		return
	// You are responsible for checking config.ghost_interaction when you override this function
	// Not all of them require checking, see below
	A.attack_ghost(src)

// We don't need a fucking toggle.
/mob/dead/observer/ShiftClickOn(var/atom/A)
	user.examination(src)

/atom/proc/attack_ghost(mob/user as mob)
	var/ghost_flags = 0
	if(ghost_read)
		ghost_flags |= PERMIT_ALL
	if(canGhostRead(user,src,ghost_flags))
		src.attack_ai(user)
	else
		user.examination(src)

/* Bay edition
// Oh by the way this didn't work with old click code which is why clicking shit didn't spam you
/atom/proc/attack_ghost(mob/dead/observer/user as mob)
	if(user.client && user.client.inquisitive_ghost)
		examine()
	return
*/

// ---------------------------------------
// And here are some good things for free:
// Now you can click through portals, wormholes, gateways, and teleporters while observing. -Sayu

/obj/machinery/teleport/hub/attack_ghost(mob/user as mob)
	var/atom/l = loc
	var/obj/machinery/computer/teleporter/com = locate(/obj/machinery/computer/teleporter, locate(l.x - 2, l.y, l.z))
	if(com.locked)
		user.loc = get_turf(com.locked)

/obj/effect/portal/attack_ghost(mob/user as mob)
	if(target)
		user.loc = get_turf(target)

/obj/machinery/gateway/centerstation/attack_ghost(mob/user as mob)
	if(awaygate)
		user.loc = awaygate.loc
	else
		user << "[src] has no destination."

/obj/machinery/gateway/centeraway/attack_ghost(mob/user as mob)
	if(stationgate)
		user.loc = stationgate.loc
	else
		user << "[src] has no destination."

// -------------------------------------------
// This was supposed to be used by adminghosts
// I think it is a *terrible* idea
// but I'm leaving it here anyway
// commented out, of course.
/*
/atom/proc/attack_admin(mob/user as mob)
	if(!user || !user.client || !user.client.holder)
		return
	attack_hand(user)

*/
