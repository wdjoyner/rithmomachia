
"""
Integrated Blender Module: Professor Pyramid Teaching Rithmomachia

This module combines the Professor Pyramid character creation and animation system
with the Rithmomachia board game educational tutorial. Professor Pyramid appears
above and to the right of the game board, delivering animated lessons about pyramid
pieces while demonstrating moves on the board below.

The module handles:
1. Character creation (Professor Pyramid with full body, limbs, and facial features)
2. Game board setup with pieces (circles, triangles, squares, pyramids)
3. Educational animation sequence with scrolling text
4. Coordinated camera work and lighting
5. Character animation (walking, gesturing, mouth movement)
6. Game piece highlighting and movement demonstrations
7. Geometric figures needed to illustrate a point made by professor pyramid,
   such as a pyramid made of spheres, can be moved around just like
   rithmomachia pieces.

Last Modified: 2025-09-09

Edits are needed to the grammar in the animation_scenes list of dictionaries.
Also, replace "non-no's" with "forbidden actions"
"""

import bpy
import copy
import bmesh
import math
import os
from mathutils import Vector, Matrix
import mathutils
import sys

# =============================================================================
# GLOBAL CONFIGURATION AND CONSTANTS
# =============================================================================

# Global text management for educational content
current_top_text = None
current_bottom_text = None

# Pyramid piece configurations
WHITE_PYRAMID_VALUES = [1, 4, 9, 16, 25, 36]
BLACK_PYRAMID_VALUES = [16, 25, 36, 49, 64]

# Game board configurations - these represent different educational scenarios
INITIAL_GAME_BOARD = [
    ['S289_1', 'S153_1', 'T081_1', '', '', '', '', '', '', '', '', '', '', 't016_1', 's028_1', 's049_1'],
    ['S169_1', 'P091_1', 'T072_1', '', '', '', '', '', '', '', '', '', '', 't012_1', 's066_1', 's121_1'], 
    ['', 'T049_1', 'C064_1', 'C008_1', '', '', '', '', '', '', '', '', 'c003_1', 'c009_1', 't036_1', ''],
    ['', 'T042_1', 'C036_1', 'C006_1', '', '', '', '', '', '', '', '', 'c005_1', 'c025_1', 't030_1', ''],
    ['', 'T020_1', 'C016_1', 'C004_1', '', '', '', '', '', '', '', '', 'c007_1', 'c049_1', 't056_1', ''],
    ['', 'T025_1', 'C004_2', 'C002_1', '', '', '', '', '', '', '', '', 'c009_2', 'c081_1', 't064_1', ''], 
    ['S081_1', 'S045_1', 'T006_1', '', '', '', '', '', '', '', '', '', '', 't090_1', 's120_1', 's225_1'],
    ['S025_1', 'S015_1', 'T009_1', '', '', '', '', '', '', '', '', '', '', 't100_1', 'p190_1', 's361_1']
]

CUSTOM_GAME_BOARD = [
    ['', '      ', '', '', '', '', '', '', '', '', '', '', '', '', '      ', ''],
    ['', 'P091_1', '', '', '', '', '', '', '', '', '', '', '', '', '      ', ''], 
    ['', '      ', '', '', '', '', '', '', '', '', '', '', '', '', '      ', ''],
    ['', '      ', '', '', '', '', '', '', '', '', '', '', '', '', '      ', ''],
    ['', '      ', '', '', '', '', '', '', '', '', '', '', '', '', '      ', ''],
    ['', '      ', '', '', '', '', '', '', '', '', '', '', '', '', '      ', ''], 
    ['', '      ', '', '', '', '', '', '', '', '', '', '', '', '', '      ', ''],
    ['', '      ', '', '', '', '', '', '', '', '', '', '', '', '', 'p190_1', '']
]

# Professor Pyramid configuration
PROFESSOR_CONFIG = {
    # Position - shifted forward and positioned to face camera
    "com": Vector((-2, 3, 0.5)),  # Your updated position
    "pyramid_height": 1.5,
    "pyramid_base_scale": 0.8,
    
    # Character rotation - will be applied to main body
    "body_rotation": math.radians(90),  # Your updated rotation (positive 90 degrees)
    
    # Limbs
    "arm_radius": 0.06,
    "leg_radius": 0.10,
    "leg_length": 1.0,
    "hand_size": Vector((0.15, 0.15, 0.25)),
    "foot_size": Vector((0.20, 0.35, 0.15)),
    
    # Animation parameters
    "step_length": 0.6,
    "step_height": 0.15,
    "frames_per_step": 20,
    "num_steps": 100,
    
    # Pointer (teaching tool)
    "pointer_len": 1.2,
    "pointer_radius": 0.025,
    "pointer_theta": -45,
    "pointer_z_offset": 0.0,
    
    # Camera positioning for integrated scene
    "camera_location": Vector((40.0, 0.0, 35.0)),  # Your updated camera position
}

# =============================================================================
# UTILITY FUNCTIONS FOR MATERIALS AND BASIC OBJECTS
# =============================================================================

def get_or_create_material(name, color, is_emission=False, shininess=0.8):
    """
    Creates or retrieves a Blender material with specified properties.
    
    This function manages material creation with support for both standard BSDF
    and emission shaders. It includes shininess control for metallic/reflective
    surfaces, which is used extensively for game pieces and Professor Pyramid's
    body parts.
    
    Args:
        name (str): Unique identifier for the material
        color (tuple): RGBA color values (0.0-1.0 range)
        is_emission (bool): If True, creates emission shader for glowing effects
        shininess (float): Controls metallic/roughness properties (0.0=matte, 1.0=mirror)
    
    Returns:
        bpy.types.Material: The created or existing material object
    
    Usage in animation:
        - Game pieces use shininess=0.8 for polished appearance
        - Highlighting effects use is_emission=True
        - Professor Pyramid uses varied shininess for different body parts
    """
    mat = bpy.data.materials.get(name)
    if not mat:
        mat = bpy.data.materials.new(name=name)
        mat.use_nodes = True
    
    nodes = mat.node_tree.nodes
    links = mat.node_tree.links
    
    # Clear existing nodes for clean setup
    for node in nodes:
        nodes.remove(node)

    output_node = nodes.new(type='ShaderNodeOutputMaterial')
    output_node.location = (200, 0)
    
    if is_emission:
        emission_node = nodes.new(type='ShaderNodeEmission')
        emission_node.inputs['Color'].default_value = color
        emission_node.inputs['Strength'].default_value = 1.0
        emission_node.location = (0, 0)
        links.new(emission_node.outputs['Emission'], output_node.inputs['Surface'])
    else:
        bsdf_node = nodes.new(type='ShaderNodeBsdfPrincipled')
        bsdf_node.inputs['Base Color'].default_value = color
        bsdf_node.inputs['Metallic'].default_value = shininess
        bsdf_node.inputs['Roughness'].default_value = 1.1 - shininess
        bsdf_node.location = (0, 0)
        links.new(bsdf_node.outputs['BSDF'], output_node.inputs['Surface'])
        
    return mat


def create_stacked_slabs_graphic(location, slab_sizes, obj_type="cube", diameter=1.0, sep_dist=0.1, name="SlabStack", stack_color = (0.6, 0.1, 0.1, 1.0)):
    """
    Creates a stack of n x n slabs made of smaller spheres or cubes.

    The slabs are built from the bottom up based on the slab_sizes list.
    The entire structure is parented to a single empty object for easy animation.

    Args:
        location (Vector): The world-space location for the base of the entire stack.
        slab_sizes (list): A list of integers defining the slab sizes from bottom to top (e.g., [5, 3, 2]).
        obj_type (str): The type of unit to use, either "cube" or "sphere".
        diameter (float): The diameter (or size) of each individual cube or sphere.
        sep_dist (float): The separation distance between units and between slabs.
        name (str): The base name for the parent object.

    Returns:
        bpy.types.Object: The parent empty object of the entire slab stack.
    """
    # 1. Create a single Empty object to be the parent for the entire structure.
    # This allows us to move the whole complex object as one unit.
    bpy.ops.object.empty_add(type='PLAIN_AXES', location=location)
    parent_obj = bpy.context.active_object
    parent_obj.name = name

    # Get a material for the units
    stack_material = get_or_create_material(f"{name}_Material", stack_color, shininess=0.8)
    
    current_z_offset = 0.0 # This will track the vertical height as we build the stack

    # 2. Iterate through the slab sizes to build each slab from the bottom up
    for n in slab_sizes:
        if n <= 0:
            continue # Skip invalid slab sizes

        # 3. Calculate dimensions for the current n x n slab to ensure it's centered
        slab_width = (n * diameter) + ((n - 1) * sep_dist)
        # The starting point for the first unit's center, to center the whole slab
        start_offset = -slab_width / 2.0 + diameter / 2.0

        # 4. Create the n x n grid of objects for the current slab
        for i in range(n):  # Corresponds to Y-axis
            for j in range(n):  # Corresponds to X-axis
                
                # Calculate the local position for this unit relative to the parent empty
                local_pos = Vector((
                    start_offset + j * (diameter + sep_dist),
                    start_offset + i * (diameter + sep_dist),
                    current_z_offset + diameter / 2.0
                ))

                # Create the specified primitive object
                if obj_type.lower() == "sphere":
                    bpy.ops.mesh.primitive_uv_sphere_add(radius=diameter / 2.0, location=local_pos)
                elif obj_type.lower() == "cube":
                    bpy.ops.mesh.primitive_cube_add(size=diameter, location=local_pos)
                else:
                    print(f"Warning: Unknown object type '{obj_type}'. Defaulting to cube.")
                    bpy.ops.mesh.primitive_cube_add(size=diameter, location=local_pos)

                unit_obj = bpy.context.active_object
                
                # Assign material and parent the unit to the main empty
                if len(unit_obj.data.materials) == 0:
                    unit_obj.data.materials.append(stack_material)
                
                unit_obj.parent = parent_obj

        # 5. Update the vertical offset for the next slab
        current_z_offset += diameter + sep_dist

    return parent_obj
    
    
def create_cylinder_between(p1, p2, radius, name, segments=32):
    """
    Creates a cylinder mesh connecting two 3D points with proper local coordinates.
    
    This is a critical utility function used throughout the module for creating
    limbs, pointers, and connecting elements. It avoids rotation operations by
    calculating the local coordinate system mathematically and positioning vertices
    directly in world space before converting to local coordinates.
    
    Args:
        p1 (Vector): Start point of the cylinder (becomes object origin)
        p2 (Vector): End point of the cylinder
        radius (float): Cylinder radius
        name (str): Object name for the created cylinder
        segments (int): Number of circular segments (detail level)
    
    Returns:
        bpy.types.Object: The created cylinder object, or None if invalid
    
    Key Features:
        - No rotation matrices used - direct vertex computation
        - Origin set to p1 for proper armature attachment
        - Local coordinate transformation for animation compatibility
        
    Usage in animation:
        - Professor Pyramid's arms and legs
        - Pointer teaching tool
        - Any connecting geometry between two points
    """
    p1 = Vector(p1)
    p2 = Vector(p2)

    # Calculate orientation vectors for cylinder caps
    vec = p2 - p1
    length = vec.length
    if length < 1e-8:  # Cannot create zero-length cylinder
        print(f"Warning: Could not create cylinder '{name}' with zero length.")
        return None
    
    z_axis = vec.normalized()
    
    # Find an arbitrary vector not parallel to cylinder axis
    if abs(z_axis.x) > 0.999 or abs(z_axis.y) > 0.999:
        not_z = Vector((0, 0, 1))
    else:
        not_z = Vector((1, 0, 0))
        
    x_axis = z_axis.cross(not_z).normalized()
    y_axis = z_axis.cross(x_axis).normalized()

    # Generate vertices in world space
    verts = []
    # First cap vertices (at p1)
    for i in range(segments):
        angle = 2 * math.pi * i / segments
        pt_on_circle = radius * Vector((math.cos(angle), math.sin(angle)))
        verts.append(p1 + (pt_on_circle.x * x_axis) + (pt_on_circle.y * y_axis))
        
    # Second cap vertices (at p2)
    for i in range(segments):
        angle = 2 * math.pi * i / segments
        pt_on_circle = radius * Vector((math.cos(angle), math.sin(angle)))
        verts.append(p2 + (pt_on_circle.x * x_axis) + (pt_on_circle.y * y_axis))

    # Generate faces for cylinder geometry
    faces = []
    # Side faces connecting the two caps
    for i in range(segments):
        v1 = i
        v2 = (i + 1) % segments
        v3 = v2 + segments
        v4 = v1 + segments
        faces.append((v1, v2, v3, v4))
    # End caps
    faces.append(tuple(range(segments)))
    faces.append(tuple(range(segments, 2 * segments)))

    # Create mesh and object
    mesh_data = bpy.data.meshes.new(name + "_mesh")
    mesh_data.from_pydata(verts, [], faces)
    mesh_data.update()

    obj = bpy.data.objects.new(name, mesh_data)
    bpy.context.collection.objects.link(obj)

    # Critical: Set origin to p1 and adjust vertices to local coordinates
    # This ensures proper armature deformation for animation
    obj.location = p1
    for v in obj.data.vertices:
        v.co -= p1
        
    return obj

