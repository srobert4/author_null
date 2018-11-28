import guru.ttslib.*;
import processing.video.*;
import oscP5.*;

// OSC Related
OscP5 oscP5;

// TTS Related
TTS tts;

// News API: Pulling JSON
int pageSize = 100; // default 20, max 100
int numPages;
int curPage = 1;

// News API: Storing & tracking
JSONArray articles;
HashMap<String, Word> words;
int articleIndex;
int headlineIndex;
String curAuthor;
String[] curHeadline;

// Graphics related
PGraphics canvas;
boolean found;
Capture cam;

void setup() {
  // graphics
  fullScreen();
  background(255);
  fill(0);
  PFont font = createFont("PrestigeEliteStd-Bd", 20);
  textFont(font);
  textAlign(LEFT, CENTER);
  
  // set up News API
  String query = "q=and&sortBy=popularity&page=1&pageSize=" + str(pageSize);
  JSONObject json = loadJSONObject(url+query+"&apiKey="+apiKey);
  int numResults = json.getInt("totalResults");
  numPages = numResults / 100 + 1;

  articles = json.getJSONArray("articles");
  words = new HashMap<String, Word>();
  articleIndex = 0;
  JSONObject article = articles.getJSONObject(articleIndex);
  curAuthor = article.isNull("author") ? "" : article.getString("author");
  curHeadline = splitTokens(article.getString("title"));
  headlineIndex = 0;
  curPage++;

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
  if (curPage > numPages) return;
  if (articleIndex >= articles.size()) {
    getNextPage();
  }
  if (headlineIndex >= curHeadline.length) {
    articleIndex++;
    headlineIndex = 0;
    if (articleIndex < articles.size()) {
      JSONObject article = articles.getJSONObject(articleIndex);
      curAuthor = article.isNull("author") ? "" : article.getString("author");
      curHeadline = splitTokens(article.getString("title"));
    }
  }
  String word = curHeadline[headlineIndex];
  headlineIndex++;
  if (words.containsKey(word)) {
    words.get(word).increment(curAuthor.equals(""));
  } else {
    words.put(word, 
      new Word(word, random(0, width), random(0, height), curAuthor.equals("")));
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
    } else {
      fill(w.getColor());
    }
    text(i, w.getX(), w.getY());
  }
  tts.speak(curAuthor);
}


void getNextPage() {
  String query = "q=and&page=" + str(curPage) + "&pageSize=" + str(pageSize);
  curPage++;
  headlineIndex = 0;
  articleIndex = 0;
  JSONObject json = loadJSONObject(url+query+"&apiKey="+apiKey);
  articles = json.getJSONArray("articles");
  JSONObject article = articles.getJSONObject(articleIndex);

  curAuthor = article.isNull("author") ? "" : article.getString("author");
  curHeadline = splitTokens(article.getString("title"));
}

public void found(int i) {
  // println("found: " + i); // 1 == found, 0 == not found
  found = i == 1;
}
