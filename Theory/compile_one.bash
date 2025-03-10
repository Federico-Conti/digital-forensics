pandoc --output out/preview.pdf \
-H styles/preamble.tex \
--resource-path=.:media \
--verbose src/3.0.md 