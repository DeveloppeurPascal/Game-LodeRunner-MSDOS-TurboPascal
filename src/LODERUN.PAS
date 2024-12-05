program loderun;
{
Auteur: Patrick Pr‚martin
Date: 14/03/1993. 21/03/1993.
Langage: Turbo Pascal 6.0
But: Jeu dans lequel vous promenez un personnage … la recherche des cadeaux dans
     des labyrinthes.

     Limite: 100 data-disks (de 00 … 99) ayant 16 niveaux chacun,
             100 sauvegardes de parties (de 00 … 99),
             15 meilleurs scores dans la liste.
}

uses
    ldrn_var,
    ldrn_sav,
    ldrn_scr,
    ldrn_dat,
    ldrn_code_acces,
    olf_software,
    crt,
    u_pres2;

var
   n : longint;

begin
  vga_presentation_2 ('GAMELDRN', mess_shareware, 'Lode Runner '+num_ver,
                      '(c) Patrick Pr‚martin '+dat_ver);
  n := select_data_disk ('Choix d''un data-disk.', true);
  textcolor (lightgray);
  textbackground (black);
  clrscr;
  writeln ('Lode Runner v'+num_ver);
  writeln ('(c) Olf Software '+dat_ver);
  writeln;
end.
