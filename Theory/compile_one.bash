pandoc --output out/preview.pdf \
-H styles/preamble.tex \
--resource-path=.:media \
--verbose src/0.0.md src/FileSystem/4.3.md

