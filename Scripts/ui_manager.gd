extends Panel

class_name ui

signal card_picked
signal begin_card_pick

var max_cards = 3
var selected_card = 1
var avaliable_cards = [null, null, null]
var player_choosing: GameManager.PLAYER_TYPES = GameManager.PLAYER_TYPES.PLAYER1

@onready var pick_text : RichTextLabel = $"./PickingText"
@onready var overlay = $"/root/Game/Overlay"

func test_rarity_pulls():
	var rarities = {}
	
	for i in Items.rarity_prob:
		rarities[i] = 0
	
	for i in range(5000):
		rarities[Items.get_rarity(randi_range(0, Items.rarity_total))] += 1
	
	for i in rarities:
		print("%s: %d" % [Items.rarity_prob[i].bbcode, rarities[i]])

func _ready() -> void:
	GameManager.ui_control = self

	test_rarity_pulls()
	
	visible = false
	connect("begin_card_pick", on_begin_card_pick)
	
func _input(event: InputEvent) -> void:
	if GameManager.game_state != GameManager.GAME_STATES.PICKING_CARD:
		return
	
	var p_string = "P1" if player_choosing == GameManager.PLAYER_TYPES.PLAYER1 else "P2"
	var selector = "SelectorRed" if player_choosing == GameManager.PLAYER_TYPES.PLAYER1 else "SelectorBlue"
	
	if event.is_action_released(p_string + "_Right"):
		get_child(selected_card).scale = Vector2(1.3, 1.3)
		get_child(selected_card).find_child(selector).visible = false
		selected_card = posmod((selected_card + 1), max_cards)
		get_child(selected_card).scale = Vector2(1.6, 1.6)
		get_child(selected_card).find_child(selector).visible = true
		$"/root/Game/Ui-Select-Sfx".play()
	if event.is_action_released(p_string + "_Left"):
		get_child(selected_card).scale = Vector2(1.3, 1.3)
		get_child(selected_card).find_child(selector).visible = false
		selected_card = posmod((selected_card - 1), max_cards)
		get_child(selected_card).find_child(selector).visible = true
		get_child(selected_card).scale = Vector2(1.6, 1.6)
		$"/root/Game/Ui-Select-Sfx".play()
	if event.is_action_released(p_string + "_Swing"):
		# fancy outro for the cards dissipating and stuff
		create_tween().tween_property(get_child(selected_card).find_child(selector), "modulate:a", 0, 0.25)
		for i in range(max_cards):
			var card_title_UI: RichTextLabel = get_child(i).find_child("Title")
			var card_desc_UI: RichTextLabel = get_child(i).find_child("Desc")
			var card_rarity_UI: RichTextLabel = get_child(i).find_child("Rarity")
			
			create_tween().tween_property(card_title_UI, "modulate:a", 0, 0.25)
			create_tween().tween_property(card_desc_UI, "modulate:a", 0, 0.25)
			create_tween().tween_property(card_rarity_UI, "modulate:a", 0, 0.25)
			
		await get_tree().create_timer(0.25).timeout
		
		for i in range(max_cards):
			get_child(i).find_child("Texture").play("outro")
			# scale out animation (reverse of scale in)
			create_tween().tween_property(get_child(i), "scale:x", 0, 0.33).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CIRC)
			create_tween().tween_property(get_child(i), "scale:y", get_child(i).scale.y * 1.5, 0.33).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CIRC)
			
		await get_tree().create_timer(0.33).timeout
		
		visible = false
		get_child(selected_card).find_child(selector).visible = false
		$"/root/Game/Game-ui/Card-Red".visible = false
		$"/root/Game/Game-ui/Card-Blue".visible = false
		get_child(selected_card).scale = Vector2(1.3, 1.3)
		emit_signal("card_picked", avaliable_cards[selected_card], player_choosing)
		avaliable_cards = [null, null, null]

