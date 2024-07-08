all:
	./montador rogue.asm cpuram.mif

run: all
	./simulador test.mif charmap.mif

clean:
	rm test.mif

save: clean
	mv test.asm ex.asm
