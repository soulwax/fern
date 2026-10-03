import math
import struct
import random

def generate_thunder(filename="Assets/Audio/thunder_distant.wav", sample_rate=44100):
    duration = 2.8
    total_samples = int(sample_rate * duration)
    samples = [0.0] * total_samples
    
    # Generate low frequency rolling noise + sine rumble
    for i in range(total_samples):
        t = i / sample_rate
        # Envelope: initial crack at 0.15s, then rolling rumble decaying over 2.5s
        if t < 0.15:
            env = (t / 0.15) ** 2
        else:
            env = math.exp(-1.4 * (t - 0.15)) * (0.85 + 0.15 * math.sin(2.0 * math.pi * 3.0 * t))
            
        noise = random.uniform(-1.0, 1.0)
        # Deep bass harmonics
        bass = math.sin(2.0 * math.pi * 45.0 * t + 0.5 * math.sin(t * 8.0)) * 0.4
        sub = math.sin(2.0 * math.pi * 32.0 * t) * 0.5
        samples[i] = (noise * 0.5 + bass + sub) * env

    # Low-pass filter to keep it deep and rolling (around 120 Hz cutoff)
    filtered = [0.0] * total_samples
    alpha = 0.05
    for i in range(1, total_samples):
        filtered[i] = alpha * samples[i] + (1.0 - alpha) * filtered[i-1]

    max_val = max(max(abs(s) for s in filtered), 0.001)
    scale = 32767.0 * 0.90 / max_val
    raw_data = bytearray()
    for s in filtered:
        int_val = int(max(min(s * scale, 32767), -32768))
        raw_data.extend(struct.pack("<h", int_val))
        
    num_samples = len(filtered)
    data_size = num_samples * 2
    header = struct.pack(
        "<4sI4s4sIHHIIHH4sI",
        b"RIFF", 36 + data_size, b"WAVE", b"fmt ", 16, 1, 1,
        sample_rate, sample_rate * 2, 2, 16, b"data", data_size
    )
    with open(filename, "wb") as f:
        f.write(header + raw_data)
    print(f"Generated {filename} ({duration}s)")

def generate_breath_cold(filename="Assets/Audio/breath_cold.wav", sample_rate=44100):
    duration = 0.9
    total_samples = int(sample_rate * duration)
    samples = [0.0] * total_samples
    
    for i in range(total_samples):
        t = i / sample_rate
        # Gentle breath swell and taper
        env = math.sin(math.pi * (t / duration)) ** 1.8
        noise = random.uniform(-1.0, 1.0)
        samples[i] = noise * env

    # Bandpass filter around 600–1800 Hz for authentic whispered exhale
    filtered = [0.0] * total_samples
    alpha = 0.12
    for i in range(1, total_samples):
        filtered[i] = alpha * samples[i] + (1.0 - alpha) * filtered[i-1]

    max_val = max(max(abs(s) for s in filtered), 0.001)
    scale = 32767.0 * 0.65 / max_val
    raw_data = bytearray()
    for s in filtered:
        int_val = int(max(min(s * scale, 32767), -32768))
        raw_data.extend(struct.pack("<h", int_val))
        
    num_samples = len(filtered)
    data_size = num_samples * 2
    header = struct.pack(
        "<4sI4s4sIHHIIHH4sI",
        b"RIFF", 36 + data_size, b"WAVE", b"fmt ", 16, 1, 1,
        sample_rate, sample_rate * 2, 2, 16, b"data", data_size
    )
    with open(filename, "wb") as f:
        f.write(header + raw_data)
    print(f"Generated {filename} ({duration}s)")

def generate_chain_clink(filename="Assets/Audio/chain_clink.wav", sample_rate=44100):
    duration = 0.85
    total_samples = int(sample_rate * duration)
    samples = [0.0] * total_samples
    
    def add_metallic_tap(start_t, freq1, freq2, decay):
        start_idx = int(start_t * sample_rate)
        tap_len = int(0.25 * sample_rate)
        for i in range(tap_len):
            idx = start_idx + i
            if idx < total_samples:
                t = i / sample_rate
                env = math.exp(-decay * t)
                val = (math.sin(2.0 * math.pi * freq1 * t) * 0.6 +
                       math.sin(2.0 * math.pi * freq2 * t) * 0.4) * env
                samples[idx] += val

    # Clinking links
    add_metallic_tap(0.02, 1420.0, 2180.0, 28.0)
    add_metallic_tap(0.09, 1650.0, 2450.0, 32.0)
    add_metallic_tap(0.18, 1310.0, 1920.0, 25.0)

    max_val = max(max(abs(s) for s in samples), 0.001)
    scale = 32767.0 * 0.85 / max_val
    raw_data = bytearray()
    for s in samples:
        int_val = int(max(min(s * scale, 32767), -32768))
        raw_data.extend(struct.pack("<h", int_val))
        
    num_samples = len(samples)
    data_size = num_samples * 2
    header = struct.pack(
        "<4sI4s4sIHHIIHH4sI",
        b"RIFF", 36 + data_size, b"WAVE", b"fmt ", 16, 1, 1,
        sample_rate, sample_rate * 2, 2, 16, b"data", data_size
    )
    with open(filename, "wb") as f:
        f.write(header + raw_data)
    print(f"Generated {filename} ({duration}s)")

if __name__ == "__main__":
    generate_thunder()
    generate_breath_cold()
    generate_chain_clink()
