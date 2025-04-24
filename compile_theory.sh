pandoc --output Theory/out/digitalforensics.pdf \
-H Theory/styles/preamble.tex \
--resource-path=.:media \
--verbose Theory/src/0.0.md Theory/src/ForensicAcquisition/3.0.md Theory/src/ForensicAcquisition/3.1.md \
 Theory/src/FileSystem/4.0.md Theory/src/FileSystem/4.1.md Theory/src/FileSystem/4.2.md Theory/src/FileSystem/4.3.md



#   pandoc --output out/quiz.pdf \
# -H styles/preamble.tex \
# --resource-path=.:media \
# --verbose quiz/quiz.md