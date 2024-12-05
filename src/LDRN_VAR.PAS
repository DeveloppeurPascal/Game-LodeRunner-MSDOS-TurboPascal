unit ldrn_var;
{
Auteur: Patrick Pr‚martin
Date: 14/03/1993. 21/03/1993. 28/03/1993.
Langage: Turbo Pascal 6.0
But: D‚claration des types et variables utiles dans tout LODE RUNNER.
}
interface

const
     num_ver = '1.0';
     dat_ver = '28/03/1993';

     ct_rien = 0;    { Case vide dans le tableau }
     ct_mur = 1;     { Mur dans cette case }
     ct_echelle = 2; { Echelle }
     ct_corde = 4;   { Corde horizontale }
     ct_ennemi = 8;  { Ennemi }
     ct_joueur = 16; { Joueur }
     ct_cadeau = 32; { Paquet cadeau }

type
    string1 = string [1];
    string10 = string [10];
    string15 = string [15];
    string20 = string [20];
    t_score = longint; { Type des zones de score }
    t_num_dtdk = word; { Type des num‚ros de data-disks }

    t_tableau = array [1..40, 1..20] of byte;
    t_data =
      record
        tab_valid : boolean; { Validit‚ de ce tableau ? }
        tableau : t_tableau; { Ecran du jeu }
        vit_ennemi : byte; { Vitesse des ennemis -> 0..99 }
        pad : array [1..14] of byte;
      end;
    t_data_disk = array [1..16] of t_data;

var
   data_disk : t_data_disk;
   num_tab : byte; { Num‚ro du tableau en cours }

function str2num (c : string) : longint;
function num2str (n : longint) : string;
procedure eff_screen;

implementation
uses
    crt,
    u_pal,
    u_int10h,
    u_sgf;

var
   pal : p_pal;

function str2num (c : string) : longint;
var
   r : longint;
   i : byte;
begin
  r := 0;
  for i := 1 to length (c) do
    r := r*10 + ord (c [i]) - ord ('0');
  {endfor}
  str2num := r;
end; { str2num }

function num2str (n : longint) : string;
var
   r : string;
begin
  {$r-}
  str (n, r);
  {$r+}
  num2str := r;
end; { num2str }

procedure eff_screen;
begin
  repeat
  until (set_mode (19) or true);
  directvideo := false;
  use_pal (pal);
end; { eff_screen }

var
   old_exitproc : pointer;

procedure done_var; far;
begin
  if (pal <> nil)
  then
    dispose (pal);
  {endif}
  exitproc := old_exitproc;
end; { done_var }

procedure init_var; far;
begin
  pal := load_pal (get_file_name ('LODERUN.PAL'));
  old_exitproc := exitproc;
  exitproc := @done_var;
end; { init_var }

begin
  init_var;
end.
