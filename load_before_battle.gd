extends Control

@onready var loading_bar = $Panel/LoadingBar
@onready var random_message = $Panel/Randomfacts
@onready var province_label = $Panel/provinceName

var target_scene_path := ""
var random_texts = []
var loading_percentage := 0

func _ready() -> void:
	randomize()
	Input.set_custom_mouse_cursor(
		load("res://assets/game/cursor.png"),
		Input.CURSOR_ARROW
	)
	loading_bar.value = 0
	
	set_province_data()
	perform_loading()

func set_province_data() -> void:
	var file_name = target_scene_path.get_file().get_basename()  # e.g., "bohol"

	var province_facts = {
		"bohol": [
			"Bohol is home to the myth of Sappia, the goddess of mercy who helped end a long famine by filling the barren land with rice, symbolizing compassion and nourishment.",
			"The story of Sappia explains why rice in Bohol is traditionally white or red, with white representing her milk and red representing her blood.",
			"Bohol’s rich mythology may have been influenced by neighboring regions like Borneo and China, especially through trade and cultural exchanges involving Chinese traders and traders from Sabah.",
			"The myth of rice’s origin in Bohol shares similarities with stories from Northern Borneo and China, highlighting a shared Asian folkloric theme of compassionate deities helping humanity",
			"February 19th, a date observed in Chinese culture to honor Guan Yin (the Chinese goddess of mercy), could also be seen as a special day to honor Sappia in Bohol’s folklore tradition"
		],
		"cebu": [
			"Cebuano folklore features a variety of mythical beings, such as the Agta, a hairy giant spirit known for luring women with flowers and causing men to become suicidal. ",
			"The aswang, a shape-shifting creature, is believed to prey on pregnant women by eating their fetuses, especially at night.",
			"Duwendes, mischievous goblin-like creatures, are said to inhabit ant mounds and can cause illnesses if disrespected, highlighting local superstitions about respecting nature.",
			"The kataw, akin to mermaids, are powerful sea spirits who can manipulate water and often lure men to the depths of the ocean with their beauty.",
			"In Cebuano belief, trees are sacred because they are homes to spirits called Mansalauan, and cutting them without permission can bring sickness or misfortune."
		],
		"siquijor": [
			"Siquijor was originally called 'Isla de Fuego' (Fire Island) by Spanish explorers because they thought the island was on fire, but it was actually due to fireflies swarming over the trees.",
			"The island is renowned for its healing traditions, where local healers, called mananambal, use herbs from over 300 medicinal plants to treat various ailments.",
			"Siquijor’s reputation for enchantment dates back to the time of Spanish explorers, who were fascinated by the firefly-lit nights and the island’s mystical aura.",
			"The island blends shamanic practices with Catholic beliefs, with healers acknowledging their powers as gifts from God and incorporating religious icons into their therapies.",
			"Every year during Holy Week, healers visit sacred sites to gather ingredients for a powerful black elixir called minasa, used in rituals to exorcise spirits and spells."
		],
		"biliran": [
			"Biliran was originally called Isla de Panamao, named after a native fishing net, and was the first large-scale Spanish shipyard site in the Philippines before it was transferred to Cavite in 1604.",
			"The province is home to the active Panamao Volcano, which erupted around 1669, and its name might be derived from native grass used for mats.",
			"Mount Suiro, standing at 2,495 feet, is the tallest peak in Biliran and is known for its thermal features, including hot springs and mud pools.",
			"Biliran has a rich history linked to Spanish conquests, being the landing site of the first Spanish explorers in the Philippines",
			"The picturesque Tres Marias mountain features three peaks and is known for its numerous waterfalls and biodiversity, making it a popular hiking destination"
		],
		"Eastern Samar": [
			"Eastern Samar is home to Ogis Island, a beautiful island known for its pristine beaches and natural scenery.",
			"The island of Samar, including Eastern Samar, is part of the central Philippines and is divided into three provinces: Samar, Northern Samar, and Eastern Samar.",
			"The location of the mysterious Biringan City is rumored to be somewhere between Calbayog City and Cataman in Samar, which includes parts of Eastern Samar.",
			"Eastern Samar’s forests and natural sites are believed to be linked to Philippine myths and legends, including tales of mystical portals like the Balete tree.",
			"Local stories warn against disturbing the spiritual energies of the forests and waters in Eastern Samar, as they are believed to be connected to the legendary city of Biringan and other supernatural phenomena."
		],
		"leyte": [
			"Leyte is historically significant as the site of General Douglas MacArthur's famous return to the Philippines during World War II on October 20, 1944, at Palo, Leyte.",
			"The island of Leyte was originally named “Felipina” by Spanish navigator Ruy Lopez de Villalobos in honor of King Philip of Spain.",
			"Leyte was the first place in the Philippines where the blood compact, a traditional Filipino ritual of friendship, was recorded between Rajah Kolambu and Magellan in 1521.",
			"Leyte’s land area of 5,712.80 square kilometers makes up about 26.66% of the total land area of Eastern Visayas.",
			"Leyte has a diverse landscape that includes agricultural lands, timberland, mangroves, wetlands, and built-up areas, supporting a vibrant local economy and community."
		],
		"Northern Samar": [
			"Northern Samar is part of the Philippines, located in a region known for its active volcanoes, including Mount Mayon and Mount Taal, which even has a lake inside its crater.",
			"The local community in Northern Samar uses plants like Malunggay, Calambo, and Yerba Buena for traditional medicine, often asking neighbors for help with remedies.",
			"Seawater in Northern Samar is believed to have healing properties, and after circumcisions, swimming in the sea is a common practice to promote healing.",
			"Traditional beliefs in Northern Samar include spirits residing in trees and mythical creatures like a white lady and a monster called Onay, adding a mystical touch to everyday life.",
			"Despite challenges, the people of Northern Samar find magic in their environment—through their plants, stories, and resilient spirits—highlighting their hopeful outlook amid hardships."
		],
		"Samar": [
			"Despite challenges, the people of Northern Samar find magic in their environment—through their plants, stories, and resilient spirits—highlighting their hopeful outlook amid hardships",
			"Stories from the 1960s mention mysterious shipments of expensive construction equipment arriving at ports in Tacloban, addressed to Biringan, despite the city not existing on maps.",
			"Locals believe Biringan is a city that rises from the waters up to the clouds, with everything in it being sleek, black, and ultramodern.",
			"The legend includes tales of Biringan being a place where real money is used for transactions, challenging the idea that fairies or spirits rely solely on glamour.",
			"Despite its mythical status, belief in Biringan persists today, with stories spreading through social media and stories from locals about encounters and sightings."
		],
		"Southern Leyte": [
			"Southern Leyte is rich in folk poetry, including riddles, proverbs, folk songs, and balitao, which reflect the local culture and beliefs.",
			"The region's oral literature acts as a living cultural treasure, capturing the life, character, and traditions of the Southern Leytenos.",
			"Despite modern influences like television and the internet, efforts are underway to document and preserve Southern Leyte’s unique folk stories and poetry.",
			"The folk literature of Southern Leyte includes various genres such as myths, legends, jokes, and creation stories that serve as a window into their cultural identity.",
			"The community actively participates in research activities like data collection and field immersion to safeguard their oral traditions for future generations."
		],
		"Negros Occidental": [
			"Negros Occidental is famously known as 'The Sugar Capital of the Philippines' due to its thriving sugar industry that significantly contributed to local culture and prosperity.",
			"The province is renowned for its delicious pastries and confectionery, including guapple pie, piaya, barquillos, and dulce gatas, which are celebrated both locally and nationally.",
			"Negrense cuisine is famous for Inasal, a flavorful marinated and barbecued chicken that is a staple dish in the region.",
			"The vibrant MassKara Festival in Bacolod showcases the Negrenses' joyful spirit, featuring colorful masks and lively street celebrations every year.",
			"Historic landmarks like the San Sebastian Cathedral (built in 1876) and the Capitol Building (1931) highlight Negros Occidental’s rich architectural heritage."
		],
		"Negros Oriental": [
			"Negros Oriental is known for its rich folklore featuring mythical creatures like the Aswang, a shapeshifting monster feared since the 16th century by Spanish colonists.",
			"The Agta, a tall, black, tree-dwelling creature, is often mistaken for a Kapre but is actually a distinct being native to the Eastern Visayan provinces, including Negros Oriental.",
			"The Banwaanon, a Cebuano mythological being with Caucasian features, is believed to appear to those who help or befriend them, highlighting the region's connection to enchanted forest spirits.",
			"Duwende, mischievous small creatures living in ant mounds, are believed to cause diseases if offended, emphasizing local beliefs in nature spirits' influence on health",
			"The Tambaluslos, originating from Bicol but known in nearby regions, is a humanoid creature with distinct features and a humorous weakness—if you see it following you, wearing your clothes upside-down can make it laugh and leave you alone"
			
		],
		"Aklan": [
			"The legendary Barter of Panay began in the 1250s when Bornean datus traded land with the Ati people, marking the start of Aklan's history.  ",
			"The Ati-atihan Festival, celebrated every January, has roots in a miraculous wooden figure that brought blessings and inspired the famous celebration.",
			"Aklan is home to mythical creatures like the aswang, which can transform into animals such as birds, pigs, or cats to prowl the night.",
			"The legendary manananggal, a creature that separates its upper body to fly at night, was reportedly seen in Aklan in 1997, adding to the province’s spooky folklore",
			"The panigotlo, a mythical beast in Aklan, is believed to signal either a bountiful harvest or impending trouble, depending on when its cry is heard during a full moon."
		],
		"Antique": [
			"Antique is home to many mythical creatures, including Tamawo, an elf-like being that can hypnotize people with its food and is believed to roam in hidden underground mansions or woods.",
			"The province celebrates the Binirayan Festival every December, commemorating the arrival of the ten Bornean datus and the first Malayan settlement in the Philippines.",
			"Antiqueños follow unique superstitious death rituals, such as avoiding sweeping the floor while the body is in state and not bringing wake food home, to ensure a smooth journey to the afterlife.",
			"Traditional livelihood in Antique includes Buri-making, where women craft bags, baskets, and mats from palm leaves, preserving a age-old craft passed down through generations.",
			"The earliest settlers of Panay, including Antique, are believed to be tribal Negritos or Atis, with legends stating that Malay datus from Borneo arrived fleeing persecution, establishing the region’s rich history."
		],
		"Guimaras": [
			"Guimaras is rich in myths and legends, with each barangay having its own unique story about their place.",
			"The island features four main mythological legends and ten miscellaneous legends, highlighting its vibrant oral tradition.",
			"Many legends recount heroic deeds of actual historical figures, emphasizing the community’s respect for their heroes.",
			"The stories often explore themes like good versus evil, love versus fear, and power and strength, reflecting core values of Guimaras' culture.",
			"Legends in Guimaras typically do not specify exact dates or detailed character development, focusing instead on moral lessons and cultural symbols"
		],
		"Ilo-ilo": [
			"Iloilo is nicknamed “the Heart of the Philippines” because of its central location and vibrant culture.",
			"The Dinagyang Festival in Iloilo blends pagan and Christian traditions in a lively street dance honoring Sto. Nino.",
			"Iloilo was once called the “Queen City of the South” due to its importance as a major trading port during the sugar industry’s heyday.",
			"The province is known as the Food Basket and Rice Granary of the Region, with popular dishes like La Paz Batchoy and Chicken Inasal",
			"Iloilo’s rich heritage includes beautiful old buildings inspired by European and American architecture, including century-old churches and mansions."
		]
		
	}
	province_label.text = file_name.capitalize().replace("_", " ").replace("-", " ")

	if province_label.text == "Home Base":
		province_label.text = "Capiz"

	if province_facts.has(file_name.capitalize()):
		random_texts = province_facts[file_name.capitalize()]
	else:
		random_texts = ["Loading facts...", "Prepare for battle!", "Good luck, commander!"]

