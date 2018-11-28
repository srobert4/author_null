class Word {
  String word;
  float x,y;
  int count;
  int null_count;
  
  Word(String word, float x, float y, boolean author_null) {
    this.word = word;
    this.x = x;
    this.y = y;
    this.count = author_null ? 0 : 1;
    this.null_count = author_null ? 1 : 0;
  }
  
  void increment(boolean author_null) {
    if (author_null) {
      this.null_count++;
    } else {
      this.count++;
    }
  }
  
  float getX() {return this.x;}
  float getY() {return this.y;}
  
  color getColor() {
    return color(map(count, 0, 20, 255, 0));
  }
}
