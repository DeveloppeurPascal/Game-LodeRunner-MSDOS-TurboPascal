unit ldrn_sav;
{
Auteur: Patrick Pr‚martin
Date: 14/03/1993
Langage: Turbo Pascal 6.0
But: Gestion du fichier des sauvegardes LDRNSAV.IDF
}
interface
uses
    ldrn_var;

type
    r_save =
      record
        nom : string15;
        num_dtdk : t_num_dtdk;
        date : string10;
      end;

    t_tab_save = array [1..99] of r_save;

var
   tab_save : t_tab_save;
   nb_save : word;
   you_made_save_game : boolean;

implementation
uses
    u_date,
    u_sgf,
    u_idf;

var
   old_exitproc : pointer;
   idf2 : t_tab_champ;

procedure done_sav; far;
var
   f : file;
   i : word;
   j : byte;
   e : pointer;
begin
  if (you_made_save_game)
  then
    begin
      assign (f, get_file_name ('LDRNSAV.IDF'));
      {$i-}
      rewrite (f, 1);
      {$i+}
      if (ioresult = 0)
      then
        begin
          idf2 [1].taille := 16;
          idf2 [1].typ := 1;
          idf2 [1].offset := 0;
          idf2 [2].taille := 4;
          idf2 [2].typ := 2;
          idf2 [2].offset := 16;
          idf2 [3].taille := 11;
          idf2 [3].typ := 1;
          idf2 [3].offset := 20;
          j := 3;
          save_idf_header (f, j, idf2);
          e := init_idf_enreg (3, idf2);
          set_idf_champ (1, 3, idf2, e, '               ');
          set_idf_champ (2, 3, idf2, e, '000');
          set_idf_champ (3, 3, idf2, e, '          ');
          write_idf (f, 3, idf2, e);
          for i := 1 to nb_save do
            begin
              set_idf_champ (1, 3, idf2, e, tab_save [i].nom);
              set_idf_champ (2, 3, idf2, e, num2str (tab_save [i].num_dtdk));
              set_idf_champ (3, 3, idf2, e, tab_save [i].date);
              write_idf (f, 3, idf2, e);
            end;
          {endfor}
          close (f);
          del_idf_enreg (3, idf2, e);
        end;
      {endif}
    end;
  {endif}
  exitproc := old_exitproc;
end; { done_sav }

procedure init_sav; far;
var
   f : file;
   i : byte;
   e : pointer;
begin
  nb_save := 0;
  you_made_save_game := false;
  assign (f, get_file_name ('LDRNSAV.IDF'));
  {$i-}
  reset (f, 1);
  {$i+}
  if (ioresult = 0)
  then
    begin
      init_idf (f, i, idf2);
      e := init_idf_enreg (3, idf2);
      read_idf (f, 3, idf2, e);
      read_idf (f, 3, idf2, e);
      while ((nb_save < 99) and (ioresult = 0)) do
        begin
          inc (nb_save);
          tab_save [nb_save].nom := get_idf_champ (1, 3, idf2, e);
          tab_save [nb_save].num_dtdk := str2num (get_idf_champ (2, 3, idf2, e));
          tab_save [nb_save].date := get_idf_champ (3, 3, idf2, e);
          read_idf (f, 3, idf2, e);
        end;
      {endfor}
      close (f);
      del_idf_enreg (3, idf2, e);
    end;
  {endif}
  old_exitproc := exitproc;
  exitproc := @done_sav;
end; { init_sav }

begin
  init_sav;
end.
