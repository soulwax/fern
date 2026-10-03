import math
import struct
import wave
import random

SAMPLE_RATE = 44100

def write_wav(filename, samples):
    with wave.open(filename, 'w') as wav_file:
        wav_file.setnchannels(1)
        wav_file.setsampwidth(2)
        wav_file.setframerate(SAMPLE_RATE)
        # Normalize and convert to 16-bit PCM
        max_amp = max(abs(s) for s in samples) if samples else 1.0
        if max_amp < 1e-5:
            max_amp = 1.0
        scale = 32767.0 * 0.95 / max_amp
        data = bytearray()
        for s in samples:
            val = int(max(min(s * scale, 32767), -32768))
            data.extend(struct.pack('<h', val))
        wav_file.writeframes(data)
    print(f"Generated {filename} ({len(samples)/SAMPLE_RATE:.2f}s)")

def generate_mirror_wipe(filename):
    duration = 0.65
    n_samples = int(duration * SAMPLE_RATE)
    samples = [0.0] * n_samples
    
    # 2 squeak strokes: forward wipe then back wipe
    for i in range(n_samples):
        t = i / SAMPLE_RATE
        # Envelope with two peaks
        env = (math.sin(t * math.pi / duration) ** 2) * (0.8 + 0.2 * math.sin(t * 30.0))
        
        # High friction squeak pitch modulating between 2100Hz and 3200Hz
        freq = 2400.0 + 700.0 * math.sin(t * 45.0) + 200.0 * math.sin(t * 120.0)
        squeak = math.sin(2.0 * math.pi * freq * t)
        
        # Slip-stick friction noise
        noise = (random.random() * 2.0 - 1.0) * 0.25
        # Soft cloth rub low-end
        cloth_rub = math.sin(2.0 * math.pi * 320.0 * t) * 0.3
        
        samples[i] = (squeak * 0.65 + noise + cloth_rub) * env
        
    write_wav(filename, samples)

def generate_floor_creak_deep(filename):
    duration = 1.3
    n_samples = int(duration * SAMPLE_RATE)
    samples = [0.0] * n_samples
    
    # Deep resonant wooden strain groan
    random.seed(42)
    for i in range(n_samples):
        t = i / SAMPLE_RATE
        # Swelling and releasing envelope
        env = (math.sin(t * math.pi / duration) ** 1.5)
        
        # Creak pitch drops slightly as plank settles (85Hz down to 68Hz)
        base_freq = 88.0 - 18.0 * (t / duration)
        
        # Wood strain jitter (micro-slips)
        jitter = math.sin(t * 65.0 + math.sin(t * 180.0) * 4.0) * 12.0
        inst_freq = base_freq + jitter
        
        phase = 2.0 * math.pi * inst_freq * t
        # Oak resonance harmonics
        tone = (
            math.sin(phase) * 0.5 +
            math.sin(phase * 2.0) * 0.35 +
            math.sin(phase * 3.0) * 0.25 +
            math.sin(phase * 4.0) * 0.15 +
            math.sin(phase * 5.0) * 0.08
        )
        
        # Dry wood splinter friction
        wood_friction = 0.0
        if math.sin(t * 40.0) > 0.4:
            wood_friction = (random.random() * 2.0 - 1.0) * 0.25
            
        samples[i] = (tone + wood_friction) * env
        
    write_wav(filename, samples)

def generate_tool_rattle(filename):
    duration = 0.8
    n_samples = int(duration * SAMPLE_RATE)
    samples = [0.0] * n_samples
    
    # Sequence of jittery metallic/wood clatters
    clicks = [0.05, 0.12, 0.18, 0.23, 0.27, 0.31, 0.36, 0.42, 0.49, 0.58, 0.66]
    for c_time in clicks:
        c_idx = int(c_time * SAMPLE_RATE)
        # Random frequency for each impact
        f1 = random.uniform(900.0, 1600.0)
        f2 = random.uniform(2200.0, 3600.0)
        imp_dur = random.uniform(0.04, 0.08)
        imp_samples = int(imp_dur * SAMPLE_RATE)
        for j in range(imp_samples):
            if c_idx + j < n_samples:
                jt = j / SAMPLE_RATE
                decay = math.exp(-jt * 55.0)
                imp_tone = (math.sin(2.0 * math.pi * f1 * jt) * 0.6 + math.sin(2.0 * math.pi * f2 * jt) * 0.4)
                samples[c_idx + j] += imp_tone * decay * random.uniform(0.4, 0.9)
                
    # Add subtle low-end table vibration
    for i in range(n_samples):
        t = i / SAMPLE_RATE
        env = math.exp(-t * 3.5)
        table_hum = math.sin(2.0 * math.pi * 95.0 * t) * 0.15 * env
        samples[i] = (samples[i] + table_hum)
        
    write_wav(filename, samples)

if __name__ == "__main__":
    generate_mirror_wipe("Assets/Audio/mirror_wipe.wav")
    generate_floor_creak_deep("Assets/Audio/floor_creak_deep.wav")
    generate_tool_rattle("Assets/Audio/tool_rattle.wav")
    print("All v1.9.0 audio generated successfully.")
