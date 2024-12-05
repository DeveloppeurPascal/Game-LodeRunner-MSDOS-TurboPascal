unit ldrn_scr;
{
Auteur: Patrick Pr‚martin
Date: 14/03/1993
Langage: Turbo Pascal 6.0
But: Gestion du fichier des scores LDRNSCR.IDF
}
interface
uses
    ldrn_var;

type
    r_score =
      record
        nom : string15;
        score : t_score;
        date : string10;
      end;

    t_tab_score = array [1..15] of r_score;

var
   tab_score : t_tab_score;

function add_score (nom : string15; score : t_score) : byte;
{ Essaie d'ajouter un score … la liste, renvoie le rang (de 1 … 15) du joueur,
ou 0 s'il ne fait pas partir des meilleurs scores. }

implementation
uses
    u_date,
    u_sgf,
    u_idf;

function add_score (nom : string15; score : t_score) : byte;
var
   i : byte;
begin
  i := 15;
  while ((i > 1) and (tab_score [i].score <= score)) do
    begin
      tab_score [i] := tab_score [i-1];
      dec (i);
    end;
  {endwhile}
  if ((tab_score [i].score > score) and (i < 15))
  then
    begin
      inc (i);
      tab_score [i].score := score;
      tab_score [i].nom := nom;
      tab_score [i].date := get_date_chaine;
    end
  else
    i := 0;
  {endif}
  add_score := i;
end; { add_score }

var
   old_exitproc : pointer;
   idf1 : t_tab_champ;

procedure done_scr; far;
var
   f : file;
   i : byte;
   e : pointer;
begin
  assign (f, get_file_name ('LDRNSCR.IDF'));
  {$i-}
  rewrite (f, 1);
  {$i+}
  if (ioresult = 0)
  then
    begin
      idf1 [1].taille := 16;
      idf1 [1].typ := 1;
      idf1 [1].offset := 0;
      idf1 [2].taille := 7;
      idf1 [2].typ := 2;
      idf1 [2].offset := 16;
      idf1 [3].taille := 11;
      idf1 [3].typ := 1;
      idf1 [3].offset := 23;
      i := 3;
      save_idf_header (f, i, idf1);
      e := init_idf_enreg (3, idf1);
      set_idf_champ (1, 3, idf1, e, '               ');
      set_idf_champ (2, 3, idf1, e, '000000');
      set_idf_champ (3, 3, idf1, e, '          ');
      write_idf (f, 3, idf1, e);
      for i := 1 to 15 do
        begin
          set_idf_champ (1, 3, idf1, e, tab_score [i].nom);
          set_idf_champ (2, 3, idf1, e, num2str (tab_score [i].score));
          set_idf_champ (3, 3, idf1, e, tab_score [i].date);
          write_idf (f, 3, idf1, e);
        end;
      {endfor}
      close (f);
      del_idf_enreg (3, idf1, e);
    end;
  {endif}
  exitproc := old_exitproc;
end; { done_scr }

procedure init_scr; far;
var
   f : file;
   i : byte;
   e : pointer;
begin
  assign (f, get_file_name ('LDRNSCR.IDF'));
  {$i-}
  reset (f, 1);
  {$i+}
  if (ioresult <> 0)
  then
    for i := 1 to 15 do
      begin
        tab_score [i].nom := 'Olf Software';
        tab_score [i].score := 0;
        tab_score [i].date := get_date_chaine;
      end
    {endfor}
  else
    begin
      init_idf (f, i, idf1);
      e := init_idf_enreg (3, idf1);
      read_idf (f, 3, idf1, e);
      for i := 1 to 15 do
        begin
          read_idf (f, 3, idf1, e);
          tab_score [i].nom := get_idf_champ (1, 3, idf1, e);
          tab_score [i].score := str2num (get_idf_champ (2, 3, idf1, e));
          tab_score [i].date := get_idf_champ (3, 3, idf1, e);
        end;
      {endfor}
      close (f);
      del_idf_enreg (3, idf1, e);
    end;
  {endif}
  old_exitproc := exitproc;
  exitproc := @done_scr;
end; { init_scr }

begin
  init_scr;
end.
