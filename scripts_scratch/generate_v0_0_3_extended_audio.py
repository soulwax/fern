import math
import struct
import random
import wave
import os

SAMPLE_RATE = 44100

def write_wav(filename, samples):
    with wave.open(filename, 'w') as wav_file:
        wav_file.setnchannels(1)  # Mono
        wav_file.setsampwidth(2)  # 16-bit
        wav_file.setframerate(SAMPLE_RATE)
        raw_data = bytearray()
        for s in samples:
            val = max(-1.0, min(1.0, s))
            int_val = int(val * 32767.0)
            raw_data.extend(struct.pack('<h', int_val))
        wav_file.writeframes(raw_data)
    print(f"Generated: {filename} ({len(samples)} samples)")

def generate_totenbrett_consecrate():
    # 2.4s: Gouge carving into sacred pine plank + brush application + deep resonant folk chord
    duration = 2.4
    num_samples = int(SAMPLE_RATE * duration)
    samples = [0.0] * num_samples

    # 1. Chisel gouge cut (0.0 to 0.6s)
    gouge_len = int(0.55 * SAMPLE_RATE)
    for i in range(gouge_len):
        t = i / SAMPLE_RATE
        env = math.sin(math.pi * (i / gouge_len))
        wood_friction = (random.random() * 2.0 - 1.0) * 0.4
        tool_harmonic = math.sin(2.0 * math.pi * 840.0 * t) * 0.2 + math.sin(2.0 * math.pi * 1680.0 * t) * 0.1
        samples[i] += (wood_friction + tool_harmonic) * env * 0.75

    # 2. Consecration resonant chord (0.5s to 2.4s)
    chord_start = int(0.5 * SAMPLE_RATE)
    chord_len = num_samples - chord_start
    chord_freqs = [110.0, 165.0, 220.0, 330.0] # A-major / fifth organ-like swell
    for i in range(chord_len):
        idx = chord_start + i
        t = i / SAMPLE_RATE
        env = math.exp(-t * 1.8) * math.sin(math.pi * min(1.0, t * 4.0))
        swell = 0.0
        for f in chord_freqs:
            swell += math.sin(2.0 * math.pi * f * t) * 0.22
        samples[idx] += swell * env * 0.85

    return samples

def generate_talisman_carve():
    # 1.5s: Rhythm of sharp wood chip shaving + smooth leather cord knot pull
    duration = 1.5
    num_samples = int(SAMPLE_RATE * duration)
    samples = [0.0] * num_samples

    # Three slicing strokes
    strokes = [0.05, 0.45, 0.85]
    for st in strokes:
        start_idx = int(st * SAMPLE_RATE)
        s_len = int(0.22 * SAMPLE_RATE)
        for i in range(s_len):
            idx = start_idx + i
            if idx >= num_samples:
                break
            t = i / SAMPLE_RATE
            env = math.sin(math.pi * (i / s_len)) ** 1.5
            grain = (random.random() * 2.0 - 1.0) * 0.5
            blade = math.sin(2.0 * math.pi * 1250.0 * t) * 0.25
            samples[idx] += (grain + blade) * env * 0.7

    # Leather cord tighten click at 1.1s
    cord_start = int(1.15 * SAMPLE_RATE)
    cord_len = int(0.25 * SAMPLE_RATE)
    for i in range(cord_len):
        idx = cord_start + i
        if idx >= num_samples:
            break
        t = i / SAMPLE_RATE
        env = math.exp(-t * 28.0)
        leather = (random.random() * 2.0 - 1.0) * 0.35 + math.sin(2.0 * math.pi * 420.0 * t) * 0.4
        samples[idx] += leather * env * 0.8

    return samples

def generate_glass_carillon():
    # 3.2s: Multi-tone crystalline glass bell chimes with delicate long ringing decay
    duration = 3.2
    num_samples = int(SAMPLE_RATE * duration)
    samples = [0.0] * num_samples

    # Glass bell frequencies (high crystal harmonics)
    bells = [
        (0.0, 1760.0, 0.45), # A6
        (0.18, 2093.0, 0.4), # C7
        (0.35, 2637.0, 0.5), # E7
        (0.65, 3136.0, 0.35),# G7
        (0.95, 3520.0, 0.3)  # A7
    ]

    for start_t, freq, amp in bells:
        start_idx = int(start_t * SAMPLE_RATE)
        decay_len = num_samples - start_idx
        for i in range(decay_len):
            idx = start_idx + i
            t = i / SAMPLE_RATE
            env = math.exp(-t * 2.5) # Crystal sustain
            strike_click = math.exp(-t * 90.0) * (random.random() * 0.2)
            tone = math.sin(2.0 * math.pi * freq * t) + 0.3 * math.sin(2.0 * math.pi * (freq * 2.76) * t)
            samples[idx] += (tone * env + strike_click) * amp * 0.55

    return samples

if __name__ == "__main__":
    out_dir = os.path.join(os.path.dirname(__file__), "..", "Assets", "Audio")
    os.makedirs(out_dir, exist_ok=True)

    write_wav(os.path.join(out_dir, "totenbrett_consecrate.wav"), generate_totenbrett_consecrate())
    write_wav(os.path.join(out_dir, "talisman_carve.wav"), generate_talisman_carve())
    write_wav(os.path.join(out_dir, "glass_carillon_chime.wav"), generate_glass_carillon())
