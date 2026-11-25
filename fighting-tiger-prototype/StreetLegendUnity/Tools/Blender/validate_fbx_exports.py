import bpy, os, sys

root=os.path.abspath(os.path.join(os.path.dirname(__file__),"../../Assets/Characters/Generated"))
names=["Wanimoo_Player","Hotel_Enforcer"]
required={"SL_Idle","SL_Walk","SL_Guard","SL_Jab","SL_HeavyKick","SL_HitReact","SL_Knockout"}
for name in names:
    path=os.path.join(root,name+".fbx")
    if not os.path.isfile(path) or os.path.getsize(path)<1000:
        raise RuntimeError("Missing/empty FBX: "+path)
    bpy.ops.wm.read_factory_settings(use_empty=True)
    bpy.ops.import_scene.fbx(filepath=path)
    armatures=[o for o in bpy.context.scene.objects if o.type=="ARMATURE"]
    meshes=[o for o in bpy.context.scene.objects if o.type=="MESH"]
    if not armatures or not meshes:
        raise RuntimeError(name+": missing armature or mesh")
    arm=armatures[0]
    bones={b.name for b in arm.data.bones}
    for bone in ["Hips","Spine","Chest","Head","LeftUpperArm","RightUpperArm","LeftUpperLeg","RightUpperLeg"]:
        if bone not in bones: raise RuntimeError(name+": missing bone "+bone)
    animation_names={a.name for a in bpy.data.actions}
    # FBX import may prefix action names; match expected clip tokens.
    missing=[clip for clip in required if not any(clip.lower() in action.lower() for action in animation_names)]
    if missing: raise RuntimeError(name+": missing animation clips "+str(missing)+"; imported="+str(animation_names))
    print(name+": PASS, armature bones="+str(len(bones))+", meshes="+str(len(meshes))+", actions="+str(len(animation_names)))
print("FBX reopen/import validation PASS")
