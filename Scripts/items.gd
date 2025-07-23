extends Node

enum RARITIES {
	COMMON,
	RARE,
	EPIC,
	LEGENDARY,
	
	EXOTIC,
	SECRET,
}

var rarity_prob = {
	RARITIES.COMMON: {"prob": 4500, "bbcode": "Common", "color": "#d2dfe5", "icon": preload("res://Assets/Sprites/rarity-indicator-common.png")},
	RARITIES.RARE: {"prob": 2500, "bbcode": "Rare", "color": "#a3d4ed", "icon": preload("res://Assets/Sprites/rarity-indicator-rare.png")},
	RARITIES.EPIC: {"prob": 1000, "bbcode": "Epic", "color": "#ffb0f3", "icon": preload("res://Assets/Sprites/rarity-indicator-epic.png")},
	RARITIES.LEGENDARY: {"prob": 0, "bbcode": "Legendary", "color": "#edd196", "icon": preload("res://Assets/Sprites/rarity-indicator-legendary.png")},
	
	RARITIES.EXOTIC: {"prob": 0, "bbcode": "Exotic", "color": "#88ffaa", "icon": preload("res://Assets/Sprites/rarity-indicator-exotic.png")},
	RARITIES.SECRET: {"prob": 0, "bbcode": "Secret", "color": "#ff8888", "icon": preload("res://Assets/Sprites/rarity-indicator-secret.png")}
}	

func get_rarity(rarity: int):
	for i in rarity_prob:
		if rarity <= rarity_prob[i].prob:
			return i
		rarity -= rarity_prob[i].prob
	assert(false)

var rarity_total = 0

var rich_text_formats = {
	"bgn": "[color=#6cff96]", # green
	"egn": "[/color]",
	"bbn": "[color=#ff8888]", # red
	"ebn": "[/color]",
	"bs": "[color=#fcd583]", # orange
	"es": "[/color]",
	"oa": "[color=#88faff]On Ability[/color]", # light blue
	"os": "[color=#88faff]On Swing[/color]",
	"bt": "[font_size=24]",
	"et": "[/font_size]",
}

var items = {
	RARITIES.COMMON: [
		{
			"name": "Big Arm",
			"desc": "{bgn}+20%{egn} Swing Power".format(rich_text_formats),
		},
		{
			"name": "Bouncy Ball",
			"desc": "{bgn}+0.4{egn} Bouncyness".format(rich_text_formats),
		},
		{
			"name": "Quicker Cooldown",
			"desc": "{bgn}-0.5{bt}s{et}{egn} Ability Cooldown Time\n{bbn}+10%{ebn} Mass".format(rich_text_formats),
		},
	],
	RARITIES.RARE: [
		{
			"name": "Small Ball",
			"desc": "{bgn}-15%{egn} Ball Size\n{bgn}-10%{egn} Ball Mass\n{bbn}-10%{ebn} Swing Power".format(rich_text_formats),
		},
		{
			"name": "Dash",
			"desc": "{oa}, dash forward\n{bbn}+0.5{bt}s{et}{ebn} ability cooldown".format(rich_text_formats),
		},
		{
			"name": "Double Jump",
			"desc": "{oa}, jump upwards\n{bbn}+0.5{bt}s{et}{ebn} ability cooldown".format(rich_text_formats),
		},
	],
	RARITIES.EPIC: [
		{
			"name": "Repulsion Field",
			"desc": "{bgn}+50%{egn} Passive enemy repulsion".format(rich_text_formats),
		},
		{
			"name": "Gravity Well",
			"desc": "{oa}, attract enemy for {bs}5{bt}s{et}{es}\n{bbn}+3{bt}s{et}{ebn} ability cooldown".format(rich_text_formats),
		},
		#{
			#"name": "Sticky Ball",
			#"desc": "Ball {bs}sticks{es} to walls".format(rich_text_formats),
		#},
		{
			"name": "Perfect Form",
			"desc": "{bgn}-2{bt}s{et}{egn} Ability Cooldown\n{bgn}+20%{egn} Swing Power".format(rich_text_formats),
		},
	],	
	RARITIES.LEGENDARY: [
		{
			"name": "Sniper",
			"desc": "{oa}, snipe the enemy and send them flying!\n{bbn}+15%{ebn} Ability Cooldown".format(rich_text_formats)
		},
		{
			"name": "Bouncy Blocker",
			"desc": "{oa}, build a bouncer next to the enemy and bounce them away!\n{bbn}+15%{ebn} Ability Cooldown".format(rich_text_formats)
		},
		{
			"name": "Snake Launcher",
			"desc": "{os}, launch a flying snake to discombobulate the enemy!".format(rich_text_formats)
		},
	],
	RARITIES.EXOTIC: [],
	RARITIES.SECRET: [],
}

func _ready() -> void:
	for i in rarity_prob:
		rarity_total += rarity_prob[i].prob
