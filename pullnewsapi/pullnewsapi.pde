import guru.ttslib.*;
import processing.video.*;
import oscP5.*;

// OSC Related
OscP5 oscP5;

// TTS Related
TTS tts;

// News API: Pulling JSON
News news;
HashMap<String, Word> words;

// Graphics related
PGraphics canvas;
boolean found;
Capture cam;

void setup() {
  // graphics
  //fullScreen();
  size(680, 680);
  background(255);
  fill(0);
  PFont font = createFont("PrestigeEliteStd-Bd", 20);
  textFont(font);
  textAlign(LEFT, CENTER);

  // set up News API
  String query = "q=and&sortBy=popularity";
  news = new News(query);
  if (news.error()){
    print("news error");
    exit();
  }
  words = new HashMap<String, Word>();

  // Set up Face OSC
  oscP5 = new OscP5(this, 8338);
  oscP5.plug(this, "found", "/found");

  // Set up cameras
  String[] cameras = Capture.list();
  if (cameras.length == 0) {
    println("There are no cameras available for capture.");
    exit();
  } else {
    // The camera can be initialized directly using an 
    // element from the array returned by list():
    cam = new Capture(this, cameras[0]);
    cam.start();
  }

  // Set up voice
  tts = new TTS();
}

void draw() {
  // Get word to add
  Word word = news.getNextWord();
  if (word != null) {
    if (words.containsKey(word.getWord())) {
      words.get(word.getWord()).increment(word.authorIsNull());
    } else {
      words.put(word.getWord(), word);
    }
    if (found && word.authorIsNull()) tts.speak(word.getWord());
  }

  // draw
  if (found) {
    if (cam.available() == true) {
      cam.read();
    }
    image(cam, 0, 0, width, height);
  } else {
    background(255);
  }
  for (String i : words.keySet()) {
    Word w = words.get(i);
    if (found) {
      int x = int(w.getX() + textWidth(i) / 2);
      x = x >= width ? width - 1 : x;
      int y = int(w.getY());
      y = y >= height ? height - 1 : y;
      fill(color(get(x, y)));
      if (w.anyAuthorNull()) text(i, w.getX(), w.getY());
    } else {
      fill(w.getColor());
      text(i, w.getX(), w.getY());
    }
  }
}

public void found(int i) {
  // println("found: " + i); // 1 == found, 0 == not found
  found = i == 1;
}
