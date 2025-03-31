module cross_with_number(num, size, thickness, text_thickness) {
    // Horizontal rectangle
    translate([-size/2 + size/16, -thickness/2, 0])
        cube([size, thickness*2, thickness]);
    
    // Vertical rectangle
    translate([-thickness/2, -size/2 + size/16, 0])
        cube([thickness*2, size, thickness]);

    // Number
    translate([size/8 - 1, size/8 - 1, thickness])
        scale([0.1, 0.1, 0.1])
            linear_extrude(height = text_thickness)
                text(str(num), size = size*4, valign = "center", halign = "center", $fn=100);
}


// Layout of crosses with numbers dynamically
num_positions = 20; // Total positions
num_range = 10; // Numbers from 1 to 10
distance = 25; // Distance between each position

// Generate positions and place crosses
for (i = [0 : num_positions - 1]) {
    x = (i % 5) * distance; // Modulo for x position to wrap every 5 crosses
    y = (i / 5) * distance; // Division for y position to move down every 5 crosses
    number = i % num_range + 1; // Assign numbers from 1 to 10, repeating each twice

    translate([x, y, 0])
        cross_with_number(number, 20, 3, 25);
}
