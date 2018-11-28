class News {
  int curPage = 0;
  int nPages;
  IntList wordIndices;
  ArrayList<Word> words;
  int curWordIdx = 0;

  String apiKey = "6ec2f36af8c54796a75d94335092fbd4";
  String url = "https://newsapi.org/v2/top-headlines?";
  String query;
  
  boolean errFlag = false;

  News(String query) {
    this.query = query;
    JSONObject json = getNextPage();
    if (json == null) {
      this.errFlag = true;
      return;
    }
    int numResults = json.getInt("totalResults");
    this.nPages = numResults / 100 + 1;
    processPage(json);
  }
  
  boolean error() {return errFlag;}
  
  Word getNextWord() {
    if (curWordIdx >= wordIndices.size()) {
      JSONObject next = getNextPage();
      if (next == null) return null;
      processPage(next);
    }
    Word word = this.words.get(this.wordIndices.get(this.curWordIdx));
    curWordIdx++;
    return word;
  }

  JSONObject getNextPage() {
    curPage++;
    print("Getting page " + curPage);
    if (curPage > 1 && curPage > this.nPages) return null;
    return loadJSONObject(this.url+this.query+"&pageSize=100&page=" + str(curPage) + "&apiKey="+this.apiKey);
  }
  
  void processPage(JSONObject page) {
    this.words = new ArrayList<Word>();
    this.wordIndices = new IntList();
    this.curWordIdx = 0;
    
    JSONArray articles = page.getJSONArray("articles");
    for(int i = 0; i < articles.size(); i++) {
      JSONObject article = articles.getJSONObject(i);
      processArticle(article);
    }
    for(int i = 0; i < words.size(); i++) {
      wordIndices.append(i);
    }
    wordIndices.shuffle();
  }
  
  void processArticle(JSONObject article) {
    String curAuthor = article.isNull("author") ? "" : article.getString("author");
    String[] curHeadline = splitTokens(article.getString("title"));
    for (int i = 0; i < curHeadline.length; i++) {
      words.add(new Word(curHeadline[i], random(0, width), random(0, height), curAuthor.equals("")));
    }
  }
}
