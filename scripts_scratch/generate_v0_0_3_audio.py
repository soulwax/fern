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

def generate_salt_sizzle():
    # 1.4 seconds duration: intense crackling, hissing, and sizzling of salt crystals
    duration = 1.4
    num_samples = int(SAMPLE_RATE * duration)
    samples = [0.0] * num_samples

    # White-noise based hiss with multiple crackle impulses
    for i in range(num_samples):
        t = i / SAMPLE_RATE
        # Envelope: explosive surge in first 0.3s, decaying over 1.4s
        if t < 0.08:
            env = t / 0.08
        else:
            env = math.exp(-(t - 0.08) * 2.8)

        # High-frequency hiss
        noise = (random.random() * 2.0 - 1.0) * env * 0.35

        # Sizzling frequency bands
        sizzle1 = math.sin(2.0 * math.pi * 3200.0 * t + random.random() * 0.5) * env * 0.25
        sizzle2 = math.sin(2.0 * math.pi * 4800.0 * t + random.random() * 0.5) * env * 0.20
        # Low burning ember hum
        hum = math.sin(2.0 * math.pi * 240.0 * t) * env * 0.15

        samples[i] = noise + sizzle1 + sizzle2 + hum

    # Add random crisp pop/crackle transients throughout
    num_pops = 85
    for _ in range(num_pops):
        pop_time = random.uniform(0.02, 1.1)
        pop_idx = int(pop_time * SAMPLE_RATE)
        pop_len = int(random.uniform(0.005, 0.025) * SAMPLE_RATE)
        pop_amp = random.uniform(0.3, 0.75) * math.exp(-pop_time * 2.2)
        pop_freq = random.uniform(1200.0, 3600.0)
        for j in range(pop_len):
            idx = pop_idx + j
            if idx >= num_samples:
                break
            dt = j / SAMPLE_RATE
            p_env = math.exp(-dt * 220.0)
            samples[idx] += pop_amp * math.sin(2.0 * math.pi * pop_freq * dt) * p_env

    return samples

def generate_shavings_crunch():
    # 0.75 seconds duration: crisp, dry carpenter pine shavings crunching and rustling
    duration = 0.75
    num_samples = int(SAMPLE_RATE * duration)
    samples = [0.0] * num_samples

    # Background dry friction rustle
    for i in range(num_samples):
        t = i / SAMPLE_RATE
        env = math.exp(-t * 4.5)
        # Filtered dry noise
        noise = (random.random() * 2.0 - 1.0) * env * 0.28
        # Wood resonance
        res = math.sin(2.0 * math.pi * 950.0 * t) * env * 0.18
        samples[i] = noise + res

    # Clustered dry wood splinter crackles (hoof impact clusters)
    num_snaps = 40
    for _ in range(num_snaps):
        snap_time = random.uniform(0.01, 0.45)
        snap_idx = int(snap_time * SAMPLE_RATE)
        snap_len = int(random.uniform(0.008, 0.035) * SAMPLE_RATE)
        snap_amp = random.uniform(0.35, 0.85) * math.exp(-snap_time * 3.5)
        snap_freq = random.uniform(1400.0, 4200.0)
        for j in range(snap_len):
            idx = snap_idx + j
            if idx >= num_samples:
                break
            dt = j / SAMPLE_RATE
            s_env = math.exp(-dt * 180.0)
            samples[idx] += snap_amp * math.sin(2.0 * math.pi * snap_freq * dt) * s_env

    return samples

def main():
    audio_dir = os.path.join(os.getcwd(), "Assets", "Audio")
    os.makedirs(audio_dir, exist_ok=True)

    salt_path = os.path.join(audio_dir, "salt_sizzle.wav")
    write_wav(salt_path, generate_salt_sizzle())
    print(f"Generated: {salt_path}")

    shavings_path = os.path.join(audio_dir, "shavings_crunch.wav")
    write_wav(shavings_path, generate_shavings_crunch())
    print(f"Generated: {shavings_path}")

    print("All v0.0.3 audio files generated successfully.")

if __name__ == "__main__":
    main()
