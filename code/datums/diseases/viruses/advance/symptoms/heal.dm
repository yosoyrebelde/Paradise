/*
//////////////////////////////////////

Healing

	Little bit hidden.
	Lowers resistance tremendously.
	Decreases stage speed tremendously.
	Decreases transmittablity temrendously.
	Fatal Level.

Bonus
	Heals toxins in the affected mob's blood stream.

//////////////////////////////////////
*/

/datum/symptom/heal

	name = "Toxic Filter"
	id = "heal"
	stealth = 1
	resistance = -4
	stage_speed = -4
	transmittable = -4
	level = 6

/datum/symptom/heal/Activate(datum/disease/virus/advance/A)
	..()
	if(prob(SYMPTOM_ACTIVATION_PROB * 10))
		var/mob/living/M = A.affected_mob
		switch(A.stage)
			if(4, 5)
				Heal(M, A)
	return

/datum/symptom/heal/proc/Heal(mob/living/M, datum/disease/virus/advance/A)
	var/get_damage = (sqrtor0(20+A.totalStageSpeed())*(1+rand()))
	M.adjustToxLoss(-get_damage)
	return 1

/*
//////////////////////////////////////

Metabolism

	Little bit hidden.
	Lowers resistance.
	Decreases stage speed.
	Decreases transmittablity temrendously.
	High Level.

Bonus
	Cures all diseases (except itself) and creates anti-bodies for them until the symptom dies.

//////////////////////////////////////
*/

/datum/symptom/heal/metabolism

	name = "Anti-Bodies Metabolism"
	id = "metabolism"
	stealth = -1
	resistance = -1
	stage_speed = -1
	transmittable = -4
	level = 3
	var/list/cured_diseases = list()

/datum/symptom/heal/metabolism/Heal(mob/living/M, datum/disease/virus/advance/A)
	var/cured = 0
	for(var/thing in M.diseases)
		var/datum/disease/D = thing
		if(D.virus_heal_resistant)
			continue
		if(D != A)
			cured = 1
			cured_diseases += D.GetDiseaseID()
			D.cure()
	if(cured)
		to_chat(M, span_notice("You feel much better."))

/datum/symptom/heal/metabolism/End(datum/disease/virus/advance/A)
	// Remove all the diseases we cured.
	var/mob/living/M = A.affected_mob
	if(istype(M))
		if(cured_diseases.len)
			for(var/res in M.resistances)
				if(res in cured_diseases)
					M.resistances -= res
		to_chat(M, span_warning("You feel weaker."))

/*
//////////////////////////////////////

Longevity

	Medium hidden boost.
	Large resistance boost.
	Large stage speed boost.
	Large transmittablity boost.
	High Level.

Bonus
	After a certain amount of time the symptom will cure itself.

//////////////////////////////////////
*/

/datum/symptom/heal/longevity

	name = "Longevity"
	id = "longevity"
	stealth = 3
	resistance = 4
	stage_speed = 4
	transmittable = 4
	level = 3
	var/longevity = 30

/datum/symptom/heal/longevity/Heal(mob/living/M, datum/disease/virus/advance/A)
	longevity -= 1
	if(!longevity)
		A.cure()

/datum/symptom/heal/longevity/Start(datum/disease/virus/advance/A)
	longevity = rand(initial(longevity) - 5, initial(longevity) + 5)
