class Question {
  String _questionText = "";
  bool _questionAnswer = false;

  Question(String q, bool a) {
    _questionText = q;
    _questionAnswer = a;
  }

  String getQuestionText() {
    return _questionText;
  }

  bool getQuestionAnswer() {
    return _questionAnswer;
  }




}