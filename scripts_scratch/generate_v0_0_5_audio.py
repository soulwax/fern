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

def generate_cuckoo_call():
    # 1.25s duration: wooden bird door snap, followed by traditional "cu-ckoo" wooden pipe whistles
    duration = 1.25
    num_samples = int(SAMPLE_RATE * duration)
    samples = [0.0] * num_samples

    # Door snap click at t=0.04s
    snap_idx = int(0.04 * SAMPLE_RATE)
    for j in range(int(0.03 * SAMPLE_RATE)):
        dt = j / SAMPLE_RATE
        samples[snap_idx + j] += 0.45 * math.sin(2.0 * math.pi * 850.0 * dt) * math.exp(-dt * 240.0)

    # Note 1 ("Cu"): t = 0.12s to 0.42s (~740 Hz, wooden pipe)
    note1_start = 0.12
    note1_dur = 0.28
    for i in range(int(note1_dur * SAMPLE_RATE)):
        t_note = i / SAMPLE_RATE
        t_global = note1_start + t_note
        idx = int(t_global * SAMPLE_RATE)
        if idx >= num_samples:
            break
        # Envelope: smooth breath attack and decay
        env = math.sin(math.pi * (t_note / note1_dur)) ** 1.2
        f = 740.0 - 15.0 * (t_note / note1_dur)
        # Pipe fundamental + slight breath noise + warm 3rd harmonic
        pipe = math.sin(2.0 * math.pi * f * t_note) * 0.55
        harm = math.sin(2.0 * math.pi * f * 3.0 * t_note) * 0.08
        breath = (random.random() * 2.0 - 1.0) * 0.05
        samples[idx] += (pipe + harm + breath) * env

    # Note 2 ("Ckoo"): t = 0.46s to 0.95s (~587 Hz)
    note2_start = 0.46
    note2_dur = 0.48
    for i in range(int(note2_dur * SAMPLE_RATE)):
        t_note = i / SAMPLE_RATE
        t_global = note2_start + t_note
        idx = int(t_global * SAMPLE_RATE)
        if idx >= num_samples:
            break
        env = math.sin(math.pi * (t_note / note2_dur)) ** 1.4
        f = 587.0 - 10.0 * (t_note / note2_dur)
        pipe = math.sin(2.0 * math.pi * f * t_note) * 0.52
        harm = math.sin(2.0 * math.pi * f * 3.0 * t_note) * 0.06
        breath = (random.random() * 2.0 - 1.0) * 0.04
        samples[idx] += (pipe + harm + breath) * env

    # Door close snap at t=1.05s
    close_idx = int(1.05 * SAMPLE_RATE)
    for j in range(int(0.04 * SAMPLE_RATE)):
        dt = j / SAMPLE_RATE
        if close_idx + j < num_samples:
            samples[close_idx + j] += 0.35 * math.sin(2.0 * math.pi * 620.0 * dt) * math.exp(-dt * 210.0)

    return samples

def generate_automaton_jam():
    # 0.75s duration: rapid wooden cog teeth slipping and binding
    duration = 0.75
    num_samples = int(SAMPLE_RATE * duration)
    samples = [0.0] * num_samples

    # Shuddering escapement vibration
    for i in range(num_samples):
        t = i / SAMPLE_RATE
        env = math.exp(-t * 3.5)
        shudder = math.sin(2.0 * math.pi * 65.0 * t) * 0.22 * env
        samples[i] = shudder

    # Clustered gear teeth clicks
    clicks = [0.02, 0.07, 0.12, 0.18, 0.25, 0.33, 0.42, 0.53]
    for c_time in clicks:
        c_idx = int(c_time * SAMPLE_RATE)
        c_len = int(0.025 * SAMPLE_RATE)
        amp = 0.75 * math.exp(-c_time * 2.8)
        freq = random.uniform(850.0, 1400.0)
        for j in range(c_len):
            idx = c_idx + j
            if idx >= num_samples:
                break
            dt = j / SAMPLE_RATE
            samples[idx] += amp * math.sin(2.0 * math.pi * freq * dt) * math.exp(-dt * 260.0)

    return samples

def generate_chisel_strike():
    # 0.65s duration: heavy cold-iron parry strike with sharp steel ring
    duration = 0.65
    num_samples = int(SAMPLE_RATE * duration)
    samples = [0.0] * num_samples

    for i in range(num_samples):
        t = i / SAMPLE_RATE
        # Deep concussive impact thud
        thud = math.sin(2.0 * math.pi * 145.0 * t) * 0.55 * math.exp(-t * 60.0)

        # High-carbon steel resonance modes
        m1 = math.sin(2.0 * math.pi * 1180.0 * t) * 0.45 * math.exp(-t * 14.0)
        m2 = math.sin(2.0 * math.pi * 1840.0 * t) * 0.38 * math.exp(-t * 18.0)
        m3 = math.sin(2.0 * math.pi * 3250.0 * t) * 0.25 * math.exp(-t * 26.0)
        m4 = math.sin(2.0 * math.pi * 4820.0 * t) * 0.18 * math.exp(-t * 35.0)

        samples[i] = thud + m1 + m2 + m3 + m4

    return samples

def generate_herb_crush():
    # 0.55s duration: crisp dried botanical leaves and petals crumbling
    duration = 0.55
    num_samples = int(SAMPLE_RATE * duration)
    samples = [0.0] * num_samples

    # Background dry leaf friction
    for i in range(num_samples):
        t = i / SAMPLE_RATE
        env = math.exp(-t * 4.2)
        noise = (random.random() * 2.0 - 1.0) * 0.24 * env
        samples[i] = noise

    # Granular leaf snaps and crumbling impulses
    num_snaps = 35
    for _ in range(num_snaps):
        s_time = random.uniform(0.02, 0.40)
        s_idx = int(s_time * SAMPLE_RATE)
        s_len = int(random.uniform(0.005, 0.022) * SAMPLE_RATE)
        s_amp = random.uniform(0.25, 0.65) * math.exp(-s_time * 3.5)
        s_freq = random.uniform(1600.0, 4800.0)
        for j in range(s_len):
            idx = s_idx + j
            if idx >= num_samples:
                break
            dt = j / SAMPLE_RATE
            samples[idx] += s_amp * math.sin(2.0 * math.pi * s_freq * dt) * math.exp(-dt * 280.0)

    return samples

def main():
    audio_dir = os.path.join(os.getcwd(), "Assets", "Audio")
    os.makedirs(audio_dir, exist_ok=True)

    cuckoo_path = os.path.join(audio_dir, "cuckoo_call.wav")
    print(f"Generating {cuckoo_path}...")
    write_wav(cuckoo_path, generate_cuckoo_call())

    jam_path = os.path.join(audio_dir, "automaton_jam.wav")
    print(f"Generating {jam_path}...")
    write_wav(jam_path, generate_automaton_jam())

    chisel_path = os.path.join(audio_dir, "chisel_strike.wav")
    print(f"Generating {chisel_path}...")
    write_wav(chisel_path, generate_chisel_strike())

    herb_path = os.path.join(audio_dir, "herb_crush.wav")
    print(f"Generating {herb_path}...")
    write_wav(herb_path, generate_herb_crush())

    print("Milestone v0.0.5 audio synthesis complete!")

if __name__ == "__main__":
    main()
