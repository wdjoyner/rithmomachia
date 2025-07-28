"""
helper functions to draw Professor Pyramid, a character designed to teach rithmomachia

all code suggested by gemini following lots of very detailed prompts from me.


copyright william david joyner, wdjoyner@gmail.com
last modified 2025-07-28
"""

import matplotlib.pyplot as plt
import matplotlib.patches as patches
from matplotlib.patches import Rectangle, Circle, Polygon, Ellipse, FancyBboxPatch, RegularPolygon

import io
import numpy as np
import math
import textwrap
import os # Ensure os is imported
#import imageio
import imageio.v2 as imageio # Use v2 for consistency

# Import the actual Rithmomachia classes from rithmo.py
import rithmo # Your game logic module
from rithmo import Board, Piece, Circle as PieceCircle, Triangle as PieceTriangle, Square as PieceSquare, Pyramid as PiecePyramid # Import necessary classes

FPS = 20

# --- Helper functions for drawing ---

def combine_frames_to_video(frames, output_path, audio_path=None): # <--- ADD audio_path=None
    """
    Combines a list of image frames into a video file, optionally adding an audio track.
    """
    valid_frames = [f for f in frames if f is not None and hasattr(f, 'shape') and len(f.shape) >= 2]

    if not valid_frames:
        raise ValueError("No valid frames to write to video.")

    print(f"DEBUG_VIDEO: Combining frames to video-only clip: {output_path}") # Adjusted debug print
    imageio.mimsave(output_path, valid_frames, fps=FPS) # <--- REMOVED audio_filepath=audio_path
    # This will now create a video-only MP4 clip.

import os
import subprocess

def concatenate_mp4_clips(temp_frames_dir, output_filename="concatenated_output.mp4"):
    """
    Concatenates MP4 clips from a directory alphabetically using FFmpeg.

    Args:
        temp_frames_dir (str): The path to the directory containing MP4 clips.
        output_filename (str): The desired name for the concatenated output file.
                               Defaults to "concatenated_output.mp4".
    """
    if not os.path.isdir(temp_frames_dir):
        print(f"Error: Directory '{temp_frames_dir}' not found.")
        return

    mp4_files = []
    for filename in os.listdir(temp_frames_dir):
        if filename.lower().endswith(".mp4"):
            mp4_files.append(os.path.join(temp_frames_dir, filename))

    if not mp4_files:
        print(f"No MP4 files found in '{temp_frames_dir}'.")
        return

    mp4_files.sort()  # Sort the files alphabetically

    print("Creating a text file with the list of MP4 files now ...\n")
    list_file_path = os.path.join(temp_frames_dir, "filelist-of-rithmo-mp4s.txt")
    with open(list_file_path, "w") as f:
        for mp4_file in mp4_files:
            # FFmpeg requires paths with single quotes if they contain spaces
            # and prefers forward slashes on all OSs for list files.
            f.write(f"file '{mp4_file.replace(os.sep, '/')}'\n")

    print(f"Created file list at: {list_file_path}")

    # FFmpeg command to concatenate videos
    # The -f concat demuxer reads the list file.
    # -safe 0 is used to allow potentially unsafe filenames (e.g., those with special characters).
    # -c copy avoids re-encoding, which is much faster.
    ffmpeg_command = [
        "ffmpeg",
        "-f", "concat",
        "-safe", "0",
        "-i", list_file_path,  # Input is the list file

        # --- Video Re-encoding (Robust Settings) ---
        '-c:v', 'libx264',      # Use H.264 video codec
        '-preset', 'medium',    # Encoding speed vs. compression efficiency. 'medium' is a good balance.
        '-crf', '23',           # Constant Rate Factor for quality. Lower values mean better quality, larger files. 18-24 is common.
        '-pix_fmt', 'yuv420p',  # Standard pixel format (important for broad compatibility)

        # --- Audio Re-encoding (Robust Settings) ---
        '-c:a', 'aac',          # Use AAC audio codec (standard for MP4)
        '-b:a', '192k',         # Audio bitrate (e.g., 192 kbps for good quality)
        '-ar', '44100',         # Audio sample rate (standard 44.1 kHz)
        '-ac', '2',             # Audio channels (2 for stereo)
        # Optional: Add any audio filters like volume adjustment here if you want it applied to the final output
        # E.g., '-af', 'volume=0.8', # Adjust volume of final output

        output_filename         # Final output file
    ]

    print(f"Executing FFmpeg command: {' '.join(ffmpeg_command)}")

    try:
        subprocess.run(ffmpeg_command, check=True)
        print(f"Successfully concatenated clips to '{output_filename}'")
    except subprocess.CalledProcessError as e:
        print(f"Error during FFmpeg execution: {e}")
    except FileNotFoundError:
        print("Error: FFmpeg not found. Please ensure FFmpeg is installed and added to your system's PATH.")
    #### uncomment for cleanup
    #finally:
    #    # Clean up the generated file list
    #    if os.path.exists(list_file_path):
    #        os.remove(list_file_path)
    #        print(f"Removed temporary file list: {list_file_path}")

