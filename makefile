all:
	./montador rogue.asm cpuram.mif

run: all
	./simulador test.mif charmap.mif

clean:
	rm cpuram.mif
