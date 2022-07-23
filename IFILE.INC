{  IFILE.INC

   ließt die Parameter von Disk und speichert
   sie wieder ab.

}


{-----------------------------------------}
{-----  Kosmetik der Ausgaberoutine   ----}
{-----------------------------------------}

procedure tabs(var tabzahl:integer);
begin
  if test then
  begin
    for ij:=1 to tabzahl do write(#196);
    writeln;
  end;
end;

{-----------------------------------------}
{-------  Parameterdatei einlesen   ------}
{-----------------------------------------}

procedure parameter_load;

  { Fehlermeldung: Parameter-Datei nicht in Ordnung }
  procedure file_error;
  begin
  {if ioresult then
    begin
      writeln(#7,#7,#7,meldung_param);
      exit;
    end;}
  end;

begin
  { Parameterdatei einlesen }
  meldung_param:='Parameterdatei ISOTOP.PAR nicht in Ordnung !';
  pardatei:='ISOTOP.PAR';
  assign(filvar,pardatei);
  reset(filvar);
  readln(filvar);     { Die ersten drei Zeilen ueberlesen }
  readln(filvar);
  readln(filvar);
  readln(filvar,defaultelement);
  readln(filvar,defaultvon);
  readln(filvar,defaultnach);
  readln(filvar,jo,ju,ikern1,ikern2);
  readln(filvar,isotop1);
  readln(filvar,ao1,au1);
  readln(filvar,bo1,bu1);
  readln(filvar,hauf1,s1);
  readln(filvar,isotop2);
  readln(filvar,ao2,au2);
  readln(filvar,bo2,bu2);
  readln(filvar,hauf2,s2);
  readln(filvar,kommentar);
  close(filvar);
  is:=abs(s1-s2);    { Isotopieverschiebung zuordnen }
  file_error;
end;

{-----------------------------------------}
{-------  Parameterdatei speichern  ------}
{-----------------------------------------}

procedure parameter_save;
begin
  gotoxy(1,3);
  write('Letztgültiger Parametersatz wird gespeichert in ISOTOP.PAR');
  gotoxy(1,9); write('                                                ');
  gotoxy(1,9);
  write('Kommentar zum Datensatz:');
  gotoxy(1,10);
  for ij:=1 to 80 do write(#205);
  gotoxy(1,12);
  for ij:=1 to 80 do write(#205);
  gotoxy(1,11);
  write(kommentar);
  gotoxy(1,11);
  readln(kom);
  if (kom<>'') then kommentar:=kom;

  pardatei:='ISOTOP.PAR';
  assign(filvar,pardatei);
  rewrite(filvar);
  writeln(filvar,'Isotopenparameter: (Element/unt. Zust./ober. Zust./Jo,Ju,I1,I2/');
  writeln(filvar,'------------------  Isotop1/Ao1,Au1/Bo1,Bu1/H„ufigk1,Schwpkt1/');
  writeln(filvar,'                    Isotop2/Ao2,Au2/Bo2,Bu2/H„ufigk2,Schwpkt2)');
  writeln(filvar,element);
  writeln(filvar,vonzustand);
  writeln(filvar,nachzustand);
  writeln(filvar,jo:5:1,ju:5:1,ikern1:5:1,ikern2:5:1);
  writeln(filvar,isotop1);
  writeln(filvar,ao1:12:4,au1:12:4);
  writeln(filvar,bo1:12:4,bu1:12:4);
  writeln(filvar,hauf1:6:2,s1:15:4);
  writeln(filvar,isotop2);
  writeln(filvar,ao2:12:4,au2:12:4);
  writeln(filvar,bo2:12:4,bu2:12:4);
  writeln(filvar,hauf2:6:2,s2:15:4);
  writeln(filvar,kommentar);
  close(filvar);
end;

{--------------------------------------}
{-------  Profilparameter lesen  ------}
{--------------------------------------}

procedure profil_parameter_load;
begin
  profildatei:='ISPROFIL.PAR';
  assign(filvar,profildatei);
  reset(filvar);
  readln(filvar);
  readln(filvar,untergrund);
  readln(filvar,FWHM);
  readln(filvar,aufloesung);
  close(filvar);
end;

{------------------------------------------}
{-------  Profilparameter schreiben  ------}
{------------------------------------------}

procedure profil_parameter_save;
begin
  gotoxy(1,4);
  write('Letztgültige Profilparameter werden gespeichert in ISPROFIL.PAR');
  untergrund:=untergrund-205;
  profildatei:='ISPROFIL.PAR';
  assign(filvar,profildatei);
  rewrite(filvar);
  writeln(filvar,'Profilparameter (Untergrund/FWHM/Auflösung):');
  writeln(filvar,untergrund:4:2);
  writeln(filvar,FWHM:4:2);
  writeln(filvar,aufloesung:4);
  close(filvar);
  gotoxy(1,14);
end;

