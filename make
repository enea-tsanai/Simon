bison -y -d simon.y 
#bison -y --debug --verbose -d simon.y 
flex simon.l
gcc -c y.tab.c lex.yy.c
gcc y.tab.o lex.yy.o -o parser
./parser $1
