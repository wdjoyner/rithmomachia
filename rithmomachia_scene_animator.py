"""
draws Professor Pyramid, a character designed to teach rithmomachia

all code suggested by gemini following lots of very detailed prompts from me.

2025-07-28:
   Changed  openai -> gtts for Prof Pyramid's computer voice 

copyright william david joyner, wdjoyner@gmail.com
last modified 2025-07-28
"""

import os
import json
from pathlib import Path
import subprocess
import shutil
import math
import numpy as np
import copy
import sys

import matplotlib.pyplot as plt
import matplotlib.patches as patches
from matplotlib.patches import Rectangle, Circle, Polygon, Ellipse, FancyBboxPatch

import imageio.v2 as imageio
import traceback
import inspect

from gtts import gTTS ########## for computer voices


# Import your game logic module
import rithmo # Your game logic from rithmomachia4_AI-2025-06-14.txt
from rithmo import RithmomachiaGame, Board # Import RithmomachiaGame and Board class

# Import the new helper module with a distinct alias
import rithmomachia_scene_animation_helper as rithmo_help 

import screenplay # Assuming this module defines animation_scenes and CUSTOM_STARTING_BOARD



# --- Configuration ---

AVERAGE_WORDS_PER_SECOND = 1.0

FPS = 20 # Frames per second for the output video

# Directories
BASE_DIR = os.path.dirname(os.path.abspath(__file__)) # Get the directory where the script itself is located

TEMP_FRAMES_DIR = os.path.join(BASE_DIR, "temp_animation_frames")
OUTPUT_VIDEO_DIR = os.path.join(BASE_DIR, "output_videos")
AUDIO_DIR = os.path.join(BASE_DIR, "generated_audio")

# Ensure directories exist
os.makedirs(TEMP_FRAMES_DIR, exist_ok=True)
os.makedirs(OUTPUT_VIDEO_DIR, exist_ok=True)
os.makedirs(AUDIO_DIR, exist_ok=True)

final_ffmpeg_log_path_direct = OUTPUT_VIDEO_DIR

def get_audio_duration_ffprobe(audio_filepath):
    try:
        # Use ffprobe to get the duration of the audio file
        cmd = [
            'ffprobe', '-v', 'error', '-show_entries', 'format=duration',
            '-of', 'default=noprint_wrappers=1:nokey=1', audio_filepath
        ]
        result = subprocess.run(cmd, stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True, check=True)
        duration_str = result.stdout.strip()
        return float(duration_str)
    except (subprocess.CalledProcessError, ValueError) as e:
        print(f"ERROR_FFPROBE: Could not get duration for {audio_filepath}: {e}")
        return None


