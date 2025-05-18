pandoc --output assignement/ass-network.pdf \
-H Theory/styles/preamble.tex \
--resource-path=.:media \
--verbose Theory/src/0.0.md  assignement/network/report.md assignement/network/report1.md assignement/network/report2.md assignement/network/report3.md

