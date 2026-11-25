"""
Street Legend procedural fighter base generator.
Run with Blender 4.x:
  blender --background --python generate_fighter_pair.py
Creates two distinct, proportioned, bone-deformable base characters and FBX exports.
These are rigged prototype bases, not final photorealistic production characters.
Replace/upgrade meshes and textures before release.
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
        sh = (xoff + s*0.22, 0, 1.52)
        elbow = (xoff + s*0.39, 0, 1.22)
        wrist = (xoff + s*0.43, -0.01, 0.98)
        hand = (xoff + s*0.43, -0.02, 0.86)
        upper = make_bone(eb, "UpperArm."+side, sh, elbow, chest)
        fore = make_bone(eb, "LowerArm."+side, elbow, wrist, upper, True)
        make_bone(eb, "Hand."+side, wrist, hand, fore, True)
        hip = (xoff + s*0.12, 0, 0.92)
        knee = (xoff + s*0.13, 0, 0.52)
        ankle = (xoff + s*0.13, 0, 0.12)
        foot = (xoff + s*0.13, -0.13, 0.06)
        thigh = make_bone(eb, "UpperLeg."+side, hip, knee, pelvis)
        shin = make_bone(eb, "LowerLeg."+side, knee, ankle, thigh, True)
        make_bone(eb, "Foot."+side, ankle, foot, shin)
    bpy.ops.object.mode_set(mode="OBJECT")
    arm.show_in_front = True
    arm.data.display_type = "OCTAHEDRAL"
    return arm

def build_character(prefix, xoff, skin_color, shirt_color, pants_color, accent_color, broad=False):
    skin = material(prefix+"_Skin", skin_color, roughness=0.82)
    shirt = material(prefix+"_Streetwear", shirt_color, roughness=0.76)
    pants = material(prefix+"_Trousers", pants_color, roughness=0.88)
    accent = material(prefix+"_Accents", accent_color, metallic=0.08)
    eye = material(prefix+"_Eyes", (0.055, 0.035, 0.025), roughness=0.25)
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
    for s, side in ((-1,"L"),(1,"R")):
        uv_part(prefix+"_Ear_"+side, (xoff+s*0.124, 0, 1.82), (0.027,0.035,0.052), skin, "Head", arm, parts, 16, 12)
        uv_part(prefix+"_Eye_"+side, (xoff+s*0.047, -0.108, 1.855), (0.018,0.012,0.012), eye, "Head", arm, parts, 16, 12)
        # Upper/lower arms, deltoids, forearms and wrapped fists.
        uv_part(prefix+"_Shoulder_"+side, (xoff+s*0.245, 0, 1.51), (0.12,0.13,0.13), shirt, "UpperArm."+side, arm, parts)
        uv_part(prefix+"_UpperArm_"+side, (xoff+s*0.315, 0, 1.36), (0.095,0.095,0.19), skin, "UpperArm."+side, arm, parts)
        uv_part(prefix+"_Elbow_"+side, (xoff+s*0.39, 0, 1.22), (0.078,0.078,0.075), skin, "LowerArm."+side, arm, parts)
        uv_part(prefix+"_Forearm_"+side, (xoff+s*0.41, -0.005, 1.09), (0.078,0.075,0.15), skin, "LowerArm."+side, arm, parts)
        uv_part(prefix+"_Glove_"+side, (xoff+s*0.43, -0.025, 0.91), (0.075,0.085,0.085), accent, "Hand."+side, arm, parts)
        # Legs with separate trouser and lower-leg volumes.
        uv_part(prefix+"_Thigh_"+side, (xoff+s*0.12, 0, 0.73), (0.12,0.13,0.235), pants, "UpperLeg."+side, arm, parts)
        uv_part(prefix+"_Knee_"+side, (xoff+s*0.13, -0.005, 0.51), (0.09,0.10,0.09), pants, "LowerLeg."+side, arm, parts)
        uv_part(prefix+"_Shin_"+side, (xoff+s*0.13, 0, 0.31), (0.078,0.09,0.20), pants, "LowerLeg."+side, arm, parts)
        uv_part(prefix+"_Boot_"+side, (xoff+s*0.13, -0.10, 0.12), (0.09,0.17,0.075), accent, "Foot."+side, arm, parts)
    # Subtle brow and nose volumes, attached to head bone.
    uv_part(prefix+"_Nose", (xoff, -0.125, 1.82), (0.026,0.035,0.045), skin, "Head", arm, parts, 16, 12)
    for s in (-1,1):
        uv_part(prefix+"_Brow", (xoff+s*0.047, -0.111, 1.883), (0.031,0.018,0.012), skin, "Head", arm, parts, 16, 12)
    # Add a simple belt detail.
    uv_part(prefix+"_Belt", (xoff, -0.002, 1.075), (0.205,0.14,0.035), accent, "Hips", arm, parts)
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
        bake_anim=False,
        path_mode="COPY",
        embed_textures=True
    )
    print("Exported rigged base:", os.path.join(OUT, prefix+".fbx"))

clear_scene()
build_character("Wanimoo_Player", 0.0, (0.48,0.29,0.20), (0.035,0.16,0.31), (0.075,0.085,0.10), (0.035,0.045,0.055), broad=False)
clear_scene()
build_character("Hotel_Enforcer", 0.0, (0.30,0.17,0.11), (0.24,0.045,0.035), (0.10,0.075,0.055), (0.035,0.03,0.025), broad=True)
print("Street Legend fighter base exports complete. These are rigged greybox-art bases; production realism requires detailed sculpting, textures and authored animation.")
