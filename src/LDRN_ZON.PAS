unit ldrn_zone;
{
Auteur: Patrick Pr‚martin.
Date: 28/03/1993.
But: Gestion des diff‚rentes zones utilisables au clavier et … la souris.
}
interface
const
     icn_left = 1;
     icn_right = 2;
     icn_plus = 3;
     icn_save = 4;
     icn_load = 5;
     icn_undo = 6;
     icn_pop = 7;
     icn_push = 8;
     icn_exit_dos = 9;
     icn_help = 10;

procedure init_zone;
procedure done_zone;
procedure add_zone (x, y, l, h : word; code_nul : boolean; code_carac : char);
procedure add_icn (n, x, y : byte; code_nul : boolean; code_carac : char);
procedure run_zone (var code_nul : boolean; var code_carac : char);

implementation
uses
    crt,
    u_m_zone,
    u_icn,
    u_sgf,
    u_msg,
    u_mouse,
    u_mou;

const
     mou_cross = 1;

type
    p_m_zone2 = ^o_m_zone2;
    o_m_zone2 =
      object (o_m_zone)
        procedure idle; virtual;
      end;
    r_icn =
      record
        n : byte;
        x, y : word;
        code_nul : boolean;
        code_carac : char;
      end;
    t_tab_icn = array [1..20] of r_icn;

var
   icn : array [1..10] of p_icn;
   tab_icn : t_tab_icn;
   nb_icn : byte;
   touche : p_m_zone2;
   croix : boolean;
   old_exitproc : pointer;

procedure forme_souris (n : word);
begin
  if (mou_select (n) <> 0)
  then
    begin
      writeln (get_msg (4), '(', n, ')');
      halt (1);
    end;
  {endif}
end; { forme_souris }

procedure o_m_zone2.idle;
var
   e : p_zone;
   tst : boolean;
   i, j : word;
begin
  i := pos_m_x;
  j := pos_m_y;
  e := touche^.zone;
  tst := false;
  while ((e <> nil) and not tst) do
    begin
      tst := ((e^.pos_x <= i) and (e^.pos_y <= j)
          and (i <= e^.pos_x+e^.largeur) and (j <= e^.pos_y+e^.hauteur));
      e := e^.next;
    end;
  {endif}
  if (tst)
  then
    begin
      if not croix
      then
        begin
          forme_souris (mou_cross);
          croix := true;
        end;
      {endif}
    end
  else
    begin
      if croix
      then
        begin
          forme_souris (0);
          croix := false;
        end;
      {endif}
    end;
  {endif}
end; { o_m_zone2.idle }

procedure init_zone;
begin
  if (touche = nil)
  then
    touche := new (p_m_zone2, init)
  else
    begin
      done_zone;
      init_zone;
    end;
  {endif}
  nb_icn := 0;
end; { init_zone }

procedure done_zone;
begin
  if (touche <> nil)
  then
    dispose (touche, done);
  {endif}
  touche := nil;
  nb_icn := 0;
end; { done_zone }

procedure add_zone (x, y, l, h : word; code_nul : boolean; code_carac : char);
begin
  if (touche = nil)
  then
    init_zone;
  {endif}
  touche^.add_graph (x, y, l, h, code_nul, code_carac);
end; { add_zone }

procedure add_icn (n, x, y : byte; code_nul : boolean; code_carac : char);
begin
  if ((n > 0) and (n < 11))
  then
    begin
      if (icn [n] = nil)
      then
        case n of
          1 : icn [1] := new (p_icn, load (get_file_name ('LEFT.ICN'), black, darkgray, lightgray));
          2 : icn [2] := new (p_icn, load (get_file_name ('RIGHT.ICN'), black, darkgray, lightgray));
          3 : icn [3] := new (p_icn, load (get_file_name ('PLUS.ICN'), black, darkgray, lightgray));
          4 : icn [4] := new (p_icn, load (get_file_name ('SAVE.ICN'), black, darkgray, lightgray));
          5 : icn [5] := new (p_icn, load (get_file_name ('LOAD.ICN'), black, darkgray, lightgray));
          6 : icn [6] := new (p_icn, load (get_file_name ('UNDO.ICN'), black, darkgray, lightgray));
          7 : icn [7] := new (p_icn, load (get_file_name ('POP.ICN'), black, darkgray, lightgray));
          8 : icn [8] := new (p_icn, load (get_file_name ('PUSH.ICN'), black, darkgray, lightgray));
          9 : icn [9] := new (p_icn, load (get_file_name ('EXIT_DOS.ICN'), black, darkgray, lightgray));
          10 : icn [10] := new (p_icn, load (get_file_name ('HELP.ICN'), black, darkgray, lightgray));
        end;
      {endif}
      if (icn [n] = nil)
      then
        begin
          writeln (get_msg (6), n);
          halt(1);
        end;
      {endif}
      icn [n]^.aff_sortie ((x-2)*8, (y-1)*8);
      if (touche = nil)
      then
        init_zone;
      {endif}
      touche^.add_graph (x*8-8, y*8-8, 16, 16, code_nul, code_carac);
    end;
  {endif}
  if (nb_icn < 20)
  then
    begin
      inc (nb_icn);
      tab_icn [nb_icn].x := (x-2)*8;
      tab_icn [nb_icn].y := (y-1)*8;
      tab_icn [nb_icn].n := n;
      tab_icn [nb_icn].code_nul := code_nul;
      tab_icn [nb_icn].code_carac := code_carac;
    end;
  {endif}
end; { add_icn }

procedure run_zone (var code_nul : boolean; var code_carac : char);
var
   i : byte;
begin
  croix := false;
  if (touche <> nil)
  then
    touche^.test_graph (code_nul, code_carac);
  {endif}
  for i := 1 to nb_icn do
    if ((tab_icn [i].code_nul = code_nul) and (tab_icn [i].code_carac = code_carac))
    then
      icn [tab_icn [i].n]^.aff_enfonce (tab_icn [i].x, tab_icn [i].y);
    {endif}
  {endfor}
  while (mousek <> 0) do;
  {endwhile}
end; { run_zone }

procedure done_ldrn_zone; far;
var
   i : byte;
begin
  exitproc := old_exitproc;
  for i := 1 to 10 do
    if (icn [i] <> nil)
    then
      dispose (icn [i], done);
    {endif}
  {endfor}
  if (touche <> nil)
  then
    dispose (touche, done);
  {endif}
end; { done_ldrn_zone }

procedure init_ldrn_zone; far;
var
   i : byte;
begin
  for i := 1 to 10 do
    icn [i] := nil;
  {endfor}
  touche := nil;
  croix := false;
  nb_icn := 0;
  if (mou_register (mou_load (get_file_name ('CROSS.MOU')), mou_cross) <> 0)
  then
    begin
      writeln (get_msg (5), get_file_name ('CROSS.MOU'));
      halt (1);
    end;
  {endif}
  old_exitproc := exitproc;
  exitproc := @done_ldrn_zone;
end; { init_ldrn_zone }

begin
  init_ldrn_zone;
end.
