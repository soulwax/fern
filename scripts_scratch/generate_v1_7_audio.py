import math
import struct
import random

def generate_heartbeat_slow(filename="Assets/Audio/heartbeat_slow.wav", sample_rate=44100):
    # 60 BPM -> 1.0s loop. Lub at t=0.0, Dub at t=0.28
    duration = 1.0
    total_samples = int(sample_rate * duration)
    samples = [0.0] * total_samples
    
    def add_thump(start_time, freq, amp, decay):
        start_idx = int(start_time * sample_rate)
        thump_len = int(0.22 * sample_rate)
        for i in range(thump_len):
            idx = start_idx + i
            if idx < total_samples:
                t = i / sample_rate
                # Pitch drops slightly during thump
                current_freq = freq * (1.0 - t * 1.8)
                env = math.exp(-decay * t)
                val = math.sin(2.0 * math.pi * current_freq * t) * env * amp
                samples[idx] += val

    # Lub (lower pitch, slightly louder)
    add_thump(0.05, 75.0, 0.85, 18.0)
    add_thump(0.05, 45.0, 0.60, 14.0) # Sub-bass body
    
    # Dub (slightly higher pitch, crisper decay)
    add_thump(0.32, 90.0, 0.70, 22.0)
    add_thump(0.32, 55.0, 0.50, 16.0)

    # Normalize and write 16-bit PCM WAV
    max_val = max(max(abs(s) for s in samples), 0.001)
    scale = 32767.0 * 0.90 / max_val
    raw_data = bytearray()
    for s in samples:
        int_val = int(max(min(s * scale, 32767), -32768))
        raw_data.extend(struct.pack("<h", int_val))
        
    num_samples = len(samples)
    data_size = num_samples * 2
    header = struct.pack(
        "<4sI4s4sIHHIIHH4sI",
        b"RIFF",
        36 + data_size,
        b"WAVE",
        b"fmt ",
        16,
        1, # PCM
        1, # Mono
        sample_rate,
        sample_rate * 2,
        2, # Block align
        16, # Bits per sample
        b"data",
        data_size
    )
    with open(filename, "wb") as f:
        f.write(header + raw_data)
    print(f"Generated {filename} ({duration}s, 60 BPM)")

def generate_heartbeat_fast(filename="Assets/Audio/heartbeat_fast.wav", sample_rate=44100):
    # 140 BPM -> ~0.428s loop. Lub at t=0.02, Dub at t=0.16
    duration = 60.0 / 140.0
    total_samples = int(sample_rate * duration)
    samples = [0.0] * total_samples
    
    def add_thump(start_time, freq, amp, decay):
        start_idx = int(start_time * sample_rate)
        thump_len = int(0.15 * sample_rate)
        for i in range(thump_len):
            idx = start_idx + i
            if idx < total_samples:
                t = i / sample_rate
                current_freq = freq * (1.0 - t * 2.2)
                env = math.exp(-decay * t)
                val = math.sin(2.0 * math.pi * current_freq * t) * env * amp
                samples[idx] += val

    add_thump(0.02, 95.0, 0.95, 22.0)
    add_thump(0.02, 60.0, 0.70, 16.0)
    
    add_thump(0.16, 110.0, 0.80, 26.0)
    add_thump(0.16, 70.0, 0.60, 18.0)

    max_val = max(max(abs(s) for s in samples), 0.001)
    scale = 32767.0 * 0.92 / max_val
    raw_data = bytearray()
    for s in samples:
        int_val = int(max(min(s * scale, 32767), -32768))
        raw_data.extend(struct.pack("<h", int_val))
        
    num_samples = len(samples)
    data_size = num_samples * 2
    header = struct.pack(
        "<4sI4s4sIHHIIHH4sI",
        b"RIFF",
        36 + data_size,
        b"WAVE",
        b"fmt ",
        16,
        1, 1, sample_rate, sample_rate * 2, 2, 16, b"data", data_size
    )
    with open(filename, "wb") as f:
        f.write(header + raw_data)
    print(f"Generated {filename} ({duration:.3f}s, 140 BPM)")

def generate_chalk_scratch(filename="Assets/Audio/chalk_scratch.wav", sample_rate=44100):
    duration = 1.2
    total_samples = int(sample_rate * duration)
    samples = [0.0] * total_samples
    
    # Generate abrasive friction bursts (strokes of chalk on stone)
    for i in range(total_samples):
        t = i / sample_rate
        # Multiple stroke modulation
        stroke_env = 0.5 + 0.5 * math.sin(2.0 * math.pi * 3.5 * t)
        # Fade in and out
        fade = min(t / 0.05, 1.0) * min((duration - t) / 0.1, 1.0)
        
        # White noise
        white_noise = random.uniform(-1.0, 1.0)
        # High friction resonant squeak
        squeak = math.sin(2.0 * math.pi * (1800.0 + 400.0 * math.sin(t * 15.0)) * t) * 0.25
        samples[i] = (white_noise * 0.75 + squeak) * stroke_env * fade

    # Simple 2-pole lowpass filter smoothing
    filtered = [0.0] * total_samples
    alpha = 0.25
    for i in range(1, total_samples):
        filtered[i] = alpha * samples[i] + (1.0 - alpha) * filtered[i-1]

    max_val = max(max(abs(s) for s in filtered), 0.001)
    scale = 32767.0 * 0.85 / max_val
    raw_data = bytearray()
    for s in filtered:
        int_val = int(max(min(s * scale, 32767), -32768))
        raw_data.extend(struct.pack("<h", int_val))
        
    num_samples = len(filtered)
    data_size = num_samples * 2
    header = struct.pack(
        "<4sI4s4sIHHIIHH4sI",
        b"RIFF",
        36 + data_size,
        b"WAVE",
        b"fmt ",
        16,
        1, 1, sample_rate, sample_rate * 2, 2, 16, b"data", data_size
    )
    with open(filename, "wb") as f:
        f.write(header + raw_data)
    print(f"Generated {filename} ({duration}s)")

if __name__ == "__main__":
    generate_heartbeat_slow()
    generate_heartbeat_fast()
    generate_chalk_scratch()
