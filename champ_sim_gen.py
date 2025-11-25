import random

def bin16(x):
    return format(x & 0xffff, '016b')

lines=[]

# 1. Loop-heavy pattern (200 lines)
for i in range(200):
    pc = 0x1000 + (i % 16) * 4
    taken = 1 if (i % 10) != 9 else 0   # loop exit every 10th branch
    lines.append(f"{bin16(pc)}_{taken}")

# 2. Alternating pattern (200 lines)
for i in range(200):
    pc = 0x2000 + (i % 32) * 4
    taken = i % 2
    lines.append(f"{bin16(pc)}_{taken}")

# 3. Strong bias (200 lines)
for i in range(200):
    pc = 0x3000 + (i % 64) * 4
    taken = 1 if random.random() < 0.85 else 0
    lines.append(f"{bin16(pc)}_{taken}")

# 4. Random bursts (200 lines)
for i in range(200):
    pc = 0x4000 + random.randint(0, 255) * 4
    taken = random.randint(0, 1)
    lines.append(f"{bin16(pc)}_{taken}")

# 5. Correlated branches (200 lines)
for i in range(200):
    pc = 0x5000 + (i % 32) * 4
    base_taken = 1 if (i // 4) % 2 == 0 else 0
    taken = base_taken
    lines.append(f"{bin16(pc)}_{taken}")

# Write output file
with open("trace_1000.mem", "w") as f:
    for line in lines:
        f.write(line + "\n")

print("Generated 1000-branch trace: trace_1000.mem")