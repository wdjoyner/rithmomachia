"""
draws Professor Pyramid, a character designed to teach rithmomachia


copyright: william david joyner, wdjoyner@gmail.com
licence: modified BSD
last modified: 2025-07-08
"""
import matplotlib.pyplot as plt
from matplotlib.patches import Polygon, Circle, Ellipse
import numpy as np

def draw_professor_pyramid(
    # Pyramid placement and features
    pyramid_base_center_x=3.5, pyramid_base_center_y=1.0,
    pyramid_height = 4.0,
    pyramid_base_width = 4.0,
    pupil_offset_x=0.0, pupil_offset_y=0.0,
    mouth_width=1.0, mouth_height=0.4,
    ear_offset = 1.3,
    left_ear_angle=0,   # <-- NEW PARAMETER FOR LEFT EAR ROTATION
    right_ear_angle=0,  # <-- NEW PARAMETER FOR RIGHT EAR ROTATION

    # Left hand parameters with new defaults
    left_hand_visible=True,
    left_hand_wrist_angle=0,
    left_hand_wrist_base_width = 0.3,
    left_hand_offset_x = -2.0,
    left_hand_offset_y = 0.2,
    left_palm_width=1.5,
    left_palm_height=1.0,
    left_palm_offset_x=0.0,
    left_palm_offset_y=0.8,

    # Right hand parameters with new defaults
    right_hand_visible=True,
    right_hand_wrist_angle=0,
    right_hand_wrist_base_width = 0.3,
    right_hand_offset_x = 2.0,
    right_hand_offset_y = 0.2,
    right_palm_width=1.5,
    right_palm_height=1.0,
    right_palm_offset_x=0.0,
    right_palm_offset_y=0.8,

    # Pointer parameters
    pointer_hand='right',  # 'left', 'right', or None
    pointer_length=3.0,
    pointer_angle_degrees=-20
    ):
    """
    Draws a complete "Professor Pyramid" character using the new
    set of default values for a refined appearance.
    """
    fig, ax = plt.subplots(figsize=(8, 8))

    # --- 1. Draw the Pyramid (Head/Body) ---
    top_vertex = np.array([pyramid_base_center_x, pyramid_base_center_y + pyramid_height])
    base_left = np.array([pyramid_base_center_x - pyramid_base_width / 2, pyramid_base_center_y])
    base_right = np.array([pyramid_base_center_x + pyramid_base_width / 2, pyramid_base_center_y])
    base_center = np.array([pyramid_base_center_x, pyramid_base_center_y - 1.0])
    front_face_left = Polygon([top_vertex, base_left, base_center], closed=True, facecolor='khaki', edgecolor='black', linewidth=2)
    front_face_right = Polygon([top_vertex, base_center, base_right], closed=True, facecolor='goldenrod', edgecolor='black', linewidth=2)
    ax.add_patch(front_face_left)
    ax.add_patch(front_face_right)
    
    ############################################## nose
    nose_tip = np.array([pyramid_base_center_x, pyramid_base_center_y + 1.8])
    nose = Polygon([nose_tip, [nose_tip[0] - 0.3, nose_tip[1] - 0.8], [nose_tip[0] + 0.3, nose_tip[1] - 0.8]],
                   closed=True, facecolor='orange', edgecolor='black', linewidth=2)
    ax.add_patch(nose)
    mouth_center = (pyramid_base_center_x, pyramid_base_center_y + 0.5)
    ax.add_patch(Ellipse(mouth_center, width=mouth_width, height=mouth_height, facecolor='red', edgecolor='black', linewidth=2))

    # --- THIS SECTION IS UPDATED FOR EAR ROTATION ---
    def rotate_points(points, angle_deg, center):
        """Helper function to rotate a list of points."""
        angle_rad = np.radians(angle_deg)
        cos_t, sin_t = np.cos(angle_rad), np.sin(angle_rad)
        cx, cy = center
        rotated_points = []
        for x, y in points:
            x_shifted, y_shifted = x - cx, y - cy
            xr = cos_t * x_shifted - sin_t * y_shifted + cx
            yr = sin_t * x_shifted + cos_t * y_shifted + cy
            rotated_points.append([xr, yr])
        return rotated_points

    ############################################ ears
    ear_height = pyramid_base_center_y + 2.5
    ear_length = 1.2
    y_ratio = (ear_height - base_left[1]) / (top_vertex[1] - base_left[1])
    ear_attach_x_left = base_left[0] + (top_vertex[0] - base_left[0]) * y_ratio
    ear_attach_x_right = base_right[0] + (top_vertex[0] - base_right[0]) * y_ratio

    # Left Ear
    left_ear_attach_point = [ear_attach_x_left - ear_offset, ear_height]
    unrotated_left_ear = [
        left_ear_attach_point,
        [left_ear_attach_point[0], left_ear_attach_point[1] + ear_length],
        [left_ear_attach_point[0] - ear_length, left_ear_attach_point[1]]
    ]
    rotated_left_ear_pts = rotate_points(unrotated_left_ear, left_ear_angle, center=left_ear_attach_point)
    ax.add_patch(Polygon(rotated_left_ear_pts, closed=True, facecolor='khaki', edgecolor='black', linewidth=2))

    # Right Ear
    right_ear_attach_point = [ear_attach_x_right + ear_offset, ear_height]
    unrotated_right_ear = [
        right_ear_attach_point,
        [right_ear_attach_point[0], right_ear_attach_point[1] + ear_length],
        [right_ear_attach_point[0] + ear_length, right_ear_attach_point[1]]
    ]
    rotated_right_ear_pts = rotate_points(unrotated_right_ear, right_ear_angle, center=right_ear_attach_point)
    ax.add_patch(Polygon(rotated_right_ear_pts, closed=True, facecolor='goldenrod', edgecolor='black', linewidth=2))

    #################### ears
    eye_radius = 0.4
    eye_y = pyramid_base_center_y + 2.2
    eye_x_offset = pyramid_base_width * 0.25
    left_eye_center = (pyramid_base_center_x - eye_x_offset, eye_y)
    right_eye_center = (pyramid_base_center_x + eye_x_offset, eye_y)
    ax.add_patch(Circle(left_eye_center, eye_radius, facecolor='white', edgecolor='black', linewidth=2))
    ax.add_patch(Circle(right_eye_center, eye_radius, facecolor='white', edgecolor='black', linewidth=2))
    pupil_radius = 0.15
    ax.add_patch(Circle((left_eye_center[0] + pupil_offset_x, eye_y + pupil_offset_y), pupil_radius, facecolor='black'))
    ax.add_patch(Circle((right_eye_center[0] + pupil_offset_x, eye_y + pupil_offset_y), pupil_radius, facecolor='black'))


    # --- Helper Function to Draw a Hand ---
    # The hardcoded values in this function are now the smaller, refined defaults.
    def draw_hand(ax, hand_type, wrist_angle_deg, wrist_base_width, base_cx, base_cy,
                  palm_w, palm_h, palm_ox, palm_oy):
        theta = np.radians(wrist_angle_deg)
        cos_t, sin_t = np.cos(theta), np.sin(theta)
        def rotate_point(x, y, cx, cy):
            x_shifted, y_shifted = x - cx, y - cy
            xr = cos_t * x_shifted - sin_t * y_shifted + cx
            yr = sin_t * x_shifted + cos_t * y_shifted + cy
            return xr, yr
        wrist_height = 1.0
        wrist_top_width = 1.2
        wrist_pts = np.array([
            [base_cx - wrist_top_width / 2, base_cy + wrist_height], [base_cx + wrist_top_width / 2, base_cy + wrist_height],
            [base_cx + wrist_base_width / 2, base_cy], [base_cx - wrist_base_width / 2, base_cy]
        ])
        wrist_pts_rot = np.array([rotate_point(x, y, base_cx, base_cy) for x, y in wrist_pts])
        ax.add_patch(Polygon(wrist_pts_rot, closed=True, facecolor='tan', edgecolor='black', linewidth=2))
        palm_center = rotate_point(base_cx + palm_ox, base_cy + wrist_height + palm_oy, base_cx, base_cy)
        ax.add_patch(Ellipse(palm_center, palm_w, palm_h, angle=wrist_angle_deg, facecolor='tan', edgecolor='black', linewidth=2))
        finger_centers = [
            rotate_point(base_cx - 0.5, base_cy + wrist_height + 1.1, base_cx, base_cy),
            rotate_point(base_cx, base_cy + wrist_height + 1.4, base_cx, base_cy),
            rotate_point(base_cx + 0.5, base_cy + wrist_height + 1.1, base_cx, base_cy)
        ]
        for fc in finger_centers:
            ax.add_patch(Ellipse(fc, 0.4, 1.0, angle=wrist_angle_deg, facecolor='tan', edgecolor='black', linewidth=2))
        thumb_offset_x = 0.5 if hand_type == 'right' else -0.5
        thumb_angle = wrist_angle_deg + (-60 if hand_type == 'right' else 60)
        thumb_center = rotate_point(base_cx + thumb_offset_x, base_cy + wrist_height + 0.5, base_cx, base_cy)
        ax.add_patch(Ellipse(thumb_center, 0.4, 1.0, angle=thumb_angle, facecolor='tan', edgecolor='black', linewidth=2))
        return palm_center

    # --- Draw Hands ---
    palm_centers = {}
    if left_hand_visible:
        cx_left = pyramid_base_center_x + left_hand_offset_x
        cy_left = pyramid_base_center_y + left_hand_offset_y
        palm_centers['left'] = draw_hand(ax, 'left', left_hand_wrist_angle, left_hand_wrist_base_width, cx_left, cy_left,
                                         left_palm_width, left_palm_height, left_palm_offset_x, left_palm_offset_y)
    if right_hand_visible:
        cx_right = pyramid_base_center_x + right_hand_offset_x
        cy_right = pyramid_base_center_y + right_hand_offset_y
        palm_centers['right'] = draw_hand(ax, 'right', right_hand_wrist_angle, right_hand_wrist_base_width, cx_right, cy_right,
                                          right_palm_width, right_palm_height, right_palm_offset_x, right_palm_offset_y)

    # --- Draw Pointer ---
    if pointer_hand and pointer_hand in palm_centers:
        hand_center = palm_centers[pointer_hand]
        pointer_angle_rad = np.radians(pointer_angle_degrees)
        start_x, start_y = hand_center
        end_x = start_x + pointer_length * np.cos(pointer_angle_rad)
        end_y = start_y + pointer_length * np.sin(pointer_angle_rad)
        pointer_width = 0.1
        dx = pointer_width * np.cos(pointer_angle_rad + np.pi/2)
        dy = pointer_width * np.sin(pointer_angle_rad + np.pi/2)
        pointer_pts = [
            (start_x - dx, start_y - dy), (start_x + dx, start_y + dy),
            (end_x + dx, end_y + dy), (end_x - dx, end_y - dy)
        ]
        ax.add_patch(Polygon(pointer_pts, closed=True, facecolor='saddlebrown', edgecolor='black', linewidth=1.5))

    # --- Final Display Settings ---
    ax.set_xlim(-1, 9)
    ax.set_ylim(0, 8)
    ax.set_aspect('equal')
    ax.axis('off')
    plt.show()

# --- Example Usage ---
# Calling the function without arguments now uses your new defaults
#print("Displaying Professor Pyramid with the new default appearance...")
#draw_professor_pyramid()

draw_professor_pyramid(
    left_palm_offset_y=0.5,  # <-- DECREASED FROM 0.8
    right_palm_offset_y=0.5, # <-- DECREASED FROM 0.8
    # You can also adjust other parameters for the pose
    right_hand_wrist_angle=-25,
    left_hand_wrist_angle=35,
    pointer_hand='right',
    pointer_angle_degrees=90,
    left_ear_angle = 200,
    right_ear_angle = -200
)
