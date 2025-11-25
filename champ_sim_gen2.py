
import random

# ---------------------------------------------------------
# Utility function
# ---------------------------------------------------------

def bin16(x):
    """Convert integer to 16-bit binary string"""
    return format(x & 0xFFFF, '016b')

def make_record(pc, taken):
    """Return a string in <16-bit PC>_<taken> format"""
    return f"{bin16(pc)}_{taken}"


# ---------------------------------------------------------
# Branch pattern generators
# ---------------------------------------------------------

def gen_loops(count, base_ip):
    for i in range(count):
        pc = base_ip + (i % 16) * 4
        taken = 0 if (i % 10 == 9) else 1  # loop exit every 10th branch
        yield make_record(pc, taken)

def gen_alternating(count, base_ip):
    for i in range(count):
        pc = base_ip + (i % 32) * 4
        taken = i % 2
        yield make_record(pc, taken)

def gen_biased(count, base_ip, bias=0.85):
    for i in range(count):
        pc = base_ip + (i % 64) * 4
        taken = 1 if random.random() < bias else 0
        yield make_record(pc, taken)

def gen_random(count, base_ip):
    for _ in range(count):
        pc = base_ip + random.randint(0, 255) * 4
        taken = random.randint(0, 1)
        yield make_record(pc, taken)

def gen_correlated(count, base_ip):
    for i in range(count):
        pc = base_ip + (i % 32) * 4
        group = (i // 4) % 2
        taken = 1 if group == 0 else 0
        yield make_record(pc, taken)

def gen_indirect(count, base_ip):
    targets = [base_ip + 0x500, base_ip + 0x600, base_ip + 0x700]
    for i in range(count):
        pc = base_ip + (i % 16) * 4
        taken = 1
        yield make_record(pc, taken)


# ---------------------------------------------------------
# Generate full mixed trace
# ---------------------------------------------------------

def generate_trace(filename="mixed_trace_16bit.mem"):
    sections = [
        ("loops",       gen_loops,      200, 0x1000),
        ("alternating", gen_alternating,200, 0x2000),
        ("biased",      gen_biased,     200, 0x3000),
        ("random",      gen_random,     200, 0x4000),
        ("correlated",  gen_correlated, 200, 0x5000),
        ("indirect",    gen_indirect,   200, 0x6000),
    ]

    with open(filename, "w") as f:
        for name, gen, count, base in sections:
            print(f"Generating {count} {name} branches...")
            for line in gen(count, base):
                f.write(line + "\n")

    print(f"\nDone! Wrote mixed 16-bit PC trace to: {filename}")


# ---------------------------------------------------------
# Run
# ---------------------------------------------------------

if __name__ == "__main__":
    generate_trace()