if __name__ == "__main__":
    # Example usage:
    # Replace 'path/to/your/TEMP_FRAMES_DIR' with the actual path to your directory
    # For testing, you might want to create a dummy directory and some dummy mp4 files.
    # e.g., os.makedirs("my_temp_clips", exist_ok=True)
    # Then create some empty files:
    # with open("my_temp_clips/clip_a.mp4", "w") as f: pass
    # with open("my_temp_clips/clip_b.mp4", "w") as f: pass
    # with open("my_temp_clips/clip_c.mp4", "w") as f: pass

    # Example: Using a directory named 'my_temp_clips' in the same directory as the script
    TEMP_FRAMES_DIR = "my_temp_clips"
    OUTPUT_FILE = "final_concatenated_video.mp4"

    # Create a dummy directory and files for demonstration if they don't exist
    if not os.path.exists(TEMP_FRAMES_DIR):
        os.makedirs(TEMP_FRAMES_DIR)
        print(f"Created dummy directory: {TEMP_FRAMES_DIR}")
        dummy_files = ["a_clip.mp4", "c_clip.mp4", "b_clip.mp4"]
        for df in dummy_files:
            with open(os.path.join(TEMP_FRAMES_DIR, df), "w") as f:
                f.write("dummy content") # FFmpeg will complain about non-video content, but serves to test the file listing.
            print(f"Created dummy file: {os.path.join(TEMP_FRAMES_DIR, df)}")

    concatenate_mp4_clips(TEMP_FRAMES_DIR, OUTPUT_FILE)

    
def print_simple_board(board_object):
    print("\n🧮 Board Matrix (values only):")
    for row in board_object.matrix:
        print(" ".join(f"{getattr(p, 'value', '.'):>3}" if p else "  ."
                       for p in row))
    print()
    


def print_board_piece_positions(board_object):
    print(f"DEBUG_PRINT_BOARD_ID: Board object ID (in print_board_piece_positions): {id(board_object)}")
    print(f"DEBUG_PRINT_BOARD_ID: Matrix ID (in print_board_piece_positions): {id(board_object.matrix)}")
    
    print("\n📋 Current Piece Positions on the Board:")
    for row_idx, row in enumerate(board_object.matrix):
        row_str_parts = [] # <--- ADD THIS LINE BACK (Initialize for each row)
        for col_idx, piece in enumerate(row):
            if piece is not None:
                piece_type = type(piece).__name__
                value = getattr(piece, "value", "?")
                color = getattr(piece, "color", "?")
                # This formatting is also causing long lines, let's simplify for readability in the console
                row_str_parts.append(f"({row_idx},{col_idx}):{piece_type[0]}{value} {color[0]}") # e.g. (6,2):T72 w
            else:
                row_str_parts.append(f"({row_idx},{col_idx}):Empty")
        print(" | ".join(row_str_parts)) # This prints the representation for one row
    print() # Newline after the board print

    

