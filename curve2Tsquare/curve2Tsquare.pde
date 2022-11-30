// Author: Lorenzo Salmina (lorenzo.salmina@outlook.com)
// Date: 09/November/2022
//---------------------------------------------------
// input curve file name
String input_file = "data/input_file_4.BMP";
//---------------------------------------------------
import processing.pdf.*;
// configuration file
JSONObject config_file;
// size of the center square 
int size_first_square; 
// number of step from the center square 
int nb_iter; 
// number of columns of the grid 
int grid_w; 
// number of row of the grid 
int grid_h;
// true if you want draw the curve
Boolean draw_curve = true;

float Min_size = 1;
ArrayList<Grid_cell> grid_elements  = new ArrayList<Grid_cell>();
int grid_size; 
int img_w; 
int img_h; 
PImage curve;

void setup() 
{
 
  //!! change sizes according to the generator 
  size(2340, 1755, PDF, "../output/out.pdf");
  rectMode(CENTER);
  background(255);
  
  
  config_file = loadJSONObject("data/config_file.json");
  size_first_square = config_file.getInt("size_center_square");
  nb_iter=config_file.getInt("nb_iter"); 
  grid_w=config_file.getInt("grid_w"); 
  grid_h=config_file.getInt("grid_h");
  img_w = config_file.getInt("img_w");
  img_h = config_file.getInt("img_h");
  grid_size = config_file.getInt("grid_size");
  draw_curve =config_file.getBoolean("draw_curve");
  
  curve = loadImage(input_file);
  curve.loadPixels();
  
  if(draw_curve == true){
    noStroke();
    for (int x=0; x < img_w; x++){
      for (int y=0; y < img_h; y++){
        int i = x + y*width;
        float colr = red(curve.pixels[i]);
        if(colr == 255){
          fill(255);
        }else{
          fill(0);
        }
        rect(x,y,1,1);
      }   
    }
  }
  for (int x=int(grid_size/2); x <= img_w-int(grid_size/2); x=x+grid_size){
    for (int y=int(grid_size/2); y <= img_h-int(grid_size/2); y=y+grid_size){
      Grid_cell G = new Grid_cell (y, x,  grid_size,  nb_iter, img_w, img_h ); 
      grid_elements.add(G);
    }
  }
  noLoop();
}

void draw() { 
  for(Grid_cell G :grid_elements){
    G.make_Tsquare();
    G.get_starts(curve);
    G.draw_curve();
  }
  exit();
}

class Grid_cell {  
  float ypos;
  float xpos; 
  float size;
  float iter;
  int img_width;
  int img_hight;
  ArrayList<Square> child_collection = new ArrayList<Square>();
  ArrayList<PVector> start_points = new ArrayList<PVector>();
  
  Grid_cell (float y, float x, float s, int i, int img_w, int img_h) {
    ypos = y;
    xpos = x;
    size = s;
    iter = i; 
    img_width = img_w;
    img_hight = img_h;
  } 
  
  void make_Tsquare(){
    Square S1 = new Square(0, 0, size_first_square, size_first_square, Min_size); 
    child_collection.add(S1);
    for (int i = 0; i < iter; i++) {
     ArrayList<Square> new_child_collection = new ArrayList<Square>();
     for (Square C : child_collection) {
       ArrayList<Square> childsS2 = C.make_childs(); 
       new_child_collection.addAll(childsS2); 
     }
     child_collection = new_child_collection;
    } 
  }
  
  void draw_family(Square C){
    float  s = C.size;
    while (s < size_first_square) {
      C.draw_square(0,ypos,xpos);
      C = C.parent;
      s = C.size;
    }
    C.draw_square(0,ypos,xpos);
  }
  
  void get_starts(PImage curve){
    float sh = size/2; 
    //L to R
    int y_top = int(ypos - sh);
    int y_bottom = int(ypos - sh) + int(size)-1;
    for (int x = int(xpos - sh); x < int(xpos - sh) + int(size); x++){
      float colr_top = curve.get(x, y_top);
      if(!(colr_top == -1)){
        start_points.add(new PVector(x-xpos, y_top-ypos));
      }
      float colr_bottom = curve.get(x, y_bottom);
      if(!(colr_bottom == -1)){
        start_points.add(new PVector(x-xpos, y_bottom-ypos));
      }
    }
    //top to bottom 
    int x_top = int(xpos - sh) + int(size)-1;
    int x_bottom = int(xpos - sh);
    for(int y = int(ypos - sh); y < int(ypos - sh) + int(size); y++){
      float colr_top = curve.get(x_top, y);
      if(!(colr_top == -1)){
        start_points.add(new PVector(x_top-xpos, y-ypos));
      }
      float colr_bottom = curve.get(x_bottom, y);
      if(!(colr_bottom == -1)){
        start_points.add(new PVector(x_bottom-xpos, y-ypos));
      } 
    }
  }
  
  void draw_curve(){
    for (PVector start : start_points) {
      float min_dist = width;
      Square start_child = child_collection.get(0);
      for(Square c : child_collection){
        float dist = c.pos.dist(start);
        if(min_dist > dist){
          start_child = c; 
          min_dist = dist;
        }
      }
      this.draw_family(start_child);
    }
    
  }
  void draw_childs(){
    for(Square c : child_collection){
      noStroke();
      fill(255,100,100);
      pushMatrix();
      translate(xpos, ypos);
      square(c.pos.x,c.pos.y,10);
      fill(100,255,100);
      square(start_points.get(0).x - xpos, start_points.get(0).y - ypos,10);
      popMatrix();
    }
  }
}
  
