# Godot Dithered Lighting Shaders

This is a small demo project of some custom lighting shaders used in my games [A Windy Day in '89](https://pefeper.itch.io/a-windy-day-in-89) and [Combo Chess](https://pefeper.itch.io/combo-chess). Please note that these shaders are not intended for production use yet, and contain bugs.

The shaders support both GLES2 and GLES3. If you don't care about demo files, you can copy and paste the "godot_dithered_lighting/Dither Lighting" folder into your project.

![A render of a shrine using the lighting shaders in GLES3](/reference_images/shrine.png)

## How to Use:

1. Create a ShaderMaterial and assign the appropriate shader (the demo material uses the default shader, which assigns a single color to the surface, though there are others that support standalone textures or the palette texture).

2. Assign your palette texture to the shader under "Palette Tex" and configure the "Tex Size" according to the width of the texture (the demo material uses the Endesga 32 palette. The texture is a 32x1 png, each color being one pixel. The shaders expect the palette texture to be formatted like this).

3. Assign the matrix texture to "Dithering Matrix Tex", there is an included 8x8 Bayer matrix texture included in the "Dither Lighting" folder, however any square matrix will work. Assign "Dithering Matrix Size" according to the width of the matrix (so for the included 8x8 texture, this would be the default value of 8.0).

4. Assign the Color or Surface texture if applicable.

5. Assign the material to an object.

6. In the scene, add a light and assign the corresponding script to it (located in the "Dither Lighting" folder with the syntax "Index [Light Type].gd"). Set "Palette Size" to the same value you assigned to the materials "Tex Size" property. Set the index to the index of the color you want to use in the palette (the range is from 0 - (Palette Size - 1)).

7. You should now have the dithered lighting effect on your object!

## Known Issues:

Overlapping lights may not mix as expected (especially in GLES2).

Larger palettes may be difficult to assign light colors correctly.
