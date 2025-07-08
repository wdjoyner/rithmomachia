"""
draws Professor Pyramid, a character designed to teach rithmomachia


copyright william david joyner, wdjoyner@gmail.com
last modified 2025-07-08
"""
import matplotlib.pyplot as plt
from matplotlib.patches import Polygon, Circle, Ellipse
import numpy as np

def draw_professor_pyramid(
    # Pyramid placement and features
    pyramid_base_center_x=3.5, pyramid_base_center_y=1.0,
    pyramid_angle=20, pupil_offset_x=0.0, pupil_offset_y=0.0,
    mouth_width=1.0, mouth_height=0.4,

    # Left hand parameters
    left_hand_visible=True,
    left_hand_wrist_angle=0,
    left_hand_wrist_base_width=0.6,
    left_hand_offset_x=-2.0,
    left_hand_offset_y=0.5,

    # Right hand parameters
    right_hand_visible=True,
    right_hand_wrist_angle=0,
    right_hand_wrist_base_width=0.6,
    right_hand_offset_x=2.0,
    right_hand_offset_y=0.5,

    # Pointer parameters
    pointer_hand='right',  # 'left', 'right', or None
    pointer_length=3.0,
    pointer_angle_degrees=-20
    ):
    """
    Draws a complete "Professor Pyramid" character with a head, hands, and a pointer.

    The function is highly parameterized to control the position and features of the
    pyramid, each hand, and a pointer held in one of the hands. This is intended
    for use in animations where character movements explain concepts.
    """
    fig, ax = plt.subplots(figsize=(8, 8))

    # --- 1. Draw the Pyramid (Head/Body) ---
    # Center point of the pyramid's top
    T = np.array([pyramid_base_center_x, pyramid_base_center_y + 4.0])
    base_width = 4.0 * np.cos(np.radians(pyramid_angle))
    P1 = np.array([pyramid_base_center_x - base_width / 2, pyramid_base_center_y])
    P2 = np.array([pyramid_base_center_x + base_width / 2, pyramid_base_center_y])
    P3 = np.array([pyramid_base_center_x + base_width / 4, pyramid_base_center_y + 0.5])

    # Front and side faces
    front_face = Polygon([T, P1, P2], closed=True, facecolor='khaki', edgecolor='black', linewidth=2)
    side_face = Polygon([T, P2, P3], closed=True, facecolor='goldenrod', edgecolor='black', linewidth=2)
    ax.add_patch(front_face)
    ax.add_patch(side_face)

    # Eyes
    eye_radius = 0.4
    eye_y = pyramid_base_center_y + 2.2
    eye_x_offset = 0.8 * np.cos(np.radians(pyramid_angle))
    left_eye_center = (pyramid_base_center_x - eye_x_offset, eye_y)
    right_eye_center = (pyramid_base_center_x + eye_x_offset, eye_y)
    ax.add_patch(Circle(left_eye_center, eye_radius, facecolor='white', edgecolor='black', linewidth=2))
    ax.add_patch(Circle(right_eye_center, eye_radius, facecolor='white', edgecolor='black', linewidth=2))

    # Pupils
    pupil_radius = 0.15
    ax.add_patch(Circle((left_eye_center[0] + pupil_offset_x, eye_y + pupil_offset_y), pupil_radius, facecolor='black'))
    ax.add_patch(Circle((right_eye_center[0] + pupil_offset_x, eye_y + pupil_offset_y), pupil_radius, facecolor='black'))

    # Nose
    nose_tip = np.array([pyramid_base_center_x, pyramid_base_center_y + 1.8])
    nose = Polygon([nose_tip, [nose_tip[0] - 0.3, nose_tip[1] - 0.8], [nose_tip[0] + 0.3, nose_tip[1] - 0.8]],
                   closed=True, facecolor='orange', edgecolor='black', linewidth=2)
    ax.add_patch(nose)

    # Mouth
    mouth_center = (pyramid_base_center_x, pyramid_base_center_y + 0.5)
    ax.add_patch(Ellipse(mouth_center, width=mouth_width, height=mouth_height, facecolor='red', edgecolor='black', linewidth=2))

    # Ears
    ear_height = pyramid_base_center_y + 2.5
    ear_length = 0.8
    left_ear = Polygon([[P1[0] + 0.2, ear_height], [P1[0] + 0.2, ear_height + ear_length], [P1[0] + 0.2 - ear_length, ear_height]],
                        closed=True, facecolor='khaki', edgecolor='black', linewidth=2)
    right_ear = Polygon([[P2[0] - 0.2, ear_height], [P2[0] - 0.2, ear_height + ear_length], [P2[0] - 0.2 + ear_length, ear_height]],
                         closed=True, facecolor='khaki', edgecolor='black', linewidth=2)
    ax.add_patch(left_ear)
    ax.add_patch(right_ear)


    # --- 2. Helper Function to Draw a Hand ---
    def draw_hand(ax, hand_type, wrist_angle_deg, wrist_base_width, base_cx, base_cy):
        theta = np.radians(wrist_angle_deg)
        cos_t, sin_t = np.cos(theta), np.sin(theta)

        def rotate_point(x, y, cx, cy):
            x_shifted, y_shifted = x - cx, y - cy
            xr = cos_t * x_shifted - sin_t * y_shifted + cx
            yr = sin_t * x_shifted + cos_t * y_shifted + cy
            return xr, yr

        wrist_height = 1.0
        wrist_top_width = 1.6
        wrist_pts = np.array([
            [base_cx - wrist_top_width / 2, base_cy + wrist_height], [base_cx + wrist_top_width / 2, base_cy + wrist_height],
            [base_cx + wrist_base_width / 2, base_cy], [base_cx - wrist_base_width / 2, base_cy]
        ])
        wrist_pts_rot = np.array([rotate_point(x, y, base_cx, base_cy) for x, y in wrist_pts])
        ax.add_patch(Polygon(wrist_pts_rot, closed=True, facecolor='tan', edgecolor='black', linewidth=2))

        palm_center = rotate_point(base_cx, base_cy + wrist_height + 0.8, base_cx, base_cy)
        ax.add_patch(Ellipse(palm_center, 3, 3, angle=wrist_angle_deg, facecolor='tan', edgecolor='black', linewidth=2))

        finger_centers = [
            rotate_point(base_cx - 1.0, base_cy + wrist_height + 2.8, base_cx, base_cy),
            rotate_point(base_cx, base_cy + wrist_height + 3.1, base_cx, base_cy),
            rotate_point(base_cx + 1.0, base_cy + wrist_height + 2.8, base_cx, base_cy)
        ]
        for fc in finger_centers:
            ax.add_patch(Ellipse(fc, 0.7, 2, angle=wrist_angle_deg, facecolor='tan', edgecolor='black', linewidth=2))

        thumb_offset_x = 2.0 if hand_type == 'right' else -2.0
        thumb_angle = wrist_angle_deg + (-80 if hand_type == 'right' else 80)
        thumb_center = rotate_point(base_cx + thumb_offset_x, base_cy + wrist_height + 1.5, base_cx, base_cy)
        ax.add_patch(Ellipse(thumb_center, 0.7, 1.8, angle=thumb_angle, facecolor='tan', edgecolor='black', linewidth=2))

        return palm_center # Return palm center for pointer placement

    # --- 3. Draw Hands ---
    palm_centers = {}
    if left_hand_visible:
        cx_left = pyramid_base_center_x + left_hand_offset_x
        cy_left = pyramid_base_center_y + left_hand_offset_y
        palm_centers['left'] = draw_hand(ax, 'left', left_hand_wrist_angle, left_hand_wrist_base_width, cx_left, cy_left)

    if right_hand_visible:
        cx_right = pyramid_base_center_x + right_hand_offset_x
        cy_right = pyramid_base_center_y + right_hand_offset_y
        palm_centers['right'] = draw_hand(ax, 'right', right_hand_wrist_angle, right_hand_wrist_base_width, cx_right, cy_right)


    # --- 4. Draw the Pointer ---
    if pointer_hand and pointer_hand in palm_centers:
        hand_center = palm_centers[pointer_hand]
        pointer_angle_rad = np.radians(pointer_angle_degrees)

        # Start pointer from the center of the palm
        start_x, start_y = hand_center

        # Calculate the end point of the pointer
        end_x = start_x + pointer_length * np.cos(pointer_angle_rad)
        end_y = start_y + pointer_length * np.sin(pointer_angle_rad)

        # Draw pointer as a thick line (using a narrow polygon)
        pointer_width = 0.1
        dx = pointer_width * np.cos(pointer_angle_rad + np.pi/2)
        dy = pointer_width * np.sin(pointer_angle_rad + np.pi/2)

        pointer_pts = [
            (start_x - dx, start_y - dy),
            (start_x + dx, start_y + dy),
            (end_x + dx, end_y + dy),
            (end_x - dx, end_y - dy)
        ]
        ax.add_patch(Polygon(pointer_pts, closed=True, facecolor='saddlebrown', edgecolor='black', linewidth=1.5))

    # --- 5. Final Display Settings ---
    ax.set_xlim(0, 7)
    ax.set_ylim(0, 7)
    ax.set_aspect('equal')
    ax.axis('off')
    plt.show()


# --- Example Usage ---
# Call the function with custom parameters to create a specific pose.
# Here, the pyramid is looking up and to the right, and the right hand
# is raised and holding a pointer.
draw_professor_pyramid(
    pyramid_base_center_x=3.5,
    pupil_offset_x=0.1,
    pupil_offset_y=0.1,
    mouth_width=1.2,
    mouth_height=0.3,
    right_hand_wrist_angle=-45,
    right_hand_offset_y=0.2,
    left_hand_wrist_angle=10,
    pointer_hand='right',
    pointer_length=3.5,
    pointer_angle_degrees=110
)
