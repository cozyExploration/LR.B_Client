extends Node

@onready var player_module_chunk_projection := $"../chunk_projection" as Chunk_projection
@onready var space_module_chunk := %space_modules/chunk as Chunk
@onready var player_module_player := $"../player"
@onready var player = %offline_player

func handle(v : Dictionary):
	var head_rotation
	match v.get("Request"):
		"spawn":
			print("request spawn received!")
			# init chunk
			space_module_chunk.init()
			# load player
			player_module_player.load_player(v.ID)
			var position = player.position
			head_rotation = %offline_player/head.rotation.x
			var player_rotation = %offline_player.rotation.y
			# sync
			terminal.handle(
				{
					"Hub" : terminal.local_hub,
					"ModuleContainer" : "Player",
					"Module" : "player_motion_sync",
					"Content" : {
						"sync_position" : [position.x,position.y,position.z], 
						"sync_head_rotation" : [head_rotation, player_rotation]
					}
				}
			)

	
	# sync head_rotation
	head_rotation = v.get("sync_head_rotation")
	if head_rotation != null:
		%offline_player/head.rotation.x = head_rotation[0]
		%offline_player.rotation.y = head_rotation[1]
	# sync pos
	var pos = v.get("sync_position")
	if pos != null:
		player.position = Vector3(pos[0], pos[1], pos[2])
		
#	print("sync -> ", %player/head.global_rotation_degrees, " / ", %player.position)