def display_board_matplotlib_enhanced(ax, board_matrix, cell_width=1.0, cell_height=1.0, font_size=12, circles=None, set_ax_limits=True):
    """
    Draw the current state of the Rithmomachia board using matplotlib.
    Assumes board_matrix is indexed (row_from_bottom, col_from_left),
    where row 0 is the bottom row (Algebraic row 1).
    """
    num_rows = 8 # Number of rows (corresponds to algebraic rows 1-8)
    num_cols = 16 # Number of columns (corresponds to algebraic a-p)

    if set_ax_limits:
        ax.set_xlim(0, num_cols * cell_width)
        ax.set_ylim(0, num_rows * cell_height) # Y-axis from 0 (bottom) to max_height (top)
        ax.set_aspect('equal')
        ax.axis('off')

        # >>> ADD THIS LINE TO FLIP THE Y-AXIS (so Algebraic Row 1 is at the bottom of the plot) <<<
        ax.invert_yaxis() # This flips the y-axis, making higher data values appear lower on the plot.

    # === Draw board background ===
    # r_bottom_up iterates from 0 (bottom row) to 7 (top row)
    for r_bottom_up in range(num_rows):
        for c in range(num_cols):
            x = c * cell_width
            y = r_bottom_up * cell_height # Y position directly maps to row_from_bottom
            base_color = '#f0f0f0' if (r_bottom_up + c) % 2 == 0 else '#dcdcdc'
            ax.add_patch(Rectangle((x, y), cell_width, cell_height,
                                   facecolor=base_color, edgecolor='black', linewidth=0.5))

            if (r_bottom_up + c) % 2 == 0:
                triangle = [(x, y), (x + cell_width, y), (x, y + cell_height)]
                ax.add_patch(Polygon(triangle, facecolor='#e8e8e8', edgecolor='gray', linewidth=0.2))

    # === Highlight circles, if any ===
    if circles:
        for c_data in circles:
            r_circle_bottom_up, c_circle = c_data["pos"][0], c_data["pos"][1]
            cx = c_circle * cell_width + cell_width / 2
            cy = r_circle_bottom_up * cell_height + cell_height / 2 
            ax.add_patch(Circle((cx, cy), 0.3 * cell_width, color='lime', alpha=c_data.get("alpha", 0.2)))

    # === Draw pieces ===
    # Pieces are read from board_matrix which is (row_from_bottom, col_from_left)
    for r_bottom_up in range(num_rows):
        for c in range(num_cols):
            piece = board_matrix[r_bottom_up][c] 
            if piece:
                center_x = c * cell_width + cell_width / 2
                center_y = r_bottom_up * cell_height + cell_height / 2 # Y position directly maps to row_from_bottom
                # --- REMOVE THIS LINE IF IT'S STILL PRESENT: ---
                # center_y = 7 - center_y # THIS WAS AN INCORRECT MANUAL FLIP. REMOVE IT.
                
                shape = getattr(piece, 'shape', 'circle').lower()
                color = 'lightgray' if piece.color == 'white' else 'dimgray'
                edgecolor = 'black'
                label_color = 'green' if piece.color == 'white' else 'red'

                size = 0.8 * min(cell_width, cell_height)

                # ... (rest of shape drawing logic for circle, square, triangle, pyramid) ...
                if shape == 'circle':
                    ax.add_patch(Circle((center_x, center_y), size / 2, facecolor=color, edgecolor=edgecolor, linewidth=1))
                elif shape == 'square':
                    ax.add_patch(Rectangle((center_x - size / 2, center_y - size / 2), size, size, facecolor=color, edgecolor=edgecolor, linewidth=1))
                elif shape == 'triangle':
                    ax.add_patch(RegularPolygon((center_x, center_y), numVertices=3, radius=0.8 * size / 2, orientation=np.pi, facecolor=color, edgecolor=edgecolor, linewidth=1))
                elif shape == 'pyramid':
                    ax.add_patch(RegularPolygon((center_x, center_y), numVertices=4, radius=0.8 * size / 2, orientation=0, facecolor='goldenrod', edgecolor='black', linewidth=1))
                else:
                    # The debug print you mentioned for "unknown piece shape" when it defaults to circle
                    print(f"DEBUG: Unknown piece shape '{shape}' at ({r_bottom_up}, {c}). Drawing default gray circle.")
                    ax.add_patch(Circle((center_x, center_y), size / 2, facecolor='gray', edgecolor='black'))

                # Draw value label
                ax.text(center_x, center_y, str(piece.value),
                        fontsize=font_size, ha='center', va='center',
                        color=label_color, weight='bold')



