import wave
import struct
import math
import random

sample_rate = 44100
duration = 2.2 # seconds
num_samples = int(sample_rate * duration)

samples = [0.0] * num_samples

# Seed random for determinism
random.seed(42)

# Generate a sequence of violent shutter rattle impacts and vibrations
impact_times = [0.05, 0.18, 0.32, 0.44, 0.58, 0.72, 0.85, 1.02, 1.15, 1.30, 1.48, 1.62, 1.78, 1.95]

for it in impact_times:
    start_idx = int(it * sample_rate)
    impact_amp = random.uniform(0.6, 0.95)
    # Impact frequencies: low wood resonance ~90-180 Hz, mid clatter ~300-600 Hz
    base_freq = random.uniform(110.0, 150.0)
    decay_rate = random.uniform(25.0, 45.0)
    
    impact_len = int(sample_rate * 0.3)
    for i in range(impact_len):
        idx = start_idx + i
        if idx >= num_samples:
            break
        t = i / sample_rate
        env = math.exp(-decay_rate * t)
        
        # Wood resonance (fundamental + octave + hollow rattle harmonics)
        s1 = math.sin(2.0 * math.pi * base_freq * t)
        s2 = math.sin(2.0 * math.pi * (base_freq * 2.3) * t) * 0.6
        s3 = math.sin(2.0 * math.pi * (base_freq * 4.1) * t) * 0.35
        # Wood snap noise
        snap = (random.random() * 2.0 - 1.0) * math.exp(-120.0 * t) * 0.5
        
        sig = (s1 + s2 + s3 + snap) * env * impact_amp
        samples[idx] += sig

# Continuous shutter vibration hum between impacts
for i in range(num_samples):
    t = i / sample_rate
    shutter_shake = math.sin(2.0 * math.pi * 38.0 * t) * 0.08
    # Subtle wind draft rattle
    jitter = (random.random() * 2.0 - 1.0) * 0.03
    samples[i] += shutter_shake + jitter

# Normalize to avoid clipping
max_amp = max(abs(s) for s in samples)
if max_amp > 0.0:
    gain = 0.88 / max_amp
    samples = [s * gain for s in samples]

# Write mono 16-bit PCM WAV
with wave.open("Assets/Audio/window_rattle.wav", "wb") as wav_file:
    wav_file.setnchannels(1)
    wav_file.setsampwidth(2)
    wav_file.setframerate(sample_rate)
    
    raw_data = bytearray()
    for s in samples:
        int_val = int(max(min(s, 1.0), -1.0) * 32767)
        raw_data.extend(struct.pack("<h", int_val))
    wav_file.writeframes(raw_data)

print("Generated Assets/Audio/window_rattle.wav successfully.")