def create_ellipsoid(location, size, name):
    """
    Creates a scaled sphere (ellipsoid) for hands, feet, and facial features.
    
    This function generates ellipsoidal objects by creating a UV sphere and
    scaling it non-uniformly. Used for Professor Pyramid's hands, feet,
    eyes, and mouth components.
    
    Args:
        location (Vector): 3D position for the ellipsoid center
        size (Vector): Scale factors for X, Y, Z axes
        name (str): Object identifier
    
    Returns:
        bpy.types.Object: The created ellipsoid object
        
    Usage in animation:
        - Professor Pyramid's hands and feet
        - Facial features (eyes, mouth when sphere-based)
        - Any organic-shaped elements requiring non-uniform scaling
    """
    bpy.ops.mesh.primitive_uv_sphere_add(location=location)
    obj = bpy.context.object
    obj.scale = size
    obj.name = name
    return obj

# =============================================================================
# PROFESSOR PYRAMID CHARACTER CREATION FUNCTIONS
# =============================================================================

def create_professor_body(config):
    """
    Creates the main pyramid body for Professor Pyramid character.
    
    This function constructs a five-sided pyramid mesh from vertices defined
    by the configuration parameters. The pyramid serves as the central body
    that all other character components attach to.
    
    Args:
        config (dict): Configuration dictionary containing:
            - "com": Center of mass position (Vector)
            - "pyramid_height": Height of the pyramid
            - "pyramid_base_scale": Scale factor for base size
    
    Returns:
        tuple: (pyramid_object, vertex_list)
            - pyramid_object: The main body mesh object
            - vertex_list: List of pyramid vertices for face/limb positioning
    
    Vertex Layout:
        - p0: Apex (top point)
        - p1-p4: Base vertices in counterclockwise order
        
    Usage in animation:
        - Serves as parent object for all other character parts
        - Provides attachment points for limbs and facial features
        - Acts as the main transform node for character movement
    """
    com = config["com"]
    height = config["pyramid_height"]
    s0 = config["pyramid_base_scale"]

    # Define pyramid vertices relative to center of mass
    p0 = Vector((0, 0, height)) + com  # Apex
    p1 = Vector((-s0, -s0, 0)) + com  # Base vertex 1
    p2 = Vector((s0, -s0, 0)) + com   # Base vertex 2
    p3 = Vector((s0, s0, 0)) + com    # Base vertex 3
    p4 = Vector((-s0, s0, 0)) + com   # Base vertex 4
    
    verts = [p0, p1, p2, p3, p4]
    
    # Define faces using vertex indices
    faces = [
        (1, 2, 3, 4),  # Base
        (0, 2, 1),     # Front face
        (0, 3, 2),     # Right face
        (0, 4, 3),     # Back face
        (0, 1, 4)      # Left face
    ]

    mesh = bpy.data.meshes.new("PyramidBodyMesh")
    obj = bpy.data.objects.new("PyramidBody", mesh)

    bpy.context.collection.objects.link(obj)
    mesh.from_pydata(verts, [], faces)
    mesh.update()

    # Apply material for Professor Pyramid's body
    body_material = get_or_create_material("ProfessorBody", (0.2, 0.6, 0.8, 1.0), shininess=0.95)
    obj.data.materials.append(body_material)

    # Apply rotation if specified in config
    if "body_rotation" in config:
        obj.rotation_euler = (0, 0, config["body_rotation"])

    return obj, verts

def create_professor_face(config, body_verts):
    """
    Creates and positions facial features on Professor Pyramid's front face.
    
    This function places nose, mouth, and eyes on the front triangular face
    of the pyramid. The nose uses manual vertex rotation to achieve proper
    orientation without using rotation matrices.
    
    Args:
        config (dict): Configuration parameters (currently unused but maintained for consistency)
        body_verts (list): List of pyramid body vertices for positioning calculations
    
    Returns:
        Vector: Position of the nose (used for camera targeting)
        
    Face Layout:
        - Nose: Cone rotated 90° around X-axis, positioned at face center
        - Eyes: Two spheres positioned above nose
        - Mouth: Sphere positioned below nose
        
    Animation Features:
        - Mouth scaling animation for speech simulation
        - All features parent to main body for unified movement
        - Strategic positioning for clear visibility during instruction
    """
    p0, p1, p2 = body_verts[0], body_verts[1], body_verts[2]  # Apex, Front-Left, Front-Right

    # Calculate feature positions based on front face geometry
    front_face_center = (p0 + p1 + p2) / 3
    nose_pos = front_face_center
    mouth_pos = front_face_center - Vector((0, 0.15, 0.3))
    eye1_pos = front_face_center + Vector((-0.15, -0.15, 0.3))  # Right eye
    eye2_pos = front_face_center + Vector((0.15, -0.15, 0.3))   # Left eye

    # Create nose with manual 90-degree X-axis rotation
    bpy.ops.mesh.primitive_cone_add(radius1=0.08, depth=0.15, location=(0, 0, 0))
    nose_obj = bpy.context.object
    nose_obj.name = "ProfessorNose"
    
    # Manual vertex rotation (90° around X-axis) to avoid rotation matrices
    for v in nose_obj.data.vertices:
        original_co = v.co.copy()
        v.co.y = -original_co.z
        v.co.z = original_co.y
    
    # Position the pre-rotated nose
    nose_obj.location = nose_pos
    
    # Apply nose material
    nose_material = get_or_create_material("NoseMaterial", (0.8, 0.4, 0.2, 1.0), shininess=0.6)
    nose_obj.data.materials.append(nose_material)

    # Create mouth (will be animated for speech)
    mouth_obj = create_ellipsoid(mouth_pos, Vector((0.08, 0.02, 0.05)), "ProfessorMouth")
    mouth_material = get_or_create_material("MouthMaterial", (0.8, 0.2, 0.2, 1.0), shininess=0.5)
    mouth_obj.data.materials.append(mouth_material)

    # Create eyes
    eye1_obj = create_ellipsoid(eye1_pos, Vector((0.08, 0.08, 0.08)), "ProfessorEye_R")
    eye2_obj = create_ellipsoid(eye2_pos, Vector((0.08, 0.08, 0.08)), "ProfessorEye_L")
    
    eye_material = get_or_create_material("EyeMaterial", (1.0, 1.0, 1.0, 1.0), shininess=0.9)
    eye1_obj.data.materials.append(eye_material)
    eye2_obj.data.materials.append(eye_material)
    
    return nose_pos

def create_professor_limbs(config, body_verts):
    """
    Creates Professor Pyramid's arms, legs, hands, and feet with proper positioning.
    
    This function generates the character's appendages using the cylinder creation
    utility for limbs and ellipsoids for extremities. The limb positioning is
    calculated based on the pyramid's geometry to ensure natural proportions.
    
    Args:
        config (dict): Configuration containing limb dimensions and proportions
        body_verts (list): Pyramid vertices for attachment point calculation
    
    Returns:
        dict: Dictionary containing limb objects and key position data:
            - Limb objects for parenting and animation
            - Hip and ankle positions for walking animation setup
            - Wrist positions for pointer attachment
            
    Limb Structure:
        - Arms: Cylinders from shoulders to wrists
        - Legs: Cylinders from hips to ankles  
        - Hands/Feet: Ellipsoids at limb endpoints
        - All limbs use shoulder-based positioning for aesthetic consistency
        
    Animation Integration:
        - Leg objects returned for IK rigging in walking animation
        - Hip/ankle positions used for armature bone setup
        - All parts designed for smooth animation and realistic movement
    """
    p0, p1, p2 = body_verts[0], body_verts[1], body_verts[2]

    # Calculate shoulder positions from pyramid geometry
    shoulder_pt1 = (p1 + p0) / 2  # Right shoulder
    shoulder_pt2 = (p2 + p0) / 2  # Left shoulder
    
    # Position arms extending downward and outward
    wrist_pt1 = shoulder_pt1 + Vector((-0.15, -0.8, -0.15))  # Right wrist
    wrist_pt2 = shoulder_pt2 + Vector((0.15, -0.8, -0.15))   # Left wrist
    
    # Create arms using cylinder utility
    arm_r = create_cylinder_between(shoulder_pt1, wrist_pt1, config["arm_radius"], "ProfessorArm_R")
    arm_l = create_cylinder_between(shoulder_pt2, wrist_pt2, config["arm_radius"], "ProfessorArm_L")
    
    # Apply arm materials
    arm_material = get_or_create_material("ArmMaterial", (0.2, 0.6, 0.8, 1.0), shininess=0.7)
    if arm_r:
        arm_r.data.materials.append(arm_material)
    if arm_l:
        arm_l.data.materials.append(arm_material)

    # Create hands
    hand_r = create_ellipsoid(wrist_pt1, config["hand_size"], "ProfessorHand_R")
    hand_l = create_ellipsoid(wrist_pt2, config["hand_size"], "ProfessorHand_L")
    
    hand_material = get_or_create_material("HandMaterial", (0.8, 0.6, 0.4, 1.0), shininess=0.6)
    hand_r.data.materials.append(hand_material)
    hand_l.data.materials.append(hand_material)

    # Position legs using shoulder-based calculation for aesthetic consistency
    hip_pt1 = shoulder_pt1 + Vector((0.0, 0, -0.8))   # Right hip (closer to center)
    hip_pt2 = shoulder_pt2 + Vector((0.0, 0, -0.8))  # Left hip (closer to center)
    
    leg_length = config["leg_length"]
    ankle_pt1 = hip_pt1 + Vector((0.0, 0, -leg_length))  # Right ankle (closer)
    ankle_pt2 = hip_pt2 + Vector((0.0, 0, -leg_length))   # Left ankle (closer)

    # Create legs
    leg_r = create_cylinder_between(hip_pt1, ankle_pt1, config["leg_radius"], "ProfessorLeg_R")
    leg_l = create_cylinder_between(hip_pt2, ankle_pt2, config["leg_radius"], "ProfessorLeg_L")
    
    leg_material = get_or_create_material("LegMaterial", (0.2, 0.6, 0.8, 1.0), shininess=0.7)
    if leg_r:
        leg_r.data.materials.append(leg_material)
    if leg_l:
        leg_l.data.materials.append(leg_material)
    
    # Find the main body object to use as a parent
    body_obj = bpy.data.objects.get("PyramidBody")

    # Calculate knee positions relative to the body's UNROTATED state
    leg_length = config["leg_length"]
    # We use the original hip points for local positioning
    knee_pt1_local = (hip_pt1 + ankle_pt1) / 2
    knee_pt2_local = (hip_pt2 + ankle_pt2) / 2        
    # Now set their location, which is now LOCAL to the parent
    rotation_angle = config.get("body_rotation", 0)
    com = config["com"]
    rot_mat = Matrix.Rotation(rotation_angle, 4, 'Z')
    
    # Create simple yellow knobs (feet)
    bpy.ops.mesh.primitive_uv_sphere_add(radius=0.12, location = ankle_pt1)
    foot_r = bpy.context.active_object
    foot_r.name = "ProfessorKnob_R"
    
    bpy.ops.mesh.primitive_uv_sphere_add(radius=0.12, location = ankle_pt2)
    foot_l = bpy.context.active_object
    foot_l.name = "ProfessorKnob_L"
    
    # Parent the feet to the body THEN set their location
    if body_obj:
        foot_r.parent = body_obj
        foot_l.parent = body_obj

    # Apply bright yellow material for cartoonish knobs
    knob_material = get_or_create_material("KnobMaterial", (1.0, 1.0, 0.0, 1.0), shininess=0.9)
    foot_r.data.materials.append(knob_material)
    foot_l.data.materials.append(knob_material)

    # The limb data dictionary needs to be updated with the correct knee positions
    # for the IK targets, which still need to be in world space.
    # So we must manually rotate them here for the animation function to use.
    #rotation_angle = config.get("body_rotation", 0)
    #com = config["com"]
    
    # Create a rotation matrix for the body's rotation
    rot_mat = Matrix.Rotation(rotation_angle, 4, 'Z')

    # Calculate final world positions for IK setup
    knee_world_pos_r = com + rot_mat @ (knee_pt1_local - com) 
    knee_world_pos_l = com + rot_mat @ (knee_pt2_local - com) 
    
    # Return comprehensive limb data for animation system
    return {
        "wrist_R": wrist_pt2,
        "leg_L": leg_l,
        "leg_R": leg_r,
        "foot_L": foot_l,
        "foot_R": foot_r,
        "hip_L": hip_pt2,
        "hip_R": hip_pt1,
        "ankle_L_initial": ankle_pt2,
        "ankle_R_initial": ankle_pt1,
        # Use the correctly calculated WORLD positions for the IK targets
        "knee_L": knee_world_pos_l,
        "knee_R": knee_world_pos_r
    }

