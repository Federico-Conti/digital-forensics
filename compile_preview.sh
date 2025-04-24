pandoc --output Theory/out/preview.pdf \
-H Theory/styles/preamble.tex \
--resource-path=.:media \
--verbose Theory/src/0.0.md Theory/src/NetworkForensics/5.0.md 

