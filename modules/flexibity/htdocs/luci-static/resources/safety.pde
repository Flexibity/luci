int sizex = 600;
int sizey = 440;

void setup()
{
  size( sizex, sizey );
  frameRate( 5 );
}

void draw()
{
  int motion = frameCount;
  int water = frameCount;
  int smoke = frameCount;

  background(255, 255, 255);
  stroke(100, 100, 100);

  // draw a house plan
  fill(255, 255, 255);
  strokeWeight( 2 );
  rect(1, 1, sizex-1, sizey-1);
  line(400, 0, 400, sizey);
  line(400, 300, sizex, 300);
  line(2, 300, 2, 400); // front door
  line(150, 2, 250, 2); // window
  line(398, 180, 398, 280); // kitchen door
  line(398, 315, 398, 415); // toilet door

  strokeWeight( 5 );
  sensor(30, 300, color(0x80, 0xc0, 0x20), "Front door activity: 3%", "Battery: 90%");
  sensor(150, 30, color(0x80, 0xc0, 0x20), "Window activity: 5%", "Battery: 93%");
  sensor(450, 100, color(0x80, 0xc0, 0x20), "Kitchen smoke: 2%", "Battery: 90%");
  sensor(460, 170, color(0x80, 0xc0, 0x20), "Kitchen water: 0%", "Battery: 90%");
  sensor(450, 350, color(0xff, 0, 0), "Toilet water: 75%", "Battery: 10%");
}

void sensor(int x, int y, color c, String str1, String str2)
{
  fill(c);
  ellipse(x, y, 20, 20 );
  fill(0, 0, 0);
  text(str1, x+20, y+10);
  text(str2, x+20, y+25);
}
