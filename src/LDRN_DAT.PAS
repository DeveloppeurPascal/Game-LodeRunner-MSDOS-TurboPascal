unit ldrn_dat;
{
Auteur: Patrick Pr‚martin
Date: 14/03/1993. 21/03/1993. 28/03/1993.
Langage: Turbo Pascal 6.0
But: Gestion du fichier contenant la liste des tableaux LDRNDAT.IDF
     Gestion du fichier contenant les tableaux
}
interface
uses
    ldrn_var;

type
    r_dat =
      record
        nom : string20;
        num_dtdk : t_num_dtdk;
        date : string10;
        typ : string1; { S = Shareware, U = Utilisateur }
        nb_tab_valid : byte; { Nombre de tableaux valides dans le data-disk }
        auteur : string15;
      end;

    t_tab_dat = array [1..99] of r_dat;

var
   tab_dat : t_tab_dat;
   nb_dat : word;

function select_data_disk (titre : string; add : boolean) : t_num_dtdk;
procedure load_data_disk (n : t_num_dtdk);
procedure save_data_disk (n : t_num_dtdk);

implementation
uses
    crt,
    ldrn_zone,
    u_code_clavier,
    u_date,
    u_vga_graph,
    u_vga_jeux,
    u_sgf,
    u_msg,
    u_time,
    u_idf;

const
     c_data_disk = #8'Lode Runner Data Disk'#10#13'(c) Olf Software 1993'#10#13#26;

function select_data_disk (titre : string; add : boolean) : t_num_dtdk;
var
   res : t_num_dtdk;
   i, oi, j : word;
   code_nul,
   fin : boolean;
   code_carac : char;
begin
  res := 0;
  i := 1;
  oi := 0;
  fin := false;
  repeat
    if (i <> oi) { Affichage de l'‚cran. }
    then
      begin
        init_zone;
        oi := i;
        eff_screen;
        textattr := 70; { Couleur du texte 'LODE RUNNER'. }
        gotoxy (14, 1);
        writeln ('LODE RUNNER:');
        textattr := 71; { Couleur du sous-titre }
        gotoxy ((40-length (titre)) div 2, 2);
        writeln (titre);
        for j := 0 to 8 do
          if (i+j <= nb_dat)
          then
            begin
              textattr := 72+j; { Couleurs des lignes de l'affichage d'une liste }
              gotoxy (2, j*2+4);
              write (copy (tab_dat [i+j].nom, 1, 19):19, ' ',
                     tab_dat [i+j].nb_tab_valid:2, ' ',
                     tab_dat [i+j].auteur:15);
              box (4, (j*2+4)*8-10, 316, (j*2+4)*8+2, 72+j);
              box (20*8+4, (j*2+4)*8-10, 23*8+3, (j*2+4)*8+2, 72+j);
              add_zone (4, (j*2+4)*8-10, 312, 12, false, chr (48+j));
            end;
          {endif}
        {endfor}

        { Affichage des icones de d‚placement gauche, droite }
        if (i > 1)
        then
          add_icn (icn_left, 3, 23, true, touche_gauche);
        {endif}
        if (i+8 < nb_dat)
        then
          add_icn (icn_right, 37, 23, true, touche_droite);
        {endif}

        if (add)
        then
          { Affichage de l'icone d'ajout d'un data-disk }
          add_icn (icn_plus, 7, 23, false, '+');
        {endif}
      end;
    {endif}

    { Gestion des touches autoris‚es sur cet ‚cran. }
    run_zone (code_nul, code_carac);
    case code_nul of
       true :
        case code_carac of
          touche_gauche :
            if (i > 1)
            then
              dec (i, 9);
            {endif}
          touche_droite :
            if (i + 9 <= nb_dat)
            then
              inc (i, 9);
            {endif}
        end;
      false :
        case code_carac of
          touche_escape :
            begin
              fin := true;
              res := 0;
            end;
          '0'..'8' :
            begin
              res := i + (ord (code_carac)-ord ('0'));
              fin := (res <= nb_dat);
            end;
          '+' :
            if (add)
            then
              begin
                { Saisie des informations sur un nouveau data-disk, puis affectation
                d'un num‚ro. }
                res := succ (nb_dat);
                tab_dat [res].nom := saisie_texte (20, 'Lode Runner', get_msg (1), get_msg (2));
                tab_dat [res].date := get_date_chaine;
                tab_dat [res].auteur := saisie_texte (15, 'Lode Runner', get_msg (1), get_msg (3));
                tab_dat [res].num_dtdk := maxint;
                fin := true;
              end;
            {endif}
        end;
    end;
  until (fin);
  done_zone;
  if (res > 0)
  then
    res := tab_dat [res].num_dtdk;
  {endif}
  select_data_disk := res;
end; { select_data_disk }

procedure load_data_disk (n : t_num_dtdk);
var
   f : file;
   ch : string;
begin
  ch := num2str (n);
  ch := get_file_name (copy ('LDRN_000', 1, 8-length (ch))+ch+'.DAT');
  assign (f, ch);
  {$i-}
  reset (f, 1);
  {$i+}
  if (ioresult = 0)
  then
    begin
      blockread (f, ch [0], 1);
      if (ch [0] > #0)
      then
        blockread (f, ch [1], ord (ch [0]));
      {endif}
      blockread (f, data_disk, sizeof (data_disk));
      close (f);
    end;
  {endif}
end; { load_data_disk }

procedure save_data_disk (n : t_num_dtdk);
var
   f : file;
   ch : string;
begin
  ch := num2str (n);
  ch := copy ('LDRN_000', 1, 8-length (ch))+ch+'.DAT';
  assign (f, ch);
  {$i-}
  rewrite (f, 1);
  {$i+}
  if (ioresult = 0)
  then
    begin
      ch := c_data_disk;
      blockwrite (f, ch [0], succ (length (ch)));
      blockwrite (f, data_disk, sizeof (data_disk));
      close (f);
    end;
  {endif}
end; { save_data_disk }

var
   idf3 : t_tab_champ;

procedure init_dat; far;
var
   f : file;
   i : byte;
   e : pointer;
begin
  nb_dat := 0;
  assign (f, get_file_name ('LDRNDAT.IDF'));
  {$i-}
  reset (f, 1);
  {$i+}
  if (ioresult = 0)
  then
    begin
      init_idf (f, i, idf3);
      e := init_idf_enreg (6, idf3);
      read_idf (f, 6, idf3, e);
      read_idf (f, 6, idf3, e);
      while ((nb_dat < 99) and (ioresult = 0)) do
        begin
          inc (nb_dat);
          tab_dat [nb_dat].nom := get_idf_champ (1, 6, idf3, e);
          tab_dat [nb_dat].num_dtdk := str2num (get_idf_champ (2, 6, idf3, e));
          tab_dat [nb_dat].date := get_idf_champ (3, 6, idf3, e);
          tab_dat [nb_dat].typ := get_idf_champ (4, 6, idf3, e);
          tab_dat [nb_dat].nb_tab_valid := str2num (get_idf_champ (5, 6, idf3, e));
          tab_dat [nb_dat].auteur := get_idf_champ (6, 6, idf3, e);
          read_idf (f, 6, idf3, e);
        end;
      {endfor}
      close (f);
      del_idf_enreg (6, idf3, e);
    end;
  {endif}
end; { init_dat }

begin
  init_DAT;
end.
