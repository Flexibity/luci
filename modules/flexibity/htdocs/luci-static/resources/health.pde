/* @pjs preload="/luci-static/flexibity/girl.png,/luci-static/flexibity/boy.png,/luci-static/flexibity/lady.png,/luci-static/flexibity/face.png"; */

PImage img;

void setup() {
  size( 640, 480 );
  frameRate( 5 );
}

void draw()
{
  background(255, 255, 255);

  img = loadImage("/luci-static/flexibity/girl.png");
  image(img, 60, 200);
  health(60, 160, 75, 36.6);

  img = loadImage("/luci-static/flexibity/lady.png");
  image(img, 180, 80);
  health(260, 360, 60, 36.8);

  img = loadImage("/luci-static/flexibity/boy.png");
  image(img, 380, 160);
  health(420, 110, 95, 36.6);

  img = loadImage("/luci-static/flexibity/face.png");
  image(img, 520, 160);
  health(570, 290, 0, 0);
}

void health(int x, int y, float a, float t)
{
  String activity = "activity";
  String temp = "temp";
  String summary = "summary";
  bool problem = false;

  textAlign(CENTER);
  fill(0, 0, 0);

  if (a == 0) {
    activity = "N/A";
    fill(0, 0, 0);
  } else if (a < 50) {
    activity = "LOW";
    problem = true;
    fill(255, 0, 0);
  } else if (a < 75) {
    activity = "NORMAL";
    fill(0, 0, 255);
  } else if (a < 90) {
    activity = "GOOD";
    fill(0, 0, 255);
  } else {
    activity = "HIGH!";
    fill(0, 0, 255);
  }
  text("Activity: " + activity, x, y);

  fill(0, 0, 0);
  temp = String(t);
  if (temp == 0) {
    fill(0, 0, 0);
  } else if (temp < 36) {
    problem = true;
    fill(200, 128, 0);
  } else if (temp > 36.6) {
    problem = true;
    fill(255, 0, 0);
  } else {
    fill(0, 0, 255);
  }
  text("Temperature: " + temp, x, y+15);

  fill(0, 0, 0);
  if (t == 0 || a == 0) {
    fill(0, 0, 0);
    summary = "Too busy..."
  } else {
    if (problem) {
      summary = "See a doctor?";
      fill(255, 0, 0);
    } else {
      summary = "Ok";
      fill(0, 255, 0);
    }
  }
  text("Summary: " + summary, x, y+30);
}