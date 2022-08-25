/mob/living/carbon/superior_animal/human/voidwolf/exoboss/fists
name = "XM-07 'Sokeritanssi' Combat Walker"
	desc = "The faint sound of pop music can be heard from its cockpit.."
	icon_state = "voidwolf_exoboss"
	icon_dead = "voidwolf_exoboss_dead"
	maxHealth = 800
	health = 800
	melee_damage_lower = 40 //Ow.
	melee_damage_upper = 50
	flash_resistance = 100 //How do you flash a mech?
	breath_required_type = 0
	breath_poison_type = 0
	min_air_pressure = 0
	attacktext = "delivers a powerful punch to"
	attack_sound = 'sound/xenomorph/alien_footstep_charge1.ogg'
	light_range = 4
	light_color = COLOR_LIGHTING_WHITE_BRIGHT
	deathmessage = "suddenly sparks up and collapses, before its hatch shoots upwards and ejects the pilot inside!"
	var/has_ejected = FALSE

armor = list(melee = 50, bullet = 30, energy = 20, bomb = 20, bio = 100, rad = 100) //Swords and hammers won't work. I hate prospectors!

//Ejection sequence for when the mech dies
/mob/living/carbon/superior_animal/voidwolf/exoboss/fists/death(var/gibbed,var/message = deathmessage)
	if (stat != DEAD)
		target_mob = null
		stance = initial(stance)
		stop_automated_movement = initial(stop_automated_movement)
		walk(src, 0)
		if(!has_ejected)
			new /mob/living/carbon/superior_animal/human/voidwolf/zerosuit(src.loc)
			has_ejected = TRUE

		density = 0
		layer = LYING_MOB_LAYER

	. = ..()

/mob/living/carbon/superior_animal/voidwolf/exoboss/fists/emp_act(severity)
	..()
	if(rapid)
		rapid = FALSE
	if(prob(95) && ranged)
		ranged = FALSE
	if(emp_damage)
		adjustFireLoss(rand(50,80)*severity)

/mob/living/carbon/superior_animal/voidwolf/exoboss/fists/slip(var/slipped_on,stun_duration=8)
	return FALSE
// You can't slip a 5+ ton mech.

/mob/living/carbon/superior_animal/voidwolf/exoboss/fists/attack_hand(mob/living/carbon/M as mob)
	..()
	var/mob/living/carbon/human/H = M

	switch(M.a_intent)
		if (I_HELP)
			help_shake_act(M)

		if (I_GRAB)
			if(!weakened && stat == CONSCIOUS)
				M.adjustBruteLoss(25)
				M.adjustBruteLoss(25)
				M.adjustBruteLoss(25)
				M.adjustBruteLoss(25)
				M.adjustBruteLoss(25)
				M.adjustBruteLoss(25)
				M.adjustBruteLoss(25)
				M.adjustBruteLoss(25)
				M.adjustOxyLoss(25)
				M.Weaken(5)
				visible_message(SPAN_WARNING("\red [src] stares dumbfoundedly before slapping [M] when they try to grab them!"))
				playsound(src.loc, 'sound/weapons/tablehit1', 100, 1, 8, 8)

				return 1
			else
				if(M == src || anchored)
					return 0
				for(var/obj/item/grab/G in src.grabbed_by)
					if(G.assailant == M)
						to_chat(M, SPAN_NOTICE("You already grabbed [src]."))
						return

				var/obj/item/grab/G = new /obj/item/grab(M, src)
				if(buckled)
					to_chat(M, SPAN_NOTICE("You cannot grab [src], \he is buckled in!"))
				if(!G) //the grab will delete itself in New if affecting is anchored
					return

				M.put_in_active_hand(G)
				G.synch()
				LAssailant = M

				M.do_attack_animation(src)
				playsound(loc, 'sound/weapons/thudswoosh.ogg', 50, 1, -1)
				visible_message(SPAN_WARNING("[M] has grabbed [src] passively!"))

				return 1

		if (I_DISARM)
			if(!weakened && stat == CONSCIOUS)
				M.visible_message("\red [src] punches [M] with a resounding crack!")
				M.Weaken(5)
				M.adjustBruteLoss(75) //I don't want them to instakill their target, that's lame.

				playsound(loc, 'sound/xenomorph/alien_footstep_charge2', 50, 8, 8 )
				playsound(loc, 'sound/weapons/punchmiss.ogg', 25, 1, -1)

			M.do_attack_animation(src)

		if (I_HURT)
			var/damage = 3
			if ((stat == CONSCIOUS) && prob(10))
				playsound(loc, 'sound/weapons/punchmiss.ogg', 25, 1, -1)
				M.visible_message("\red [M] missed \the [src]")
			else
				if (istype(H))
					damage += max(0, (H.stats.getStat(STAT_ROB) / 10))
					if (HULK in H.mutations)
						damage *= 2

				playsound(loc, "punch", 25, 1, -1)
				M.visible_message("\red [M] has punched \the [src]")

				adjustBruteLoss(damage)
				updatehealth()
				M.do_attack_animation(src)

				return 1
