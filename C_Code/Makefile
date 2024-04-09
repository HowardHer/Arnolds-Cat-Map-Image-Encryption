Arnold.out: Arnold.o Arnoldfns.o
	gcc -Wall Arnold.o Arnoldfns.o -o Arnold.out -lm
Arnold.o: Arnold.c Arnoldfns.h
	gcc -Wall -c Arnold.c -o Arnold.o -lm
Arnoldfns.o: Arnoldfns.c Arnoldfns.h
	gcc -Wall -c Arnoldfns.c -o Arnoldfns.o -lm
clean:
	rm *.o
	rm *.out
	rm ./output/*.bmp