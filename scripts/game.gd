extends Node2D

@export var ending_screen: EndingScreen

func show_game_over(reason: String):
	if ending_screen:
		ending_screen.show_ending(reason)
	else:
		print("No ending screen found!")

func player_died():
	show_game_over("The warrior has fallen!")

func castle_destroyed():
	show_game_over("Your castle was destroyed!")
