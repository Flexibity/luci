/* @pjs preload="/luci-static/flexibity/girlwithheadphone4.svg,/luci-static/flexibity/sport_man.svg,/luci-static/flexibity/teacher.svg,/luci-static/flexibity/curius_face.svg"; */

PImage img;

void setup() {
  size( 640, 480 );
  frameRate( 5 );
}

void draw()
{
  background(255, 255, 255);
  img = loadImage("/luci-static/flexibity/girlwithheadphone4.svg");
  image(img, 0, 0);
  img = loadImage("/luci-static/flexibity/teacher.svg");
  image(img, 100, 0);
  img = loadImage("/luci-static/flexibity/sport_man.svg");
  image(img, 350, 0);
  img = loadImage("/luci-static/flexibity/curius_face.svg");
  image(img, 550, 0);
}