# --- New Audio Helper Function ---
def generate_tts_audio_and_timestamps(text_to_speak, scene_id, word_timestamps_from_screenplay=None, duration_override=None):
    """
    Generates TTS audio using gTTS and estimates word-level timestamps for a given text segment.
    Creates a truly silent audio file using FFmpeg if no real audio is generated or if gTTS fails.

    Parameters:
        text_to_speak (str): The narration text for the professor. If empty, silent audio is generated.
        scene_id (str): A unique identifier for the scene (e.g., "scene_1", "intro_scene").
                        Used for naming output audio files.
        word_timestamps_from_screenplay (list, optional): A list of word timestamp dictionaries
                                                          (e.g., [{'word': 'Hello', 'start': 0.0, 'end': 0.5}])
                                                          provided directly from the screenplay. If provided,
                                                          gTTS is skipped, and silent audio is generated
                                                          to match the specified timestamps/duration.
                                                          Defaults to None.
        duration_override (float, optional): If provided, this duration overrides any calculated or
                                             estimated audio duration. Useful for fixed-length silent scenes.
                                             Defaults to None.

    Returns:
        tuple: (audio_path, word_timestamps, total_duration)
               - audio_path (str or None): Path to the generated audio file (e.g., .mp3 or .m4a), or None if creation failed.
               - word_timestamps (list): A list of dictionaries, where each dict has 'word', 'start', and 'end' keys.
                                         These are estimated when using gTTS.
               - total_duration (float): The total duration of the generated audio in seconds.

    Notes:
        - gTTS does not provide exact word-level timestamps. These are estimated by
          dividing the total estimated duration by the number of words.
        - FFmpeg is used to create silent audio or to convert gTTS output if necessary.
          Ensure FFmpeg is installed and accessible in your system's PATH.
        - This function is designed to be a replacement for an OpenAI-based TTS/ASR pipeline.

    Examples:
        # Example 1: Generate audio for a speaking scene with estimated timestamps
        >>> audio_path, timestamps, duration = generate_tts_audio_and_timestamps(
        ...     text_to_speak="Hello, class, and welcome to Rithmomachia.",
        ...     scene_id="intro_speech_1"
        ... )
        DEBUG_GTTS: Attempting gTTS call...
        DEBUG_GTTS: gTTS successful for generated_audio/intro_speech_1/intro_speech_1_audio.mp3.
        DEBUG_AUDIO: Generated gTTS audio. Using estimated timestamps. Duration: X.XXs
        # audio_path will be a path like 'generated_audio/intro_speech_1/intro_speech_1_audio.mp3'
        # timestamps will be a list like: [{'word': 'Hello,', 'start': 0.0, 'end': 0.25}, ...] (estimated)
        # duration will be the estimated total duration.

        # Example 2: Generate silent audio for a board action scene
        >>> audio_path, timestamps, duration = generate_tts_audio_and_timestamps(
        ...     text_to_speak="",
        ...     scene_id="board_move_1",
        ...     duration_override=3.5
        ... )
        DEBUG_AUDIO: No text provided. Creating silent audio for 3.50s.
        DEBUG_AUDIO: Created silent audio file at generated_audio/board_move_1/board_move_1_audio.m4a for silent scene.
        # audio_path will be a path like 'generated_audio/board_move_1/board_move_1_audio.m4a'
        # timestamps will be an empty list []
        # duration will be 3.5

        # Example 3: Use pre-provided timestamps (e.g., from an external ASR process)
        >>> pre_stamps = [{'word': 'Pre-timed', 'start': 0.0, 'end': 0.6}, {'word': 'speech', 'start': 0.7, 'end': 1.2}]
        >>> audio_path, timestamps, duration = generate_tts_audio_and_timestamps(
        ...     text_to_speak="This text will be ignored if word_timestamps_from_screenplay is provided.",
        ...     scene_id="pre_timed_narration",
        ...     word_timestamps_from_screenplay=pre_stamps
        ... )
        DEBUG_AUDIO: Using provided word_timestamps from screenplay for scene pre_timed_narration.
        DEBUG_AUDIO: Created dummy audio file at generated_audio/pre_timed_narration/pre_timed_narration_audio.m4a for screenplay-provided timestamps.
        # audio_path will be a path like 'generated_audio/pre_timed_narration/pre_timed_narration_audio.m4a'
        # timestamps will be pre_stamps
        # duration will be 1.2 (from the last timestamp's end)
    """
    print(f"DEBUG_AUDIO: Generating audio for scene {scene_id}: '{text_to_speak[:50]}...'")

    temp_audio_dir = os.path.join(AUDIO_DIR, scene_id)
    os.makedirs(temp_audio_dir, exist_ok=True) # Ensure specific scene audio directory exists
    # Changed extension to .mp3 for gTTS native output. FFmpeg merge should handle .mp3 fine.
    audio_path = os.path.join(temp_audio_dir, f"{scene_id}_audio.mp3")

    total_duration = 0.0
    word_timestamps = []
    
    # Flag to track if TTS (gTTS) was attempted and failed, or if no text was provided
    tts_failed_or_skipped = False

    # --- Step 1: Determine total_duration and word_timestamps ---
    # Case 1: Word timestamps are provided directly in screenplay (no TTS needed, generate silent audio)
    if word_timestamps_from_screenplay:
        print(f"DEBUG_AUDIO: Using provided word_timestamps from screenplay for scene {scene_id}.")
        word_timestamps = word_timestamps_from_screenplay
        if word_timestamps: # Check if list is not empty before accessing [-1]
            # Use 'end' attribute for TranscriptionWord objects, or 'end' key for dicts
            if hasattr(word_timestamps[-1], 'end'): 
                total_duration = word_timestamps[-1].end
            elif isinstance(word_timestamps[-1], dict) and 'end' in word_timestamps[-1]: 
                total_duration = word_timestamps[-1]['end']
            else: # Fallback if word_timestamps format is unexpected
                print(f"Warning: Provided word_timestamps format for scene {scene_id} is unexpected. Estimating duration.")
                total_duration = len(text_to_speak.split()) / AVERAGE_WORDS_PER_SECOND
                word_timestamps = [] # Clear problematic timestamps if format is bad
        else: # word_timestamps_from_screenplay was an empty list
            print(f"DEBUG_AUDIO: screenplay.word_timestamps was provided but is empty for scene {scene_id}. Estimating duration.")
            total_duration = len(text_to_speak.split()) / AVERAGE_WORDS_PER_SECOND # Estimate duration if no stamps
        
        # If duration_override is present, it takes precedence
        if duration_override is not None:
            total_duration = duration_override
        
        # Create a dummy silent audio if no real audio is produced (because screenplay provided timestamps only)
        try:
            subprocess.run([
                'ffmpeg', '-y', '-loglevel', 'quiet',
                '-f', 'lavfi',                              # Input format is lavfi (filtergraph)
                '-i', f'anullsrc=cl=mono:r=44100',          # Null audio source, mono, 44.1 kHz (no [a] mapping)
                '-c:a', 'libmp3lame',                       # Explicitly use libmp3lame for MP3 encoding
                '-b:a', '128k',                             # Audio bitrate
                '-t', str(total_duration),                  # Duration
                audio_path                                  # Output file (must be .mp3)
            ], check=True, text=True)

            print(f"DEBUG_AUDIO: Created dummy audio file at {audio_path} for screenplay-provided timestamps.")
        except subprocess.CalledProcessError as ffmpeg_e:
            print(f"ERROR_FFMPEG_AUDIO: Failed to create dummy audio for scene {scene_id}: {ffmpeg_e}")
            audio_path = None # Indicate failure
            total_duration = 0 # Mark duration as 0 if audio generation failed
        except Exception as e: # Catch any other unexpected errors during audio creation
            print(f"ERROR_AUDIO_CREATION: General error creating audio file for scene {scene_id}: {e}")
            audio_path = None
            total_duration = 0

    # Case 2: Text provided, attempt gTTS (or fallback if gTTS fails)
    elif text_to_speak: # This block handles actual text-to-speech
        try:
            print("DEBUG_GTTS: Attempting gTTS call...")
            tts = gTTS(text=text_to_speak, lang='en', slow=False) # Or slow=True as desired
            tts.save(audio_path)
            print(f"DEBUG_GTTS: gTTS successful for {audio_path}.")

            # --- Start of the corrected block ---
            words_list = text_to_speak.split()
            num_words = len(words_list) # <--- Ensure num_words is defined HERE

            # Get actual duration from ffprobe
            actual_audio_duration = get_audio_duration_ffprobe(audio_path)
            if actual_audio_duration is not None:
                total_duration = actual_audio_duration
                print(f"DEBUG_AUDIO: Actual gTTS audio duration via ffprobe: {total_duration:.2f}s")
            else:
                # Fallback to estimated if ffprobe fails
                total_duration = num_words / AVERAGE_WORDS_PER_SECOND # Use num_words here
                print(f"DEBUG_AUDIO: Failed to get actual duration, falling back to estimated: {total_duration:.2f}s")

            if num_words > 0: # Only create estimated timestamps if there are words
                segment_duration = total_duration / num_words
                current_time_stamp = 0.0
                for word_text in words_list:
                    word_timestamps.append({"word": word_text, "start": current_time_stamp, "end": current_time_stamp + segment_duration})
                    current_time_stamp += segment_duration
            print(f"DEBUG_AUDIO: Generated gTTS audio. Using estimated timestamps. Duration: {total_duration:.2f}s")

            # --- End of the corrected block ---

            # If duration_override is present, it takes precedence (after gTTS has generated audio)
            if duration_override is not None:
                total_duration = duration_override

        except Exception as e: # This exception block catches the num_words error!
            print(f"ERROR_GTTS: Error generating gTTS audio for scene {scene_id}: {e}")
            print("DEBUG_GTTS: Falling back to estimated duration and silent audio.")
            tts_failed_or_skipped = True
            audio_path = None
            total_duration = 0 # Reset duration if TTS generation failed



    # Case 3: No text provided (e.g., board_action scenes), just create truly silent audio
    else:
        total_duration = duration_override if duration_override is not None else 1.0
        word_timestamps = [] # Ensure empty for silent scenes
        print(f"DEBUG_AUDIO: No text provided. Creating silent audio for {total_duration:.2f}s.")
        
        try:
            subprocess.run([
                'ffmpeg', '-y', '-loglevel', 'quiet',
                '-f', 'lavfi',                              # Input format is lavfi (filtergraph)
                '-i', f'anullsrc=cl=mono:r=44100',          # Null audio source, mono, 44.1 kHz (no [a] mapping)
                '-c:a', 'libmp3lame',                       # Explicitly use libmp3lame for MP3 encoding
                '-b:a', '128k',                             # Audio bitrate
                '-t', str(total_duration),                  # Duration
                audio_path                                  # Output file (must be .mp3)
            ], check=True, text=True)
                
            print(f"DEBUG_AUDIO: Created silent audio file at {audio_path} for silent scene.")
        except subprocess.CalledProcessError as ffmpeg_e:
            print(f"ERROR_FFMPEG_AUDIO: Failed to create silent audio for scene {scene_id}: {ffmpeg_e}")
            audio_path = None # Indicate failure
            total_duration = 0 # Mark duration as 0 if audio generation failed
        except Exception as e: # Catch any other unexpected errors during audio creation
            print(f"ERROR_AUDIO_CREATION: General error creating audio file for scene {scene_id}: {e}")
            audio_path = None
            total_duration = 0

    # Final check if audio_path exists before returning
    return audio_path if audio_path and os.path.exists(audio_path) else None, word_timestamps, total_duration