#def draw_scene_and_save(
# In rithmomachia_scene_animation_helper.py
def draw_scene_and_get_image_data(
    # 'filename' parameter is REMOVED as it's no longer used for saving to disk.
    output_folder=None, # This parameter is effectively unused now, but can be kept for compatibility
    scene_type='combined',
    board_state=None,
    professor_pose=None,
    speech_text="",
    current_word_idx=None,
    word_timestamps=None,
    total_duration=0,
    current_time=0,
    **kwargs # For additional params like circles, highlights etc.
):
    """
    Draws a single frame of the animation into an in-memory buffer and returns its image data (numpy array).

    Parameters:
        output_folder (str, optional): Not directly used for saving files anymore, but kept for compatibility.
        scene_type (str): Type of scene to draw ('combined', 'board_only', 'professor_only').
        board_state (rithmo.Board): Current state of the Rithmomachia board.
        professor_pose (dict): Dictionary defining professor's pose (mouth, eyes, pointer).
        speech_text (str): Text for the professor's speech bubble.
        current_word_idx (int, optional): Index of the current word being spoken for highlighting.
        word_timestamps (list): List of word objects/dicts with start/end times for lip-sync.
        total_duration (float): Total duration of the current speech segment.
        current_time (float): Current time within the speech segment.
        **kwargs: Arbitrary keyword arguments (e.g., 'circles' for board highlights, specific cell_width/height).

    Returns:
        numpy.ndarray: The image data for the generated frame.
    """
    # Create the figure with a 16:9 aspect ratio, yielding 1920x1080 pixels at dpi=100
    fig = plt.figure(figsize=(12.80, 7.20)) 

    if scene_type == 'combined':
        # Use GridSpec to define two subplots: professor on top, board on bottom
        gs = fig.add_gridspec(2, 1, height_ratios=[0.6, 0.4]) # Professor takes 60%, Board 40% of vertical space

        ax_professor = fig.add_subplot(gs[0, 0]) # Top subplot for the professor
        ax_board = fig.add_subplot(gs[1, 0])     # Bottom subplot for the board

        # Set specific limits for the professor's subplot (as expected by display_professor_and_bubble)
        ax_professor.set_xlim(0, 10)
        ax_professor.set_ylim(0, 10)
        ax_professor.axis('off') # Hide axes for a clean look

        # Draw the professor and speech bubble
        if professor_pose:
            # Get bubble dimensions, with defaults that allow for more text space
            bubble_width = kwargs.get('professor_bubble_width', 8.5 * 0.8) 
            bubble_height = kwargs.get('professor_bubble_height', 3.5 * 1.2) 

            display_professor_and_bubble(ax_professor, professor_pose, speech_text,
                                         current_word_idx, word_timestamps,
                                         total_duration, current_time,
                                         bubble_width, bubble_height)

        # Draw the Rithmomachia board in its subplot
        if board_state:
            # Get board cell dimensions, with defaults for combined view
            board_cell_width = kwargs.get('board_cell_width_combined', 0.9)
            board_cell_height = kwargs.get('board_cell_height_combined', 0.9)
            board_font_size = kwargs.get('board_font_size_combined', 10)

            # Pass `set_ax_limits=True` so `display_board_matplotlib_enhanced` sets its own limits
            # appropriate for its subplot area and turns off its axis.
            display_board_matplotlib_enhanced(ax_board, board_state.matrix,
                                              cell_width=board_cell_width,
                                              cell_height=board_cell_height,
                                              font_size=board_font_size,
                                              circles=kwargs.get('circles', []),
                                              set_ax_limits=True) # Ensure it sets its own limits


    elif scene_type == 'board_only':
        # For a full-screen board view (no professor)
        ax_board = fig.add_subplot(1, 1, 1) # Board takes up the entire figure
        
        # Get board cell dimensions, with defaults for full-screen view
        cell_width = kwargs.get('cell_width', 1.0)
        cell_height = kwargs.get('cell_height', 1.0)
        font_size = kwargs.get('font_size', 12)
        circles = kwargs.get('circles', [])

        if board_state:
            # Optional: piece validation print (can be removed once debugged)
            for r, row in enumerate(board_state.matrix):
                for c, piece in enumerate(row):
                    if piece and not hasattr(piece, 'shape'):
                        print(f"⚠️ Invalid piece at ({r}, {c}): {piece} — missing 'shape'")

            # Pass `set_ax_limits=True` for full-screen board to manage its own limits
            display_board_matplotlib_enhanced(ax_board, board_state.matrix,
                                              cell_width=cell_width,
                                              cell_height=cell_height,
                                              font_size=font_size,
                                              circles=circles,
                                              set_ax_limits=True)
        else:
            ax_board.text(0.5, 0.5, "No board state provided for 'board_only' scene.", ha='center', va='center', transform=ax_board.transAxes)

    elif scene_type == 'professor_only':
        # For a full-screen professor view (no board)
        ax_professor = fig.add_subplot(1, 1, 1)
        ax_professor.set_xlim(0, 10) # Set limits for professor's full screen view
        ax_professor.set_ylim(0, 10)
        ax_professor.axis('off')

        # Get bubble dimensions for full-screen professor
        bubble_width = kwargs.get('professor_bubble_width', 8.5 * 0.8) # May need different scaling for full screen
        bubble_height = kwargs.get('professor_bubble_height', 3.5 * 1.2) 
        display_professor_and_bubble(ax_professor, professor_pose, speech_text,
                                     current_word_idx, word_timestamps,
                                     total_duration, current_time,
                                     bubble_width, bubble_height)

    else:
        # Fallback for unknown scene types
        ax = fig.add_subplot(1, 1, 1)
        ax.text(0.5, 0.5, "Unknown scene type.", ha='center', va='center', transform=ax.transAxes)

    plt.tight_layout() # Adjust subplot parameters for a tight layout

    # Save the figure to an in-memory buffer (BytesIO) instead of a file
    # Ensure 'import io' is at the top of rithmomachia_scene_animation_helper.py
    buf = io.BytesIO()
    plt.savefig(buf, format='png', dpi=100) # Save to the buffer, not a filename
    buf.seek(0) # Rewind the buffer to the beginning

    # Read the image data from the buffer using imageio
    # Ensure 'import imageio.v2 as imageio' is at the top of rithmomachia_scene_animation_helper.py
    image_data = imageio.imread(buf)

    plt.close(fig) # Always close the figure to release memory
    return image_data # Return the numpy array directly


