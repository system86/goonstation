/* ._.-'~'-._.-'~'-._.-'~'-._.-'~'-._.-'~'-._. */
/*-=-=-=-=-=-=-=DJ PANEL BY ZEWAKA-=-=-=-=-=-=-*/
/* '~'-._.-'~'-._.-'~'-._.-'~'-._.-'~'-._.-'~' */

client/proc/open_dj_panel()
	set name = "DJ Panel"
	set desc = "Get your groove on!" //"funny function names???? first you use the WRONG INDENT STYLE and now this????" --that fuckhead on the forums
	SET_ADMIN_CAT(ADMIN_CAT_FUN)
	if (!isadmin(src) && !src.non_admin_dj)
		boutput(src, "Only administrators or those with access may use this command.")
		return

	global.dj_panel.ui_interact(src)

/** DJ Panel for Admins
 *  Allows for easily accessible music/sound playing for admins/allowed players.
 */
/datum/dj_panel
	var/loaded_sound = null // holds current song file
	var/sound_volume = 50
	var/sound_frequency = 1
	var/admin_sound_channel = 1014

/datum/dj_panel/ui_state(mob/user)
	return tgui_always_state

/datum/dj_panel/ui_status(mob/user)
  return min(
		tgui_admin_state.can_use_topic(src, user),
		src.dj_access_check(user)
	)

/// Checks if the passed mob is an admin or has dj access
/datum/dj_panel/proc/dj_access_check(mob/user)
	if (isadmin(user) || user?.client?.non_admin_dj)
		return UI_INTERACTIVE
	else
		return UI_CLOSE

/datum/dj_panel/ui_interact(mob/user, datum/tgui/ui)
	ui = tgui_process.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "DJPanel")
		ui.open()

/datum/dj_panel/ui_data(mob/user)
	var/list/data = list()
	data["loadedSound"] = loaded_sound
	data["soundVol"] = sound_volume
	data["soundFreq"] = sound_frequency

	return data

/datum/dj_panel/ui_act(action, params)
	if(..())
		return

	if (!config.allow_admin_sounds)
		alert(usr, "Admin sounds disabled")
		ui_close(usr)

	switch(action)
		if("set-file")
			loaded_sound = (input(usr, "Upload a file:", "File Uploader - No 50MB songs!", "") as sound|null)
			. = TRUE

		if("set-volume")
			var/new_volume = params["volume"]
			if(new_volume  == "reset")
				sound_volume = initial(sound_volume)
				. = TRUE
			else if(new_volume == "min")
				sound_volume = 0
				. = TRUE
			else if(new_volume == "max")
				sound_volume = 100
				. = TRUE
			else if(text2num(new_volume) != null)
				sound_volume = clamp(text2num(new_volume), 0, 100)
				. = TRUE

		if("set-freq")
			var/new_freq = params["frequency"]
			if(new_freq  == "reset")
				sound_frequency = initial(sound_frequency)
				. = TRUE
			else if(text2num(new_freq) != null)
				sound_frequency = clamp(text2num(new_freq), -100, 100)
				. = TRUE

		if("toggle-announce")
			if (!usr.client)
				return TRUE
			usr.client.djmode = !usr.client.djmode
			boutput(usr, "<span class='notice'>DJ mode now [(usr.client.djmode ? "On" : "Off")].</span>")

			logTheThing("admin", usr, null, "set their DJ mode to [(usr.client.djmode ? "On" : "Off")]")
			logTheThing("diary", usr, null, "set their DJ mode to [(usr.client.djmode ? "On" : "Off")]", "admin")
			message_admins("[key_name(usr)] set their DJ mode to [(usr.client.djmode ? "On" : "Off")]")
			. = TRUE

		if("play-sound")
			usr.client?.play_sound_real(loaded_sound, sound_volume, sound_frequency)
			. = TRUE

		if("play-music")
			usr.client?.play_music_real(loaded_sound, sound_frequency)
			. = TRUE

		if("play-ambience")
			logTheThing("admin", usr, null, "played ambient sound [loaded_sound]")
			logTheThing("diary", usr, null, "played ambient sound [loaded_sound]", "admin")
			message_admins("[admin_key(usr.client)] played ambient sound [loaded_sound]")
			playsound(get_turf_loc(usr), loaded_sound, sound_volume, sound_frequency)

		if("play-remote")
			usr.client?.play_youtube_audio()

		if("play-player")
			var/client/C = input(usr, "Choose a client:", "Choose a client:", usr) in clients
			if (!C) return FALSE
			logTheThing("admin", usr, null, "played sound [loaded_sound] to [C]")
			logTheThing("diary", usr, null, "played sound [loaded_sound] to [C]", "admin")
			message_admins("[admin_key(usr)] played sound [loaded_sound] to [C]")
			playsound(C.mob, loaded_sound, sound_volume, sound_frequency)

		if("toggle-player-dj")
			toggledj(input(usr, "Choose a client:", "Choose a client:") in clients)

		if("stop-sound")
			move_admin_sound_channel(backwards=TRUE)
			SPAWN_DBG(0)
				var/sound/stopsound = sound(null, wait = 0, channel=admin_sound_channel)
				for (var/client/C in clients)
					C << stopsound
					LAGCHECK(LAG_MEDIUM)
			. = TRUE

		if("stop-radio")
			SPAWN_DBG(0)
				var/sound/stopsound = sound(null, wait = 0, channel=1013)
				for (var/client/C in clients)
					C << stopsound
					LAGCHECK(LAG_MEDIUM)
			. = TRUE


