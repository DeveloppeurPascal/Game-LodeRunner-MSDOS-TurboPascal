@echo off
set code=gameldrn
mkmsg loderun
lha a c:\olf_soft\lzh\%code% loderun.doc loderun.exe loderun.pal loderun.spr loderun.msg left.icn right.icn plus.icn
lha a c:\olf_soft\lzh\%code% ldrndat.idf ldrnscr.idf ldrnsav.idf cross.mou
lha a c:\olf_soft\lzh\%code% ldrn_000.dat setup.cfg c:\prg\others\divers\setstick.exe c:\prg\others\divers\setdflt.exe
set code=
echo on