def create_professor_pointer(config, wrist_pos):
    """
    Creates Professor Pyramid's teaching pointer attached to the right hand.
    
    This function generates a cylindrical pointer that Professor Pyramid uses
    to indicate specific elements on the game board during instruction. The
    pointer extends from the right wrist at a configurable angle and length.
    
    Args:
        config (dict): Configuration containing pointer specifications:
            - "pointer_len": Length of the pointer
            - "pointer_radius": Thickness of the pointer
            - "pointer_theta": Angle in XY plane (degrees)
            - "pointer_z_offset": Vertical offset from wrist
        wrist_pos (Vector): 3D position of the right wrist for attachment
    
    Returns:
        None (creates pointer object in scene)
        
    Pointer Mechanics:
        - Uses cylindrical coordinates for natural pointing gestures
        - Extends from right wrist at specified angle
        - Will be animated to rotate during instruction for emphasis
        - Material designed to be easily visible against game board
    """
    length = config["pointer_len"]
    theta = math.radians(config["pointer_theta"])  # Convert to radians
    z_offset = config["pointer_z_offset"]

    # Calculate pointer endpoint using cylindrical coordinates
    end_point = Vector((length * math.cos(theta), length * math.sin(theta), z_offset))
    pointer_end = wrist_pos + end_point
    
    # Create pointer using cylinder utility
    pointer_obj = create_cylinder_between(wrist_pos, pointer_end, config["pointer_radius"], "ProfessorPointer")
    
    if pointer_obj:
        # Apply distinctive pointer material
        pointer_material = get_or_create_material("PointerMaterial", (0.8, 0.8, 0.2, 1.0), shininess=0.9)
        pointer_obj.data.materials.append(pointer_material)

# =============================================================================
# PROFESSOR PYRAMID ANIMATION FUNCTIONS
# =============================================================================

def animate_professor_intro(body_obj, start_pos, end_pos, start_rot_z, end_rot_z, 
                          start_rot_y, end_rot_y, start_rot_x, end_rot_x, start_frame, duration):  # Add X,Y params
    """
    Animates Professor Pyramid moving from a starting close-up position
    to his final teaching position.

    Args:
        body_obj (Object): The main body of Professor Pyramid.
        start_pos (Vector): The initial, close-up position.
        end_pos (Vector): The final position for the tutorial.
        start_rot_z (float): The initial euler_angle[2] rotation in radians.
        end_rot_z (float): The final euler_angle[2] rotation in radians.
        start_rot_y (float): The initial euler_angle[1] rotation in radians.
        end_rot_y (float): The final euler_angle[1] rotation in radians.
        start_frame (int): The frame to begin the animation.
        duration (int): The number of frames the animation should take.

    Returns:
        int: The end frame of this animation sequence.
    """
    end_frame = start_frame + duration

    # Set initial state
    bpy.context.scene.frame_set(start_frame)
    body_obj.location = start_pos
    body_obj.rotation_euler.z = start_rot_z
    body_obj.rotation_euler.y = start_rot_y  # NEW
    body_obj.rotation_euler.x = start_rot_x  # NEW
    body_obj.keyframe_insert(data_path="location", frame=start_frame)
    body_obj.keyframe_insert(data_path="rotation_euler", frame=start_frame, index=2)
    body_obj.keyframe_insert(data_path="rotation_euler", frame=start_frame, index=1)  # NEW
    body_obj.keyframe_insert(data_path="rotation_euler", frame=start_frame, index=0)  # NEW

    # Set final state
    bpy.context.scene.frame_set(end_frame)
    body_obj.location = end_pos
    body_obj.rotation_euler.z = end_rot_z
    body_obj.rotation_euler.y = end_rot_y  # NEW
    body_obj.rotation_euler.x = end_rot_x  # NEW
    body_obj.keyframe_insert(data_path="location", frame=end_frame)
    body_obj.keyframe_insert(data_path="rotation_euler", frame=end_frame, index=2)
    body_obj.keyframe_insert(data_path="rotation_euler", frame=end_frame, index=1)  # NEW
    body_obj.keyframe_insert(data_path="rotation_euler", frame=end_frame, index=0)  # NEW

    return end_frame

def animate_professor_walk(config, body, limbs, body_verts):
    """
    Creates a realistic walking animation for Professor Pyramid using IK rigging.
    
    This function implements a sophisticated walking cycle that moves Professor Pyramid
    forward while bobbing up and down naturally. It uses Inverse Kinematics (IK) to
    ensure the legs move realistically, with proper foot placement and body motion.
    
    Args:
        config (dict): Animation configuration including step length, height, timing
        body (Object): Main pyramid body object to animate
        limbs (dict): Dictionary of limb objects and position data
        body_verts (list): Body vertices for calculating relative motion
    
    Animation System:
        1. Creates armature with leg bones from hips to ankles
        2. Sets up IK constraints with target objects at feet
        3. Animates body forward motion with vertical bobbing
        4. Animates IK targets to create walking leg motion
        5. Synchronizes foot rotation for natural heel-toe movement
        
    Technical Details:
        - Uses world-space animation for IK targets
        - Linear interpolation for smooth forward motion
        - Sinusoidal patterns for natural leg swing
        - Proper parent relationships for unified character movement
        
    Returns:
        None (modifies objects in place with keyframe animations)
    """
    # Extract limb data for IK setup
    hip_L, hip_R = limbs["hip_L"], limbs["hip_R"]
    ankle_L_initial, ankle_R_initial = limbs["ankle_L_initial"], limbs["ankle_R_initial"]

    # Create armature for leg animation
    bpy.ops.object.armature_add(enter_editmode=True, location=(0, 0, 0))
    armature_obj = bpy.context.object
    armature_obj.name = "ProfessorLegRig"
    armature = armature_obj.data
    
    # Remove default bone and create leg bones
    armature.edit_bones.remove(armature.edit_bones[0])
    armature.edit_bones.new('LegBone_L').head, armature.edit_bones['LegBone_L'].tail = hip_L, ankle_L_initial
    armature.edit_bones.new('LegBone_R').head, armature.edit_bones['LegBone_R'].tail = hip_R, ankle_R_initial
    bpy.ops.object.mode_set(mode='OBJECT')

    def assign_mesh_to_bone(mesh_obj, bone_name):
        """Helper function to bind mesh objects to armature bones for deformation."""
        if mesh_obj:
            vg = mesh_obj.vertex_groups.new(name=bone_name)
            vg.add([v.index for v in mesh_obj.data.vertices], 1.0, 'REPLACE')
            mod = mesh_obj.modifiers.new(name='Armature', type='ARMATURE')
            mod.object = armature_obj
            mesh_obj.parent = armature_obj

    # Bind leg meshes to their respective bones
    assign_mesh_to_bone(limbs["leg_L"], 'LegBone_L')
    assign_mesh_to_bone(limbs["leg_R"], 'LegBone_R')
    
    # Parent armature to main body
    armature_obj.parent = body

    # Create IK target objects for foot positioning at knee level
    knee_L_initial, knee_R_initial = limbs["knee_L"], limbs["knee_R"]
    
    bpy.ops.object.empty_add(type='CUBE', location=knee_L_initial)
    ik_target_l = bpy.context.object
    ik_target_l.name = "ProfIKTarget_L"
    bpy.ops.object.empty_add(type='CUBE', location=knee_R_initial)
    ik_target_r = bpy.context.object
    ik_target_r.name = "ProfIKTarget_R"
    
    # Parent feet to IK targets for unified movement
    #if limbs["foot_L"]:
    #    limbs["foot_L"].parent = ik_target_l
    #if limbs["foot_R"]:
    #    limbs["foot_R"].parent = ik_target_r
    
    # Set up IK constraints in pose mode
    bpy.context.view_layer.objects.active = armature_obj
    bpy.ops.object.mode_set(mode='POSE')

    for bone_name, target in [('LegBone_L', ik_target_l), ('LegBone_R', ik_target_r)]:
        pbone = armature_obj.pose.bones[bone_name]
        ik = pbone.constraints.new(type='IK')
        ik.target = target
        ik.chain_count = 1
    bpy.ops.object.mode_set(mode='OBJECT')

    # Define walking parameters
    step_length = config["step_length"]
    step_height = config["step_height"]
    frames_per_step = config["frames_per_step"]
    num_steps = config["num_steps"]
    
    scene = bpy.context.scene
    scene.frame_start = 1
    scene.frame_end = frames_per_step * num_steps + 1

    # Animate body forward motion and bobbing
    body.keyframe_insert(data_path="location", frame=1)
    body.location.y += step_length * num_steps
    body.keyframe_insert(data_path="location", frame=scene.frame_end)
    
    # Make forward motion linear
    if body.animation_data and body.animation_data.action:
        fcurve = body.animation_data.action.fcurves.find('location', index=1)
        if fcurve:
            for kf in fcurve.keyframe_points:
                kf.interpolation = 'LINEAR'

    # Animate body bobbing (vertical motion)
    for i in range(num_steps + 1):
        frame = i * frames_per_step + 1
        body.location.z = body_verts[1].z - step_height
        body.keyframe_insert(data_path="location", frame=frame, index=2)
        if frame < scene.frame_end:
            mid_frame = frame + frames_per_step // 2
            body.location.z = body_verts[1].z
            body.keyframe_insert(data_path="location", frame=mid_frame, index=2)

    # Animate IK targets for walking motion
    initial_knee_L_y = knee_L_initial.y
    initial_knee_R_y = knee_R_initial.y

    for i in range(num_steps):
        start_frame = i * frames_per_step + 1
        mid_frame = start_frame + frames_per_step // 2
        end_frame = start_frame + frames_per_step

        # Alternate which foot swings
        swing_foot, plant_foot = (ik_target_l, ik_target_r) if i % 2 == 0 else (ik_target_r, ik_target_l)
        initial_y_swing = initial_knee_L_y if i % 2 == 0 else initial_knee_R_y
        
        # Animate swinging foot
        swing_foot.location.y = initial_y_swing + i * step_length
        swing_foot.location.z = 0
        swing_foot.rotation_euler.x = math.radians(30)
        swing_foot.keyframe_insert(data_path="location", frame=start_frame)
        swing_foot.keyframe_insert(data_path="rotation_euler", frame=start_frame)
        
        swing_foot.location.y = initial_y_swing + (i + 0.5) * step_length
        swing_foot.location.z = step_height
        swing_foot.rotation_euler.x = math.radians(-10)
        swing_foot.keyframe_insert(data_path="location", frame=mid_frame)
        swing_foot.keyframe_insert(data_path="rotation_euler", frame=mid_frame)
        
        swing_foot.location.y = initial_y_swing + (i + 1) * step_length
        swing_foot.location.z = 0
        swing_foot.rotation_euler.x = 0
        swing_foot.keyframe_insert(data_path="location", frame=end_frame)
        swing_foot.keyframe_insert(data_path="rotation_euler", frame=end_frame)

        # Keep planted foot on ground
        plant_foot.location.z = 0
        plant_foot.keyframe_insert(data_path="location", frame=start_frame, index=2)
        plant_foot.keyframe_insert(data_path="location", frame=end_frame, index=2)

