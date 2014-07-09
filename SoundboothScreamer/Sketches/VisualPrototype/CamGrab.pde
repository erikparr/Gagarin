
class CamGrab{

Capture cam;

void init() {

  String[] cameras = Capture.list();

  if (cameras.length == 0) {
    println("There are no cameras available for capture.");
    exit();
  } else {
    println("Available cameras:");
    for (int i = 0; i < cameras.length; i++) {
      println(cameras[i]);
    }

    // The camera can be initialized directly using an
    // element from the array returned by list():
    cam = new Capture(VisualPrototype.this, cameras[0]);
    cam.start();
  }
}

void update() {
  if (cam.available() == true) {
    cam.read();
  }
  image(cam, 0, 200,300,300);
  // The following does the same, and is faster when just drawing the image
  // without any additional resizing, transformations, or tint.
  //set(0, 0, cam);
}
}
