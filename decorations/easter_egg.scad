// Easter Egg - Two-Color Design for Bambu Studio
// Export two STLs: one with part="body", one with part="pattern"
//   openscad -o easter_egg_body.stl -D 'part="body"' easter_egg.scad
//   openscad -o easter_egg_pattern.stl -D 'part="pattern"' easter_egg.scad
// Import BOTH STLs into Bambu Studio -> assigns each to a different filament.
//
// NOTE: Both parts together form one solid egg. The pattern is a surface-depth
// inlay (not a hole). Body + pattern = complete egg with no gaps.

// === Parameters ===
egg_height = 50;          // Total egg height in mm
egg_radius = 17;          // Max radius at widest point
egg_pointy = 1.15;        // >1 makes top pointier (egg-like), 1.0 = ellipsoid
band_count = 5;           // Number of zigzag bands
band_width = 2.0;         // Width (height) of each band in mm
zigzag_teeth = 12;        // Number of zigzag points per band
zigzag_amplitude = 2.0;   // How pointy the zigzags are in mm
pattern_depth = 1.5;      // How deep the color-2 inlay goes from the surface
star_points = 5;          // Points on the top star
star_radius = 6;          // Outer radius of the top star
flat_bottom = 1.5;        // Flat cut at bottom for bed adhesion
fn = 120;                 // Resolution

// Which part to render: "body", "pattern", or "both" (preview only)
part = "both";

// === Egg shape using rotate_extrude of a computed profile ===
// Uses a superellipse-like profile: wider at bottom, narrower at top.
// The egg sits with its base at z=0 and top at z=egg_height.
module egg_shape() {
    // Profile points: half-cross-section of egg in XZ plane
    // We sample from bottom (z=0) to top (z=egg_height)
    steps = 100;
    profile_pts = [
        [0, 0],  // center bottom
        for (i = [0 : steps])
            let(
                t = i / steps,                      // 0..1 from bottom to top
                z = t * egg_height,
                // Sine-based radius: 0 at bottom, max in lower-middle, 0 at top
                // Shift the peak downward for egg shape
                angle = t * 180,
                base_r = sin(angle),
                // Make top half narrower by compressing it
                squish = (t > 0.5) ? pow(1 - (t - 0.5) * 2, 1/egg_pointy) * 2 * (1 - 0.5) : 1,
                r = (t <= 0.5) ?
                    egg_radius * sin(t * 180) :
                    egg_radius * sin(0.5 * 180) * pow(1 - (t - 0.5) / 0.5, 1/egg_pointy)
                        * (1 + 0.0) // placeholder for tweaking
            )
            [max(r, 0), z],
        [0, egg_height]  // center top
    ];

    difference() {
        rotate_extrude($fn = fn)
            polygon(profile_pts);
        // Flat bottom cut for bed adhesion
        translate([0, 0, -50])
            cube([100, 100, 50 + flat_bottom], center=true);
    }
}

// === Shrunken egg (inner boundary - pattern never goes deeper than this) ===
// Uniform inward offset approximated by scaling down from centroid
module egg_inner() {
    // Scale uniformly inward by pattern_depth from all surfaces
    // We scale relative to the egg center
    translate([0, 0, egg_height/2])
        scale([
            (egg_radius - pattern_depth) / egg_radius,
            (egg_radius - pattern_depth) / egg_radius,
            (egg_height/2 - pattern_depth) / (egg_height/2)
        ])
        translate([0, 0, -egg_height/2])
            egg_shape();
}

// === Outer shell only (the region where patterns live) ===
module egg_shell() {
    difference() {
        egg_shape();
        egg_inner();
    }
}

// === Zigzag band ring ===
// Creates a zigzag-edged slab at a given Z height, extending radially outward
module zigzag_band(z_pos, width, teeth, amplitude) {
    r_big = egg_radius * 2;  // Oversized radius, will be clipped by egg intersection
    union() {
        for (i = [0 : teeth - 1]) {
            angle1 = i * 360 / teeth;
            angle2 = (i + 0.5) * 360 / teeth;
            angle3 = (i + 1) * 360 / teeth;

            // Upward-pointing tooth
            hull() {
                rotate([0, 0, angle1])
                    translate([0, 0, z_pos - width/2])
                        cube([r_big, 0.01, 0.01], center=true);
                rotate([0, 0, angle2])
                    translate([0, 0, z_pos + width/2 + amplitude])
                        cube([r_big, 0.01, 0.01], center=true);
                rotate([0, 0, angle3])
                    translate([0, 0, z_pos - width/2])
                        cube([r_big, 0.01, 0.01], center=true);
            }
            // Downward-pointing tooth
            hull() {
                rotate([0, 0, angle1])
                    translate([0, 0, z_pos + width/2])
                        cube([r_big, 0.01, 0.01], center=true);
                rotate([0, 0, angle2])
                    translate([0, 0, z_pos - width/2 - amplitude])
                        cube([r_big, 0.01, 0.01], center=true);
                rotate([0, 0, angle3])
                    translate([0, 0, z_pos + width/2])
                        cube([r_big, 0.01, 0.01], center=true);
            }
        }
    }
}

// === All bands combined ===
module all_bands() {
    spacing = egg_height / (band_count + 1);
    for (b = [1 : band_count]) {
        z = b * spacing;
        zigzag_band(z, band_width, zigzag_teeth, zigzag_amplitude);
    }
}

// === Star on top ===
module star_2d(points, outer_r, inner_r) {
    polygon([
        for (i = [0 : 2 * points - 1])
            let(angle = i * 180 / points - 90,
                r = (i % 2 == 0) ? outer_r : inner_r)
            [r * cos(angle), r * sin(angle)]
    ]);
}

module top_star() {
    // Star extruded downward from the top of the egg
    translate([0, 0, egg_height - pattern_depth * 2])
        linear_extrude(height = pattern_depth * 3)
            star_2d(star_points, star_radius, star_radius * 0.4);
}

// === Pattern volume: bands + star, clipped to egg shell only ===
// This is the second-color part. It occupies only the outer shell of the egg,
// so it never creates holes - the inner egg remains solid (first color).
module pattern_volume() {
    intersection() {
        // Clip everything to the outer shell region
        egg_shell();
        // The decorative shapes (oversized, will be trimmed)
        union() {
            all_bands();
            top_star();
        }
    }
}

// === Final parts ===
// Body = full solid egg minus the pattern inlay regions
module body() {
    difference() {
        egg_shape();
        pattern_volume();
    }
}

// Pattern = just the inlay pieces (second color fills these exactly)
module pattern() {
    pattern_volume();
}

// === Render ===
if (part == "body") {
    body();
} else if (part == "pattern") {
    pattern();
} else {
    // Preview: show both parts in different colors side by side
    color("PaleGreen") body();
    color("Gold") pattern();
}