func perform_loading() -> void:
	ResourceLoader.load_threaded_request(target_scene_path)
	var last_message_change := 0.0
	var change_message_interval := 0.30
	var loading_speed := 1.0

	var scene_ready := false
	var resource_loaded: Resource = null
	var reached_99 := false
	var hold_timer := 0.0
	var hold_duration := 0.7  # How long to pause at 99% before finishing

	while true:
		# Update loading status
		if not scene_ready:
			var status = ResourceLoader.load_threaded_get_status(target_scene_path)
			if status == ResourceLoader.THREAD_LOAD_LOADED:
				print("Before Scene Target: ",target_scene_path)
				
				resource_loaded = ResourceLoader.load_threaded_get(target_scene_path)
				
				print("After: ",resource_loaded.resource_path.get_file().get_basename(), "Scene Target: ",target_scene_path)
				scene_ready = true
			elif status == ResourceLoader.THREAD_LOAD_FAILED:
				push_error("Failed to load scene: " + target_scene_path)
				break

		# Simulate progress
		if loading_bar.value < 99:
			loading_bar.value = clamp(loading_bar.value + randf_range(0.5, loading_speed), 0, 99)
		elif scene_ready and not reached_99:
			# Stay at 99 while holding
			reached_99 = true
			loading_bar.value = 99
		elif reached_99 and hold_timer < hold_duration:
			hold_timer += 0.02  # Same as timer wait
		elif reached_99 and hold_timer >= hold_duration:
			loading_bar.value = 100

		# Update loading text
		if last_message_change >= change_message_interval:
			random_message.text = random_texts[randi() % random_texts.size()]
			last_message_change = 0.0
		else:
			last_message_change += 0.02

		# Change scene only when bar hits 100 and resource is ready
		if scene_ready and loading_bar.value >= 100:
			var new_scene: Node = resource_loaded.instantiate()
			get_tree().root.add_child(new_scene)
			get_tree().current_scene.queue_free()
			get_tree().current_scene = new_scene
			var path = Global.save_path
			if ResourceLoader.exists(path):
				SaverLoader.saved_game = load(Global.save_path) as SavedGame
				if !SaverLoader.saved_game.building_data:
					return
				for data in SaverLoader.saved_game.building_data:
					if data.name == "bodega(empty)" or data.name =="imbakan_lv_1_empty" or data.name == "malacadabra":
						print("instancing storage")
						var scene_path = "res://Scene/buildings/%s.tscn" % data["name"]
						var packed_scene = load(scene_path)

						if packed_scene and packed_scene is PackedScene:
							var building = packed_scene.instantiate()
							print("Instance: ", building)
							if data.name == "malacadabra":
								Global.all_bodega.append(building)
								Global.all_imbakan.append(building)
							elif data.name == "bodega(empty)":
								Global.all_bodega.append(building)
							else:
								Global.all_imbakan.append(building)
					pass
			if get_tree().current_scene.name == "HomeBase":
				Global.all_kampo = Global.all_kampo.filter(func(k): return is_instance_valid(k))
				Global.all_kubos = Global.all_kubos.filter(func(k): return is_instance_valid(k))
				Global.all_bodega = Global.all_bodega.filter(func(k): return is_instance_valid(k))
				Global.all_imbakan = Global.all_imbakan.filter(func(k): return is_instance_valid(k))
				if ResourceLoader.exists(path):
					SaverLoader.load_save_data()
				SaverLoader.save_game()
				SignalManager.homebase.emit()
			queue_free()
			break

		await get_tree().create_timer(0.08).timeout
