// Spirit Island - Beast/Serpent Token (Two-Color for Bambu Studio AMS)
// Yellow flat pedestal base + black coiled snake on top.
//
// Export:
//   openscad -o spirit_island_beast_base.stl -D 'part="base"' spirit_island_beast.scad
//   openscad -o spirit_island_beast_snake.stl -D 'part="snake"' spirit_island_beast.scad
//
// Bambu Studio: Import both STLs, Assemble them, assign yellow to base, black to snake.

// === Parameters ===
token_diameter = 25;       // Overall token diameter in mm
base_height = 2.0;         // Yellow pedestal thickness (flat disc)
snake_height = 1.5;        // Black snake raised height on top
snake_width = 2.5;         // Width of the snake body
spiral_turns = 2.5;        // Number of spiral coils
spiral_steps = 200;        // Smoothness of spiral curve
head_size = 3.8;           // Snake head diameter
eye_size = 1.3;            // Eye dot diameter
eye_depth = 1.0;           // Eye inset (base color shows through)
chamfer = 0.4;             // Small bottom edge chamfer for clean print
fn = 80;                   // Resolution

// Which part: "base", "snake", or "both" (preview)
part = "both";

// === Base pedestal - simple flat disc with chamfered bottom edge ===
module base_shape() {
    r = token_diameter / 2;
    // Flat cylinder with a small chamfer on the bottom edge
    union() {
        // Main body (above chamfer)
        translate([0, 0, chamfer])
            cylinder(r = r, h = base_height - chamfer, $fn = fn);
        // Chamfer ring at bottom
        cylinder(r1 = r - chamfer, r2 = r, h = chamfer, $fn = fn);
    }
}

// === Spiral snake body ===
// Archimedean spiral from center outward, built from hulled cylinders
module spiral_body() {
    max_r = token_diameter/2 - snake_width/2 - 1.0;  // Keep inside base edge
    min_r = 1.8;  // Tight center coil

    for (i = [0 : spiral_steps - 1]) {
        t1 = i / spiral_steps;
        t2 = (i + 1) / spiral_steps;

        angle1 = t1 * spiral_turns * 360;
        angle2 = t2 * spiral_turns * 360;

        r1 = min_r + (max_r - min_r) * t1;
        r2 = min_r + (max_r - min_r) * t2;

        x1 = r1 * cos(angle1);
        y1 = r1 * sin(angle1);
        x2 = r2 * cos(angle2);
        y2 = r2 * sin(angle2);

        hull() {
            translate([x1, y1, base_height])
                cylinder(r = snake_width/2, h = snake_height, $fn = 20);
            translate([x2, y2, base_height])
                cylinder(r = snake_width/2, h = snake_height, $fn = 20);
        }
    }
}

// === Snake head - larger blob at the outer end of spiral ===
module snake_head() {
    end_angle = spiral_turns * 360;
    max_r = token_diameter/2 - snake_width/2 - 1.0;
    ex = max_r * cos(end_angle);
    ey = max_r * sin(end_angle);

    // Slightly elongated head along the spiral tangent direction
    tangent_angle = end_angle + 90;
    translate([ex, ey, base_height])
        scale([1.2, 1, 1])
            rotate([0, 0, tangent_angle])
                cylinder(r = head_size/2, h = snake_height, $fn = 30);
}

// === Eye hole (cut from snake head, base color shows through) ===
module snake_eye() {
    end_angle = spiral_turns * 360;
    max_r = token_diameter/2 - snake_width/2 - 1.0;
    ex = max_r * cos(end_angle);
    ey = max_r * sin(end_angle);

    // Eye positioned toward the outer edge of the head
    eye_dir = end_angle + 30;
    eye_r = head_size * 0.2;
    eye_x = ex + eye_r * cos(eye_dir);
    eye_y = ey + eye_r * sin(eye_dir);

    translate([eye_x, eye_y, base_height + snake_height - eye_depth])
        cylinder(r = eye_size/2, h = eye_depth + 0.1, $fn = 20);
}

// === Combined snake (spiral + head - eye), clipped to base outline ===
module snake() {
    difference() {
        intersection() {
            union() {
                spiral_body();
                snake_head();
            }
            // Clip to base diameter so nothing overhangs
            translate([0, 0, base_height - 0.01])
                cylinder(r = token_diameter/2 - 0.3, h = snake_height + 0.1, $fn = fn);
        }
        snake_eye();
    }
}

// === Base (flat disc, no recess needed - snake sits on top) ===
module base() {
    base_shape();
}

// === Render ===
if (part == "base") {
    base();
} else if (part == "snake") {
    snake();
} else {
    // Preview both colors
    color("Gold") base();
    color("DarkSlateGray") snake();
}
