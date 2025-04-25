// Function to engrave text on a cube
module engraved_cube(size, char_array) {
    difference() {
        // Create the cube
        cube([size, size, size], center=true);

        // Engrave text on each side
        for (i = [0:5]) {
            if (i == 0) { // Front face
                engrave_text(char_array[i], size, [0, 0, size/2 + 0.1], [0, 0, 0]);
            } else if (i == 1) { // Back face
                engrave_text(char_array[i], size, [0, 0, -size/2 - 0.1], [0, 0, 0]);
            } else if (i == 2) { // Top face
                engrave_text(char_array[i], size, [0, size/2 + 0.1, 0], [90, 0, 180]);
            } else if (i == 3) { // Bottom face
                engrave_text(char_array[i], size, [0, -size/2 - 0.1, 0], [90, 180, 180]);
            } else if (i == 4) { // Right face
                engrave_text(char_array[i], size, [size/2 + 0.1, 0, 0], [90, 0, 90]);
            } else if (i == 5) { // Left face
                engrave_text(char_array[i], size, [-size/2 - 0.1, 0, 0], [90, 0, -90]);
            }
        }
    }
}

// Helper module to engrave text with appropriate translation and rotation
module engrave_text(text, size, translate_vec, rotate_vec) {
    translate(translate_vec)
    rotate(rotate_vec)
    linear_extrude(height=4, center=true) // Thickness of the engraving
        text(text, size=size/3, halign="center", valign="center", $fn=100);
}

// Define the size of the cube and the array of characters
cube_size = 50; // Size of the cube in mm
characters = ["Á", "B", "č", "D", "É", "F"]; // Array of characters to engrave

// Call the module to create the cube
engraved_cube(cube_size, characters);
