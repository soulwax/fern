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

def generate_torch_burn():
    # 2.0s seamless-capable open torch flame burn with combustion whoosh and resin pops
    duration = 2.0
    num_samples = int(SAMPLE_RATE * duration)
    samples = [0.0] * num_samples

    for i in range(num_samples):
        t = i / SAMPLE_RATE
        # Low rumble and turbulent combustion roar
        f_rumble = 95.0 + 20.0 * math.sin(2.0 * math.pi * 3.5 * t)
        rumble = math.sin(2.0 * math.pi * f_rumble * t) * 0.28
        f_body = 180.0 + 35.0 * math.cos(2.0 * math.pi * 4.2 * t)
        body = math.sin(2.0 * math.pi * f_body * t) * 0.18

        # Sputtering noise
        noise = (random.random() * 2.0 - 1.0) * (0.22 + 0.08 * math.sin(2.0 * math.pi * 7.1 * t))

        samples[i] = rumble + body + noise

    # Add erratic resin sap crackles & sparks
    num_crackles = 35
    for _ in range(num_crackles):
        c_time = random.uniform(0.05, duration - 0.05)
        c_idx = int(c_time * SAMPLE_RATE)
        c_len = int(random.uniform(0.004, 0.018) * SAMPLE_RATE)
        c_amp = random.uniform(0.25, 0.65)
        c_freq = random.uniform(1500.0, 4200.0)
        for j in range(c_len):
            idx = c_idx + j
            if idx >= num_samples:
                break
            dt = j / SAMPLE_RATE
            env = math.exp(-dt * 260.0)
            samples[idx] += c_amp * math.sin(2.0 * math.pi * c_freq * dt) * env

    # Soft fade-in and fade-out to prevent clicks
    fade_len = int(0.05 * SAMPLE_RATE)
    for i in range(fade_len):
        fi = i / fade_len
        samples[i] *= fi
        samples[num_samples - 1 - i] *= fi

    return samples

def generate_latch_rattle():
    # 0.85s heavy iron shutter drop-latch rattling against timber frame
    duration = 0.85
    num_samples = int(SAMPLE_RATE * duration)
    samples = [0.0] * num_samples

    # Clustered metallic strikes decaying in intensity
    strikes = [
        (0.00, 0.90),
        (0.06, 0.70),
        (0.13, 0.55),
        (0.21, 0.42),
        (0.30, 0.32),
        (0.40, 0.22),
        (0.52, 0.15),
        (0.65, 0.08),
    ]

    for st_time, amp in strikes:
        st_idx = int(st_time * SAMPLE_RATE)
        st_len = int(0.18 * SAMPLE_RATE)
        for j in range(st_len):
            idx = st_idx + j
            if idx >= num_samples:
                break
            dt = j / SAMPLE_RATE
            env = math.exp(-dt * 45.0)

            # Iron resonance modes
            m1 = math.sin(2.0 * math.pi * 780.0 * dt) * 0.40
            m2 = math.sin(2.0 * math.pi * 1280.0 * dt) * 0.35
            m3 = math.sin(2.0 * math.pi * 2350.0 * dt) * 0.20
            # Wood frame thud
            thud = math.sin(2.0 * math.pi * 165.0 * dt) * 0.45 * math.exp(-dt * 70.0)

            samples[idx] += amp * (m1 + m2 + m3 + thud) * env

    return samples

def generate_cauldron_boil():
    # 2.0s viscous bubbling and simmering of hot resin pitch
    duration = 2.0
    num_samples = int(SAMPLE_RATE * duration)
    samples = [0.0] * num_samples

    # Simmering background liquid hiss and low rumble
    for i in range(num_samples):
        t = i / SAMPLE_RATE
        rumble = math.sin(2.0 * math.pi * 82.0 * t) * 0.15
        hiss = (random.random() * 2.0 - 1.0) * 0.08
        samples[i] = rumble + hiss

    # Thick viscous bubble plops / pops
    num_bubbles = 28
    for _ in range(num_bubbles):
        b_time = random.uniform(0.05, duration - 0.05)
        b_idx = int(b_time * SAMPLE_RATE)
        b_len = int(random.uniform(0.04, 0.11) * SAMPLE_RATE)
        b_amp = random.uniform(0.35, 0.75)
        start_f = random.uniform(160.0, 320.0)
        end_f = start_f * random.uniform(1.6, 2.5)  # Pitch sweeps up as bubble detaches and pops
        for j in range(b_len):
            idx = b_idx + j
            if idx >= num_samples:
                break
            dt = j / SAMPLE_RATE
            norm_t = dt / (b_len / SAMPLE_RATE)
            inst_f = start_f + (end_f - start_f) * (norm_t ** 1.5)
            b_env = math.sin(math.pi * norm_t) ** 1.8
            samples[idx] += b_amp * math.sin(2.0 * math.pi * inst_f * dt) * b_env

    # Soft loop-friendly fade
    fade_len = int(0.05 * SAMPLE_RATE)
    for i in range(fade_len):
        fi = i / fade_len
        samples[i] *= fi
        samples[num_samples - 1 - i] *= fi

    return samples

def main():
    audio_dir = os.path.join(os.getcwd(), "Assets", "Audio")
    os.makedirs(audio_dir, exist_ok=True)

    torch_path = os.path.join(audio_dir, "torch_burn.wav")
    print(f"Generating {torch_path}...")
    torch_samples = generate_torch_burn()
    write_wav(torch_path, torch_samples)

    latch_path = os.path.join(audio_dir, "latch_rattle.wav")
    print(f"Generating {latch_path}...")
    latch_samples = generate_latch_rattle()
    write_wav(latch_path, latch_samples)

    cauldron_path = os.path.join(audio_dir, "cauldron_boil.wav")
    print(f"Generating {cauldron_path}...")
    cauldron_samples = generate_cauldron_boil()
    write_wav(cauldron_path, cauldron_samples)

    print("Milestone v0.0.4 audio synthesis complete!")

if __name__ == "__main__":
    main()