func on_begin_card_pick(player: GameManager.PLAYER_TYPES):
	
	# hide all the card selectors and reset scales
	for i in range(max_cards):
		get_child(i).find_child("SelectorRed").visible = false
		get_child(i).find_child("SelectorBlue").visible = false
		get_child(i).scale = Vector2(1.3, 1.3)
	
	player_choosing = player
	visible = true
	selected_card = 0
	get_child(selected_card).scale = Vector2(1.6, 1.6)
	
	if player == GameManager.PLAYER_TYPES.PLAYER1:
		get_child(selected_card).find_child("SelectorRed").modulate.a = 0
		get_child(selected_card).find_child("SelectorRed").visible = true
		create_tween().tween_property(get_child(selected_card).find_child("SelectorRed"), "modulate:a", 1.0, 1.0)
	else:
		get_child(selected_card).find_child("SelectorBlue").modulate.a = 0
		get_child(selected_card).find_child("SelectorBlue").visible = true
		create_tween().tween_property(get_child(selected_card).find_child("SelectorBlue"), "modulate:a", 1.0, 1.0)
	
	pick_text.set_text(("[color=#8080ff]Blue" if player == GameManager.PLAYER_TYPES.PLAYER2 else "[color=#ff8080]Red") + " is picking...[/color]")
	
	if player == GameManager.PLAYER_TYPES.PLAYER1:
		$"/root/Game/Game-ui/Card-Blue".visible = true
		$"/root/Game/Game-ui/Card-Red".visible = false
	else:
		$"/root/Game/Game-ui/Card-Blue".visible = false
		$"/root/Game/Game-ui/Card-Red".visible = true
	
	var selected_rarities = {}
	
	for i in range(max_cards):
		var rarity = Items.get_rarity(randi_range(0, Items.rarity_total))
		var card
		var card_scene = get_child(i)
		
		if selected_rarities.has(rarity):
			var cardi = randi_range(0, selected_rarities[rarity].size()-1)
			card = Items.items[rarity][selected_rarities[rarity].pop_at(cardi)]
		else:
			selected_rarities[rarity] = range(Items.items[rarity].size())
			var cardi = randi_range(0, selected_rarities[rarity].size()-1)
			card = Items.items[rarity][selected_rarities[rarity].pop_at(cardi)]
		
		var card_title_UI: RichTextLabel = card_scene.find_child("Title")
		var card_desc_UI: RichTextLabel = card_scene.find_child("Desc")
		var card_rarity_UI: RichTextLabel = card_scene.find_child("Rarity")
		avaliable_cards[i] = card
		
		#card_title_UI.text = "[center]{name}[/center]".format({
		card_title_UI.text = "{name}".format({
			"name": card.name,
		})
		card_desc_UI.text = "[center]{desc}[/center]".format({
			"desc": card.desc,
		})
		card_rarity_UI.text = "[center][color={color}]{rarity}[/color][/center]".format({
			"rarity": Items.rarity_prob[rarity].bbcode,
			"color": Items.rarity_prob[rarity].color,
		})
		
		# if it's common, make the glow less visible
		for rarity_blocker in card_scene.find_children("RarityBlocker", "", true):
			rarity_blocker.visible = true
			if rarity == Items.RARITIES.COMMON:
				rarity_blocker.modulate.a = 0.5
			else:
				rarity_blocker.modulate.a = 0.0

		card_title_UI.modulate.a = 0
		card_desc_UI.modulate.a = 0
		card_rarity_UI.modulate.a = 0
		
		var icon = card_scene.find_child("RarityIndicator") as Sprite2D
		icon.texture = Items.rarity_prob[rarity].icon
		
		var tex = card_scene.find_child("Texture") as AnimatedSprite2D
		tex.play("intro")
		var old_x = card_scene.scale.x
		card_scene.scale.x = 0
		card_scene.scale.y *= 2
		create_tween().tween_property(card_scene, "scale:x", old_x, 2/3.0).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CIRC)
		create_tween().tween_property(card_scene, "scale:y", card_scene.scale.y / 2.0, 2/3.0).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CIRC)
		
	
	await get_tree().create_timer(2/3.0).timeout
	for i in range(max_cards):
		var tex = get_child(i).find_child("Texture")
		var frame = tex.get_frame()
		var progress = tex.get_frame_progress()
		tex.play("default")
		tex.set_frame_and_progress(frame, progress)
		
		var card_title_UI: RichTextLabel = get_child(i).find_child("Title")
		var card_desc_UI: RichTextLabel = get_child(i).find_child("Desc")
		var card_rarity_UI: RichTextLabel = get_child(i).find_child("Rarity")
		
		create_tween().tween_property(card_title_UI, "modulate:a", 1.0, 0.25)
		create_tween().tween_property(card_desc_UI, "modulate:a", 1.0, 0.25)
		create_tween().tween_property(card_rarity_UI, "modulate:a", 1.0, 0.25)
