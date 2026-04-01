// Parameters
height = 80;       // 80mm = 8cm height to reach GPU
width = 35;        // Width of the block
depth = 35;        // Depth of the block
rounding = 2;      // Optional: corner rounding radius

// Block with slightly rounded edges
module gpu_support() {
    minkowski() {
        cube([width - rounding, depth - rounding, height - rounding]);
        sphere(r=rounding);
    }
}

gpu_support();
