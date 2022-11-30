// Author: Lorenzo Salmina (lorenzo.salmina@outlook.com)
// Date: 09/November/2022
//---------------------------------------------------
// choose your parameters 
// size of the center square 
int size_center_square = 40;
// number of step from the center square 
int nb_iter = 5; 
// number of columns of the grid 
int grid_w =  20; 
// number of row of the grid 
int grid_h =  15; 
// true if you want draw the curve
Boolean draw_curve = false;
//---------------------------------------------------
JSONObject config_file;

void setup() {
  
  size(500,170);
  config_file = new JSONObject();

  float incr = size_center_square/2; 
  float gs = size_center_square; 
  for(int i = 0; i < nb_iter; i++ ){
    gs  = gs + incr*2; 
    incr = incr/2;
  }
  int img_w = int(gs)*grid_w; 
  int img_h = int(gs)*grid_h; 

  println("img dimensions:" ,img_w,"x", img_h );

  config_file.setInt("size_center_square", size_center_square);
  config_file.setInt("nb_iter", nb_iter);
  config_file.setInt("grid_w", grid_w);
  config_file.setInt("grid_h", grid_h);
  config_file.setInt("img_w", img_w);
  config_file.setInt("img_h", img_h);
  config_file.setInt("grid_size", int(gs));
  config_file.setBoolean("draw_curve", draw_curve);
  
  
  textSize(15);
  fill(96, 96, 696);
  text("Configuration file generated.", 40, 30);
  text("Size of the input image file (pixels):", 40, 60);
  text(img_w, 40, 90);
  text("X", 120, 90);
  text(img_h, 170, 90);
  text("Run the curve2Tsquare.pde script.", 40, 120);
  text("Change the canvas size to the above dimensions.", 40, 150);
 
  saveJSONObject(config_file, "../curve2Tsquare/data/config_file.json");
}