chui/window/dj_panel //global panel
	name = "DJ Panel"
	windowSize = "500x400"
	flags = CHUI_FLAG_MOVABLE | CHUI_FLAG_CLOSABLE | CHUI_FLAG_SIZABLE
	var/loaded_sound = null //holds current song file

	GetBody()
		var/list/html = list()

		html += "<strong>Loaded Soundfile:</strong> [theme.generateButton("changefile", "[template("set_file", "None")]")] <br>"
		html += "<strong>Sound Volume:</strong> [theme.generateButton("changevol", "[template("set_volume", 50)]")] <br>"
		html += "<strong>Sound Frequency:</strong> [theme.generateButton("changefreq", "[template("set_freq", 1)]")] <br>"
		html += "<strong>DJ Announce Mode: [theme.generateButton("toggleanndj", "Toggle")]</strong> <br>"
		html += "<strong>Current Sound Channel:</strong> [template("admin_channel", admin_sound_channel)]<br><hr><br>"

		html += "[theme.generateButton("playsound", "Play Sound")] &nbsp; &nbsp; [theme.generateButton("playmusic", "Play Music")]<br><br>"
		html += "[theme.generateButton("playamb", "Play Local Ambience")] &nbsp; &nbsp; [theme.generateButton("playremote", "Play Remote File")]<br><br>"
		html += "[theme.generateButton("playplayr", "Play To Player")] &nbsp; &nbsp; [theme.generateButton("toggledj", "Toggle DJ For Player")]<br><br>"
		html += "[theme.generateButton("stopsong", "Stop Last Song")] &nbsp; &nbsp; [theme.generateButton("stopradio", "Stop Radio for Everyone")]"

		return html.Join()

/** Moves the global admin sound channel up or down one
 *
 * @param backwards - Moves it backwards if true
 */
/datum/dj_panel/proc/move_admin_sound_channel(var/backwards = FALSE)
	if (backwards)
		if (admin_sound_channel > 1014)
			admin_sound_channel--
		else //At 1014, set it bring it up 10.
			admin_sound_channel = 1024
	else
		if (admin_sound_channel < 1024)
			admin_sound_channel++
		else //At 1024, set it back down 10.
			admin_sound_channel = 1014

/** Toggles the DJ Mode for a given client
 *
 * @param C - Client to toggle the DJ Mode of
 * @param who - The client who toggled the DJ Mode
 */
/datum/dj_panel/proc/toggledj(var/client/C, var/client/who)
	C.non_admin_dj = !C.non_admin_dj
	if (C.non_admin_dj)
		C.verbs += /client/proc/open_dj_panel
		C.verbs += /client/proc/cmd_dectalk
	else
		C.verbs -= /client/proc/cmd_dectalk
		C.verbs -= /client/proc/open_dj_panel

	logTheThing("admin", who, C, "has [C.non_admin_dj ? "given" : "removed"] the ability for [constructTarget(C,"admin")] to DJ and use dectalk.")
	logTheThing("diary", who, C, "has [C.non_admin_dj ? "given" : "removed"] the ability for [constructTarget(C,"diary")] to DJ and use dectalk.", "admin")
	message_admins("[key_name(who)] has [C.non_admin_dj ? "given" : "removed"] the ability for [key_name(C)] to DJ and use dectalk.")
	boutput(C, "<span class='alert'><b>You [C.non_admin_dj ? "can now" : "no longer can"] DJ with the 'DJ Panel' and use text2speech with 'Dectalk' commands under 'Special Verbs'.</b></span>")
