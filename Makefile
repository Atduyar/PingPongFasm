FASM2 = ../fasm2

game: main.o
	# This is for dynamicly linking raylib. It requre LD_LIBRARY_PATH
	# ld -o game main.o -L./raylib-5.5/lib -lraylib -lc -lm --dynamic-linker=/lib64/ld-linux-x86-64.so.2 
	ld -o game main.o -L./raylib-5.5/lib -l:libraylib.a -lc -lm --dynamic-linker=/lib64/ld-linux-x86-64.so.2 

main.o: main.asm
	$(FASM2) main.asm 

clear:
	rm -r game main.o
