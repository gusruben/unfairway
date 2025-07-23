extends TextEdit


func _on_text_changed() -> void:
	if !self.text.contains("\n"):
		return
		
	var card_name = self.text.split("\n")[0]
	
	var found_card
	for rarity in Items.items:
		for card_object in Items.items[rarity]:
			if card_object.name.to_lower() == card_name.to_lower():
				found_card = card_object
				break
		
		if found_card:
			break
	
	# check which player to give the card to based on where the mouse is
	var player
	if get_global_mouse_position().x > 0:
		player = GameManager.PLAYER_TYPES.PLAYER2
	else:
		player = GameManager.PLAYER_TYPES.PLAYER1
		
	print("giving to ", player)
	
	if found_card:
		CaddyManager.on_card_pick(found_card, player)
	else:
		print("not found: '", card_name, "'")
	
	# reset the menu
	release_focus()
	text = ""
	visible = false
	CursorManager.hide()
	
