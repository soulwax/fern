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

def generate_bellows_pump():
    # 0.85s duration: leather creak followed by rush of compressed air
    duration = 0.85
    num_samples = int(SAMPLE_RATE * duration)
    samples = [0.0] * num_samples

    # Phase 1: Leather hinge creak (0.00s - 0.20s)
    for i in range(int(0.22 * SAMPLE_RATE)):
        t = i / SAMPLE_RATE
        creak_env = math.sin(math.pi * (t / 0.22))
        creak_freq = 160.0 + 80.0 * math.sin(2.0 * math.pi * 18.0 * t)
        creak = math.sin(2.0 * math.pi * creak_freq * t) * 0.35 * creak_env
        samples[i] += creak

    # Phase 2: Rushing air blast (0.12s - 0.85s)
    air_start = int(0.12 * SAMPLE_RATE)
    air_len = num_samples - air_start
    prev_noise = 0.0
    for i in range(air_len):
        t = i / SAMPLE_RATE
        t_norm = t / (air_len / SAMPLE_RATE)
        # Swell and decay envelope
        env = math.sin(math.pi * (t_norm ** 0.7)) ** 1.8
        # Lowpass filtered noise for air stream
        white = random.random() * 2.0 - 1.0
        filtered = prev_noise * 0.82 + white * 0.18
        prev_noise = filtered
        
        # Subtle pitch resonance in the iron nozzle
        resonance = math.sin(2.0 * math.pi * 320.0 * t) * 0.12
        samples[air_start + i] += (filtered * 0.75 + resonance) * env

    return samples

def generate_ember_hiss():
    # 0.65s duration: violent quench of glowing charcoal into steam hiss
    duration = 0.65
    num_samples = int(SAMPLE_RATE * duration)
    samples = [0.0] * num_samples

    prev1 = 0.0
    prev2 = 0.0
    for i in range(num_samples):
        t = i / SAMPLE_RATE
        # Rapid decay envelope
        env = math.exp(-t * 6.5)
        # High-pass steam hiss
        white = random.random() * 2.0 - 1.0
        hp = white - prev1 * 0.65
        prev1 = white
        # Mineral pop crackles
        crackle = 0.0
        if random.random() < 0.02 * env:
            crackle = (random.random() * 2.0 - 1.0) * 0.45

        samples[i] = (hp * 0.65 + crackle) * env

    return samples

def generate_drip_tap():
    # 0.45s duration: metallic ping of cold rainwater droplet on thin galvanized zinc sheet
    duration = 0.45
    num_samples = int(SAMPLE_RATE * duration)
    samples = [0.0] * num_samples

    # Droplet surface contact thump (t=0 to 0.04s)
    for i in range(int(0.04 * SAMPLE_RATE)):
        t = i / SAMPLE_RATE
        samples[i] += math.sin(2.0 * math.pi * 340.0 * t) * math.exp(-t * 120.0) * 0.4

    # High-Q resonant zinc plate chime (~1680 Hz + overtones)
    for i in range(num_samples):
        t = i / SAMPLE_RATE
        env = math.exp(-t * 14.0)
        f0 = 1680.0
        f1 = 2520.0
        f2 = 3980.0
        chime = (
            math.sin(2.0 * math.pi * f0 * t) * 0.55 +
            math.sin(2.0 * math.pi * f1 * t) * 0.28 +
            math.sin(2.0 * math.pi * f2 * t) * 0.14
        ) * env
        samples[i] += chime

    return samples

def generate_water_splash():
    # 0.60s duration: sudden electrostatic water ripple and splash
    duration = 0.60
    num_samples = int(SAMPLE_RATE * duration)
    samples = [0.0] * num_samples

    # Initial impact thud
    for i in range(int(0.06 * SAMPLE_RATE)):
        t = i / SAMPLE_RATE
        samples[i] += math.sin(2.0 * math.pi * 130.0 * t) * math.exp(-t * 70.0) * 0.6

    # Turbulent splashing noise
    prev = 0.0
    for i in range(num_samples):
        t = i / SAMPLE_RATE
        env = math.sin(math.pi * (t / duration)) ** 1.5 * math.exp(-t * 4.0)
        white = random.random() * 2.0 - 1.0
        # Bandpass filtered slosh
        bp = white * 0.25 + prev * 0.75
        prev = bp
        samples[i] += bp * env * 0.85

    # Secondary splatter droplets
    for drop_t in [0.08, 0.14, 0.21, 0.29]:
        idx = int(drop_t * SAMPLE_RATE)
        for j in range(int(0.02 * SAMPLE_RATE)):
            if idx + j < num_samples:
                dt = j / SAMPLE_RATE
                samples[idx + j] += math.sin(2.0 * math.pi * 1200.0 * dt) * math.exp(-dt * 180.0) * 0.25

    return samples

def generate_drawknife_peel():
    # 0.75s duration: curved blade slicing cleanly through pine wood grain
    duration = 0.75
    num_samples = int(SAMPLE_RATE * duration)
    samples = [0.0] * num_samples

    prev = 0.0
    for i in range(num_samples):
        t = i / SAMPLE_RATE
        env = math.sin(math.pi * (t / duration)) ** 1.3
        # Modulated friction of cutting tool
        grain_mod = 1.0 + 0.3 * math.sin(2.0 * math.pi * 52.0 * t)
        white = random.random() * 2.0 - 1.0
        # Filtered wood shear
        filtered = white * 0.35 + prev * 0.65
        prev = filtered
        # Slicing harmonic tone
        slice_tone = math.sin(2.0 * math.pi * (820.0 + 150.0 * (t / duration)) * t) * 0.15
        samples[i] = (filtered * 0.75 + slice_tone) * grain_mod * env * 0.7

    return samples

def main():
    audio_dir = os.path.join(os.getcwd(), "Assets", "Audio")
    os.makedirs(audio_dir, exist_ok=True)

    files = {
        "bellows_pump.wav": generate_bellows_pump(),
        "ember_hiss.wav": generate_ember_hiss(),
        "drip_tap.wav": generate_drip_tap(),
        "water_splash.wav": generate_water_splash(),
        "drawknife_peel.wav": generate_drawknife_peel(),
    }

    for fname, samples in files.items():
        path = os.path.join(audio_dir, fname)
        write_wav(path, samples)
        print(f"Generated {path} ({len(samples)} samples)")

if __name__ == "__main__":
    main()
