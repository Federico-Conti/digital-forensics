pandoc --output out/preview.pdf \
-H styles/preamble.tex \
--resource-path=.:media \
--verbose src/0.0.md src/NetworkForensics/5.0.md

