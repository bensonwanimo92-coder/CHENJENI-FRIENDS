"""
Street Legend procedural fighter base generator.
Run with Blender 4.x:
  blender --background --python generate_fighter_pair.py
Creates two distinct, proportioned, bone-deformable base characters with starter idle/guard/jab/heavy-kick/hit/knockout animation takes.
These are rigged prototype bases, not final photorealistic production characters.
Replace/upgrade meshes and textures and tune the starter animation takes before release.
"""
import bpy
import math
import os
from mathutils import Vector

OUT = os.path.abspath(os.path.join(os.path.dirname(__file__), "../../Assets/Characters/Generated"))
os.makedirs(OUT, exist_ok=True)

def clear_scene():
    bpy.ops.object.select_all(action="SELECT")
    bpy.ops.object.delete(use_global=False)

def material(name, color, metallic=0.0, roughness=0.68):
    m = bpy.data.materials.new(name)
    m.diffuse_color = (*color, 1.0)
    m.use_nodes = True
    bs = m.node_tree.nodes.get("Principled BSDF")
    bs.inputs["Base Color"].default_value = (*color, 1.0)
    bs.inputs["Metallic"].default_value = metallic
    bs.inputs["Roughness"].default_value = roughness

    # Fine procedural surface breakup prevents completely flat plastic-looking materials.
    nodes = m.node_tree.nodes
    links = m.node_tree.links
    noise = nodes.new("ShaderNodeTexNoise")
    noise.name = name + "_FineSurface"
    noise.inputs["Scale"].default_value = 38.0 if "Skin" in name else 22.0
    noise.inputs["Detail"].default_value = 3.0
    noise.inputs["Roughness"].default_value = 0.72
    bump = nodes.new("ShaderNodeBump")
    bump.inputs["Strength"].default_value = 0.12 if "Skin" in name else 0.07
    bump.inputs["Distance"].default_value = 0.018 if "Skin" in name else 0.012
    links.new(noise.outputs["Fac"], bump.inputs["Height"])
    links.new(bump.outputs["Normal"], bs.inputs["Normal"])
    rough_map = nodes.new("ShaderNodeMapRange")
    rough_map.inputs["From Min"].default_value = 0.0
    rough_map.inputs["From Max"].default_value = 1.0
    rough_map.inputs["To Min"].default_value = max(0.18, roughness - 0.12)
    rough_map.inputs["To Max"].default_value = min(1.0, roughness + 0.12)
    links.new(noise.outputs["Fac"], rough_map.inputs["Value"])
    links.new(rough_map.outputs["Result"], bs.inputs["Roughness"])
    return m

def uv_part(name, loc, scale, mat, bone, arm, groups, segments=24, rings=16):
    bpy.ops.mesh.primitive_uv_sphere_add(segments=segments, ring_count=rings, location=loc)
    o = bpy.context.object
    o.name = name
    o.scale = scale
    bpy.ops.object.transform_apply(location=False, rotation=False, scale=True)
    o.data.materials.append(mat)
    for p in o.data.polygons:
        p.use_smooth = True
    vg = o.vertex_groups.new(name=bone)
    vg.add(list(range(len(o.data.vertices))), 1.0, "REPLACE")
    mod = o.modifiers.new("Deform - humanoid rig", "ARMATURE")
    mod.object = arm
    o.parent = arm
    groups.append(o)
    return o

def make_bone(eb, name, head, tail, parent=None, connected=False):
    b = eb.new(name)
    b.head = head
    b.tail = tail
    if parent:
        b.parent = parent
        b.use_connect = connected
    return b

