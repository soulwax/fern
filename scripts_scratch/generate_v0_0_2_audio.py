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

def generate_clock_tick():
    # 1.0 second duration: Tick at 0.0s, Tock at 0.5s
    duration = 1.0
    num_samples = int(SAMPLE_RATE * duration)
    samples = [0.0] * num_samples

    # Subtle mechanical whir
    for i in range(num_samples):
        t = i / SAMPLE_RATE
        samples[i] += 0.005 * math.sin(2.0 * math.pi * 120.0 * t)

    def add_click(start_time, base_freq, thump_freq, amp):
        start_idx = int(start_time * SAMPLE_RATE)
        click_len = int(0.08 * SAMPLE_RATE)
        for i in range(click_len):
            idx = start_idx + i
            if idx >= num_samples:
                break
            t = i / SAMPLE_RATE
            env_click = math.exp(-t * 90.0)
            env_thump = math.exp(-t * 45.0)
            noise = (random.random() * 2.0 - 1.0) * env_click * 0.4
            click = math.sin(2.0 * math.pi * base_freq * t) * env_click
            click2 = math.sin(2.0 * math.pi * (base_freq * 1.6) * t) * env_click * 0.5
            thump = math.sin(2.0 * math.pi * thump_freq * t) * env_thump * 0.6
            samples[idx] += amp * (click + click2 + thump + noise)

    # Tick at 0.0s
    add_click(0.0, 950.0, 220.0, 0.75)
    # Tock at 0.5s
    add_click(0.5, 780.0, 180.0, 0.65)

    return samples

def generate_clock_chime():
    # 2.8 seconds grandfather clock gong chime
    duration = 2.8
    num_samples = int(SAMPLE_RATE * duration)
    samples = [0.0] * num_samples

    f0 = 220.0  # A3 deep grandfather chime fundamental
    for i in range(num_samples):
        t = i / SAMPLE_RATE
        # Strike transient
        strike_env = math.exp(-t * 80.0) * 0.3 * (random.random() * 2.0 - 1.0)
        # Deep harmonic gong body
        env1 = math.exp(-t * 1.1)
        env2 = math.exp(-t * 1.5)
        env3 = math.exp(-t * 2.2)
        env4 = math.exp(-t * 3.0)

        # Tremolo / beating
        tremolo = 1.0 + 0.15 * math.sin(2.0 * math.pi * 2.5 * t)

        s1 = 0.55 * math.sin(2.0 * math.pi * f0 * t) * env1 * tremolo
        s2 = 0.35 * math.sin(2.0 * math.pi * (f0 * 1.5) * t) * env2
        s3 = 0.25 * math.sin(2.0 * math.pi * (f0 * 2.0) * t) * env2
        s4 = 0.18 * math.sin(2.0 * math.pi * (f0 * 3.1) * t) * env3
        s5 = 0.10 * math.sin(2.0 * math.pi * (f0 * 4.2) * t) * env4

        samples[i] = strike_env + s1 + s2 + s3 + s4 + s5

    return samples

def generate_horseshoe_strike():
    # 1.5 seconds resonant cold iron horseshoe ward ring
    duration = 1.5
    num_samples = int(SAMPLE_RATE * duration)
    samples = [0.0] * num_samples

    for i in range(num_samples):
        t = i / SAMPLE_RATE
        # Initial sharp iron transient
        transient_env = math.exp(-t * 120.0)
        noise = (random.random() * 2.0 - 1.0) * transient_env * 0.7

        # Piercing cold iron clang harmonics (horseshoe resonant frequencies)
        env = math.exp(-t * 2.5)
        env_high = math.exp(-t * 4.0)

        ring1 = 0.50 * math.sin(2.0 * math.pi * 1280.0 * t) * env
        ring2 = 0.35 * math.sin(2.0 * math.pi * 1840.0 * t) * env
        ring3 = 0.20 * math.sin(2.0 * math.pi * 2560.0 * t) * env_high
        ring4 = 0.15 * math.sin(2.0 * math.pi * 3420.0 * t) * env_high

        # Mystical ward hum under-resonance
        mystic_hum = 0.18 * math.sin(2.0 * math.pi * 440.0 * t) * math.exp(-t * 1.5)

        samples[i] = noise + ring1 + ring2 + ring3 + ring4 + mystic_hum

    return samples

def main():
    audio_dir = os.path.join(os.getcwd(), "Assets", "Audio")
    os.makedirs(audio_dir, exist_ok=True)

    # 1. Clock Tick
    tick_path = os.path.join(audio_dir, "clock_tick.wav")
    write_wav(tick_path, generate_clock_tick())
    print(f"Generated: {tick_path}")

    # 2. Clock Chime
    chime_path = os.path.join(audio_dir, "clock_chime.wav")
    write_wav(chime_path, generate_clock_chime())
    print(f"Generated: {chime_path}")

    # 3. Horseshoe Strike
    shoe_path = os.path.join(audio_dir, "horseshoe_strike.wav")
    write_wav(shoe_path, generate_horseshoe_strike())
    print(f"Generated: {shoe_path}")

    print("All v0.0.2 audio files generated successfully.")

if __name__ == "__main__":
    main()
