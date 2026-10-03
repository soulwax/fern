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

def generate_bread_slice():
    # 1.2s: knife slice into thick rye crust + wooden trencher placement thud
    duration = 1.2
    num_samples = int(SAMPLE_RATE * duration)
    samples = [0.0] * num_samples
    
    # 1. Knife draw across rye crust (0.0 to 0.4s)
    slice_len = int(0.35 * SAMPLE_RATE)
    for i in range(slice_len):
        t = i / SAMPLE_RATE
        env = math.sin(math.pi * (i / slice_len))
        # Gritty crust friction noise
        noise = (random.random() * 2.0 - 1.0)
        # Blade harmonic
        blade = math.sin(2.0 * math.pi * 1400.0 * t) * 0.15 + math.sin(2.0 * math.pi * 2800.0 * t) * 0.08
        samples[i] += (noise * 0.45 + blade) * env * 0.65

    # 2. Wooden platter placement thud (at 0.45s)
    thud_start = int(0.45 * SAMPLE_RATE)
    thud_len = int(0.6 * SAMPLE_RATE)
    for i in range(thud_len):
        idx = thud_start + i
        if idx >= num_samples:
            break
        t = i / SAMPLE_RATE
        env_body = math.exp(-t * 22.0)
        env_click = math.exp(-t * 60.0)
        thump = (math.sin(2.0 * math.pi * 110.0 * t) * 0.7 +
                 math.sin(2.0 * math.pi * 190.0 * t) * 0.4) * env_body
        click = (random.random() * 2.0 - 1.0) * env_click * 0.35
        samples[idx] += (thump + click) * 0.85
        
    return samples

def generate_wraith_appeased():
    # 2.5s: low ethereal purr/hum + crust gnawing/crunching + spectral breath sigh
    duration = 2.5
    num_samples = int(SAMPLE_RATE * duration)
    samples = [0.0] * num_samples
    
    for i in range(num_samples):
        t = i / SAMPLE_RATE
        # Spectral drone low hum (60-90Hz undulating)
        hum_freq = 70.0 + 15.0 * math.sin(2.0 * math.pi * 1.5 * t)
        drone = math.sin(2.0 * math.pi * hum_freq * t) * 0.25
        # Ghostly sub-bass breathing envelope
        breath_env = math.sin(math.pi * (t / duration)) ** 1.5
        samples[i] += drone * breath_env
    
    # Add rhythmic gnawing/crust crunch clicks
    crunch_times = [0.35, 0.75, 1.15, 1.55, 1.95]
    for ct in crunch_times:
        start_idx = int(ct * SAMPLE_RATE)
        c_len = int(0.12 * SAMPLE_RATE)
        for i in range(c_len):
            idx = start_idx + i
            if idx >= num_samples:
                break
            t = i / SAMPLE_RATE
            env = math.exp(-t * 35.0)
            noise = (random.random() * 2.0 - 1.0) * env * 0.4
            wood = math.sin(2.0 * math.pi * 320.0 * t) * env * 0.3
            samples[idx] += (noise + wood) * 0.75

    return samples

def generate_shingle_gale():
    # 2.2s: Muffled roof wind gust + wood shingle fluttering/rattling
    duration = 2.2
    num_samples = int(SAMPLE_RATE * duration)
    samples = [0.0] * num_samples
    
    # Low-passed wind sweep
    lp_state = 0.0
    for i in range(num_samples):
        t = i / SAMPLE_RATE
        env = math.sin(math.pi * (t / duration)) ** 1.8
        white = (random.random() * 2.0 - 1.0)
        # Simple IIR low-pass filter (~180Hz)
        alpha = 0.03
        lp_state += alpha * (white - lp_state)
        samples[i] += lp_state * env * 1.4

    # Rapid shingle chatter (fluttering wood tiles)
    for k in range(25):
        shingle_t = random.uniform(0.3, 1.9)
        start_idx = int(shingle_t * SAMPLE_RATE)
        c_len = int(random.uniform(0.02, 0.05) * SAMPLE_RATE)
        freq = random.uniform(380.0, 520.0)
        amp = random.uniform(0.15, 0.35)
        for i in range(c_len):
            idx = start_idx + i
            if idx >= num_samples:
                break
            t = i / SAMPLE_RATE
            env = math.exp(-t * 70.0)
            samples[idx] += math.sin(2.0 * math.pi * freq * t) * env * amp

    return samples

if __name__ == "__main__":
    out_dir = os.path.join(os.path.dirname(__file__), "..", "Assets", "Audio")
    os.makedirs(out_dir, exist_ok=True)
    
    write_wav(os.path.join(out_dir, "bread_slice_place.wav"), generate_bread_slice())
    write_wav(os.path.join(out_dir, "wraith_appeased_feed.wav"), generate_wraith_appeased())
    write_wav(os.path.join(out_dir, "shingle_gale_rattle.wav"), generate_shingle_gale())