def display_professor_and_bubble(ax, professor_pose, speech_text, current_word_idx, word_timestamps, total_duration, current_time, bubble_width, bubble_height):
    """
    Draws the geometric-style Professor Pyramid with downward-pointing fingers, red elliptical mouth,
    and a scaled-down speech bubble.
    """
    # Removed ax.set_xlim, ax.set_ylim, ax.axis('off') here
    # These should be managed by the calling function (draw_scene_and_save) when using subplots.

    ax.set_facecolor('lightgray')

    # === Pyramid Body ===
    top_vertex = (2.5, 8.5)
    base_left = (1.0, 5.0)
    base_right = (4.0, 5.0)
    base_center = (2.5, 4.0) # Lowered for 3D effect

    ax.add_patch(patches.Polygon([top_vertex, base_left, base_center], facecolor='saddlebrown', edgecolor='black'))
    ax.add_patch(patches.Polygon([top_vertex, base_center, base_right], facecolor='peru', edgecolor='black'))

    # === Eyes ===
    eye_offset_x = 0.0
    eye_offset_y = 5.7
    angle = professor_pose.get('eye_target_angle_degrees', 270)
    if 225 <= angle < 315:
        eye_offset_x = 0.05
    elif 135 <= angle < 225:
        eye_offset_x = -0.05

    ax.add_patch(patches.Circle((2.25 + eye_offset_x, eye_offset_y), 0.1, facecolor='white', edgecolor='black'))
    ax.add_patch(patches.Circle((2.75 + eye_offset_x, eye_offset_y), 0.1, facecolor='white', edgecolor='black'))
    ax.add_patch(patches.Circle((2.25 + eye_offset_x, eye_offset_y), 0.05, facecolor='black'))
    ax.add_patch(patches.Circle((2.75 + eye_offset_x, eye_offset_y), 0.05, facecolor='black'))

    # === Left Hand ===
    left_wrist_x, left_wrist_y = base_left
    ax.add_patch(patches.Ellipse((left_wrist_x, left_wrist_y), width=0.5, height=0.25, facecolor='saddlebrown', edgecolor='black'))

    for i in range(3):
        offset_x = -0.2 + i * 0.2
        ax.add_patch(patches.Ellipse(
            (left_wrist_x + offset_x, left_wrist_y - 0.25),
            width=0.15, height=0.35,
            angle=180,
            facecolor='peru',
            edgecolor='black'
        ))

    ax.add_patch(patches.Ellipse(
        (left_wrist_x - 0.25, left_wrist_y - 0.1),
        width=0.15, height=0.35,
        angle=135,
        facecolor='peru',
        edgecolor='black'
    ))

    # === Right Hand + Pointer ===
    right_wrist_x, right_wrist_y = base_right
    ax.add_patch(patches.Ellipse((right_wrist_x, right_wrist_y), width=0.5, height=0.25, facecolor='saddlebrown', edgecolor='black'))

    for i in range(3):
        offset_x = -0.2 + i * 0.2
        ax.add_patch(patches.Ellipse(
            (right_wrist_x + offset_x, right_wrist_y - 0.25),
            width=0.15, height=0.35,
            angle=180,
            facecolor='peru',
            edgecolor='black'
        ))

    ax.add_patch(patches.Ellipse(
        (right_wrist_x + 0.25, right_wrist_y - 0.1),
        width=0.15, height=0.35,
        angle=45,
        facecolor='peru',
        edgecolor='black'
    ))

    pointer_angle_deg = professor_pose.get('pointer_angle_degrees', 225)
    angle_rad = np.deg2rad(pointer_angle_deg)
    pointer_len = 2.0
    pointer_tip_x = right_wrist_x + pointer_len * np.cos(angle_rad)
    pointer_tip_y = right_wrist_y + pointer_len * np.sin(angle_rad)

    ax.plot([right_wrist_x, pointer_tip_x], [right_wrist_y, pointer_tip_y], color='darkgray', linewidth=3)
    ax.add_patch(patches.Circle((pointer_tip_x, pointer_tip_y), 0.1, facecolor='gold', edgecolor='black'))

    # === Animated Elliptical Mouth ===
    mouth_center_x = 2.5
    mouth_center_y = 5.2
    mouth_height_scale = professor_pose.get('mouth_height', 0.1)
    height_max = 0.5
    mouth_width = professor_pose.get('mouth_width', height_max)
    mouth_height = mouth_height_scale * height_max

    ax.add_patch(patches.Ellipse(
        (mouth_center_x, mouth_center_y),
        width=mouth_width,
        height=mouth_height,
        facecolor='red',
        edgecolor='black'
    ))
    
    # === Speech Bubble ===
    bubble_width *= 0.75
    bubble_height *= 0.8
    bubble_x_center = 7.0 # Adjusted center to be more to the right
    bubble_y_center = 7.0 # Keep around here, maybe slightly lower if needed
    
    bubble_x_pos = bubble_x_center - bubble_width / 2
    bubble_y_pos = bubble_y_center - bubble_height / 2

    bubble_rect = patches.FancyBboxPatch((bubble_x_pos, bubble_y_pos),
                                         bubble_width, bubble_height,
                                         boxstyle="round,pad=0.1",
                                         facecolor='white', edgecolor='black', linewidth=1, alpha=0.9)
    ax.add_patch(bubble_rect)

    # Bubble tail (pointer to mouth)
    mouth_tip_x = mouth_center_x
    mouth_tip_y = mouth_center_y
    bubble_edge_x = bubble_x_pos
    bubble_edge_y = bubble_y_pos + bubble_height / 2
    offset_y = 0.3
    ax.add_patch(patches.Polygon([(bubble_edge_x, bubble_edge_y - offset_y),
                                   (mouth_tip_x, mouth_tip_y),
                                   (bubble_edge_x, bubble_edge_y + offset_y)],
                                   closed=True, facecolor='white', edgecolor='black', linewidth=1, alpha=0.9))

