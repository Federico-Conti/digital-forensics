pandoc --output out/result.pdf \
-H styles/preamble.tex \
--resource-path=.:media \
--verbose src/0.0.md src/ForensicAcquisition/3.0.md src/ForensicAcquisition/3.1.md \
 src/FileSystem/4.0.md src/FileSystem/4.1.md src/FileSystem/4.3.md



#   pandoc --output out/quiz.pdf \
# -H styles/preamble.tex \
# --resource-path=.:media \
# --verbose quiz/quiz.md