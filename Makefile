FASM2 = ../fasm2

game: main.o sss.o nn.o
	# This is for dynamicly linking raylib. It requre LD_LIBRARY_PATH
	# ld -o game main.o -L./raylib-5.5/lib -lraylib -lc -lm --dynamic-linker=/lib64/ld-linux-x86-64.so.2 
	ld -o PingPongFasm main.o sss.o -L./raylib-5.5/lib -l:libraylib.a -lc -lm --dynamic-linker=/lib64/ld-linux-x86-64.so.2 

test: nn.o testNN.o 
	gcc -o test nn.o testNN.o -lm

testNN.o: testNN.c
	gcc -c testNN.c

nn.o: nn.c
	gcc -c nn.c

sss.o: sss.c
	gcc -c sss.c

main.o: main.asm
	$(FASM2) main.asm 

clear:
	rm -r PingPongFasm main.o
