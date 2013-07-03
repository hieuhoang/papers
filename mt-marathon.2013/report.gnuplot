#!/usr/bin/env gnuplot
#set title 'Hierarchical System'
set key bottom right
set terminal tikz size 6.7,8
set xtics 0,1,4
set ytics -101.7,.1
set xlabel 'CPU seconds/sentence'
set ylabel 'Model score'
set output '1111-8/model.tex'
plot '1111-8/moses_probing.txt' using 5:6 with lp pt 1 lc 1 title 'Moses', '1111-8/cdec_probing.txt' using 5:6 with lp pt 2 lc 2 title 'cdec', '1111-8/joshua_probing.txt' using 5:6 with lp pt 3 lc 3 title 'Joshua'
set output '1111-8/glue_model.tex'
set terminal tikz size 13.5,8
plot '1111-8/moses_probing.txt' using 5:6 with lp pt 1 lc 1 title 'Moses', '1111-8/cdec_probing.txt' using 5:6 with lp pt 2 lc 2 title 'cdec with Moses glue', '1111-8/cdefglue_probing.txt' using 5:($6+.380318) with lp pt 4 lc 5 title 'cdec with default glue'
set terminal tikz size 6.7,8
set output '1111-8/bleu.tex'
set ylabel 'Uncased BLEU'
set ytics 21.4,.2
plot '1111-8/moses_probing.txt' using 5:7 with lp pt 1 lc 1 title 'Moses', '1111-8/cdec_probing.txt' using 5:7 with lp pt 2 lc 2 title 'cdec', '1111-8/joshua_probing.txt' using 5:7 with lp pt 3 lc 3 title 'Joshua'
set output '1111-8/glue_bleu.tex'
plot '1111-8/moses_probing.txt' using 5:7 with lp pt 1 lc 1 title 'Moses', '1111-8/cdec_probing.txt' using 5:7 with lp pt 2 lc 2 title 'cdec with Moses glue', '1111-8/cdefglue_probing.txt' using 5:7 with lp pt 4 lc 5 title 'cdec with default glue'
