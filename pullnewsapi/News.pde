class News {
  int curPage = 0;
  int nPages;
  IntList wordIndices;
  ArrayList<Word> words;
  int curWordIdx = 0;

  String apiKey = "6ec2f36af8c54796a75d94335092fbd4";
  String url = "https://newsapi.org/v2/everything?";
  String query;

  News(String query) {
    this.query = query;
    JSONObject json = getNextPage();
    if (json == null) return;
    int numResults = json.getInt("totalResults");
    this.nPages = numResults / 100 + 1;
    processPage(json);
  }
  
  Word getNextWord() {
    if (curWordIdx > wordIndices.size()) {
      JSONObject next = getNextPage();
      if (next == null) return null;
      processPage(next);
    }
    return this.words.get(this.wordIndices.get(this.curWordIdx));
  }

  JSONObject getNextPage() {
    curPage++;
    if (curPage > this.nPages) return null;
    return loadJSONObject(this.url+this.query+"&pageSize=100&page=" + str(curPage) + "&apiKey="+this.apiKey);
  }
  
  void processPage(JSONObject page) {
    this.words = new ArrayList<Word>();
    this.wordIndices = new IntList();
    this.curWordIdx = 0;
    
    articles = page.getJSONArray("articles");
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
    curAuthor = article.isNull("author") ? "" : article.getString("author");
    curHeadline = splitTokens(article.getString("title"));
    for (int i = 0; i < curHeadline.length; i++) {
      words.add(new Word(curHeadline[i], random(0, width), random(0, height), curAuthor.equals("")));
    }
  }
}