def animate_professor_gestures(config):
    """
    Animates Professor Pyramid's mouth and pointer for teaching emphasis.
    
    This function creates coordinated animations for the character's expressive
    elements during instruction delivery. The mouth animation simulates speech
    patterns while the pointer provides visual emphasis through rotation.
    
    Args:
        config (dict): Animation configuration with timing parameters
    
    Animation Elements:
        - Mouth: Scales vertically to simulate opening/closing during speech
        - Pointer: Rotates continuously to draw attention to board elements
        
    Timing Coordination:
        - Mouth opens/closes in sync with instruction delivery
        - Pointer rotation provides continuous visual interest
        - Both animations loop appropriately with lesson duration
        
    Returns:
        None (modifies objects with keyframe animation data)
    """
    mouth_obj = bpy.data.objects.get("ProfessorMouth")
    pointer_obj = bpy.data.objects.get("ProfessorPointer")

    if not mouth_obj or not pointer_obj:
        print("Animation Warning: Could not find Professor's mouth or pointer.")
        return
        
    end_frame = bpy.context.scene.frame_end

    # Animate mouth for speech simulation
    for i in range(config["num_steps"] * 2):
        frame = i * (config["frames_per_step"] // 2) + 1
        mouth_obj.scale.z = 0.3 if i % 2 == 0 else 0.2
        mouth_obj.keyframe_insert(data_path="scale", frame=frame, index=2)

    # Animate pointer rotation for emphasis
    pointer_obj.rotation_euler.z = 0
    pointer_obj.keyframe_insert(data_path="rotation_euler", frame=1, index=2)
    pointer_obj.rotation_euler.z = math.pi * config["num_steps"]
    pointer_obj.keyframe_insert(data_path="rotation_euler", frame=end_frame, index=2)
    
    # Set linear interpolation for smooth rotation
    if pointer_obj.animation_data and pointer_obj.animation_data.action:
        fcurve = pointer_obj.animation_data.action.fcurves.find('rotation_euler', index=2)
        if fcurve:
            for kf in fcurve.keyframe_points:
                kf.interpolation = 'LINEAR'

# =============================================================================
# GAME BOARD AND PIECE CREATION FUNCTIONS
# =============================================================================

def create_3d_text(text, location, font_size, color_name, color_rgba, is_emission=True):
    """
    Creates 3D text objects for game piece values and educational content.
    
    This function generates extruded 3D text with beveling for clear readability
    during the educational animation. Used extensively for piece values and
    instructional text overlays.
    
    Args:
        text (str): Text content to display
        location (Vector): 3D position for text placement
        font_size (float): Size of the text
        color_name (str): Material name identifier
        color_rgba (tuple): RGBA color values
        is_emission (bool): Whether to use emission shader for visibility
    
    Returns:
        bpy.types.Object: The created 3D text object
        
    Text Properties:
        - Extruded for 3D appearance
        - Beveled edges for professional look
        - Emission shaders for clear visibility against backgrounds
        - Proper parenting for synchronized movement with pieces
    """
    bpy.ops.object.text_add(enter_editmode=False, align='WORLD', location=location)
    text_obj = bpy.context.active_object
    text_obj.data.body = text
    text_obj.data.extrude = 0.05
    text_obj.data.bevel_depth = 0.01
    text_obj.data.bevel_resolution = 4
    text_obj.data.size = font_size
    
    text_mat = get_or_create_material(color_name, color_rgba, is_emission)
    if len(text_obj.data.materials) == 0:
        text_obj.data.materials.append(text_mat)
    else:
        text_obj.data.materials[0] = text_mat
    return text_obj

def create_board_text_area(text, location, text_id, font_size=0.4, max_width=15):
    """
    Creates multi-line text areas for educational content display.
    
    This function handles the creation of instructional text that appears during
    the educational sequence. It includes word wrapping and proper formatting
    for readability during the animation.
    
    Args:
        text (str): Text content to display
        location (Vector): 3D position for text placement
        text_id (str): Unique identifier for the text object
        font_size (float): Size of the text
        max_width (float): Maximum width before word wrapping
    
    Returns:
        bpy.types.Object: The created text area object
        
    Text Features:
        - Automatic word wrapping for long content
        - Left alignment for easy reading
        - Proper rotation for board-relative positioning
        - Material setup for clear visibility
    """
    words = text.split()
    lines = []
    current_line = ""
    chars_per_line = int(max_width / (font_size * 0.6))
    
    for word in words:
        if len(current_line + " " + word) <= chars_per_line:
            if current_line:
                current_line += " " + word
            else:
                current_line = word
        else:
            if current_line:
                lines.append(current_line)
            current_line = word
    if current_line:
        lines.append(current_line)
    
    wrapped_text = "\n".join(lines)
    bpy.ops.object.text_add(location=location)
    text_obj = bpy.context.active_object
    text_obj.data.body = wrapped_text
    text_obj.data.size = font_size
    text_obj.data.align_x = 'LEFT'
    text_obj.data.align_y = 'TOP'
    text_obj.name = text_id
    text_obj.rotation_euler = (math.radians(0), math.radians(0), math.radians(-270))
    
    white_rgba = (1.0, 1.0, 1.0, 1.0)
    text_mat = get_or_create_material(f"TextMaterial_{text_id}", white_rgba)
    if len(text_obj.data.materials) == 0:
        text_obj.data.materials.append(text_mat)
    else:
        text_obj.data.materials[0] = text_mat
    return text_obj

def create_circle_piece(x0, y0, z0, r0, val, color_name, color_rgba):
    """
    Creates circular game pieces with 3D values and professional beveling.
    
    This function generates cylindrical pieces representing circle pieces in
    Rithmomachia. Each piece includes beveled edges for visual appeal and
    3D text showing the piece's numerical value.
    
    Args:
        x0, y0, z0 (float): Position coordinates on the game board
        r0 (float): Radius of the circular piece
        val (str): Numerical value to display on the piece
        color_name (str): Material identifier
        color_rgba (tuple): RGBA color values
    
    Returns:
        bpy.types.Object: The main circle piece object with attached text
        
    Construction Process:
        1. Creates base cylinder with specified dimensions
        2. Applies beveling to top edges for polish
        3. Adds 3D text with the piece value
        4. Parents text to piece for unified movement
        5. Applies materials with shininess for realistic appearance
        
    Usage in Education:
        - Represents circle pieces in game demonstrations
        - Values clearly visible during instructional sequences
        - Professional appearance maintains visual quality
    """
    font_size_multiplier = 0.5
    font_size = 2*r0 * font_size_multiplier
    ht = 0.25
    blue_rgb = (0.0, 0.0, 1.0, 1.0)
    color_value_rgba = blue_rgb
    
    bpy.ops.mesh.primitive_cylinder_add(
        radius=r0, depth=ht,
        location=(x0+0.5, y0+0.5, z0 + ht / 2)
    )
    circle_obj = bpy.context.active_object
    
    # Apply beveling for professional appearance
    bpy.ops.object.mode_set(mode='OBJECT')
    bpy.ops.object.transform_apply(location=False, rotation=False, scale=True)
    bpy.ops.object.mode_set(mode='EDIT')
    bm = bmesh.from_edit_mesh(circle_obj.data)
    
    # Select top edge loop for beveling
    for edge in bm.edges:
        if any(v.co.z > ht/2 - 0.01 for v in edge.verts):
            edge.select = True
            
    bmesh.update_edit_mesh(circle_obj.data)
    bpy.ops.mesh.bevel(offset=0.03, segments=3, profile=0.5)
    bpy.ops.object.mode_set(mode='OBJECT')

    # Apply material with shininess
    circle_mat = get_or_create_material(color_name, color_rgba, shininess=0.8)
    circle_obj.data.materials.append(circle_mat)
    
    # Create and parent 3D text value
    text_location_relative = (0 + 0.15, 0 - 0.15, ht / 2 + (-0.05)) ## lowering text elevation by (-0.05)
    text_obj = create_3d_text(val, circle_obj.location, font_size, "Blue", color_value_rgba)
    text_obj.parent = circle_obj
    text_obj.location = text_location_relative
    text_obj.rotation_euler = (0, 0, math.radians(90))
    
    return circle_obj

def create_triangle_piece(x0, y0, z0, side, val, color_name, color_rgba):
    """
    Creates triangular game pieces with custom mesh geometry and beveling.
    
    This function constructs triangular prism pieces for Rithmomachia using
    custom mesh generation. The triangular shape is mathematically calculated
    and includes professional beveling on top edges.
    
    Args:
        x0, y0, z0 (float): Position coordinates on game board
        side (float): Length of triangle sides
        val (str): Numerical value for the piece
        color_name (str): Material identifier
        color_rgba (tuple): RGBA color values
    
    Returns:
        bpy.types.Object: The triangle piece with attached value text
        
    Geometry Details:
        - Equilateral triangle base with specified side length
        - Extruded to create prism shape
        - Top edges beveled for professional appearance
        - Custom mesh allows precise control over triangle proportions
        
    Educational Purpose:
        - Represents triangle pieces in game board
        - Clear value display for instructional clarity
        - Consistent visual style with other game pieces
    """
    dblue_rgb = (0.0, 0.0, 0.5, 1.0) 
    font_size_multiplier = 0.45
    font_size = side * font_size_multiplier
    ht = 0.25
    eps = 0.1
    color_value_rgba = dblue_rgb
    
    # Define triangular prism vertices
    verts = [
        (0, eps, 0), (side, eps, 0), (side/2, (math.sqrt(3)/2)*side + eps, 0),
        (0, eps, ht), (side, eps, ht), (side/2, (math.sqrt(3)/2)*side + eps, ht)
    ]
    faces = [
        (0, 1, 2), (3, 4, 5), (0, 1, 4, 3), (1, 2, 5, 4), (2, 0, 3, 5)
    ]
    
    # Create custom mesh
    mesh = bpy.data.meshes.new("TriangleMesh")
    mesh.from_pydata(verts, [], faces)
    mesh.update()
    triangle_obj = bpy.data.objects.new("TrianglePiece", mesh)
    bpy.context.collection.objects.link(triangle_obj)
    
    # Apply beveling to top edges
    bpy.context.view_layer.objects.active = triangle_obj
    triangle_obj.select_set(True)
    bpy.ops.object.mode_set(mode='EDIT')
    bm = bmesh.from_edit_mesh(triangle_obj.data)

    # Select only top edges for beveling
    for edge in bm.edges:
        edge.select = False
    for edge in bm.edges:
        if all(v.co.z > ht - 0.01 for v in edge.verts):
            edge.select = True
            
    bmesh.update_edit_mesh(triangle_obj.data)
    bpy.ops.mesh.bevel(offset=0.03, segments=3, profile=0.5)
    bpy.ops.object.mode_set(mode='OBJECT')
    
    # Position and apply materials
    triangle_obj.location = (x0+0.05, y0, z0)
    triangle_mat = get_or_create_material(color_name, color_rgba, shininess=0.8)
    triangle_obj.data.materials.append(triangle_mat)
    
    # Add value text
    text_y_offset = (math.sqrt(3)/2)*side/5
    if val=="100":
        text_location_relative = (side/3 +0.25, text_y_offset -0.1, ht + (-0.05)) ### lowering text elevation by (-0.05)
    else:
        text_location_relative = (side/3 +0.25, text_y_offset, ht + (-0.05))
        
    text_obj = create_3d_text(val, triangle_obj.location, font_size, "Blue", color_value_rgba)
    text_obj.parent = triangle_obj
    text_obj.location = text_location_relative
    text_obj.rotation_euler = (0, 0, math.radians(90))
    
    return triangle_obj

def create_square_piece(x0, y0, z0, side, val, color_name, color_rgba):
    """
    Creates square game pieces with beveled edges and value display.
    
    This function generates cubic pieces representing square pieces in
    Rithmomachia. Each piece is beveled for visual appeal and includes
    clear value text display.
    
    Args:
        x0, y0, z0 (float): Board position coordinates
        side (float): Size of the square piece
        val (str): Numerical value to display
        color_name (str): Material identifier  
        color_rgba (tuple): RGBA color values
    
    Returns:
        bpy.types.Object: Square piece object with value text
        
    Features:
        - Cubic base geometry scaled to specified size
        - Beveled top edges for professional appearance
        - 3D value text properly positioned and parented
        - Shininess material for realistic light interaction
    """
    dblue_rgb = (0.0, 0.0, 0.5, 1.0) 
    font_size_multiplier = 0.5
    font_size = side * font_size_multiplier
    font_elevation = 0.25
    ht = 0.25
    color_value_rgba = dblue_rgb
    
    bpy.ops.mesh.primitive_cube_add(
        size=1,
        location=(x0 + 0.5, y0 + 0.5, z0 + ht / 2)
    )
    square_obj = bpy.context.active_object
    
    # Apply beveling
    bpy.ops.object.mode_set(mode='OBJECT')
    bpy.ops.object.transform_apply(location=False, rotation=False, scale=True)
    bpy.ops.object.mode_set(mode='EDIT')
    bm = bmesh.from_edit_mesh(square_obj.data)
    
    for edge in bm.edges:
        if any(v.co.z > ht/2 - 0.01 for v in edge.verts):
            edge.select = True
            
    bmesh.update_edit_mesh(square_obj.data)
    bpy.ops.mesh.bevel(offset=0.03, segments=3, profile=0.5)
    bpy.ops.object.mode_set(mode='OBJECT')

    # Scale and apply materials
    square_obj.scale = (side, side, ht)
    square_mat = get_or_create_material(color_name, color_rgba, shininess=0.8)
    square_obj.data.materials.append(square_mat)
    
    # Add value text
    text_location_relative = (0+0.25, 0 -0.25, ht + font_elevation)
    text_obj = create_3d_text(val, text_location_relative, font_size, "Blue", color_value_rgba)
    text_obj.parent = square_obj
    text_obj.location = text_location_relative
    text_obj.rotation_euler = (0, 0, math.radians(90))
    
    return square_obj

def create_pyramid_piece(x0, y0, z0, side, values, color_name, color_rgba, show_subpiece_values=True):
    """
    Creates pyramid game pieces as stacks of squares with visible subpiece values.
    
    This is the most complex piece creation function, generating pyramid pieces
    that represent the sum of their constituent square subpieces. Each subpiece
    is visually distinct and the total value is prominently displayed.
    
    Args:
        x0, y0, z0 (float): Board position coordinates
        side (float): Size of the base square
        values (list): List of subpiece values (bottom to top)
        color_name (str): Material identifier
        color_rgba (tuple): RGBA color values
        show_subpiece_values (bool): Whether to display individual subpiece values
    
    Returns:
        bpy.types.Object: Base pyramid object with all subpieces parented
        
    Construction Details:
        - Base piece represents total value of all subpieces
        - Each subpiece scaled smaller than the one below
        - Individual value texts positioned above pyramid
        - Total value text prominently displayed at top
        - All components parented to base for unified movement
        
    Educational Significance:
        - Visually demonstrates pyramid composition
        - Shows both individual and total values clearly
        - Supports educational content about pyramid captures
        - Professional appearance maintains instructional quality
    """
    # Color definitions for text elements
    blue_rgb = (0.0, 0.0, 1.0, 1.0) 
    dblue_rgb = (0.0, 0.0, 0.5, 1.0) 
    vdblue_rgb = (0.0, 0.0, 0.25, 1.0) 
    orange_rgb = (0.8, 0.4, 0.0, 1.0) 
    
    total_value = sum(values)
    ht = 0.25  # Height of each square segment
    
    # Create base square piece
    base_side = side
    base_obj = create_square_piece(
        x0=x0, y0=y0, z0=z0, side=base_side, 
        val=str(total_value), color_name=color_name, 
        color_rgba=color_rgba
    )
    
    current_z_for_subpiece = ht  # Start stacking above base
    
    # Create and stack subpieces with transparency
    color_subpc_rgba = (color_rgba[0], color_rgba[1], color_rgba[2], 0.75)
    for i, val in enumerate(values):
        subpiece_scale_factor = 1.0 - (i * 0.15)
        subpiece_side = base_side * subpiece_scale_factor
        
        bpy.ops.mesh.primitive_cube_add(
            size=1,
            location=(0, 0, current_z_for_subpiece + ht / 2) 
        )
        sub_obj = bpy.context.active_object
        sub_obj.scale = (subpiece_side, subpiece_side, ht)
        sub_obj.data.materials.append(get_or_create_material(f"{color_name}_sub_piece_{val}", color_subpc_rgba, shininess=0.6))
        sub_obj.parent = base_obj
        
        current_z_for_subpiece += ht
    
    # Place text values above pyramid
    total_physical_pyramid_height = ht * (len(values) + 1)
    text_base_z_offset = total_physical_pyramid_height + 0.5
    if total_value==190:
        text_x_offset = 0.3 
        text_y_offset = -0.7
    else:
        text_x_offset = +0.3 
        text_y_offset = -0.25

    # Create text for each subpiece value
    if show_subpiece_values:
        for i, val in enumerate(values):
            font_size = side * 0.5 * (1.0 - (i * 0.15))
            text_z_location = text_base_z_offset + (i * 0.15)
        
            text_obj = create_3d_text(
                str(val), 
                (text_x_offset + (5/10)*math.cos(2*i*math.pi/5), 
                 text_y_offset + (5/10)*math.sin(2*i*math.pi/5), 
                 text_z_location), 
                font_size, "Orange", orange_rgb
            )
            text_obj.parent = base_obj
    
    # Create total value text at the top
    total_value_font_size = side * 0.6
    total_value_text_z = text_base_z_offset + (len(values) * 0.15) #+ 0.1  ### lowered the text elevation ?
    
    total_value_text_obj = create_3d_text(
        str(total_value), 
        (text_x_offset - 0.1, text_y_offset, total_value_text_z), 
        total_value_font_size, "Blue", vdblue_rgb
    )
    total_value_text_obj.parent = base_obj
    total_value_text_obj.rotation_euler = (0, 0, math.radians(90))
    
    return base_obj

def draw_grid_with_lines(rows=8, cols=16, square_size=1, z=0):
    """
    Creates the game board grid with tiles and border lines.
    
    This function generates the visual game board consisting of light-colored
    tiles with black grid lines. The board serves as the foundation for all
    game piece positioning and educational demonstrations.
    
    Args:
        rows (int): Number of board rows (default 8 for Rithmomachia)
        cols (int): Number of board columns (default 16 for Rithmomachia)
        square_size (float): Size of each grid square
        z (float): Vertical position of the board
    
    Board Construction:
        - Individual tiles for each square position
        - Black lines forming grid boundaries
        - Light blue-gray color scheme for visual clarity
        - Professional appearance suitable for educational content
        
    Returns:
        None (creates board geometry in scene)
    """
    light_blue_gray_rgba = (0.7, 0.8, 0.9, 1.0)
    black_rgba = (0.0, 0.0, 0.0, 1.0)
    tile_mat = get_or_create_material("LightBlueGray", light_blue_gray_rgba)
    line_mat = get_or_create_material("Black", black_rgba)
    line_thickness = 0.02
    line_height = 0.01
    
    # Create individual tiles
    for i in range(cols):
        for j in range(rows):
            bpy.ops.mesh.primitive_plane_add(
                size=square_size,
                location=(i * square_size + square_size / 2, j * square_size + square_size / 2, z)
            )
            plane_obj = bpy.context.active_object
            plane_obj.data.materials.append(tile_mat)
    
    # Create vertical grid lines
    for i in range(cols + 1):
        x = i * square_size
        bpy.ops.mesh.primitive_cube_add(
            location=(x, rows * square_size / 2, z + line_height / 2),
            scale=(line_thickness, rows * square_size, line_height)
        )
        line_obj = bpy.context.active_object
        line_obj.data.materials.append(line_mat)
    
    # Create horizontal grid lines
    for j in range(rows + 1):
        y = j * square_size
        bpy.ops.mesh.primitive_cube_add(
            location=(cols * square_size / 2, y, z + line_height / 2),
            scale=(cols * square_size, line_thickness, line_height)
        )
        line_obj = bpy.context.active_object
        line_obj.data.materials.append(line_mat)
        
    # --- NEW: Add Row and Column Labels ---
    label_font_size = 0.5
    label_z_offset = -0.05 # Slightly above the board
    yellow_rgba = (1.0, 1.0, 0.2, 1.0) # Bright yellow for contrast

    # Add letter labels for rows (a, b, ..., p)
    for j in range(rows):
        label_text = chr(ord('a') + j)
        # Position to the left of the board, centered on the row
        label_location = (
            -square_size / 2, 
            j * square_size + square_size / 2, 
            z + label_z_offset
        )
        text_obj = create_3d_text(
            label_text, 
            label_location, 
            label_font_size, 
            "LabelYellow", 
            yellow_rgba
        )
        # Optional: Rotate text to be upright if camera angle requires it
        text_obj.rotation_euler = (math.radians(0), 0, math.radians(90))

    # Add number labels for columns (1, 2, ..., 8)
    for i in range(cols):
        label_text = str(i + 1)
        # Position below the board, centered on the column
        label_location = (
            i * square_size + square_size / 2, 
            -square_size / 2, 
            z + label_z_offset
        )
        text_obj = create_3d_text(
            label_text, 
            label_location, 
            label_font_size, 
            "LabelYellow", 
            yellow_rgba
        )
        text_obj.rotation_euler = (math.radians(0), 0, math.radians(90))

# =============================================================================
# ANIMATION AND HIGHLIGHTING FUNCTIONS
# =============================================================================

def highlight_piece(piece_obj, start_frame, duration=30):
    """
    Creates visual highlighting for game pieces during educational sequences.
    
    This function generates a glowing copy of a game piece that appears during
    instruction to draw attention to specific pieces being discussed. The
    highlight uses emission shaders for clear visibility.
    
    Args:
        piece_obj (Object): The game piece to highlight
        start_frame (int): Animation frame when highlighting begins
        duration (int): How long the highlight lasts (in frames)
    
    Highlighting System:
        - Creates scaled copy of original piece
        - Applies bright emission material
        - Parents to original for synchronized movement
        - Uses keyframe animation for timed appearance/disappearance
        
    Returns:
        None (creates highlighting object in scene)
    """
    glow_obj = piece_obj.copy()
    glow_obj.data = piece_obj.data.copy()
    bpy.context.collection.objects.link(glow_obj)
    glow_obj.scale = (1.2, 1.2, 1.2)
    
    glow_mat = get_or_create_material("Highlight", (1, 1, 0, 0.5), is_emission=True)
    glow_obj.data.materials.clear()
    glow_obj.data.materials.append(glow_mat)
    glow_obj.parent = piece_obj
    
    # Animate highlight visibility
    glow_obj.hide_render = True
    glow_obj.keyframe_insert(data_path="hide_render", frame=start_frame - 1)
    glow_obj.hide_render = False
    glow_obj.keyframe_insert(data_path="hide_render", frame=start_frame)
    glow_obj.hide_render = True
    glow_obj.keyframe_insert(data_path="hide_render", frame=start_frame + duration)

def highlight_square(x_coord, y_coord, start_frame, duration=30):
    """
    Creates highlighting for empty board squares during instruction.
    
    This function places a glowing plane on empty board squares to indicate
    important positions during educational sequences. Used to show potential
    move destinations and strategic positions.
    
    Args:
        x_coord, y_coord (float): Board coordinates for the highlight
        start_frame (int): When the highlight appears
        duration (int): How long the highlight lasts
    
    Features:
        - Bright emission plane slightly above board surface
        - Timed appearance synchronized with instruction
        - Clear visibility against board background
        
    Returns:
        None (creates highlight object in scene)
    """
    highlight_mat = get_or_create_material("SquareHighlight", (1, 1, 0, 0.5), is_emission=True)
    bpy.ops.mesh.primitive_plane_add(
        size=1,
        location=(y_coord + 0.5, x_coord + 0.5, 0.02) ####### these got swapped due to older notation in screenplay
    )
    highlight_obj = bpy.context.active_object
    highlight_obj.data.materials.append(highlight_mat)
    
    # Animate highlight visibility
    highlight_obj.hide_render = True
    highlight_obj.keyframe_insert(data_path="hide_render", frame=start_frame - 1)
    highlight_obj.hide_render = False
    highlight_obj.keyframe_insert(data_path="hide_render", frame=start_frame)
    highlight_obj.hide_render = True
    highlight_obj.keyframe_insert(data_path="hide_render", frame=start_frame + duration)

def scroll_text_down(top_text_obj, bottom_text_obj, start_frame, duration=30):
    """
    Animates educational text scrolling for continuous instruction flow.
    
    This function handles the smooth transition of instructional text, moving
    the current top text down to the bottom position while fading out the
    old bottom text. This creates a natural flow of educational content.
    
    Args:
        top_text_obj (Object): Current top text to move down
        bottom_text_obj (Object): Current bottom text to fade out
        start_frame (int): When the scroll animation begins
        duration (int): Length of the scroll animation
    
    Returns:
        int: End frame of the scroll animation
        
    Animation Details:
        - Smooth position transition for top text
        - Fade out animation for bottom text
        - Synchronized timing for natural flow
        - Returns end frame for proper sequencing
    """
    if bottom_text_obj:
        bpy.context.scene.frame_current = start_frame
        bottom_text_obj.hide_render = False
        bottom_text_obj.keyframe_insert(data_path="hide_render")
        bpy.context.scene.frame_current = start_frame + duration // 2
        bottom_text_obj.hide_render = True
        bottom_text_obj.keyframe_insert(data_path="hide_render")
        
    if top_text_obj:
        bottom_position = (-2, 0, 2)
        bpy.context.scene.frame_current = start_frame
        top_text_obj.keyframe_insert(data_path="location")
        bpy.context.scene.frame_current = start_frame + duration
        top_text_obj.location = bottom_position
        top_text_obj.keyframe_insert(data_path="location")
        
    return start_frame + duration

def animate_piece_move(obj, start_frame, steps_x=0, steps_y=0):
    """
    Animates game piece movement for educational demonstrations.
    
    This function handles two types of piece animation: standard moves across
    the board and capture moves that lift pieces off the board. The movement
    type is determined by the step size magnitude.
    
    Args:
        obj (Object): The game piece to animate
        start_frame (int): When the animation begins
        steps_x, steps_y (int): Movement in grid squares (large values = capture)
    
    Returns:
        int: End frame of the animation
        
    Animation Types:
        - Standard Move: Horizontal movement across board squares
        - Capture Move: Lift up, move out of frame (indicated by large step values)
        
    Movement Mechanics:
        - Standard moves use linear interpolation across board
        - Captures lift vertically then move horizontally out of view
        - Timing adjusted for clear visibility of each movement phase
    """
    if obj is None:
        print("Error: No object provided for animation.")
        return start_frame
        
    square_size = 1.0
    move_duration = 20
    end_frame = start_frame
    
    if abs(steps_x) + abs(steps_y) > 500:  # Large values indicate capture
        print(f"Animating a CAPTURE for '{obj.name}'.")
        lift_duration = 10
        out_of_frame_duration = 30
        
        bpy.context.scene.frame_current = start_frame
        obj.keyframe_insert(data_path="location", frame=start_frame)
        
        # Lift phase
        end_frame = start_frame + lift_duration
        bpy.context.scene.frame_current = end_frame
        obj.location.z += 5.0
        obj.keyframe_insert(data_path="location", frame=end_frame)
        
        # Move out of frame phase
        end_frame = end_frame + out_of_frame_duration
        bpy.context.scene.frame_current = end_frame
        obj.location.x += steps_x * square_size * 5
        obj.location.y += steps_y * square_size * 5
        obj.location.z += 10.0
        obj.keyframe_insert(data_path="location", frame=end_frame)
    else:  # Standard move
        print(f"Animating a STANDARD MOVE for '{obj.name}'. Steps: x={steps_x}, y={steps_y}")
        x_movement = steps_x * square_size
        y_movement = steps_y * square_size
        end_frame = start_frame + move_duration
        
        bpy.context.scene.frame_current = start_frame
        obj.keyframe_insert(data_path="location", frame=start_frame)
        bpy.context.scene.frame_current = end_frame
        obj.location.x += x_movement
        obj.location.y += y_movement
        obj.keyframe_insert(data_path="location", frame=end_frame)
        
    return end_frame

# =============================================================================
# EDUCATIONAL ANIMATION SEQUENCE SYSTEM
# =============================================================================

def create_educational_animation_sequence():
    """
    Defines the complete educational animation sequence for pyramid piece instruction.
    
    This function creates a structured list of animation scenes that combine
    Professor Pyramid's teaching with game board demonstrations. Each scene
    is carefully timed and coordinated to provide clear, engaging instruction.
    
    Returns:
        list: Sequence of animation scene dictionaries
        
    Scene Types:
        - text_and_highlight: Display instruction text and highlight relevant pieces
        - move_piece: Demonstrate piece movements and captures
        
    Educational Content:
        - Pyramid piece composition and values
        - Movement and capture mechanics
        - Strategic examples from game positions
        - Interactive demonstrations with highlighting
        
    Timing Coordination:
        - Each scene includes duration and pause parameters
        - Synchronized with Professor Pyramid's gestures and expressions
        - Smooth transitions between instructional topics
    """
    animation_sequence = [
         #Scene 0a: An introduction to Prof Pyramid
         #{
         #   'scene_type': 'text_and_highlight',
         #    'move_text': " I am Professor Pyramid, your guide to learning Rithmomachia. Welcome! ",
         #   'highlighted_pieces': [], 
         #   'highlighted_empty_squares': [],
         #   'pause': 20
         #},
         #Scene 0b: An introduction to Prof Pyramid
         {
            'scene_type': 'text_and_highlight',
            'move_text': " This lesson will explain the pyramid pieces, the only pieces that contain subpieces. They are the most powerful piece of its color on the board.  ",
            'highlighted_pieces': [], 
            'highlighted_empty_squares': [],
            'pause': 20,
         },
         #Scene 0c: An introduction to the game
         {
            'scene_type': 'text_and_highlight',
            'move_text': " Are you ready? Let's get this lesson started!   ",
            'highlighted_pieces': [], 
            'highlighted_empty_squares': [],
            'pause': 20
         },
        # Scene 1a: pyramid pieces
        {
            'scene_type': 'text_and_highlight',
            'move_text': "  Each color has one pyramid. The white pyramid is composed of these subpieces: S1, S4, S9, S16, S25, S36, with total value 1+4+9+16+25+36=91.  ",
            'highlighted_pieces': [], # 
            'highlighted_empty_squares': [
                # rank a :
                (1,1),
                # rank o :  (14,7)
            ],
            'pause': 20,
        },
        
        # Scene 1a2
        {
            'scene_type': 'move_piece',
            'piece_name': "SpherePyramid6-1Graphic",
            'steps': (-100, 0),
            'pause': 10,
        },
        
        # Scene 1b: pyramid pieces
        {
            'scene_type': 'text_and_highlight',
            'move_text': "  We imagine these stacked on one another - the 6x6 square S36 at the bottom, then the 5x5 square, and so on to the 1x1 square on top, just like a pyramid should look. ",
            'highlighted_pieces': [], # 
            'highlighted_empty_squares': [
                # rank a :
                (1,1),
                # rank o :  (14,7)
            ],
            'pause': 20
        },
        # Scene 1c: pyramid pieces
        {
            'scene_type': 'text_and_highlight',
            'move_text': " The black pyramid is composed of these subpieces: s16, s25, s36, s49, s64, with total value 16+25+36+49+64=190. ",
            'highlighted_pieces': [], # 
            'highlighted_empty_squares': [
                # rank a :  (1,1),
                # rank o :
                (14,7)
            ],
            'pause': 20
        },
        # Scene 1c2
        {
            'scene_type': 'move_piece', 
            'piece_name': "SpherePyramid6-1Graphic",
            'steps': (100, 0), ############ un-move
            'pause': 10,
        },
        # Scene 1c3
        {
            'scene_type': 'move_piece',
            'piece_name': "SpherePyramid8-4Graphic",
            'steps': (-300, 0), ############ move
            'pause': 10,
        },
        
        # Scene 1d: pyramid pieces
        {
            'scene_type': 'text_and_highlight',
            'move_text': "  Now stack these on one another - the 8x8 square s64 at the bottom, then the 7x7 square, and so on to the 4x4 square on top. This is not quite a pyramid - since the 3x3 top is chopped off - but it's called one anyway! (The technical term is that it's a Truncated Square Pyramid.)",
            'highlighted_pieces': [], # 
            'highlighted_empty_squares': [
                # rank a :  (1,1),
                # rank o :
                (14,7)
            ],
            'pause': 20
        },
        

        # Scene 2a: 
        {
            'scene_type': 'text_and_highlight',
            'move_text': " The ancient Greeks were fascinated with sequences of numbers which correspond to geometric arrangements.   ",
            'highlighted_pieces': [],
            'highlighted_empty_squares': [ ],
            'pause': 20
        },
        ############## add pyramid numbers here ....
        # Scene 2a2
        {
            'scene_type': 'move_piece',
            'piece_name': "SpherePyramid8-4Graphic",
            'steps': (300, 0),############ un-move
            'pause': 10,
        },
        # Scene 2a3
        {
            'scene_type': 'move_piece',
            'piece_name': "SpherePyramid5-5Graphic",
            'steps': (-200, 0),############ move
            'pause': 10,
        },

        # Scene 2b: 
        {
            'scene_type': 'text_and_highlight',
            'move_text': "  For example: make 5 rows of pebbles spaced 1 unit from each other, to form a 5x5 square. The total number of pebbles - 25 in this case - a number the Greeks called a Square Number. We still use thie terminology today. If you stacked 5 such squares on top of each other to form a 5x5x5 cube, you would get 125 pebbles total, a Cube Number.  ",
            'highlighted_pieces': [],
            'highlighted_empty_squares': [ ],
            'pause': 20
        },
        # Scene 2a3
        {
            'scene_type': 'move_piece',
            'piece_name': "SpherePyramid5-5Graphic",
            'steps': (200, 0),
            'pause': 10,
        },
        # Scene 2c: 
        {
            'scene_type': 'text_and_highlight',
            'move_text': " The Square Pyramid Numbers are the pebble totals when you start with a square of pebbles on the base, then stack a smaller square of pebbles, and so on, until you have added all the squares less that the base square.  ",
            'highlighted_pieces': [],
            'highlighted_empty_squares': [ ],
            'pause': 20
        },
        # Scene 2d: 
        {
            'scene_type': 'text_and_highlight',
            'move_text': "  For example, 1, 1+4=5, 1+4+9=14, 1+4+9+16=30, 1+4+9+16+25=55, 1+4+9+16+25+36=91, are examples of Square Pyramid Numbers. The medieval monks who invented rithmomachia cleverly incorporated these numbers representing geometric figures into their game. ",
            'highlighted_pieces': [],
            'highlighted_empty_squares': [ ],
            'pause': 20
        },
        # Scene 2a3
        {
            'scene_type': 'move_piece',
            'piece_name': "SpherePyramid6-1GraphicS",
            'steps': (-400, 0),
            'pause': 20,
        },

        # Scene 2e
        {
            'scene_type': 'text_and_highlight',
            'move_text': "Very briefly: the way the Greeks taught Geometry and ancient Arithmetic didn't change that much by the year 1030 when rithmomachia was believed to have been invented. Sadly, limited time means we have to leave math history aside. Next, let's look at how the pyramid pieces move.",
            'highlighted_pieces': [],
            'highlighted_empty_squares': [
                #(2,1),(5,1),(8,1),(11,1),(14,1),(2,4),(5,4),
               # (8,4),(11,4),(14,4),(2,7),(5,7),(8,7),(11,7),(14,7)
            ],
            'pause': 20
        },
        # Scene 2a3
        {
            'scene_type': 'move_piece',
            'piece_name': "SpherePyramid6-1GraphicS",
            'steps': (400, 0),
            'pause': 10,
        },
        # Scene 3a: pyramid pieces
        {
            'scene_type': 'text_and_highlight',
            'move_text': "  We know of the previous lesson how each square and each pyramid moves - by 3 spaces orthogonally. (Remember, jumping over another piece is not allowed, so they can move 3 spaces only if they are not blocked.)",
            'highlighted_pieces': [], # 
            'highlighted_empty_squares': [
                # rank a :
                (1,1),
                # rank o :
                (14,7)],
            'pause': 20
        },

        # Scene 3b
        {
            'scene_type': 'text_and_highlight',
            'move_text': "The black pyramid can only move to certain squares. The highlighted coordinates are the ones it can move to (assuming no pieces blocked its way).",
            'highlighted_pieces': [],
            'highlighted_empty_squares': [
                (2,1),(5,1),(8,1),(11,1),(14,1),(2,4),(5,4),
                (8,4),(11,4),(14,4),(2,7),(5,7),(8,7),(11,7),(14,7)
            ],
            'pause': 20
        },
        # Scene 2a3
        {
            'scene_type': 'move_piece',
            'piece_name': "p190_1",
            'steps': (0,-3),
            'pause': 10,
        },
        # Scene 2a3
        {
            'scene_type': 'move_piece',
            'piece_name': "p190_1",
            'steps': (0, -3),
            'pause': 10,
        },
        # Scene 2a3
        {
            'scene_type': 'move_piece',
            'piece_name': "p190_1",
            'steps': (0, -3),
            'pause': 10,
        },
        # Scene 2a3
        {
            'scene_type': 'move_piece',
            'piece_name': "p190_1",
            'steps': (0, -3),
            'pause': 10,
        },
        # Scene 2a3
        {
            'scene_type': 'move_piece',
            'piece_name': "p190_1",
            'steps': (-3, 0),
            'pause': 10,
        },
        # Scene 2a3
        {
            'scene_type': 'move_piece',
            'piece_name': "p190_1",
            'steps': (-3, 0),
            'pause': 10,
        },
        # Scene 2a3
        {
            'scene_type': 'move_piece',
            'piece_name': "p190_1",
            'steps': (0, 3),
            'pause': 10,
        },
        # Scene 2a3
        {
            'scene_type': 'move_piece',
            'piece_name': "p190_1",
            'steps': (0, 3),
            'pause': 10,
        },
        # Scene 2a3
        {
            'scene_type': 'move_piece',
            'piece_name': "p190_1",
            'steps': (0, 3),
            'pause': 10,
        },
        # Scene 2a3
        {
            'scene_type': 'move_piece',
            'piece_name': "p190_1",
            'steps': (0, 3),
            'pause': 10,
        },
        # Scene 2a3
        {
            'scene_type': 'move_piece',
            'piece_name': "p190_1",
            'steps': (3, 0),
            'pause': 10,
        },
        # Scene 2a3
        {
            'scene_type': 'move_piece',
            'piece_name': "p190_1",
            'steps': (3, 0),
            'pause': 10,
        },

        # Scene 3c
        {
            'scene_type': 'text_and_highlight',
            'move_text': "Likewise, the white pyramid can only move to every 3rd square. We highlight the ones it can move to (assuming no pieces are in its way).",
            'highlighted_pieces': [],
            'highlighted_empty_squares': [
                (1,1),(1,4),(1,7),
                (4,1),(4,4),(4,7),
                (7,1),(7,4),(7,7),
                (10,1),(10,4),(10,7),
                # rank d (3): the forward-most white row (four values shown)
                (13,1),(13,4),(13,7)
            ],
            'pause': 20
        },
        ############## 
        # Scene 3d
        {
            'scene_type': 'text_and_highlight',
            'move_text': "Note the black pyramid can reach a coordinate adjacent to the white pyramid. (Highlighted below.) It can even land right next to it!",
            'highlighted_pieces': [],
            'highlighted_empty_squares': [
                (2,1),
            ],
            'pause': 20
        },
        # Scene 3e
        {
            'scene_type': 'text_and_highlight',
            'move_text': "Likewise, note the coordinate neighboring the black pyramid that the white pyramid can reach. (Highlighted below.) ",
            'highlighted_pieces': [],
            'highlighted_empty_squares': [
                (13,7),
            ],
            'pause': 20
        },
        ############## notice the coordinates neighboring the black pyramid that the white pyramid can reach
        # Scene 2a3
        {
            'scene_type': 'move_piece',
            'piece_name': "P091_1",
            'steps': (0,3),
            'pause': 10,
        },
        # Scene 2a3
        {
            'scene_type': 'move_piece',
            'piece_name': "P091_1",
            'steps': (0,3),
            'pause': 10,
        },
        # Scene 2a3
        {
            'scene_type': 'move_piece',
            'piece_name': "P091_1",
            'steps': (0,3),
            'pause': 10,
        },
        # Scene 2a3
        {
            'scene_type': 'move_piece',
            'piece_name': "P091_1",
            'steps': (0,3),
            'pause': 10,
        },
        # Scene 2a3
        {
            'scene_type': 'move_piece',
            'piece_name': "P091_1",
            'steps': (3, 0),
            'pause': 10,
        },
        # Scene 2a3
        {
            'scene_type': 'move_piece',
            'piece_name': "P091_1",
            'steps': (3, 0),
            'pause': 10,
        },
        # Scene 2a3
        {
            'scene_type': 'move_piece',
            'piece_name': "P091_1",
            'steps': (0, -3),
            'pause': 10,
        },
        # Scene 2a3
        {
            'scene_type': 'move_piece',
            'piece_name': "P091_1",
            'steps': (0, -3),
            'pause': 10,
        },
        # Scene 2a3
        {
            'scene_type': 'move_piece',
            'piece_name': "P091_1",
            'steps': (0, -3),
            'pause': 10,
        },
        # Scene 2a3
        {
            'scene_type': 'move_piece',
            'piece_name': "P091_1",
            'steps': (0, -3),
            'pause': 10,
        },
        # Scene 2a3
        {
            'scene_type': 'move_piece',
            'piece_name': "P091_1",
            'steps': (-3, 0),
            'pause': 10,
        },
        # Scene 2a3
        {
            'scene_type': 'move_piece',
            'piece_name': "P091_1",
            'steps': (-3, 0),
            'pause': 10,
        },
        # Scene 4
        {
            'scene_type': 'text_and_highlight',
            'move_text': "After a future lesson on capturing, you will see how the pyramid subpieces can capture or be captured in this sort of adjacent piece position.",
            'highlighted_pieces': [],
            'highlighted_empty_squares': [
                (2,1),
                (13,7),
            ],
            'pause': 20
        },
    
        
        # Scene 6: pyramid pieces
        {
            'scene_type': 'text_and_highlight',
            'move_text': "  This lesson taught us a little on how the pyramids pieces move and why ancient scholars believed the the Pyramid shape was important. We will discuss how the pyramid piece can be involved in capturing (and being captured) in a later lesson.",
            'highlighted_pieces': [], # 
            'highlighted_empty_squares': [
                # rank a :
                (1,1),
                # rank o :
                (14,7)],
            'pause': 20
        },
        # Scene 7: 
        {
            'scene_type': 'text_and_highlight',
            'move_text': " Thank you for watching this video about the Pyramid piece. This is Professor Pyramid signing off. I hope to see you in another rithmomachia lesson soon! ",
            'highlighted_pieces': [],
            'highlighted_empty_squares': [ ],
            'pause': 20
        },
    ]
    
    return animation_sequence

def run_integrated_animation(pieces_on_board, start_frame=1):
    """
    Executes the complete educational animation with Professor Pyramid and game board.
    
    This function orchestrates the entire animation sequence, coordinating Professor
    Pyramid's movements and gestures with the game board demonstrations. It handles
    text display, piece highlighting, movement animations, and character interactions.
    
    Args:
        pieces_on_board (dict): Dictionary mapping piece names to their objects
    
    Returns:
        int: Final frame number of the animation
        
    Animation Coordination:
        - Synchronizes Professor Pyramid's walking animation with instruction delivery
        - Manages text scrolling and educational content display
        - Coordinates piece highlighting with verbal instruction
        - Handles smooth transitions between educational topics
        
    Character Integration:
        - Professor Pyramid gestures toward relevant board elements
        - Mouth animation synchronized with text display
        - Pointer rotation for visual emphasis
        - Natural character movement throughout instruction
    """
    global current_top_text, current_bottom_text
    current_top_text = None
    current_bottom_text = None

    current_frame = start_frame
    animation_sequence = create_educational_animation_sequence()

    # --- NEW: Graphic management ---
    graphic_objects = {}  # A dictionary to store created graphic planes
    active_graphic = None # Keep track of the currently visible graphic
    graphic_location = Vector((15, -10, 5)) # Position for the graphic off to the side
    # --- END NEW ---

    # Initial introduction
    intro_text = "I am Professor Pyramid, your guide to learning Rithmomachia. Welcome! "

    if intro_text.strip():
        top_position = (14, 1, 2)  # Positioned to right of board, above
        current_top_text = create_board_text_area(
            intro_text, 
            top_position, 
            "initial_intro_text",
            font_size=0.4,
            max_width=20
        )
        current_top_text.hide_render = True
        bpy.context.scene.frame_current = current_frame
        current_top_text.hide_render = False
        current_frame += 120

    # Process each animation scene
    for scene in animation_sequence:
        # --- NEW: Hide the previous graphic at the start of the new scene ---
        if active_graphic:
            active_graphic.hide_render = True
            active_graphic.keyframe_insert(data_path="hide_render", frame=current_frame -1)
            active_graphic = None
        # --- END NEW ---
            
        scene_type = scene.get('scene_type')
        
        if scene_type == 'text_and_highlight':
            move_text = scene.get('move_text', "")
            pause = scene.get('pause', 10)
            highlighted_pieces = scene.get('highlighted_pieces', [])
            highlighted_empty_squares = scene.get('highlighted_empty_squares', [])
            
            # Handle text display
            new_top_text = None
            if move_text.strip():
                top_position = (14, 1, 4)
                new_top_text = create_board_text_area(
                    move_text, 
                    top_position, 
                    f"move_text_{current_frame}",
                    font_size=0.4,
                    max_width=20
                )
                new_top_text.hide_render = True
                new_top_text.keyframe_insert(data_path="hide_render", frame=current_frame - 1)
                bpy.context.scene.frame_current = current_frame
                new_top_text.hide_render = False
                new_top_text.keyframe_insert(data_path="hide_render", frame=current_frame)
                
            if current_top_text and new_top_text:
                scroll_text_down(current_top_text, current_bottom_text, current_frame + 10, duration=20)
                if current_bottom_text:
                    pass  # Keep for reference
                current_bottom_text = current_top_text
                current_top_text = new_top_text
                current_frame += 40
            elif new_top_text:
                current_top_text = new_top_text
                current_frame += 20
            
            # Handle highlighting
            highlight_duration = pause + 10 
            for piece_to_highlight in highlighted_pieces:
                piece_obj = pieces_on_board.get(piece_to_highlight)
                if piece_obj:
                    highlight_piece(piece_obj, start_frame=current_frame, duration=highlight_duration)

            for x, y in highlighted_empty_squares:
                highlight_square(x, y, start_frame=current_frame, duration=highlight_duration)

            current_frame += pause

        elif scene_type == 'move_piece':
            piece_name = scene.get('piece_name')
            steps = scene.get('steps', (0,0))
            pause = scene.get('pause', 10)
            
            piece = pieces_on_board.get(piece_name)
            if not piece:
                print(f"Warning: Piece '{piece_name}' not found on the board.")
                continue
                
            move_end_frame = animate_piece_move(piece, current_frame, steps[0], steps[1])
            current_frame = max(current_frame + 20, move_end_frame) + pause
            
    return current_frame

# =============================================================================
# SCENE SETUP FUNCTIONS
# =============================================================================

def setup_integrated_scene(config, target_location):
    """
    Sets up camera, lighting, and environment for the integrated educational scene.
    
    This function creates the professional lighting and camera setup needed for
    the educational animation. It positions the camera to capture both Professor
    Pyramid and the game board effectively, with lighting that highlights the
    3D elements clearly.
    
    Args:
        config (dict): Configuration containing camera positioning
        target_location (Vector): Point for camera to focus on
    
    Scene Elements:
        - Main camera positioned for optimal viewing of both character and board
        - Sun lamp for strong directional lighting
        - Fill light to reduce harsh shadows
        - Background elements for visual context
        
    Lighting Design:
        - Strong sun light for clear piece visibility
        - Soft fill light to illuminate shadowed areas
        - Proper contrast for educational clarity
        - Professional appearance suitable for instructional content
    """
    # Create camera target
    bpy.ops.object.empty_add(type='PLAIN_AXES', location=target_location)
    target_empty = bpy.context.object
    target_empty.name = "CameraTarget"

    # Set up main camera
    bpy.ops.object.camera_add(location=config["camera_location"])
    camera = bpy.context.object
    bpy.context.scene.camera = camera
    camera.data.lens = 50
    camera.data.clip_end = 500
    
    # Add camera tracking constraint
    constraint = camera.constraints.new(type='TRACK_TO')
    constraint.target = target_empty
    constraint.track_axis = 'TRACK_NEGATIVE_Z'
    constraint.up_axis = 'UP_Y'

    # Set up main sun lighting
    bpy.ops.object.light_add(type='SUN', location=(4, 6, 10))
    sun_lamp = bpy.context.object
    sun_lamp.data.energy = 20    
    sun_lamp.data.shadow_soft_size = 0.01
    sun_lamp.rotation_euler = (math.radians(55), math.radians(25), math.radians(0))
    
    # Add fill lighting
    bpy.ops.object.light_add(type='AREA', location=(-2, 2, 12))
    fill_light = bpy.context.object
    fill_light.data.energy = 10.0
    fill_light.data.shadow_soft_size = 0.1
    fill_light.rotation_euler = (math.radians(-25), math.radians(-25), math.radians(-5))
    
    # Create background elements
    blue_rgba = (0.1, 0.2, 0.8, 1.0)
    blue_mat = get_or_create_material("BlueWall", blue_rgba)
    bpy.ops.mesh.primitive_plane_add(size=40, location=(0, 30, 0))
    wall_obj = bpy.context.active_object
    wall_obj.rotation_euler = (math.radians(90), 0, 0)
    wall_obj.data.materials.append(blue_mat)
    
    brown_rgba = (0.15, 0.1, 0.05, 1.0)
    brown_mat = get_or_create_material("BrownBackground", brown_rgba)
    bpy.ops.mesh.primitive_plane_add(
        size=30,
        location=(3.5, 7.5, -0.01)
    )
    background_obj = bpy.context.active_object
    background_obj.data.materials.append(brown_mat)

def create_professor_pyramid(config):
    """
    Main function to create Professor Pyramid character with full animation setup.
    
    This function orchestrates the creation of the complete Professor Pyramid
    character, including body, limbs, facial features, and animation systems.
    It serves as the main entry point for character creation.
    
    Args:
        config (dict): Complete configuration for character creation and animation
    
    Returns:
        tuple: (character_objects, limb_data)
            - character_objects: Dictionary of all character components
            - limb_data: Data structure for animation system setup
            
    Character Components:
        - Main pyramid body with materials
        - Facial features (eyes, nose, mouth)
        - Arms and legs with proper proportions
        - Hands and feet
        - Teaching pointer
        - Animation rigging system
        
    Integration Features:
        - All parts properly parented for unified movement
        - Materials applied for consistent appearance
        - Animation systems ready for educational sequence
        - Proper scaling and positioning for scene integration
    """
    # Create main character components
    body, body_verts = create_professor_body(config)
    nose_location = create_professor_face(config, body_verts)
    limb_parts = create_professor_limbs(config, body_verts)
    create_professor_pointer(config, limb_parts["wrist_R"])
    
    # Set up animation systems
    #animate_professor_walk(config, body, limb_parts, body_verts)
    animate_professor_gestures(config)
    
    # Parent all parts to body (except IK targets which must remain in world space)
    for obj in bpy.context.scene.objects:
        if (obj.parent is None and obj != body and 
            "IKTarget" not in obj.name and "Camera" not in obj.name and
            "Light" not in obj.name and "Empty" not in obj.name):
            obj.parent = body

    character_objects = {
        "body": body,
        "nose_location": nose_location,
        "limb_parts": limb_parts
    }
    
    return character_objects, limb_parts

# =============================================================================
# MAIN INTEGRATION FUNCTION
# =============================================================================

def main_integrated_animation():
    """
    Main function that creates and runs the complete integrated educational animation.
    
    This is the primary entry point for the entire system. It orchestrates the
    creation of Professor Pyramid, the game board, all game pieces, and runs
    the complete educational animation sequence.
    """
    # Clean scene setup
    for obj in bpy.context.scene.objects:
        bpy.data.objects.remove(obj, do_unlink=True)

    # Define positions
    intro_start_pos = Vector((13, -5, 10.5))
    intro_start_rotation_z = math.radians(70)
    intro_start_rotation_y = math.radians(0)  # NEW: Y rotation for intro
    intro_start_rotation_x = math.radians(10)  # NEW: "X rotation" for intro

    tutorial_end_pos = Vector((-1, 1, -2.0))
    tutorial_end_rotation_z = math.radians(75)  # Keep same as intro
    tutorial_end_rotation_y = math.radians(0)  # NEW: Tilt toward camera
    tutorial_end_rotation_x = math.radians(0)  # NEW: Tilt toward camera
    
    # Timing calculations - MOVED UP
    intro_pause_duration = 120
    retreat_duration = 60
    current_frame = 1
    speech_end_frame = current_frame + intro_pause_duration  # Calculate BEFORE using

    # Create professor config for intro position
    temp_config = PROFESSOR_CONFIG.copy()
    temp_config["com"] = intro_start_pos
    temp_config["body_rotation"] = intro_start_rotation_z
    
    # Create Professor with intro position (with walking animation commented out)
    character_data, limb_data = create_professor_pyramid(temp_config)
    professor_body = character_data["body"]

    # NOW you can safely use speech_end_frame
    # Set explicit keyframes for intro position
    bpy.context.scene.frame_set(1)
    professor_body.location = intro_start_pos
    professor_body.rotation_euler.z = intro_start_rotation_z
    professor_body.keyframe_insert(data_path="location", frame=1)
    professor_body.keyframe_insert(data_path="rotation_euler", frame=1, index=2)

    # Hold position through speech
    bpy.context.scene.frame_set(speech_end_frame)
    professor_body.keyframe_insert(data_path="location", frame=speech_end_frame)
    professor_body.keyframe_insert(data_path="rotation_euler", frame=speech_end_frame, index=2)
    
    # Set up camera
    target_location = intro_start_pos
    setup_integrated_scene(PROFESSOR_CONFIG, target_location)
    
    # Hold at intro position for speech
    speech_end_frame = current_frame + intro_pause_duration
    
    # Animate retreat to tutorial position
    animation_end_frame = animate_professor_intro(
        body_obj=professor_body,
        start_pos=intro_start_pos,
        end_pos=tutorial_end_pos,  # Use explicit coordinates
        start_rot_z=intro_start_rotation_z,
        end_rot_z=tutorial_end_rotation_z,
        start_rot_y=intro_start_rotation_y,  # NEW
        end_rot_y=tutorial_end_rotation_y,   # NEW
        start_rot_x=intro_start_rotation_x,  # NEW
        end_rot_x=tutorial_end_rotation_x,   # NEW
        start_frame=speech_end_frame,
        duration=retreat_duration
    )
    
    # Update camera to look at board center after professor moves
    bpy.context.scene.frame_set(animation_end_frame + 10)
    camera_target = bpy.data.objects.get("CameraTarget")
    if camera_target:
        board_center = Vector((4, 8, 1))  # Center of 8x16 board
        camera_target.location = board_center
        camera_target.keyframe_insert(data_path="location")
    
    tutorial_start_frame = animation_end_frame + 20

    # The rest of the animation will start after the intro is finished.
    tutorial_start_frame = animation_end_frame + 20 # Add a small buffer pause
    # --- END NEW ---

    # Create game board
    draw_grid_with_lines(rows=16, cols=8, square_size=1, z=0)
    
    # Create game pieces from custom board configuration (This part is unchanged)
    #game_state = copy.copy(CUSTOM_GAME_BOARD)
    game_state = copy.copy(CUSTOM_GAME_BOARD)
    pieces_on_board = {}

    # --- START ----
    #
    # Create the new graphics object off to the side of the board.
    # This example creates a 6x6 slab, a 5x5 slab, then 4x4, 3x3, 2x2, and 1x1 on top.
    stack_location = Vector((8 + 100, -4, 2)) # Position it to the left-center of the board
    pyramid_graphic = create_stacked_slabs_graphic(
        location=stack_location,
        slab_sizes=[6, 5, 4, 3, 2, 1], # Creates a pyramid shape
        obj_type="cube",         # Use spheres as building blocks
        diameter=0.7,              # Diameter of each sphere
        sep_dist=0.1,              # Small gap between spheres
        name="SpherePyramid6-1Graphic", # Unique name for the object
        stack_color = (0.0, 0.0, 1.0, 1.0) #  blue
    )
    # Add it to the dictionary so the animation system can find it
    pieces_on_board["SpherePyramid6-1Graphic"] = pyramid_graphic
    #
    # Create the new graphics object off to the side of the board.
    # This example creates a 5x5 slab, stacked 5 times on top.
    stack_location = Vector((8 + 200, -4, 2)) # Position it to the left-center of the board
    pyramid_graphic = create_stacked_slabs_graphic(
        location=stack_location,
        slab_sizes=[5, 5, 5, 5, 5], # Creates a pyramid shape
        obj_type="sphere",         # Use spheres as building blocks
        diameter=0.7,              # Diameter of each sphere
        sep_dist=0.1,              # Small gap between spheres
        name="SpherePyramid5-5Graphic" # Unique name for the object
    )
    pieces_on_board["SpherePyramid5-5Graphic"] = pyramid_graphic
    #
    # Create the new graphics object off to the side of the board.
    stack_location = Vector((8 + 300, -4, 2)) # Position it to the left-center of the board
    pyramid_graphic = create_stacked_slabs_graphic(
        location=stack_location,
        slab_sizes=[8, 7, 6, 5, 4], # Creates a pyramid shape
        obj_type="sphere",         # Use spheres as building blocks
        diameter=0.7,              # Diameter of each sphere
        sep_dist=0.1,              # Small gap between spheres
        name="SpherePyramid8-4Graphic" # Unique name for the object
    )
    # Add it to the dictionary so the animation system can find it
    pieces_on_board["SpherePyramid8-4Graphic"] = pyramid_graphic
    #
    stack_location = Vector((8 + 400, -4, 2)) # Position it to the left-center of the board
    pyramid_graphic = create_stacked_slabs_graphic(
        location=stack_location,
        slab_sizes=[6, 5, 4, 3, 2, 1], # Creates a pyramid shape
        obj_type="sphere",         # Use spheres as building blocks
        diameter=0.7,              # Diameter of each sphere
        sep_dist=0.1,              # Small gap between spheres
        name="SpherePyramid6-1GraphicS", # Unique name for the object
        stack_color = (1.0, 1.0, 1.0, 1.0) #  blue-sh
    )
    # Add it to the dictionary so the animation system can find it
    pieces_on_board["SpherePyramid6-1GraphicS"] = pyramid_graphic
    # --- END  ---
    
    for ii in range(8):
        for jj in range(16):
            pc = game_state[ii][jj]
            if pc != "":
                pc_str = copy.copy(pc)
                
                # Determine piece type and create accordingly
                if pc_str[0] == "C":
                    val_pc_str = str(int(pc_str[-5:-2]))
                    pieces_on_board[pc_str] = create_circle_piece(
                        x0=ii, y0=jj, z0=0, r0=0.4, val=val_pc_str, 
                        color_name=pc_str, color_rgba=(0, 1, 0, 1),
                    )
                elif pc_str[0] == "T":
                    val_pc_str = str(int(pc_str[-5:-2]))
                    pieces_on_board[pc_str] = create_triangle_piece(
                        x0=ii, y0=jj, z0=0, side=0.9, val=val_pc_str, 
                        color_name=pc_str, color_rgba=(0, 1, 0, 1),
                    )
                elif pc_str[0] == "S":
                    val_pc_str = str(int(pc_str[-5:-2]))
                    pieces_on_board[pc_str] = create_square_piece(
                        x0=ii, y0=jj, z0=0, side=0.9, val=val_pc_str, 
                        color_name=pc_str, color_rgba=(0, 1, 0, 1),
                    )
                elif pc_str[0] == "P":
                    val_pc_str = str(int(pc_str[-5:-2]))
                    pieces_on_board[pc_str] = create_pyramid_piece(
                        x0=ii, y0=jj, z0=0, side=0.9, values=WHITE_PYRAMID_VALUES, 
                        color_name=pc_str, color_rgba=(0, 1, 1, 1),
                        show_subpiece_values=False
                    )
                    # Create additional pyramid variants for capture demonstrations
                    WHITE_PYRAMID_VALUES_16 = [1, 4, 9, 25, 36]
                    val_pc_str_16 = str(int(pc_str[-5:-2])-16)
                    pc_str_16 = pc_str[0] + str(val_pc_str_16).zfill(3) + "_1"
                    pieces_on_board[pc_str_16] = create_pyramid_piece(
                        x0=ii - 50 - 16, y0=jj + 50 + 16, z0=0, side=0.9, 
                        values=WHITE_PYRAMID_VALUES_16, 
                        color_name=pc_str_16, color_rgba=(0, 1, 1, 1), 
                        show_subpiece_values=False
                    )
                # Handle black pieces similarly
                elif pc_str[0] == "c":
                    val_pc_str = str(int(pc_str[-5:-2]))
                    pieces_on_board[pc_str] = create_circle_piece(
                        x0=ii, y0=jj, z0=0, r0=0.4, val=val_pc_str, 
                        color_name=pc_str, color_rgba=(1, 0, 0, 1),
                    )
                elif pc_str[0] == "t":
                    val_pc_str = str(int(pc_str[-5:-2]))
                    pieces_on_board[pc_str] = create_triangle_piece(
                        x0=ii, y0=jj, z0=0, side=0.9, val=val_pc_str, 
                        color_name=pc_str, color_rgba=(1, 0, 0, 1),
                    )
                elif pc_str[0] == "s":
                    val_pc_str = str(int(pc_str[-5:-2]))
                    pieces_on_board[pc_str] = create_square_piece(
                        x0=ii, y0=jj, z0=0, side=0.9, val=val_pc_str, 
                        color_name=pc_str, color_rgba=(1, 0, 0, 1),
                    )
                elif pc_str[0] == "p":
                    val_pc_str = str(int(pc_str[-5:-2]))
                    pieces_on_board[pc_str] = create_pyramid_piece(
                        x0=ii, y0=jj, z0=0, side=0.9, values=BLACK_PYRAMID_VALUES, 
                        color_name=pc_str, color_rgba=(1, 0, 1, 1),
                        show_subpiece_values=False
                    )
                    # Create pyramid variants for black pieces
                    BLACK_PYRAMID_VALUES_25 = [16, 36, 49, 64]
                    val_pc_str_25 = str(int(pc_str[-5:-2])-25)
                    pc_str_25 = pc_str[0] + str(val_pc_str_25).zfill(3) + "_1"
                    pieces_on_board[pc_str_25] = create_pyramid_piece(
                        x0=ii - 50 - 25, y0=jj + 50 + 25, z0=0, side=0.9, 
                        values=BLACK_PYRAMID_VALUES_25, 
                        color_name=pc_str_25, color_rgba=(1, 0, 1, 1), 
                        show_subpiece_values=False
                    )

    # Set up scene lighting and camera
    target_location = (5,8,0)
    setup_integrated_scene(PROFESSOR_CONFIG, target_location)
    
    final_frame = run_integrated_animation(pieces_on_board, start_frame=tutorial_start_frame)
    
    # Set animation timeline
    bpy.context.scene.frame_start = 1
    bpy.context.scene.frame_end = final_frame + 50
    bpy.context.scene.frame_current = 1
    
    print(f"Integrated animation complete! Professor Pyramid teaches pyramid pieces.")
    print(f"Total frames: {final_frame + 50}")
    print(f"Pieces created: {len(pieces_on_board)}")

# =============================================================================
# EXECUTION
# =============================================================================

if __name__ == "__main__":
    main_integrated_animation()
    print("Professor Pyramid Rithmomachia Tutorial - Animation Complete!")

