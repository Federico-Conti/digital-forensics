pandoc --output out/preview.pdf \
-H styles/preamble.tex \
--resource-path=.:media \
--verbose src/0.0.md src/ForensicAcquisition/3.0.md src/ForensicAcquisition/3.1.md 