def create_rig(prefix, xoff):
    bpy.ops.object.armature_add(enter_editmode=True, location=(0, 0, 0))
    arm = bpy.context.object
    arm.name = prefix + "_Rig"
    arm.data.name = prefix + "_Humanoid"
    eb = arm.data.edit_bones
    root = eb[0]
    root.name = "Root"
    root.head = (xoff, 0, 0.08)
    root.tail = (xoff, 0, 0.95)
    pelvis = make_bone(eb, "Hips", (xoff, 0, 0.92), (xoff, 0, 1.12), root)
    spine = make_bone(eb, "Spine", (xoff, 0, 1.12), (xoff, 0, 1.38), pelvis)
    chest = make_bone(eb, "Chest", (xoff, 0, 1.38), (xoff, 0, 1.58), spine)
    neck = make_bone(eb, "Neck", (xoff, 0, 1.58), (xoff, 0, 1.72), chest)
    head = make_bone(eb, "Head", (xoff, 0, 1.72), (xoff, 0, 1.98), neck)
    for side, s in (("L", -1), ("R", 1)):
        prefix_side = "Left" if side == "L" else "Right"
        sh = (xoff + s*0.22, 0, 1.52)
        elbow = (xoff + s*0.39, 0, 1.22)
        wrist = (xoff + s*0.43, -0.01, 0.98)
        hand = (xoff + s*0.43, -0.02, 0.86)
        upper = make_bone(eb, prefix_side+"UpperArm", sh, elbow, chest)
        fore = make_bone(eb, prefix_side+"LowerArm", elbow, wrist, upper, True)
        make_bone(eb, prefix_side+"Hand", wrist, hand, fore, True)
        hip = (xoff + s*0.12, 0, 0.92)
        knee = (xoff + s*0.13, 0, 0.52)
        ankle = (xoff + s*0.13, 0, 0.12)
        foot = (xoff + s*0.13, -0.13, 0.06)
        thigh = make_bone(eb, prefix_side+"UpperLeg", hip, knee, pelvis)
        shin = make_bone(eb, prefix_side+"LowerLeg", knee, ankle, thigh, True)
        make_bone(eb, prefix_side+"Foot", ankle, foot, shin)
    bpy.ops.object.mode_set(mode="OBJECT")
    arm.show_in_front = True
    arm.data.display_type = "OCTAHEDRAL"
    return arm

def add_combat_actions(arm, prefix):
    """Create simple, editable humanoid motion takes for Unity's Humanoid importer."""
    arm.animation_data_create()
    bones = arm.pose.bones
    for bone in bones:
        bone.rotation_mode = "XYZ"

    def key_pose(action_name, frames):
        action = bpy.data.actions.new(prefix + "_" + action_name)
        arm.animation_data.action = action
        for frame, pose in frames:
            bpy.context.scene.frame_set(frame)
            for bone in bones:
                bone.rotation_euler = (0.0, 0.0, 0.0)
            for bone_name, angles in pose.items():
                if bone_name in bones:
                    bones[bone_name].rotation_euler = angles
            for bone in bones:
                bone.keyframe_insert(data_path="rotation_euler", frame=frame, group=bone.name)
        action.frame_range = (frames[0][0], frames[-1][0])
        return action

    # Angles are intentionally restrained; final tuning should be done against the imported rig.
    key_pose("SL_Idle", [
        (1, {}),
        (12, {"Chest": (0.025, 0.0, 0.0), "Head": (-0.015, 0.0, 0.0)}),
        (24, {}),
    ])
    guard = {
        "LeftUpperArm": (0.0, 0.0, -0.48), "RightUpperArm": (0.0, 0.0, 0.48),
        "LeftLowerArm": (0.0, 0.0, -0.72), "RightLowerArm": (0.0, 0.0, 0.72),
        "Chest": (0.0, 0.0, 0.035),
    }
    key_pose("SL_Guard", [(1, {}), (5, guard), (18, guard), (24, {})])
    jab = {
        "RightUpperArm": (0.0, 0.0, 1.05), "RightLowerArm": (0.0, 0.0, 0.18),
        "LeftUpperArm": (0.0, 0.0, -0.42), "LeftLowerArm": (0.0, 0.0, -0.68),
        "Chest": (0.0, 0.0, 0.12),
    }
    key_pose("SL_Jab", [(1, guard), (4, {"RightUpperArm": (0.0, 0.0, 0.25)}), (8, jab), (11, jab), (17, guard), (22, {})])
    heavy = {
        "RightUpperArm": (0.0, 0.0, 1.25), "RightLowerArm": (0.0, 0.0, 0.32),
        "LeftUpperLeg": (0.75, 0.0, 0.0), "LeftLowerLeg": (-0.95, 0.0, 0.0),
        "Chest": (0.0, 0.0, 0.2),
    }
    key_pose("SL_HeavyKick", [(1, guard), (5, {"LeftUpperLeg": (0.2, 0.0, 0.0)}), (10, heavy), (13, heavy), (20, guard), (26, {})])
    hit = {
        "Chest": (-0.18, 0.0, 0.0), "Head": (-0.12, 0.0, 0.0),
        "LeftUpperArm": (0.0, 0.0, -0.8), "RightUpperArm": (0.0, 0.0, 0.8),
    }
    key_pose("SL_HitReact", [(1, {}), (4, hit), (8, hit), (15, guard), (21, {})])
    down = {
        "Chest": (-0.55, 0.0, 0.0), "Head": (-0.35, 0.0, 0.0),
        "LeftUpperLeg": (0.45, 0.0, 0.0), "RightUpperLeg": (-0.45, 0.0, 0.0),
        "LeftUpperArm": (0.0, 0.0, -0.85), "RightUpperArm": (0.0, 0.0, 0.85),
    }
    key_pose("SL_Knockout", [(1, {}), (10, hit), (20, down), (32, down)])


