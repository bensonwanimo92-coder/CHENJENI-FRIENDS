extends SceneTree
# Run headless from the project root: godot --headless --script scripts/asset_audit.gd
# Reports whether expected GLB asset slots are present; does not claim to validate imported meshes.

const EXPECTED := [
	"assets/fighters/player.glb",
	"assets/fighters/enemy.glb",
	"assets/fighters/boss.glb",
	"assets/environment/road.glb",
	"assets/environment/buildings.glb",
	"assets/environment/bridge.glb",
	"assets/vehicles/vehicle.glb",
]

func _initialize() -> void:
	print("Street Legend asset-slot audit")
	var found := 0
	for relative_path in EXPECTED:
		var path := "res://" + relative_path
		if FileAccess.file_exists(path):
			found += 1
			print("[FOUND] ", relative_path)
		else:
			print("[MISSING] ", relative_path)
	print("Slots present: %d/%d" % [found, EXPECTED.size()])
	print("This audit checks file presence only; verify imports, textures, scale, rig and animations in Godot editor.")
	quit()