# --- (1) The "Professor Shot" Animation Generator ---
def generate_professor_frames(text_to_speak, initial_state, word_timestamps, total_narration_duration): # REMOVED duration_override, added total_narration_duration
    """
    Generates frame data for a professor animation segment. This function yields
    parameters for rithmo_help.draw_scene_and_save for each frame.
    It consumes word_timestamps and total_duration provided to it, which are
    expected to come from `generate_tts_audio_and_timestamps`.

    Parameters:
        text_to_speak (str): The narration text.
        initial_state (dict): Current scene state including 'game_instance' and 'professor_pose'.
        duration_override (float, optional): If provided, overrides calculated audio duration.
                                              This will typically be the total_duration from audio generation.
        word_timestamps (list, optional): List of TranscriptionWord objects or dictionaries for precise timing.
                                           Expected to come from audio generation.

    Yields:
        dict: A dictionary of parameters for rithmo_help.draw_scene_and_save for one frame.
    """
    print(f"\n--- Generating Professor Frames for: '{text_to_speak[:50]}...' ---")

    current_professor_pose = initial_state.get("professor_pose", {
        'mouth_height': 0.1, 'right_hand_wrist_angle': 135,
        'pointer_angle_degrees': 225, 'eye_target_angle_degrees': 225
    }).copy()

    total_frames = int(total_narration_duration * FPS)
    if total_frames < 1: total_frames = 1 # Ensure at least one frame if duration is very short
    
    # --- Pre-calculate mouth height with smooth transitions ---
    frame_mouth_heights = [current_professor_pose['mouth_height']] * total_frames
    
    min_mouth_h, max_mouth_h = 0.1, 0.8
    transition_frames = 3
    
    for word_item in word_timestamps: # Use word_timestamps directly
        start_time = word_item.start if hasattr(word_item, 'start') else word_item['start']
        end_time = word_item.end if hasattr(word_item, 'end') else word_item['end']

        start_frame, end_frame = int(start_time * FPS), int(end_time * FPS)
        word_duration_frames = end_frame - start_frame
        
        for i in range(min(transition_frames, word_duration_frames // 2)):
            frame_num_open = start_frame + i
            if 0 <= frame_num_open < total_frames:
                progress_open = (i + 1) / transition_frames
                height_open = min_mouth_h + (max_mouth_h - min_mouth_h) * progress_open
                frame_mouth_heights[frame_num_open] = max(frame_mouth_heights[frame_num_open], height_open)

        for i in range(start_frame + transition_frames, end_frame - transition_frames + 1):
            if 0 <= i < total_frames:
                frame_mouth_heights[i] = max_mouth_h
        
        for i in range(min(transition_frames, word_duration_frames // 2)):
            frame_num_close = end_frame - i
            if 0 <= frame_num_close < total_frames:
                progress_close = (i + 1) / transition_frames
                height_close = min_mouth_h + (max_mouth_h - min_mouth_h) * (1 - progress_close)
                frame_mouth_heights[frame_num_close] = max(frame_mouth_heights[frame_num_close], height_close)

    professor_animation_params = initial_state.get("professor_animation_params", {}) 
    pointer_path_cues = professor_animation_params.get("pointer_path")
    
    if not pointer_path_cues:
        pointer_path_cues = [
            {'time': 0.0, 'angle': initial_state['professor_pose'].get('pointer_angle_degrees', 270)},
            {'time': total_narration_duration, 'angle': initial_state['professor_pose'].get('pointer_angle_degrees', 270)}
        ]

    current_wrist_angle = initial_state['professor_pose'].get('right_hand_wrist_angle', 135)
    current_pointer_angle = initial_state['professor_pose'].get('pointer_angle_degrees', 270)
    current_eye_angle = initial_state['professor_pose'].get('eye_target_angle_degrees', 270)


    for i in range(total_frames):
        current_time_in_scene = i / FPS
        
        current_word_idx = None
        for w_idx, word_data in enumerate(word_timestamps):
            word_start = word_data.start if hasattr(word_data, 'start') else word_data['start']
            word_end = word_data.end if hasattr(word_data, 'end') else word_data['end']
            if word_start <= current_time_in_scene < word_end:
                current_word_idx = w_idx
                break

        start_cue = pointer_path_cues[0]
        end_cue = pointer_path_cues[0]
        for j in range(len(pointer_path_cues) - 1):
            if current_time_in_scene >= pointer_path_cues[j]['time'] and current_time_in_scene < pointer_path_cues[j+1]['time']:
                start_cue, end_cue = pointer_path_cues[j], pointer_path_cues[j+1]
                break
            elif current_time_in_scene >= pointer_path_cues[-1]['time']:
                start_cue, end_cue = pointer_path_cues[-1], pointer_path_cues[-1] # Hold last pose
                
        time_in_segment = end_cue['time'] - start_cue['time']
        progress = (current_time_in_scene - start_cue['time']) / time_in_segment if time_in_segment > 0 else 0
        
        if start_cue.get('angle') is not None and end_cue.get('angle') is not None:
             current_pointer_angle = start_cue['angle'] + (end_cue['angle'] - start_cue['angle']) * progress
        elif end_cue.get('target_coords') is not None:
             current_pointer_angle = initial_state['professor_pose'].get('pointer_angle_degrees', 270)
        else:
            current_pointer_angle = initial_state['professor_pose'].get('pointer_angle_degrees', 270)


        current_professor_pose['right_hand_wrist_angle'] = current_wrist_angle
        current_professor_pose['pointer_angle_degrees'] = current_pointer_angle
        current_professor_pose['eye_target_angle_degrees'] = current_eye_angle
        current_professor_pose['mouth_height'] = frame_mouth_heights[i] if i < len(frame_mouth_heights) else min_mouth_h

        yield {
            'scene_type': 'combined',
            'board_state': initial_state['game_instance'].board,
            'professor_pose': current_professor_pose.copy(),
            'speech_text': text_to_speak,
            'current_word_idx': current_word_idx,
            'word_timestamps': word_timestamps,
            'total_duration': total_narration_duration, # Use the actual total duration
            'current_time': current_time_in_scene,
            'professor_bubble_width': 8.5 * 0.8,
            'professor_bubble_height': 3.5 * 1.2,
            'board_cell_width_combined': 0.9,
            'board_cell_height_combined': 0.9,
            'board_font_size_combined': 10
        }
    

    
# --- (2) The "Board Animation" Generator Function (DEFINITIVE VERSION) ---
def generate_board_frames(scene_config, current_animation_state_ref):
    """
    Generates frame data for a board animation segment, where the board changes
    but the professor remains static in the upper half.

    This version implements a deep copy of the board's matrix upon entry
    to isolate moves from potential external/unseen modifications.

    Parameters:
        scene_config (dict): Configuration for this board scene, including 'turn_actions', 'duration_seconds'.
        current_animation_state_ref (dict): A reference to the mutable animation state,
                                             including 'game_instance' and 'professor_pose'.

    Yields:
        dict: A dictionary of parameters for rithmo_help.draw_scene_and_save for one frame.
    
    EXAMPLES:
        # Assume rithmo.py's Piece subclasses (Triangle) are available.
        # Assume rithmo_help.get_initial_board_state_from_data is working.
        # Assume rithmo_help.print_board_piece_positions is working.

        # 1. Setup a simple initial game state for the example
        # (This initial_board_data is top-down, just like screenplay.CUSTOM_STARTING_BOARD)
        #>>> _example_initial_board_data = [
        #...     [None, None, None, None], # Alg Row 8
        #...     [None, None, rithmo.Triangle(72, 'white'), None], # Alg Row 7 (T072 at c7)
        #...     [None, None, None, None], # Alg Row 6
        #...     [None, None, None, rithmo.Triangle(12, 'black')] # Alg Row 5 (t012 at d5)
        #... ]
        >>> _example_initial_board_data = [ [None, None, None, None], [None, None, rithmo.Triangle(72, 'white'), None],  [None, None, None, None],  [None, None, None, rithmo.Triangle(12, 'black')]  ]
        
        >>> _example_game_instance = rithmo.RithmomachiaGame()
        >>> _example_game_instance.board = rithmo_help.get_initial_board_state_from_data(_example_initial_board_data)
        
        # Verify initial board state for the example (prints to console)
        # _ = rithmo_help.print_board_piece_positions(_example_game_instance.board) # Use _ to suppress output if not needed in doctest

        #>>> _example_animation_state = {
        #...     'game_instance': _example_game_instance,
        #...     'professor_pose': {'mouth_height': 0.1}, # Minimal pose for example
        #...     'captured_pieces': []
        #... }

        >>> _example_animation_state = { 'game_instance': _example_game_instance, 'professor_pose': {'mouth_height': 0.1}, 'captured_pieces': [] }

        # 2. Define a simple scene config to move T072 from c7 to e7
        #>>> _example_scene_config = {
        #...     "description": "Example: Move T072 from c7 to e7.",
        #...     "duration_seconds": 0.3, # Short duration for example (3 frames at 10 FPS)
        #...     "turn_actions": [
        #...         {
        #...             'description': 'Move T072 from c7 to e7.',
        #...             'move_string': 'c7e7', # T072 at (6,2) moves to (6,4)
        #...             'captures': [],
        #...             'highlights': [(6,2), (6,4)]
        #...         }
        #...     ]
        #... }
        >>> _example_scene_config = { "description": "Example: Move T072 from c7 to e7.", "duration_seconds": 0.3, "turn_actions": [ { 'description': 'Move T072 from c7 to e7.', 'move_string': 'c7e7',  'captures': [], 'highlights': [(6,2), (6,4)] } ] }

        # 3. Call the generator and iterate through frames
        >>> generated_frames_data = []
        >>> for frame_data in generate_board_frames(_example_scene_config, _example_animation_state):
        ...     generated_frames_data.append(frame_data)
        ... 

        # 4. Inspect the yielded frame data
        # All yielded frames will contain the board state *after* the move.
        >>> len(generated_frames_data) > 0 # Should yield frames
        True
        >>> first_frame_board_matrix = generated_frames_data[0]['board_state'].matrix
        # T072 should now be at e7 (raw: (6,4)), and c7 (raw: (6,2)) should be Empty
        >>> first_frame_board_matrix[6][4] # Piece is at the new location
        T072
        >>> first_frame_board_matrix[6][2] # Original location is empty
        None

    """
    # --- CRITICAL NEW DEBUGGING STEP: Create a deep copy of the board's matrix ---
    
    # Access the original game_instance and its board components
    original_game_instance = current_animation_state_ref['game_instance']
    original_board_matrix_ref = original_game_instance.board.matrix # Get original matrix reference

    # Print original IDs before copying
    print(f"DEBUG_ID: Original game_instance ID (gen_board_frames entry, before matrix copy): {id(original_game_instance)}")
    print(f"DEBUG_ID: Original game_instance.board ID (gen_board_frames entry, before matrix copy): {id(original_game_instance.board)}")
    print(f"DEBUG_ID: Original game_instance.board.matrix ID (gen_board_frames entry, before matrix copy): {id(original_board_matrix_ref)}")

    # Create a deep copy of the matrix data
    # This ensures a completely independent copy of the nested list structure.
    copied_matrix = copy.deepcopy(original_board_matrix_ref)

    # Temporarily reassign the actual game_instance's board.matrix to this copy.
    # All subsequent board operations in this function's scope will operate on this copy.
    # The 'board.matrix' setter in rithmo.py will log this reassignment.
    original_game_instance.board.matrix = copied_matrix

    # Now, assign game_instance for the rest of this function's logic
    game_instance = original_game_instance 
    professor_pose = current_animation_state_ref['professor_pose'] # Professor remains static


    # --- DEBUGGING PRINTS (Confirming the copy) ---
    print("\n--- Board State on ENTRY to generate_board_frames (DEEP-COPIED MATRIX) ---")
    # This prints from the game_instance.board that now holds the deep copy
    rithmo_help.print_board_piece_positions(game_instance.board)
    print(f"DEBUG_ID: game_instance ID (gen_board_frames entry, after matrix copy): {id(game_instance)}")
    print(f"DEBUG_ID: game_instance.board ID (gen_board_frames entry, after matrix copy): {id(game_instance.board)}")
    print(f"DEBUG_ID: game_instance.board.matrix ID (gen_board_frames entry, after matrix copy): {id(game_instance.board.matrix)}")
    print(f"DEBUG_ID: Copied matrix ID (assigned): {id(copied_matrix)}") # Should be same as game_instance.board.matrix ID now
    print("------------------------------------------------------------------")


    print(f"\n--- Generating Board Frames for Scene: {scene_config.get('description', 'Untitled Board Scene')} ---")
    
    turn_actions = scene_config.get("turn_actions", []) 
    print(f"DEBUG: Processing {len(turn_actions)} turn_actions for scene '{scene_config.get('description', 'Untitled')}'")
    
    duration_seconds = scene_config.get("duration_seconds", 3.0) # Default duration for board actions.
    
    if turn_actions:
        frames_per_sub_action = int(duration_seconds / len(turn_actions) * FPS)
    else:
        frames_per_sub_action = int(duration_seconds * FPS) 
    if frames_per_sub_action < 1: frames_per_sub_action = 1

    for action_idx, action in enumerate(turn_actions): # <--- LOOP START
        description = action.get("description", f"Action {action_idx+1}")
        move_string_full = action.get("move_string", "").strip()
        captures = action.get("captures", []) 
        highlights = action.get("highlights", [])

        print(f"DEBUG: --- Action {action_idx+1}: {description} ---")
        
        # --- NEW ROBUST DEBUG PRINT (just before apply_move) ---
        print(f"DEBUG_MOVE: Processing action '{action.get('description', 'N/A')}' (move_string: '{move_string_full}')")
        # --- END NEW DEBUG PRINT ---

        # Apply move (if any)
        if move_string_full:
            print(f"DEBUG_MOVE: Attempting apply_move for '{move_string_full}'")
            # --- Print board state before apply_move call (to verify for contradiction) ---
            print("\n--- Board State BEFORE apply_move ---")
            rithmo_help.print_board_piece_positions(game_instance.board)
            print("-------------------------------------")
            
            # --- DEBUG_ID (before apply_move) ---
            print(f"DEBUG_ID: game_instance ID (gen_board_frames before apply_move call): {id(game_instance)}")
            print(f"DEBUG_ID: game_instance.board ID (gen_board_frames before apply_move call): {id(game_instance.board)}")
            print(f"DEBUG_ID: game_instance.board.matrix ID (gen_board_frames before apply_move call): {id(game_instance.board.matrix)}")
            # --- END DEBUG_ID ---
            try:
                # This call will run the apply_move function, which has its own aggressive prints.
                game_instance.apply_move(move_string_full)
                print(f"DEBUG_MOVE: Successfully applied move '{move_string_full}'")
            except Exception as e:
                print(f"ERROR_MOVE: Failed to apply move '{move_string_full}': {e}")
                traceback.print_exc()
        else:
            print("DEBUG_MOVE: No move_string_full for this action, skipping apply_move.")

        # Apply captures (if any)
        if captures: # <--- This block must be inside the loop
            print(f"DEBUG: Captures found: {captures}")
            try:
                for (r, c) in captures:
                    # ... (capture logic) ...
                    # Ensure game_instance.board.remove_piece is called here
                    piece_to_capture_before = game_instance.board.get_piece((r, c))
                    if piece_to_capture_before:
                        game_instance.board.remove_piece((r, c))
                        game_instance.captured_pieces.append(piece_to_capture_before)
                        print(f"DEBUG: Captured piece at ({r}, {c})")
                    else:
                        print(f"DEBUG: No piece found to capture at ({r}, {c})")
            except Exception as e:
                print(f"ERROR: Failed to apply capture at ({r}, {c}): {e}")
                traceback.print_exc()
        else:
            print("DEBUG: No captures for this action.")

        print("\n--- Board State After Current Action ---")
        rithmo_help.print_board_piece_positions(game_instance.board)
        print("------------------------------------------")

        # Now, yield frames with the *updated* board state for this sub-action
        for i in range(frames_per_sub_action):
            yield {
                'scene_type': 'combined',
                'board_state': game_instance.board, # Pass the game_instance's board (which is the deep copy)
                'professor_pose': professor_pose,
                'speech_text': "",
                'current_word_idx': None,
                'word_timestamps': [],
                'total_duration': duration_seconds,
                'current_time': i / FPS,
                'circles': [{"pos": pos, "alpha": 0.5} for pos in highlights],
                'professor_bubble_width': 8.5 * 0.8,
                'professor_bubble_height': 3.5 * 1.2,
                'board_cell_width_combined': 0.9,
                'board_cell_height_combined': 0.9,
                'board_font_size_combined': 10
            }
    
    # If no turn_actions were provided (this is outside the loop)
    if not turn_actions:
        for i in range(int(duration_seconds * FPS)):
             yield {
                'scene_type': 'combined',
                'board_state': game_instance.board,
                'professor_pose': professor_pose,
                'speech_text': "",
                'current_word_idx': None,
                'word_timestamps': [],
                'total_duration': duration_seconds,
                'current_time': i / FPS,
                'circles': [],
                'professor_bubble_width': 8.5 * 0.8,
                'professor_bubble_height': 3.5 * 1.2,
                'board_cell_width_combined': 0.9,
                'board_cell_height_combined': 0.9,
                'board_font_size_combined': 10
            }
    print(f"--- Finished Generating Board Frames. ---")

def parse_move_string(move_str):
    """
    Converts a 4-character string like 'T9k8' into ((row1, col1), (row2, col2)).
    Assumes standard algebraic notation, where rows are 1-indexed starting at the bottom.
    
    """
    move_str = move_str.strip()
    if len(move_str) != 4:
        raise ValueError(f"Invalid move string: '{move_str}' ")

    def square_to_coords(sq):
        # Rithmomachia board has rows 1-8 (bottom to top), columns A-P (left to right)
        # Our matrix is 0-indexed, 0 at top.
        # So, row '1' (bottom of algebraic) is matrix row 7. row '8' (top of algebraic) is matrix row 0.
        col = ord(sq[0].lower()) - ord('a')  # 'a' -> 0, 'b' -> 1, ...
        # Algebraic row 1 corresponds to matrix row 7 (8-1=7)
        # Algebraic row 8 corresponds to matrix row 0 (8-8=0)
        row = 8 - int(sq[1]) # Example: if sq[1] is '1', row = 7. If sq[1] is '8', row = 0.
        return (row, col)

    start = square_to_coords(move_str[:2])
    end = square_to_coords(move_str[2:])
    return start, end


def print_board_piece_positions(board_object):
    print("\n📋 Current Piece Positions on the Board:")
    for row in range(len(board_object.matrix)):
        for col in range(len(board_object.matrix[0])):
            piece = board_object.matrix[row][col]
            if piece is not None:
                piece_type = type(piece).__name__
                value = getattr(piece, "value", "?")
                color = getattr(piece, "color", "?")
                print(f"  ({row}, {col}) → {piece_type} | {color} | value={value}")
    print()


# --- (3) Main Execution Block ---
if __name__ == "__main__":
    
    # Ensure directories exist
    os.makedirs(TEMP_FRAMES_DIR, exist_ok=True)
    os.makedirs(OUTPUT_VIDEO_DIR, exist_ok=True)
    os.makedirs(AUDIO_DIR, exist_ok=True)

    animation_scenes = screenplay.animation_scenes

    game_instance = RithmomachiaGame()
    game_instance.board = rithmo_help.get_initial_board_state_from_data(screenplay.CUSTOM_STARTING_BOARD)
    
    print("\n--- Initial Board State After Setup ---")
    rithmo_help.print_board_piece_positions(game_instance.board)
    print("---------------------------------------")

    current_animation_state = {
        'game_instance': game_instance,
        'professor_pose': {
            'mouth_height': 0.1,
            'right_hand_wrist_angle': 135,
            'pointer_angle_degrees': 270,
            'eye_target_angle_degrees': 270
        },
        'captured_pieces': []
    }

    # Lists to store paths for individual scene clips (video and audio)
    scene_video_clips_paths = []

    # Lists to store paths for individual scene clips (video and audio)
    scene_video_clips_paths_final = [] # Collects paths to the final (merged) clips for concatenation
    # We no longer need scene_audio_clips_paths for the final concat, as audio is embedded per clip.
    
    frame_counter_overall = 0
    
    # --- CRITICAL: Print apply_move source code for verification ---
    try:
        source_code_apply_move = inspect.getsource(game_instance.apply_move)
        print("\n--- Source code of RithmomachiaGame.apply_move (as loaded) ---")
        print(source_code_apply_move)
        print("--------------------------------------------------")
    except Exception as e:
        print(f"ERROR: Could not inspect apply_move source code: {e}")
    # --- END CRITICAL DEBUG ---
    
    # --- Scene Processing Loop ---
    for i, scene in enumerate(animation_scenes, 1):
        scene_id = f"scene_{i}"
        
        current_scene_frames_for_clip = []
        current_scene_audio_path = None # Path to audio file for this scene (e.g., .m4a)
        current_scene_narration_duration = scene.get("duration_seconds", 1.0)
        
        frame_generator = None

        print(f"\n🎬 Processing Scene {i}: {scene.get('description', 'Untitled Scene')}")

        # 1. Handle Professor Talk Scenes (Generate Audio & Frames)
        if scene["type"] == "professor_talk":
            generated_audio_path, generated_word_timestamps, generated_total_duration = \
                generate_tts_audio_and_timestamps(
                    text_to_speak=scene["narration"],
                    scene_id=scene_id,
                    word_timestamps_from_screenplay=scene.get("word_timestamps"),
                    duration_override=scene.get("duration_seconds")
                )
            
            current_scene_audio_path = generated_audio_path
            current_scene_narration_duration = generated_total_duration 

            frame_generator = generate_professor_frames(
                text_to_speak=scene["narration"],
                initial_state=current_animation_state,
                word_timestamps=generated_word_timestamps,
                total_narration_duration=current_scene_narration_duration
            )

        # 2. Handle Board Action Scenes (Generate Silent Audio & Frames)
        elif scene["type"] == "board_action":
            current_scene_narration_duration = scene.get("duration_seconds", 3.0)
            
            generated_audio_path, _, _ = generate_tts_audio_and_timestamps(
                text_to_speak="",
                scene_id=scene_id,
                duration_override=current_scene_narration_duration
            )
            current_scene_audio_path = generated_audio_path

            frame_generator = generate_board_frames(
                scene_config=scene,
                current_animation_state_ref=current_animation_state
            )

        else: # Unknown scene type
            print(f"Error: Unknown scene type '{scene.get('type', 'N/A')}' in scene {i}. Skipping.")
            continue

        # --- Frame Generation Loop for Current Scene ---
        if frame_generator:
            for frame_data_for_draw_scene in frame_generator:
                try:
                    image_array = rithmo_help.draw_scene_and_get_image_data(**frame_data_for_draw_scene)
                    current_scene_frames_for_clip.append(image_array)
                except Exception as e:
                    print(f"ERROR: Failed to draw frame {frame_counter_overall} (Scene {i}): {e}")
                    import traceback
                    traceback.print_exc()
                    current_scene_frames_for_clip.append(np.zeros((720, 1280, 3), dtype=np.uint8)) 
                frame_counter_overall += 1

            # --- Create individual video clip for this scene ---
            if current_scene_frames_for_clip:
                # 1. Create a video-only clip using imageio
                temp_video_only_path = os.path.join(TEMP_FRAMES_DIR, f"{scene_id}_video_only.mp4")
                try:
                    rithmo_help.combine_frames_to_video(current_scene_frames_for_clip, temp_video_only_path)
                    print(f"DEBUG_CLIP: Scene {scene_id} video-only clip created: {temp_video_only_path}")
                except Exception as e:
                    print(f"ERROR_CLIP: Failed to create video-only clip for scene {scene_id}: {e}")
                    import traceback
                    traceback.print_exc()
                    continue # Skip to next scene if video-only creation fails

                # 2. Merge video-only clip with audio file using FFmpeg
                final_scene_clip_path = os.path.join(OUTPUT_VIDEO_DIR, f"{scene_id}_clip.mp4") # This is the clip to concatenate later
                if current_scene_audio_path and os.path.exists(current_scene_audio_path):
                    print(f"DEBUG_CLIP: Merging audio {current_scene_audio_path} with video {temp_video_only_path} for scene {scene_id}.")
                    try:
                        merge_scene_command = [
                            'ffmpeg', '-y', '-loglevel', 'quiet',
                            '-i', temp_video_only_path, # Input 1: Video-only clip
                            '-i', current_scene_audio_path, # Input 2: Audio file (e.g., .mp3 from gTTS)

                            # --- VIDEO ENCODING (remains the same) ---
                            '-c:v', 'libx264', '-pix_fmt', 'yuv420p', '-preset', 'fast', '-crf', '23',

                            # --- AUDIO ENCODING (Revised for maximum robustness and clarity) ---
                            '-c:a', 'libmp3lame',        # Use AAC codec
                            '-b:a', '192k',       # Set audio bitrate
                            # IMPORTANT: Combine sample rate and channel layout into the audio filtergraph
                            # This allows more complex routing if needed and better control for the encoder.

                            # Filter chain for audio:
                            # 1. `asetpts=PTS-STARTPTS`: Realigns timestamps (good practice for merged streams)
                            # 2. `aresample=44100`: Resample to 44.1 kHz (uses default resampler)
                            # 3. `pan=stereo|c0<c0+c1|c1<c0+c1`: Convert mono to stereo by duplicating the mono channel to both left and right.
                            #                                   This is often safer than just '-ac 2'
                            # 4. `volume=0.8`: Your desired volume adjustment.
                            '-af', 'asetpts=PTS-STARTPTS,aresample=44100,pan=stereo|c0<c0+c1|c1<c0+c1,volume=0.8',
                            # You can remove volume=0.8 if you want to test without any volume changes.

                            # --- Other options ---
                            '-shortest', # End when shortest stream ends (video or audio)
                            final_scene_clip_path # Output path for this scene's final clip
                        ]
                        subprocess.run(merge_scene_command, check=True, text=True)
                        print(f"DEBUG_CLIP: Scene {scene_id} final clip (with audio) created: {final_scene_clip_path}")
                        scene_video_clips_paths_final.append(final_scene_clip_path) # Add to list for final concat
                    except subprocess.CalledProcessError as e:
                        print(f"ERROR_CLIP_MERGE: Failed to merge audio for scene {scene_id}: {e}")
                        # Consider adding e.stdout and e.stderr here for more detailed logs during failure
                        scene_video_clips_paths_final.append(temp_video_only_path) # Fallback: add video-only if merge fails
                else:
                    print(f"DEBUG_CLIP: No audio file found for scene {scene_id}. Using video-only clip for concatenation.")
                    scene_video_clips_paths_final.append(temp_video_only_path) # Add video-only clip to list


            else: # No frames for this scene at all
                print(f"Warning: No frames generated for Scene {scene_id}. Skipping clip creation.")

    print(f"\n--- Total frames generated overall: {frame_counter_overall} ---")

    # --- FINAL VIDEO COMPILATION: Concatenate all temporary scene clips ---
    final_output_video_path = os.path.join(OUTPUT_VIDEO_DIR, "final_rithmomachia_animation.mp4")

    original_cwd = os.getcwd()
    os.chdir(TEMP_FRAMES_DIR) # Change directory for FFmpeg
            
    if scene_video_clips_paths_final: # Only proceed if there are video clips to concatenate
        print(f"🚀 Concatenating {len(scene_video_clips_paths_final)} video clips into {final_output_video_path}")
        rithmo_help.concatenate_mp4_clips(temp_frames_dir = os.path.abspath(OUTPUT_VIDEO_DIR), output_filename="final_concatenated_video_output.mp4") ######### my addition
        """
        try:
            # Create a concat list file for FFmpeg (content is already correctly relative)
            concat_list_path = os.path.join(TEMP_FRAMES_DIR, "final_concat_list.txt")
            with open(concat_list_path, "w") as f:
                for clip_path in scene_video_clips_paths_final: 
                    relative_path_for_ffmpeg = os.path.relpath(clip_path, start=TEMP_FRAMES_DIR)
                    f.write(f"file '{relative_clip_path_for_ffmpeg}'\n")

            # --- Define the FFmpeg command list ---
            ffmpeg_concat_args = [ # Arguments WITHOUT redirection
                'ffmpeg', '-y', # Overwrite output without asking
                '-f', 'concat', '-safe', '0', '-i', os.path.basename(concat_list_path),
                '-c', 'copy', # Copy streams directly (re-encode with libx264/aac if this fails after getting log)
                os.path.abspath(final_output_video_path) # Absolute path for output (so it goes to output_videos/)
            ]
            
            # --- CRITICAL CHANGE: Redirect FFmpeg's output to a file directly via shell ---
            # This is the most reliable way to get FFmpeg's log.
            final_ffmpeg_log_path_direct = os.path.join(os.getcwd(), "ffmpeg_final_concat_log_direct.txt") # Log in current working dir (TEMP_FRAMES_DIR)
            
            # Formulate the command string that includes redirection using subprocess.PIPE and communicate
            # No, this is for subprocess.Popen. For subprocess.run with shell=True:
            command_string_for_shell = " ".join([f'"{arg}"' if " " in arg else arg for arg in ffmpeg_concat_args])
            command_string_for_shell += f" > \"{final_ffmpeg_log_path_direct}\" 2>&1" # Redirect stdout and stderr to the log file

            print("\n--- Running FFmpeg Final Concatenation (Output to External File) ---")
            print(f"Command being executed: {command_string_for_shell}")
            print(f"FFmpeg's detailed output will be in: {final_ffmpeg_log_path_direct}")
            print("----------------------------------------------------------------")

            # Execute the command using the shell
            # check=False to let Python continue and not raise CalledProcessError immediately.
            result = subprocess.run(command_string_for_shell, shell=True, check=False, text=True) # <<< shell=True, check=False >>>

            # We won't print result.stdout/stderr here, as they are redirected to the file.

            # Check return code from the result of the shell command
            if result.returncode != 0:
                print(f"ERROR_CONCAT: FFmpeg final concat failed with exit status {result.returncode}.")
                print(f"(Details should be in {final_ffmpeg_log_path_direct}.)")
                raise RuntimeError(f"FFmpeg final concatenation failed. Check {final_ffmpeg_log_path_direct} for details.") # Raise a generic error

            print(f"Full animation saved to: {os.path.abspath(final_output_video_path)}")

        except Exception as e: # Catch any other general exceptions for robustness
            print(f"ERROR_CONCAT: An unexpected error occurred during FFmpeg final concatenation: {e}")
            print(f"(Details should be in {final_ffmpeg_log_path_direct}.)")
            raise # Re-raise to stop script upon critical error
        finally:
            os.chdir(original_cwd)
            if os.path.exists(concat_list_path): os.remove(concat_list_path)
        """
    else:
        print("\nNo video clips were generated for final concatenation since clips doesn't exist. ", scene_video_clips_paths_final)



    # --- Cleanup ---
    if os.path.exists(AUDIO_DIR):
        try:
            #shutil.rmtree(AUDIO_DIR)      don't delete where the final audio is saved ....
            print(f"Cleaned up temporary audio directory: {AUDIO_DIR}")
        except Exception as e:
            print(f"Error cleaning up temporary audio directory {AUDIO_DIR}: {e}")

    if os.path.exists(TEMP_FRAMES_DIR):
        try:
            ########                             don't delete where the final video is saved ....
            #shutil.rmtree(TEMP_FRAMES_DIR)
            print(f"Cleaned up temporary frames directory: {TEMP_FRAMES_DIR}")
        except Exception as e:
            print(f"Error cleaning up temporary frames directory {TEMP_FRAMES_DIR}: {e}")

    print("\n--- Animation Process Complete ---")
    print(f"Final video should be at: {final_output_video_path}")
