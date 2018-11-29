class Word {
  String word;
  float x, y;
  int count;
  int null_count;
  boolean author_null;
  int colorIdx = -1;

  Word(String word, float x, float y, boolean author_null) {
    this.word = word;
    this.x = x;
    this.y = y;
    this.count = author_null ? 0 : 1;
    this.null_count = author_null ? 1 : 0;
    this.author_null = author_null;
  }

  void increment(boolean author_null) {
    if (author_null) {
      this.null_count++;
    } else {
      this.count++;
    }
  }

  boolean authorIsNull() {
    return author_null;
  }

  String getWord() {
    return this.word;
  }
  int getNullCount() {
    return this.null_count;
  }
  float getX() {
    return this.x;
  }
  float getY() {
    return this.y;
  }

  color getColor() {
    return color(map(count, 0, 20, 255, 0));
    //if (this.colorIdx == -1) this.colorIdx = int(random(3));
    //if (colorIdx == 0) {
    //  return color(map(null_count + count, 0, 20, 255, 0), 
    //    255, 
    //    map(null_count, 0, 20, 255, 0));
    //} else if (colorIdx == 1) {
    //  return color(map(null_count + count, 0, 20, 255, 0), 
    //    map(null_count, 0, 20, 255, 0), 
    //    255);
    //}
    //return color(255, 
    //  map(null_count, 0, 20, 255, 0), 
    //  map(null_count, 0, 20, 255, 0));
  }

  boolean anyAuthorNull() { 
    return this.null_count > 0;
  }
}
