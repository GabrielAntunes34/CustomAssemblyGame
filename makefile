all:
	./montador test.asm test.mif

run: all
	./simulador test.mif charmap.mif

clean:
	rm test.mif

save: clean
	mv test.asm ex.asm