def build_character(prefix, xoff, skin_color, shirt_color, pants_color, accent_color, broad=False):
    skin = material(prefix+"_Skin", skin_color, roughness=0.82)
    shirt = material(prefix+"_Streetwear", shirt_color, roughness=0.76)
    pants = material(prefix+"_Trousers", pants_color, roughness=0.88)
    accent = material(prefix+"_Accents", accent_color, metallic=0.08)
    eye = material(prefix+"_Eyes", (0.055, 0.035, 0.025), roughness=0.25)
    hair = material(prefix+"_Hair", (0.025, 0.018, 0.014) if not broad else (0.055, 0.035, 0.025), roughness=0.58)
    lip = material(prefix+"_Lips", (0.22, 0.075, 0.055), roughness=0.72)
    arm = create_rig(prefix, xoff)
    parts = []
    torso_w = 0.27 if broad else 0.235
    # Anatomical core, layered clothing silhouette and neck/head.
    uv_part(prefix+"_Pelvis", (xoff, 0, 0.99), (0.205, 0.135, 0.17), pants, "Hips", arm, parts)
    uv_part(prefix+"_Abdomen", (xoff, 0, 1.25), (0.19, 0.12, 0.22), shirt, "Spine", arm, parts)
    uv_part(prefix+"_Chest", (xoff, 0, 1.48), (torso_w, 0.145, 0.205), shirt, "Chest", arm, parts)
    uv_part(prefix+"_Neck", (xoff, 0, 1.65), (0.075, 0.075, 0.12), skin, "Neck", arm, parts)
    uv_part(prefix+"_Head", (xoff, -0.005, 1.82), (0.125, 0.115, 0.17), skin, "Head", arm, parts, 32, 24)
    # Jaw/chin and ears give the silhouette more human definition.
    uv_part(prefix+"_Jaw", (xoff, -0.045, 1.75), (0.092, 0.085, 0.075), skin, "Head", arm, parts)
    # Hair cap, hairline, and mouth detail improve the facial silhouette.
    uv_part(prefix+"_HairCap", (xoff, 0.005, 1.935), (0.132, 0.12, 0.085), hair, "Head", arm, parts, 32, 16)
    uv_part(prefix+"_Hairline", (xoff, -0.082, 1.925), (0.105, 0.045, 0.035), hair, "Head", arm, parts, 24, 12)
    if broad:
        uv_part(prefix+"_ShortHairBack", (xoff, 0.075, 1.86), (0.12, 0.09, 0.12), hair, "Head", arm, parts)
    else:
        uv_part(prefix+"_HairSweep", (xoff-0.035, -0.055, 1.985), (0.09, 0.09, 0.045), hair, "Head", arm, parts)
    uv_part(prefix+"_Mouth", (xoff, -0.128, 1.765), (0.038, 0.009, 0.009), lip, "Head", arm, parts, 20, 12)
    for s, side in ((-1,"L"),(1,"R")):
        prefix_side = "Left" if side == "L" else "Right"
        uv_part(prefix+"_Ear_"+side, (xoff+s*0.124, 0, 1.82), (0.027,0.035,0.052), skin, "Head", arm, parts, 16, 12)
        uv_part(prefix+"_Eye_"+side, (xoff+s*0.047, -0.108, 1.855), (0.018,0.012,0.012), eye, "Head", arm, parts, 16, 12)
        # Upper/lower arms, deltoids, forearms and wrapped fists.
        uv_part(prefix+"_Shoulder_"+side, (xoff+s*0.245, 0, 1.51), (0.12,0.13,0.13), shirt, prefix_side+"UpperArm", arm, parts)
        uv_part(prefix+"_UpperArm_"+side, (xoff+s*0.315, 0, 1.36), (0.095,0.095,0.19), skin, prefix_side+"UpperArm", arm, parts)
        uv_part(prefix+"_Elbow_"+side, (xoff+s*0.39, 0, 1.22), (0.078,0.078,0.075), skin, prefix_side+"LowerArm", arm, parts)
        uv_part(prefix+"_Forearm_"+side, (xoff+s*0.41, -0.005, 1.09), (0.078,0.075,0.15), skin, prefix_side+"LowerArm", arm, parts)
        uv_part(prefix+"_Glove_"+side, (xoff+s*0.43, -0.025, 0.91), (0.075,0.085,0.085), accent, prefix_side+"Hand", arm, parts)
        # Legs with separate trouser and lower-leg volumes.
        uv_part(prefix+"_Thigh_"+side, (xoff+s*0.12, 0, 0.73), (0.12,0.13,0.235), pants, prefix_side+"UpperLeg", arm, parts)
        uv_part(prefix+"_Knee_"+side, (xoff+s*0.13, -0.005, 0.51), (0.09,0.10,0.09), pants, prefix_side+"LowerLeg", arm, parts)
        uv_part(prefix+"_Shin_"+side, (xoff+s*0.13, 0, 0.31), (0.078,0.09,0.20), pants, prefix_side+"LowerLeg", arm, parts)
        uv_part(prefix+"_Boot_"+side, (xoff+s*0.13, -0.10, 0.12), (0.09,0.17,0.075), accent, prefix_side+"Foot", arm, parts)
    # Subtle brow and nose volumes, attached to head bone.
    uv_part(prefix+"_Nose", (xoff, -0.125, 1.82), (0.026,0.035,0.045), skin, "Head", arm, parts, 16, 12)
    for s in (-1,1):
        uv_part(prefix+"_Brow", (xoff+s*0.047, -0.111, 1.883), (0.031,0.018,0.012), skin, "Head", arm, parts, 16, 12)
    # Add a simple belt detail.
    uv_part(prefix+"_Belt", (xoff, -0.002, 1.075), (0.205,0.14,0.035), accent, "Hips", arm, parts)
    # Add starter combat motion takes before exporting the humanoid rig.
    add_combat_actions(arm, prefix)

    # Keep rig and all skinned pieces selected for export.
    bpy.ops.object.select_all(action="DESELECT")
    arm.select_set(True)
    for obj in parts:
        obj.select_set(True)
    bpy.context.view_layer.objects.active = arm
    bpy.ops.export_scene.fbx(
        filepath=os.path.join(OUT, prefix+".fbx"),
        use_selection=True,
        object_types={"ARMATURE","MESH"},
        apply_unit_scale=True,
        apply_scale_options="FBX_SCALE_ALL",
        add_leaf_bones=False,
        bake_anim=True,
        bake_anim_use_all_actions=True,
        bake_anim_use_nla_strips=False,
        bake_anim_force_startend_keying=True,
        bake_anim_step=1.0,
        bake_anim_simplify_factor=0.0,
        path_mode="COPY",
        embed_textures=True
    )
    print("Exported rigged base:", os.path.join(OUT, prefix+".fbx"))

clear_scene()
build_character("Wanimoo_Player", 0.0, (0.48,0.29,0.20), (0.035,0.16,0.31), (0.075,0.085,0.10), (0.035,0.045,0.055), broad=False)
clear_scene()
build_character("Hotel_Enforcer", 0.0, (0.30,0.17,0.11), (0.24,0.045,0.035), (0.10,0.075,0.055), (0.035,0.03,0.025), broad=True)
print("Street Legend fighter base exports complete. These are rigged greybox-art bases; production realism requires detailed sculpting, textures and authored animation.")
