pandoc --output out/ass-filesystem.pdf \
-H styles/preamble.tex \
--resource-path=.:media \
--verbose src/0.0.md  \
 ./../assignement/filesystem/report.md