class Square {
  PVector pos;
  float size;
  float y_p_corner;
  float x_p_corner;
  float max_size; 
  float min_size; 
  Square parent; 
  ArrayList<Square> childs = new ArrayList<Square>();
  ArrayList<FloatList> free_centers = new ArrayList<FloatList>();
  ArrayList<FloatList> parent_corners = new ArrayList<FloatList>();
  Square (float y, float x, float s, float maxs, float mins ) {  
    pos = new PVector(x, y);
    size = s;
    max_size = maxs;
    min_size = mins;
    if (size == max_size){
      float new_s = size/2;
      //BR
      FloatList cord1  = new FloatList();
      cord1.append(pos.y+new_s+new_s/2);
      cord1.append(pos.x+new_s+new_s/2);
      FloatList pcord1  = new FloatList();
      pcord1.append(pos.y+new_s);
      pcord1.append(pos.x+new_s);
      //TL
      FloatList cord2  = new FloatList();
      cord2.append(pos.y-new_s-new_s/2);
      cord2.append(pos.x-new_s-new_s/2);
      FloatList pcord2  = new FloatList();
      pcord2.append(pos.y-new_s);
      pcord2.append(pos.x-new_s);
      //TR
      FloatList cord3  = new FloatList();
      cord3.append(pos.y-new_s-new_s/2);
      cord3.append(pos.x+new_s+new_s/2);
      FloatList pcord3  = new FloatList();
      pcord3.append(pos.y-new_s);
      pcord3.append(pos.x+new_s);
      //BL
      FloatList cord4  = new FloatList();
      cord4.append(pos.y+new_s+new_s/2);
      cord4.append(pos.x-new_s-new_s/2);
      FloatList pcord4  = new FloatList();
      pcord4.append(pos.y+new_s);
      pcord4.append(pos.x-new_s); 
      free_centers.add(cord1);
      free_centers.add(cord2);
      free_centers.add(cord3);
      free_centers.add(cord4);
      parent_corners.add(pcord1);
      parent_corners.add(pcord2);
      parent_corners.add(pcord3);
      parent_corners.add(pcord4);
    }
  } 
  
  void set_parent(Square p, FloatList corner_p){
    parent = p;
    y_p_corner = corner_p.get(0);
    x_p_corner = corner_p.get(1);
  }
  
  void set_free_corners(){
    float new_s = size/2;
    //BR
    FloatList cord1  = new FloatList();
    cord1.append(pos.y+new_s+new_s/2);
    cord1.append(pos.x+new_s+new_s/2);
    FloatList pcord1  = new FloatList();
    pcord1.append(pos.y+new_s);
    pcord1.append(pos.x+new_s);
    //TL
    FloatList cord2  = new FloatList();
    cord2.append(pos.y-new_s-new_s/2);
    cord2.append(pos.x-new_s-new_s/2);
    FloatList pcord2  = new FloatList();
    pcord2.append(pos.y-new_s);
    pcord2.append(pos.x-new_s);
    //TR
    FloatList cord3  = new FloatList();
    cord3.append(pos.y-new_s-new_s/2);
    cord3.append(pos.x+new_s+new_s/2);
    FloatList pcord3  = new FloatList();
    pcord3.append(pos.y-new_s);
    pcord3.append(pos.x+new_s);
    //BL
    FloatList cord4  = new FloatList();
    cord4.append(pos.y+new_s+new_s/2);
    cord4.append(pos.x-new_s-new_s/2);
    FloatList pcord4  = new FloatList();
    pcord4.append(pos.y+new_s);
    pcord4.append(pos.x-new_s);
    ArrayList<FloatList> FC = new ArrayList<FloatList>();
    ArrayList<FloatList> PC = new ArrayList<FloatList>();
    FC.add(cord1);
    FC.add(cord2);
    FC.add(cord3);
    FC.add(cord4); 
    PC.add(pcord1);
    PC.add(pcord2);
    PC.add(pcord3);
    PC.add(pcord4);
    for (int i = 0; i < PC.size(); i++) {
      FloatList cord = PC.get(i);
      if (!(cord.get(0)==y_p_corner && cord.get(1)==x_p_corner)){
        free_centers.add(FC.get(i));
        parent_corners.add(PC.get(i));
      }
    }
  }
  ArrayList<Square> make_childs(){
    for (int i = 0; i < free_centers.size(); i++) {
      FloatList cord = free_centers.get(i);
      float s = size/2;
      float y_ = cord.get(0);
      float x_ = cord.get(1);
      Square sq = new Square(y_, x_, s, max_size, min_size);
      FloatList p_corn = parent_corners.get(i);
      sq.set_parent(this, p_corn);
      sq.set_free_corners();
      childs.add(sq);
    }
    return childs;
  }
  void draw_square(int f, float yoff, float xoff) { 
    fill(f);
    noStroke();
    pushMatrix();
    translate(xoff, yoff);  
    square(pos.x, pos.y, size);
    popMatrix(); 
  } 
  
}
