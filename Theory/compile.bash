pandoc --output out/result.pdf \
-H styles/preamble.tex \
--resource-path=.:media \
--verbose src/0.1.md src/0.2.md \
  src/1.0.md src/1.1.md src/1.2.md src/1.3.md \
  src/2.0.md src/2.1.md \
  src/3.0.md src/3.1.md src/3.2.md src/3.3.md \
  src/4.0.md src/4.1.md src/4.2.md \
  src/5.0.md \
  src/6.0.md src/6.1.md


#   pandoc --output out/quiz.pdf \
# -H styles/preamble.tex \
# --resource-path=.:media \
# --verbose quiz/quiz.md