# === Speech Text (with "scrolling" logic) ===
    if speech_text:
        # Define text box limits relative to the bubble
        # Use a consistent padding inside the bubble
        text_padding_horizontal = 0.25 # Smaller padding
        text_padding_vertical = 0.25  # Smaller padding

        text_box_width = bubble_width - 2 * text_padding_horizontal
        text_box_height = bubble_height - 2 * text_padding_vertical
        
        # Recalculate textwrap width based on effective text box width
        # A good empirical value for character width per axes unit
        # (assuming fontsize 12-14 in a 10-unit wide axis for professor)
        # 4.5-5 characters per unit width is often a decent starting point.
        chars_per_unit_width = 6.5 # Adjusted: Try this. If lines are too long, decrease. Too short, increase.
        line_height_axes_units = 0.4 # Tweak this: increase if lines overlap vertically, decrease if too much space
        textwrap_width_chars = int(text_box_width * chars_per_unit_width)
        if textwrap_width_chars < 1: textwrap_width_chars = 1 # Minimum width
        
        wrapped_lines = textwrap.wrap(speech_text, width=textwrap_width_chars)
        
        max_visible_lines = int(text_box_height / line_height_axes_units)
        if max_visible_lines < 1: max_visible_lines = 1

        current_word_line_idx = 0
        if current_word_idx is not None and word_timestamps:
            if current_word_idx < len(word_timestamps):
                word_item = word_timestamps[current_word_idx]
                current_word_text = word_item.word if hasattr(word_item, 'word') else word_item['word']
                
                matched = False
                for line_idx, line in enumerate(wrapped_lines):
                    # Check if the current word (case-insensitive) is in this specific line
                    # Using 'any' with split is better for matching individual words
                    if any(w.lower() == current_word_text.lower() for w in line.split()):
                        current_word_line_idx = line_idx
                        matched = True
                        break
                # Fallback: if not found, it stays 0 or previous line, or no highlighting on that line.

        # --- Scrolling Window Logic ---
        ideal_start_line = current_word_line_idx - (max_visible_lines // 2)
        
        start_display_line_idx = max(0, ideal_start_line)
        start_display_line_idx = min(start_display_line_idx, max(0, len(wrapped_lines) - max_visible_lines))
        
        end_display_line_idx = start_display_line_idx + max_visible_lines
        end_display_line_idx = min(end_display_line_idx, len(wrapped_lines))

        # Calculate the Y position for the very first line to be drawn.
        # This is the top of the text box within the bubble, minus half a line height (for va='center').
        # The bubble_y_pos is the BOTTOM of the bubble.
        # So, the top edge of the text box is bubble_y_pos + bubble_height - text_padding_vertical.
        # We want the *center* of the first line to be at `text_y_start`.
        text_x = bubble_x_pos + bubble_width / 2 # Horizontal center of text in bubble
        text_y_start        = (bubble_y_pos + bubble_height) - text_padding_vertical - (line_height_axes_units / 2)
        first_line_y_center = (bubble_y_pos + bubble_height) - text_padding_vertical - (line_height_axes_units / 2)
        
        # Iterate only through the lines that should be displayed
        for i, line in enumerate(wrapped_lines[start_display_line_idx : end_display_line_idx]):
            current_line_y = first_line_y_center - (i * line_height_axes_units)

            color = 'black'
            if current_word_idx is not None and word_timestamps:
                if current_word_idx < len(word_timestamps):
                    word_item = word_timestamps[current_word_idx]
                    current_word_text = word_item.word if hasattr(word_item, 'word') else word_item['word']
                    
                    line_words_cleaned = [w.strip(".,!?;:").lower() for w in line.split()]
                    current_word_cleaned = current_word_text.strip(".,!?;:").lower()
                    
                    if current_word_cleaned in line_words_cleaned:
                        color = 'red'
                        
            ax.text(text_x, current_line_y, line,
                    ha='center', va='center', fontsize=12, color=color, wrap=False)

            
            
def display_custom_board(board_data, cell_width=1.0, cell_height=1.0, font_size=10):
    """
    Displays a custom board represented by a list of lists of strings
    using Matplotlib. Each string represents the content of a cell.
    This function is primarily for *previewing* raw string board data,
    not for the animated game board which uses rithmo.Board objects.

    Args:
        board_data (list of list of str): The board data, where each inner list
                                          is a row of cells.
        cell_width (float): The width of each cell in the plot.
        cell_height (float): The height of each cell in the plot.
        font_size (int): The font size for the text within each cell.
    """
    if not board_data:
        print("Board data is empty. Nothing to display.")
        return

    num_rows = len(board_data)
    num_cols = max(len(row) for row in board_data) if num_rows > 0 else 0

    if num_cols == 0:
        print("Board data has no columns. Nothing to display.")
        return

    fig, ax = plt.subplots(figsize=(num_cols * cell_width, num_rows * cell_height))
    ax.set_xlim(0, num_cols * cell_width)
    ax.set_ylim(0, num_rows * cell_height)
    ax.set_aspect('equal', adjustable='box') # Ensures cells are square if width/height are equal

    # Hide axes ticks and labels for a cleaner board look
    ax.set_xticks([])
    ax.set_yticks([])
    ax.set_xticklabels([])
    ax.set_yticklabels([])

    # Invert y-axis so (0,0) is top-left, similar to typical matrix indexing
    ax.invert_yaxis()

    for r_idx, row in enumerate(board_data):
        for c_idx, cell_content in enumerate(row):
            rect = patches.Rectangle(
                (c_idx * cell_width, r_idx * cell_height),
                cell_width,
                cell_height,
                linewidth=1,
                edgecolor='black',
                facecolor='lightgray' if cell_content else 'white'
            )
            ax.add_patch(rect)

            if cell_content:
                text_x = c_idx * cell_width + cell_width / 2
                text_y = r_idx * cell_height + cell_height / 2
                ax.text(
                    text_x,
                    text_y,
                    cell_content,
                    ha='center', va='center',
                    fontsize=font_size,
                    color='black'
                )

    plt.title("Custom Game Board Preview")
    plt.show()

# --- Utility to get an initial rithmo.Board object ---

def get_initial_board_state_from_data(board_data_list_of_objects): # Renamed parameter for clarity
    """
    Creates a rithmo.Board object and populates its matrix.
    
    Assumes `board_data_list_of_objects` is a list of lists containing
    `rithmo.Piece` instances or `None`.
    It's ordered from ALGEBRAIC ROW 8 (TOP, index 0) down to ALGEBRAIC ROW 1 (BOTTOM, index 7).
    
    It populates `board.matrix` such that `board.matrix[0]` corresponds to Algebraic Row 1 (bottom),
    and `board.matrix[7]` corresponds to Algebraic Row 8 (top).
    This makes `board.matrix` consistent with `notation_to_pos`'s `(row_from_bottom, col_from_left)` output.

    EXAMPLES:
        # Assume rithmo.py's Piece subclasses (Square, Triangle) are available.
        # Example miniature top-down board data (Algebraic Row 2 to Row 1)
        # T006 is White Triangle 6
        # t090 is Black Triangle 90
        # S025 is White Square 25
        # S015 is White Square 15
        #_test_board_data = [
            # Alg Row 2 (Index 0 in this test data)
        #    [Square(81, 'white'), Square(45, 'white'), Triangle(6, 'white'), None],
            # Alg Row 1 (Index 1 in this test data)
        #    [Square(25, 'white'), Square(15, 'white'), None, Triangle(100, 'black')]
        #]

        >>> _test_board_data = [[rithmo.Square(81, 'white'), rithmo.Square(45, 'white'), rithmo.Triangle(6, 'white'), None], [rithmo.Square(25, 'white'), rithmo.Square(15, 'white'), None, rithmo.Triangle(100, 'black')]]
        # Call the function to get the populated Board object
        >>> test_board_instance = rithmo_help.get_initial_board_state_from_data(_test_board_data)

        # Check a piece that was in Alg Row 2 (index 0 of _test_board_data), like T006 at (0,2) in _test_board_data
        # It should be placed in matrix index (1,2) in the bottom-up board.
        >>> test_board_instance.matrix[1][2] # (row=1 from bottom, col=2 from left)
        T006

        # Check a piece that was in Alg Row 1 (index 1 of _test_board_data), like S025 at (1,0) in _test_board_data
        # It should be placed in matrix index (0,0) in the bottom-up board.
        >>> test_board_instance.matrix[0][0] # (row=0 from bottom, col=0 from left)
        S025
        >>> test_board_instance.matrix 
        [[S025, S015, None, t100], [S081, S045, T006, None]]

    """
    board = Board() 
    
    num_rows_alg_def = len(board_data_list_of_objects) # Will be 8 for your board
    num_cols = len(board_data_list_of_objects[0]) if num_rows_alg_def > 0 else 0

    # Initialize the board matrix to hold rows indexed from bottom (0) to top (7).
    board.matrix = [[None for _ in range(num_cols)] for _ in range(num_rows_alg_def)]

    # Iterate through the `board_data_list_of_objects` which is top-down (Alg Row 8 at index 0, Alg Row 1 at index 7).
    # `r_current_list_idx` goes from 0 to 7.
    for r_current_list_idx, row_data in enumerate(board_data_list_of_objects):
        # Calculate the corresponding `r_matrix` index for board.matrix (bottom-up).
        r_matrix = (num_rows_alg_def - 1) - r_current_list_idx 

        for c_matrix, piece_obj in enumerate(row_data):
            if piece_obj is not None: # Check if it's a Piece object (not None)
                # Directly assign the Piece object. No parsing needed here.
                board.matrix[r_matrix][c_matrix] = piece_obj 
                # Debug print to confirm placement with correct indices for board.matrix
                print(f"DEBUG_LOAD: Placed {piece_obj} (Value: {getattr(piece_obj, 'value', 'N/A')}, Color: {getattr(piece_obj, 'color', 'N/A')}, Shape: {getattr(piece_obj, 'shape', 'N/A')}) from screenplay list index {r_current_list_idx} (Alg Row {num_rows_alg_def - r_current_list_idx}) into board.matrix index ({r_matrix}, {c_matrix})")
            else: # If it's None (empty square)
                board.matrix[r_matrix][c_matrix] = None # Ensure empty cells are explicitly None
                print(f"DEBUG_LOAD: Placed None at matrix index ({r_matrix}, {c_matrix}) from screenplay list index {r_current_list_idx}.")

    return board

# --- End of Helper module ---

# --- Main Execution Block (Replace your existing main block with this) ---

if __name__ == "__main__":
    print("Animation helper module.")



####################### the end ###############################################


"""### uncomment to use
CUSTOM_STARTING_BOARD = [
    ['S289', 'S153', 'T81', '', '', '', '', '', '', '', '', '', '', 't16', 's28', 's49'],
    ['S169', 'P91', 'T72', '', '', '', '', '', '', '', '', 't12', '', '', 's66', 's121'],
    ['', 'T49', 'C64', 'C8', '', '', '', '', '', '', '', '', 'c3', 'c9', 't36', ''],
    ['', 'T42', 'C36', 'C6', '', '', '', '', '', '', '', '', 'c5', 'c25', 't30', ''],
    ['', 'T20', 'C16', 'C4', '', '', '', '', '', '', '', '', 'c7', 'c49', 't56', ''],
    ['', 'T25', 'C4', 'C2', '', '', '', '', '', '', 'T9', '', 'c9', 'c81', 't64', ''],
    ['S81', 'S45', 'T6', '', '', '', '', '', '', '', '', '', '', 't90', 's120', 's225'],
    ['S25', 'S15', '', '', '', '', '', '', '', '', '', '', '', 't100', 'p190', 's361']
]
display_custom_board(CUSTOM_STARTING_BOARD)
"""

