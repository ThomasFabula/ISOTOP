{   ISOTOP.PAS

    berechnet das HFS-Spektrum zweier Isotope eines Elementes in
    Abhängigkeit der A- und B-Faktoren bei bekannten Drehimpuls-
    quantenzahlen ( Ju, Jo, I1, I2 ). Außerdem sind die Isotopie-
    verschiebung IS [MHz], sowie die relativen Häufigkeiten H1, H2
    der Isotope [%] einzugeben.

    ( Ansonsten siehe Programme: HFSSPEK.PAS und SPEKTRUM.PAS )
    Die F-, K-, W- und Energiewerte für jeweils den unteren bzw.
    oberen Zustand werden berechnet und ausgegeben. Hierfür kann
    eine Ausgabedatei benannt werden. (Default: ISOTOP.DAT)

    Die Übergänge lassen sich als einzelne Linien oder auf Wunsch
    als Summenprofil am Bildschirm oder auf dem Drucker anzeigen.
    Für die Druckerausgabe benötigt man bei der HERCULES-Karte das
    Systemprogramm HGC.COM mit den Optionen (HGC FULL HPRINT).

    Hiernach ist die residente Interruptroutine des Print-Screen
    Hardcopyprogramms auf die Grafikseite "umgebogen", und bei
    Drcken der Tastenkombination <Shift>+<Prnt-Scr>+<n> erscheint
    ein Hardcopy auf dem jeweils angeschlossenen Drucker.
    ( n = 0, Ausdruck der Grafikseite 0 im Format DIN A4 )
    Für weitere Informationen siehe Datei ISOTOP.TXT

    (C) 1987  Institut fr Angewandte Physik
              der Universität Bonn

    Thomas Fabula, Wolfgang Rupprecht

}

program isotop;

{ Einbinden der GRAPHIX Turbo-Toolbox notwendigen Zeichenroutinen,   }
{ GRAPHIX.SYS angepaát auf Hercules-Grafikkarte (720x348 pixel)      }
{ d.h. zur Installation vorher GRAPHIX.HGH nach GRAPHIX.SYS kopieren.}

{$I typedef.sys}          { System unabhängige Typendefinitionen     }
{$I graphix.sys}          { System abhängige Definitionen & Routinen }
{$I kernel.sys}           { System unabhängige Support Routinen      }

{$I ideclare.inc}         { Deklarationen (const, type, var)         }
{$I njsymbol.inc}         { Berechnung der nj-Symbole    (T.Brenner) }
{$I realin.inc}           { REAL-Zahl Einleseroutine                 }
{$I ifile.inc}            { Disketten I/O-Routinen für Parameter     }
{$I iparam.inc}           { Parameter editieren                      }
{$I ifunct.inc}           { zusätzliche  Funktionen                  }


{------------------------------}
{-----  Initialisierung  ------}
{------------------------------}

procedure belegen;
begin
  for i:=1 to aufloesung do
  begin
    ysuma[i]:=0; ysum[i]:=0;
  end;
  for n:=0 to 30 do
  begin
    for m:=0 to 30 do
    begin
      energie1[m,n]:=0;
      energie2[m,n]:=0;
    end;
  end;
end;

{------------------------------}
{-----   Lorentzprofil   ------}
{------------------------------}

function lorentz(var energie,e_0,intensy : real) : real;
var zaehler,nenner : real;
begin { lorentz }
  zaehler:=sqr(FWHM);
  nenner:=sqr(energie - e_0);
  nenner:=nenner+0.25*zaehler;
  if (nenner=0) then
    begin
      writeln(#7,#7,#7);
      writeln('Lorentz: Division durch Null');
      halt;
    end { if };
  lorentz:=intensy*zaehler/nenner;
end { lorentz };

{---------------------------}
{-----   Gaußprofil   ------}
{---------------------------}

function gauss(var energie,e_0,intensy : real) : real;
var ar,argum : real;
begin { gauss }
  argum:=abs(energie-e_0);
  if (FWHM=0) then
    begin
      writeln(#7,#7,#7);
      writeln('Gauß:  FWHM = Null');
      halt;
    end { if };
  argum:=argum/FWHM;
  ar:=sqr(argum);
  gauss:=intensy*exp(-ar);   { -ar/2 }
end { gauss };

{-------------------------------------------------}
{-------  Berechnen eines Lorentzprofils  --------}
{-------------------------------------------------}

procedure lorentz_profil(var resonance,inten:real;switchi:boolean);
begin { lorentz_profil }
  ijk:=1;
  if switchi then
    begin  gotoxy(3,23); write('Lorentz'); end;
  ylo:=0;
  xlo:=x_links;
  deltalo:=abs(x_links-x_rechts)/aufloesung;
  { 0        <= Y-Achse <= 1000     }
  { x_links  <  X-Wert  <  x_rechts }
  repeat
    ylo:=0.25*lorentz(xlo,resonance,inten);
    ysum[ijk]:=ysum[ijk]+ylo;  { Aufsummierung des Signals }
    ylo:=untergrund+ylo;
    {  if switchi then DrawPoint(xlo,ylo); }
    xlo:=xlo + deltalo;   { X-Wert erhöhen }
    ijk:=ijk+1;           { Laufindex für Summe erhöhen }
  until (xlo > x_rechts);
end { lorentz_profil };

{----------------------------------------------}
{-------  Berechnen eines Gaußprofils  --------}
{----------------------------------------------}

procedure gauss_profil(var resonanc,inte:real; switch:boolean);
begin { gauss_profil }
  ijk:=1;
  if switch then
   begin
     gotoxy(3,23);
     write('Gauß');
     gotoxy(73,2);
     write('Gauß');
   end { if };
  ylo:=0;
  xlo:=x_links;
  deltalo:=abs(x_links-x_rechts)/aufloesung;
  { 0        <= Y-Achse <= 1000     }
  { x_links  <  X-Wert  <  x_rechts }
  repeat
    ylo:=gauss(xlo,resonanc,inte);
    ysum[ijk]:=ysum[ijk]+ylo;  { Aufsummierung des Signals }
    ylo:=untergrund+ylo;
    {  if switch then DrawPoint(xlo,ylo);  }
    xlo:=xlo + deltalo;   { X-Wert erhöhen }
    ijk:=ijk+1;           { Laufindex für Summe erhöhen }
  until (xlo > x_rechts);
end { gauss_profil };

{---------------------------------------------}
{-------  Berechnen der Intensitäten  --------}
{-------  Intens(ju,jo,fu,fo,ikern)   --------}
{-------   ber die sechsJ-Symbole    --------}
{---------------------------------------------}

function intens(var juu,joo,fuu,foo,ikernspin : real) : real;
var temp1,temp2,xq : real;
begin { intens }
  temp1:=2*foo+1;
  temp2:=2*fuu+1;
  temp1:=temp1*temp2;
  { SechsJ-Symbole siehe Datei : njsymbol.inc }
  xq:=sechsJ(joo,foo,ikernspin,fuu,juu,1);
  intens:=temp1*xq*xq;
end { intens };


{----------------------------------------------}
{-------  Skalierung der Intensitäten  --------}
{----------------------------------------------}

procedure skal_intensity(var kern1,kern2:real);
{ Skalierung der Intensitäten, suchen von Int(max) }
var   max_intensi1,such_intensi1,
      max_intensi2,such_intensi2,kern : real;
begin { skal_intensity }
  if test then
    begin
      tabs(t);
      writeln('Skalierung der Intensitäten auf 100% ... !');
    end;
  { Welches Isotop ist häufiger ? }
  if (hauf1 > hauf2)
    then
      begin  hf1:=1; hf2:=hauf2/hauf1;  end
    else
      begin  hf2:=1; hf1:=hauf1/hauf2;  end;
  max_intensi1:=0.001;
  max_intensi2:=0.001;

{ Isotop 1 }
  kern:=kern1;
  for n:=0 to maxxu1 do
  begin
    for m:=0 to maxxo1 do
    begin
      if ( ( fu1[n]-fo1[m] = 0) or (abs( fu1[n] - fo1[m]) = 1) ) then
      begin
        {  maximale Linien-Intensitäten  }
        such_intensi1:=intens(ju,jo,fu1[n],fo1[m],kern)*100*hf1;
        if (such_intensi1 > max_intensi1) then max_intensi1 := such_intensi1;
      end { if };
    end { for };
  end { for };

{ Isotop 2 }
  kern:=kern2;
  for n:=0 to maxxu2 do
  begin
    for m:=0 to maxxo2 do
    begin
      if ( ( fu2[n]-fo2[m] = 0) or (abs( fu2[n] - fo2[m]) = 1) ) then
      begin
        {  maximale Linien-Intensitäten  }
        such_intensi2:=intens(ju,jo,fu2[n],fo2[m],kern)*100*hf2;
        if (such_intensi2 > max_intensi2) then max_intensi2 := such_intensi2;
      end { if };
    end { for };
  end { for };

  if (max_intensi1 > max_intensi2)
    then skal_intensi := 100 / max_intensi1
    else skal_intensi := 100 / max_intensi2;

end { skal_intensity };


{-----------------------------------------}
{--  Abspeichern der berechneten Werte  --}
{- Fu(n), Fo(n), Wu(n), Wo(n) und E(n,m) -}
{-----------------------------------------}

procedure save;
label ende1,ende2;
begin { save }
  writeln('Isotopiedaten werden gespeichert in der Datei : ',datname);
  assign(filvar,datname);
  rewrite(filvar);             { gleichnamige Datei wird überschrieben }
{  Parameter  }
  writeln(filvar,'Isotopiedaten:');
  writeln(filvar,'==============');
  writeln(filvar,'Element   : ',element);
  writeln(filvar,'Uebergang : ',vonzustand,' -> ',nachzustand);
  writeln(filvar);
  writeln(filvar,'Parameter:');
  writeln(filvar,'----------');
  writeln(filvar,'Ju        = ',ju:10:1);
  writeln(filvar,'Jo        = ',jo:10:1);
  writeln(filvar);
  writeln(filvar,'Isotop1   : ',isotop1);
  writeln(filvar,'Ao1 [MHz] = ',ao1:15:6);
  writeln(filvar,'Au1 [MHz] = ',au1:15:6);
  writeln(filvar,'Bo1 [MHz] = ',bo1:15:6);
  writeln(filvar,'Bu1 [MHz] = ',bu1:15:6);
  writeln(filvar,'I1        = ',ikern1:10:1);
  writeln(filvar,'Rel.Hfgk. = ',hauf1:10:1,' [%]');
  writeln(filvar,'Schwpkt.  = ',s1:10:4,' [MHz]');
  writeln(filvar);
  writeln(filvar,'Isotop2   : ',isotop2);
  writeln(filvar,'Ao2 [MHz] = ',ao2:15:6);
  writeln(filvar,'Au2 [MHz] = ',au2:15:6);
  writeln(filvar,'Bo2 [MHz] = ',bo2:15:6);
  writeln(filvar,'Bu2 [MHz] = ',bu2:15:6);
  writeln(filvar,'I2        = ',ikern2:10:1);
  writeln(filvar,'Rel.Hfgk. = ',hauf2:10:1,' [%]');
  writeln(filvar,'Schwpkt.  = ',s2:10:4,' [MHz]');
  writeln(filvar);
  writeln(filvar,'Isotopieverschiebung = ',abs(s1-s2):9:4,' [MHz]');

{ Daten des 1. Isotops }
  {  F-Werte  }
  writeln(filvar);
  writeln(filvar,'Daten des Isotops Nr.1 : ',isotop1:5);
  writeln(filvar,'==============================');
  writeln(filvar);
  writeln(filvar,'F1-Werte:');
  writeln(filvar,'---------');
  for ii:=0 to maxxu1 do writeln(filvar,'Fu1  =  ',fu1[ii]:10:1);
  writeln(filvar);
  for ii:=0 to maxxo1 do writeln(filvar,'Fo1  =  ',fo1[ii]:10:1);
  {  K-Werte  }
  writeln(filvar);
  writeln(filvar,'K1(F)-Werte:');
  writeln(filvar,'------------');
  for ii:=0 to maxxu1 do writeln(filvar,'Ku1(',fu1[ii]:3:1,')  =  ',ku1[ii]:10:1);
  writeln(filvar);
  for ii:=0 to maxxo1 do writeln(filvar,'Ko1(',fo1[ii]:3:1,')  =  ',ko1[ii]:10:1);
  {  W-Werte  }
  writeln(filvar);
  writeln(filvar,'W1(F)-Werte [MHz]:');
  writeln(filvar,'------------------');
  for ii:=0 to maxxu1 do writeln(filvar,'Wu1(',fu1[ii]:3:1,')  =  ',wu1[ii]:15:6);
  writeln(filvar);
  for ii:=0 to maxxo1 do writeln(filvar,'Wo1(',fo1[ii]:3:1,')  =  ',wo1[ii]:15:6);
  {  Energiewerte E1(n,m)  }
  writeln(filvar);
  writeln(filvar,'E1(Fo1,Fu1)-Werte [MHz]:');
  writeln(filvar,'------------------------');
  for n:=0 to maxxu1 do
  begin
    for m:=0 to maxxo1 do
    begin
      if ( ( fu1[n]-fo1[m] = 0) or (abs( fu1[n] - fo1[m]) = 1) ) then
      begin
        if ( ( fu1[n]=0) and (fo1[m]=0) )  then goto ende1;
        energie1[m,n] := wo1[m] - wu1[n];
        write(filvar,'E1(',fo1[m]:3:1,',',fu1[n]:3:1,') = ',energie1[m,n]:15:6);
        { Isotop Linien-Intensitäten skaliert auf 100 % }
        intensi:=skal_intensi*intens(ju,jo,fu1[n],fo1[m],ikern1)*100*hf1 ;
        writeln(filvar,'   (Int : ',intensi:6:2,'%)');
        ende1:
      end { if };
    end { for };
  end { for };
  writeln(filvar);
  writeln(filvar,'Anzahl der Linien ',isotop1:5, 'Isotop : ',linien_anzahl1:3);
  writeln(filvar);

{ Daten des 2. Isotops }
  {  F-Werte  }
  writeln(filvar,'Daten des Isotops Nr.2 : ',isotop2:5);
  writeln(filvar,'==============================');
  writeln(filvar);
  writeln(filvar,'F2-Werte:');
  writeln(filvar,'---------');
  for ii:=0 to maxxu2 do writeln(filvar,'Fu2  =  ',fu2[ii]:10:1);
  writeln(filvar);
  for ii:=0 to maxxo2 do writeln(filvar,'Fo2  =  ',fo2[ii]:10:1);
  {  K-Werte  }
  writeln(filvar);
  writeln(filvar,'K2(F)-Werte:');
  writeln(filvar,'------------');
  for ii:=0 to maxxu2 do writeln(filvar,'Ku2(',fu2[ii]:3:1,')  =  ',ku2[ii]:10:1);
  writeln(filvar);
  for ii:=0 to maxxo2 do writeln(filvar,'Ko2(',fo2[ii]:3:1,')  =  ',ko2[ii]:10:1);
  {  W-Werte  }
  writeln(filvar);
  writeln(filvar,'W2(F)-Werte [MHz]:');
  writeln(filvar,'------------------');
  for ii:=0 to maxxu2 do writeln(filvar,'Wu2(',fu2[ii]:3:1,')  =  ',wu2[ii]:15:6);
  writeln(filvar);
  for ii:=0 to maxxo2 do writeln(filvar,'Wo2(',fo2[ii]:3:1,')  =  ',wo2[ii]:15:6);
  {  Energiewerte E2(n,m)  }
  writeln(filvar);
  writeln(filvar,'E2(Fo2,Fu2)-Werte [MHz]:');
  writeln(filvar,'------------------------');
  for n:=0 to maxxu2 do
  begin
    for m:=0 to maxxo2 do
    begin
      if ( ( fu2[n]-fo2[m] = 0) or (abs( fu2[n] - fo2[m]) = 1) ) then
      begin
        if ( ( fu2[n]=0) and (fo2[m]=0) ) then goto ende2;
        energie2[m,n] := wo2[m] - wu2[n];
        write(filvar,'E2(',fo2[m]:3:1,',',fu2[n]:3:1,') = ',energie2[m,n]:15:6);
        { Isotop Linien-Intensitäten skaliert auf 100 % }
        intensi:=skal_intensi*intens(ju,jo,fu2[n],fo2[m],ikern2)*100*hf2;
        writeln(filvar,'   (Int : ',intensi:6:2,'%)');
        ende2:
      end { if };
    end { for };
  end { for };
  writeln(filvar);
  writeln(filvar,'Anzahl der Linien ',isotop2:5,' Isotop : ',linien_anzahl2:3);
  writeln(filvar);
  writeln(filvar,'Energie [min]          = ',energmin:15:6,'  [MHz]');
  writeln(filvar,'Energie [max]          = ',energmax:15:6,'  [MHz]');
  writeln(filvar,'Gesamt Hfs-Aufspaltung = ',hfsaufsp:15:8,'  [GHz]');
  writeln(filvar);
  writeln(filvar,'Kommentar :');
  writeln(filvar,'-----------');
  writeln(filvar,kommentar);
  { Ende des Abspeicherns }
  close(filvar);
end { save };

{-----------------------------------------}
{-------  Berechnen der F-Werte:  --------}
{----   F = I + J , ... , abs(I - J)   ---}
{-----------------------------------------}

procedure berechne_f(var kern1,kern2:real);
var kern : real;
begin { berechne_f }

{ Isotop 1 }
  kern:=kern1;
  tabs(t);
  { Berechnung für den unteren Zustand }
  j:=ju;
  if j>=kern then max:=kern
  else max:=j;
  maxxu1:=trunc(2*max+1+0.1);    { Integerzahl aus Drehimpuls machen }
  maxxu1:=maxxu1-1;              { und sicher gehen, das nicht       }
  for n:=0 to maxxu1 do          { abgerundet wird                   }
  begin
    fu1[n] := kern + j - n;
    if test then WRITELN('Fu1(',n,') = ',FU1[N]:10:1);
  end { for };
  if test then tabs(t);
  { Berechnung fr den oberen Zustand }
  j:=jo;
  if j>=kern then max:=kern
  else max:=j;
  maxxo1:=trunc(2*max+1+0.1);      { Integerzahl aus Drehimpuls machen }
  maxxo1:=maxxo1-1;
  for n:=0 to maxxo1 do
  begin
    fo1[n] := kern + j - n;
    if test then WRITELN('Fo1(',n,') = ',FO1[N]:10:1);
  end { for };

{ Isotop 2 }
  kern:=kern2;
  tabs(t);
  { Berechnung für den unteren Zustand }
  j:=ju;
  if j>=kern then max:=kern
  else max:=j;
  maxxu2:=trunc(2*max+1+0.1);    { Integerzahl aus Drehimpuls machen }
  maxxu2:=maxxu2-1;              { und sicher gehen, das nicht       }
  for n:=0 to maxxu2 do          { abgerundet wird                   }
  begin
    fu2[n] := kern + j - n;
    if test then WRITELN('Fu2(',n,') = ',FU2[N]:10:1);
  end { for };
  if test then tabs(t);
  { Berechnung für den oberen Zustand }
  j:=jo;
  if j>=kern then max:=kern
  else max:=j;
  maxxo2:=trunc(2*max+1+0.1);      { Integerzahl aus Drehimpuls machen }
  maxxo2:=maxxo2-1;
  for n:=0 to maxxo2 do
  begin
    fo2[n] := kern + j - n;
    if test then WRITELN('Fo2(',n,') = ',FO2[N]:10:1);
  end { for };

end { berechne_f };

{-----------------------------------------}
{------  Berechnen der K-Werte:  ---------}
{----  K = F(F+1) - I(I+1) - J(J+1)  -----}
{----        ( Casimir )             -----}
{-----------------------------------------}

procedure berechne_k(var kern1,kern2:real);
var kern : real;
begin { berechne_k }
  if test then tabs(t);

 { Isotop 1 }
  kern:=kern1;
  { Berechnung für den unteren Zustand }
  for n:=0 to maxxu1 do
  begin
    j:=ju;
    f:=fu1[n];
    ku1[n]:=f*(f+1)-kern*(kern+1)-j*(j+1);
    if test then writeln('Ku1(',fu1[n]:3:1,') = ',ku1[n]:10:1);
  end { for };
  if test then tabs(t);
  { Berechnung für den oberen Zustand }
  for n:=0 to maxxo1 do
  begin
    j:=jo;
    f:=fo1[n];
    ko1[n]:=f*(f+1)-kern*(kern+1)-j*(j+1);
    if test then writeln('Ko1(',fo1[n]:3:1,') = ',ko1[n]:10:1);
  end { for };

 { Isotop 2 }
  kern:=kern2;
  { Berechnung für den unteren Zustand }
  for n:=0 to maxxu2 do
  begin
    j:=ju;
    f:=fu2[n];
    ku2[n]:=f*(f+1)-kern*(kern+1)-j*(j+1);
    if test then writeln('Ku2(',fu2[n]:3:1,') = ',ku2[n]:10:1);
  end { for };
  if test then tabs(t);
  { Berechnung fr den oberen Zustand }
  for n:=0 to maxxo2 do
  begin
    j:=jo;
    f:=fo2[n];
    ko2[n]:=f*(f+1)-kern*(kern+1)-j*(j+1);
    if test then writeln('Ko2(',fo2[n]:3:1,') = ',ko2[n]:10:1);
  end { for };

end { berechne_k };

{--------------------  Berechnen der W-Werte:  ------------------------}
{   W = 1/2h ( K*A + (3/4 K(K+1)-I(I+1)J(J+1))*B/(I(2I-1)J(2J-1)) )    }
{                Energiewerte W in [MHz] - Einheiten                   }
{                h  =    Planck'sches Wirkungsquantum                  }
{----------------------------------------------------------------------}
procedure berechne_w(var aok1,auk1,bok1,buk1,aok2,auk2,bok2,buk2,
                         kern1,kern2:real);

  function w_zahl(var a,b,k,ij,ji : real):real;
  { Berechnung des HFS-Niveau-Energiewertes }
  var  sum1,zaehler,nenner,wzahl : real;
  begin { w_zahl }
    sum1:=k*a*0.5;
    zaehler:=ij*(ij+1)*ji*(ji+1);
    zaehler:=0.75*k*(k+1)-zaehler;
    if b=0
      then nenner:=1
      else nenner:=2*ij*(2*ij-1)*ji*(2*ji-1);
    { Falls  I,J = 1/2  dann  B = 0 }
    if ( (ij=0.5) or (ji=0.5) )
      then wzahl:=zaehler
      else wzahl:=zaehler*b/nenner;
    w_zahl:=(sum1+wzahl)*h;
  end { w_zahl };

var kern : real;

begin { berechne_w }
  if test then tabs(t);
  { Berechnung für den unteren Zustand  }

 { Isotop 1 }
  kern:=kern1;
  for m:=0 to maxxu1 do
  begin
    f:=fu1[m];
    k:=ku1[m];
    wu1[m]:=w_zahl(auk1,buk1,k,kern,ju);
   if test then writeln('Wu1(',fu1[m]:3:1,') = ',wu1[m]:15:6);
  end { for };
  if test then tabs(t);
  { Berechnung für den oberen Zustand  }
  for m:=0 to maxxo1 do
  begin
    f:=fo1[m];
    k:=ko1[m];
    wo1[m]:=w_zahl(aok1,bok1,k,kern,jo);
    if test then writeln('Wo1(',fo1[m]:3:1,') = ',wo1[m]:15:6);
  end { for };

 { Isotop 2 }
  kern:=kern2;
  for m:=0 to maxxu2 do
  begin
    f:=fu2[m];
    k:=ku2[m];
    wu2[m]:=w_zahl(auk2,buk2,k,kern,ju);
   if test then writeln('Wu2(',fu2[m]:3:1,') = ',wu2[m]:15:6);
  end { for };
  if test then tabs(t);
  { Berechnung für den oberen Zustand  }
  for m:=0 to maxxo2 do
  begin
    f:=fo2[m];
    k:=ko2[m];
    wo2[m]:=w_zahl(aok2,bok2,k,kern,jo);
    if test then writeln('Wo2(',fo2[m]:3:1,') = ',wo2[m]:15:6);
  end { for };

end { berechne_w };

{----------------  Berechnen der Energiezuordnungen  ------------------}
{                  unter Beachtung der Auswahlregeln:                  }
{                                                                      }
{                       delta(F) = 0, +1, -1     und                   }
{                  Übergang F = 0 nach F = 0  verboten                 }
{                                                                      }
{                       Wo(n) - Wu(m)  ==>  E(n,m)                     }
{                Energiewerte W,E in [MHz] - Einheiten                 }
{----------------------------------------------------------------------}
procedure energien_zuordnung(var kern1,kern2:real);
label ende1,ende2;
var  ft,iii : integer;
     kern   : real;
begin { energien_zuordnung }
  iii:=0; ft:=46;
  energmin1:=10000.0; energmax1:=0;
  energmin2:=10000.0; energmax2:=0;
  if test then tabs(ft);

 { Isotop 1 }
  kern:=kern1;
  for n:=0 to maxxu1 do
  begin
    for m:=0 to maxxo1 do
    begin
      if ( ( fu1[n]-fo1[m] = 0) or (abs( fu1[n] - fo1[m]) = 1) ) then
      begin
        if ( ( fu1[n]=0) and (fo1[m]=0) ) then goto ende1;
        if (s2=0)
          then energie1[m,n] := (wo1[m] - wu1[n]) + is
          else energie1[m,n] := wo1[m] - wu1[n];
        linien_anzahl1:=linien_anzahl1+1;
        if test then write('E1(',fo1[m]:3:1,',',fu1[n]:3:1,') = ',energie1[m,n]:15:6);
        {  Linien-Intensitäten  }

        intensi:=skal_intensi*intens(ju,jo,fu1[n],fo1[m],kern)*100*hf1;
        if test then writeln('   (Int : ',intensi:6:2,'%)');
        {  Aussortieren von Emax und Emin  }
        if energmin1 >= energie1[m,n] then energmin1:=energie1[m,n];
        if energmax1 <= energie1[m,n] then energmax1:=energie1[m,n];
        ende1:
      end { if };
    end { for };
    writeln;
end { for };

 { Isotop 2 }
  kern:=kern2;
  for n:=0 to maxxu2 do
  begin
    for m:=0 to maxxo2 do
    begin
      if ( ( fu2[n]-fo2[m] = 0) or (abs( fu2[n] - fo2[m]) = 1) ) then
      begin
        if ( ( fu2[n]=0) and (fo2[m]=0) ) then goto ende2;
        if (s1=0)
          then energie2[m,n] := (wo2[m] - wu2[n]) + is
          else energie2[m,n] := wo2[m] - wu2[n];
        linien_anzahl2:=linien_anzahl2+1;
        if test then write('E2(',fo2[m]:3:1,',',fu2[n]:3:1,') = ',energie2[m,n]:15:6);
        {  Linien-Intensitäten  }

        intensi:=skal_intensi*intens(ju,jo,fu2[n],fo2[m],kern)*100*hf2;
        if test then writeln('   (Int : ',intensi:6:2,'%)');
        {  Aussortieren von Emax und Emin  }
        if energmin2 >= energie2[m,n] then energmin2:=energie2[m,n];
        if energmax2 <= energie2[m,n] then energmax2:=energie2[m,n];
        ende2:
      end { if };
    end { for };
    if test then writeln;
end { for };

  { Energien skalieren, größten Bereich wählen }
  if (energmin1 < energmin2)
    then energmin:=energmin1
    else energmin:=energmin2;
  if (energmax1 > energmax2)
    then energmax:=energmax1
    else energmax:=energmax2;

  { Gesamt Hfs-Aufspaltung in [GHz]  b e i d e r  Isotope berechnen }
  hfsaufsp:=(abs(energmin)+abs(energmax))*0.001;

 if test then
    begin
      tabs(ft);
      writeln('Gesamt Hfs-Aufspaltung = ',hfsaufsp:15:8,' [GHz]');
      writeln('Anzahl der Linien ',isotop1,' Isotop : ',linien_anzahl1:2);
      writeln('Anzahl der Linien ',isotop2,' Isotop : ',linien_anzahl2:2);
      tabs(ft);
      write('Bitte <RETURN> drcken : ');
      readln(ch);
    end { if };

end { energien_zuordnung };

{----------------------------------------}
{-------   Hfs-Spektrum drucken  --------}
{----------------------------------------}

procedure drucken;
var hc : char;
begin
  gotoxy(62,24); write('<H>ardcopy     : ');
  readln(hc);
  hc:=upcase(hc);
  gotoxy(79,24); write(hc);
  if (hc='H') then hardcopy(FALSE,1);    { TURBO-PASCAL Druckertreiber }
end;

{--------------------------------------}
{-------  Linien aufsummieren  --------}
{--------------------------------------}

procedure summation(var doit:boolean);
{ Aufsummiertes Spektrum einzeichnen }
var  ysumme,summax : real;
     kl            : integer;
     yfirst,ysecond : real;
begin { summation }
  if doit then
    begin
      gotoxy(73,3); write('-Profil');
    end { if };
  ylo:=0;
  xlo:=x_links;
  deltalo:=abs(x_links-x_rechts)/aufloesung;
  kl:=1;
  repeat
    { Aufsummiertes Signal einzeichnen        }
    ysumme:=untergrund+(ysum[kl]);
    { Kennzeichnen der Punkte die außerhalb liegen... }
    if (ysumme>830) then
      begin
        ysumme:=875;
        DrawPoint(xlo,ysumme);
      end;
    yfirst:=untergrund+ysum[kl];
    ysecond:=untergrund+ysum[kl+1];
    { Sicherheitsabfrage bzgl. DefineWorld... }
    if (yfirst  > 830) then yfirst :=830;
    if (ysecond > 830) then ysecond:=830;
    DrawLine(xlo,yfirst,xlo+deltalo,ysecond);
    xlo:=xlo + deltalo;   { X-Wert erhöhen }
    kl:=kl+1;             { Laufindex für Summe erhöhen }
  until ( (xlo > x_rechts) or (kl>=aufloesung) );
  drucken;
  gotoxy(62,24); write('        <<RETURN>>');
  readln(ch);
  LeaveGraphic;
end { summation };

{--------------------------------------}
{-------  Y-Achse einzeichnen  --------}
{--------------------------------------}

procedure y_axis;
var  iu : integer;
     x_achse,y_einh,dd : real;
begin { y_axis }
  dd:=delta_X/150;
  y_einh:=0.10*grafik_skal+205;
  x_achse:=x_min-offset/2;            { 0  <= Y-Achse <= 100 % }
  drawline(x_achse,205,x_achse,790);  { Achse einzeichnen }

  { Markierungen }
  for iu:=1 to 10 do
  begin
    DrawLine(x_achse-dd,y_einh,x_achse+dd,y_einh);
    y_einh:=y_einh+0.10*grafik_skal;
  end { for };

  gotoxy(2,6);  write('Int.',#30);      { Pfeil einzeichnen }
  gotoxy(2,8);  write('100');
  gotoxy(2,9);  write('[%]');
  gotoxy(2,13); write(' 60');
  gotoxy(2,18); write(' 20');
end { y_axis };

{-------------------------------------}
{-------  Grafik vorbereiten  --------}
{-------------------------------------}

procedure begin_grafik;
begin { begin_grafik }
  null:=0;
  delta_X:=abs(energmax)+abs(energmin);
  offset:=delta_X*0.2;
  x_min:=energmin;
  x_max:=energmax;
  InitGraphic;                            {init the system and screen}
  SelectScreen(1);
  ClearScreen;                         { Wertebereiche für Grafik:     }
  x_links:=x_min-offset;            { 0      <= Y-Achse <= 1000     }
  x_rechts:=x_max+offset;           { x_links < X-Wert  <  x_rechts }
  DefineWorld(1,x_links,0,x_rechts,1000); {define a world for drawing}
  SelectWorld(1);                         {select it}
  SelectWindow(1);
  SetBackground(0);
  DrawBorder;
  DrawLine(x_links,200,x_rechts,200);      {  doppelte Energieachse  }
  DrawLine(x_links,205,x_rechts,205);      {  [MHz] zeichnen         }

  DrawLine(x_links,870,x_rechts,870);      { Fenster für Fu/Fo-Werte }
  DrawLine(x_links,850,x_rechts,850);
  DrawLine(x_links,830,x_rechts,830);
  y_axis;                                  { Y-Achse einzeichnen     }
  SetLineStyle(2);                         { lang gestrichelte Linie }
  DrawLine(null,200,null,830);       {  Linienschwerpunkt 1 zeichnen }
  DrawLine(null,850,null,870);       {  Linienschwerpunkt 1 zeichnen }
  SetLineStyle(1);                         { gepunktete Linie        }
  DrawLine(is,200,is,850);           {  Linienschwerpunkt 2 zeichnen }
  SetLineStyle(0);
  gotoxy(3,2);
  write(element);                             {  Elementbezeichnung  }
  writeln(',  Übergang : ',vonzustand,' -> ',nachzustand);
  gotoxy(50,2);  write('ISOTOPIE-Verschiebung');
  gotoxy(50,3);  write('   * Simulation *   ');
  gotoxy(3,22);  write('Profilart <L>orentz / <G>auß : ');
  gotoxy(34,22); readln(profil);
  profil:=upcase(profil);
  gotoxy(34,22); write(profil);
  gotoxy(75,21); write('[MHz]');
end { begin_grafik };

{---------------------------------------}
{-------   Grafik abschließen   --------}
{---------------------------------------}

procedure end_grafik;
var art : char;
    zeige : boolean;
begin { end_grafik }
  { Löschen der Abfrage }
  gotoxy(3,22); write('                                     ');
  gotoxy(3,23); write('                                     ');
  gotoxy(3,24); for i:=1 to 40 do write(' ');
  { Isotop 1  }
  gotoxy(2,21); write('Au1 = ',au1:8:3);
  gotoxy(2,22); write('Ao1 = ',ao1:8:3);
  gotoxy(2,23); write('Bu1 = ',bu1:8:3);
  gotoxy(2,24); write('Bo1 = ',bo1:8:3);
  { Isotop 2  }
  gotoxy(18,21); write('Au2 = ',au2:8:3);
  gotoxy(18,22); write('Ao2 = ',ao2:8:3);
  gotoxy(18,23); write('Bu2 = ',bu2:8:3);
  gotoxy(18,24); write('Bo2 = ',bo2:8:3);
  { Drehimpulse }
  gotoxy(34,21); write('Ju = ',ju:2:1);
  gotoxy(34,22); write('Jo = ',jo:2:1);
  gotoxy(34,23); write('I1 = ',ikern1:2:1);
  gotoxy(34,24); write('I2 = ',ikern2:2:1);
  gotoxy(44,21); write('IS     = ',is:7:3);
  gotoxy(44,22); write('FWHM   = ',FWHM:7:0);
  gotoxy(44,23); write('E(min) = ',energmin:7:3);
  gotoxy(44,24); write('E(max) = ',energmax:7:3);
  gotoxy(64,21); write('Anz1 = ',linien_anzahl1:2);
  gotoxy(64,22); write('Anz2 = ',linien_anzahl2:2);
  { Abfrage }
  if (profil='L') then
    begin
      gotoxy(73,2); write('Lorentz');
      zeige:=TRUE;
      summation(zeige);
    end;
  if (profil='G') then
    begin
      gotoxy(73,2); write('Gauss  ');
      zeige:=TRUE;
      summation(zeige);
    end;
  if ((profil<>'L') and (profil<>'G')) then
    begin
      drucken;
      gotoxy(62,24); write('        <<RETURN>>');
      readln(ch);
      LeaveGraphic;
    end;
end { end_grafik };

{-------------------------------------------------------}
{--- Zeichnet die gefundenen HFS-Übergangsfrequenzen ---}
{-------  der beiden Isotope auf den Bildschirm. -------}
{-------------------------------------------------------}

procedure zeige_Spektrum_CRT(var kern1,kern2:real);
label ende1,ende2;
var  switcher : boolean;
begin { zeige_spektrum_crt }
  begin_grafik;

{ Isotop Nr. 1 }
  profanz:=0;
  gotoxy(3,24); write('Hfs-Berechnung des Isotops ',isotop1);
  { Zeichnen der E1[n,m] auf dem Bildschirm }
  for n:=0 to maxxu1 do
  begin
    for m:=maxxo1 downto 0 do
    begin
      if ( ( fu1[n]-fo1[m] = 0) or (abs( fu1[n] - fo1[m]) = 1) ) then
         begin
           if ( ( fu1[n]=0) and (fo1[m]=0) ) then goto ende1;
           profanz:=profanz+1;

           {  HFS-Übergang einzeichnen:    }
           x:=energie1[m,n];

           {  Linien-Intensitäten  }
           intensity:=intens(ju,jo,fu1[n],fo1[m],kern1)*skal_intensi;
           intensity:=intensity*grafik_skal*hf1;

           { Markierungen am oberen Rand setzen }
           DrawLine(x,850,x,870);

           { Einzelne Linienschwerpunkte einzeichnen }
           DrawLine(x,205,x,205+intensity);
           switcher:=TRUE;  { Einzel-Linien suchen & einzeichnen }
           gotoxy(11,23);
           write('- Profil Nr. : ',profanz:2);
             case profil of
               'L' : begin
                       lorentz_profil(x,intensity,switcher);
                       for i:=1 to aufloesung do ysuma[i]:=ysum[i]*hf1;
                     end;
               'G' : begin
                       gauss_profil(x,intensity,switcher);
                       for i:=1 to aufloesung do ysuma[i]:=ysum[i]*hf1;
                     end;

             end { of case };
           ende1:
         end { if };
    end { for };
  end { for };

{ Isotop Nr. 2 }
  profanz:=0;
  gotoxy(3,24); write('Hfs-Berechnung des Isotops ',isotop2);
  { Zeichnen der E2[n,m] auf dem Bildschirm }
  for n:=0 to maxxu2 do
  begin
    for m:=maxxo2 downto 0 do
    begin
      if ( ( fu2[n]-fo2[m] = 0) or (abs( fu2[n] - fo2[m]) = 1) ) then
         begin
           if ( ( fu2[n]=0) and (fo2[m]=0) ) then goto ende2;
           profanz:=profanz+1;

           {  HFS-šbergang einzeichnen:    }
           x:=energie2[m,n];

           {  Linien-Intensitäten  }
           intensity:=intens(ju,jo,fu2[n],fo2[m],kern2)*skal_intensi;
           intensity:=intensity*grafik_skal*hf2;

           { Markierungen am oberen Rand setzen }
           DrawLine(x,830,x,850);

           SetLineStyle(4); { gestrichelte Linie }
           { Einzelne Linienschwerpunkte einzeichnen }
           DrawLine(x,205,x,205+intensity);
           SetLineStyle(0); { durchgezogene Linie }

           switcher:=TRUE;  { Einzel-Linien suchen & einzeichnen }
           gotoxy(11,23);
           write('- Profil Nr. : ',profanz:2);
             case profil of
               'L' : begin
                       lorentz_profil(x,intensity,switcher);
                       for i:=1 to aufloesung do
                         ysuma[i]:=ysuma[i]+ysum[i]*hf2;
                     end;
               'G' : begin
                       gauss_profil(x,intensity,switcher);
                       for i:=1 to aufloesung do
                         ysuma[i]:=ysuma[i]+ysum[i]*hf2;
                     end;
             end { of case };
           ende2:
         end { if };
    end { for };
  end { for };

  end_grafik;
end { zeige_spektrum_crt };

{===================    H a u p t p r o g r a m m    ==================}

begin { main }
  { Anzeige der berechneten Werte beim Programmlauf }
  t:=40;
  belegen;
  werte_save:=TRUE;
  ladefacarr;  { Fakultäten-Array belegen }
  parameter_load;
  profil_parameter_load;
  untergrund:=untergrund+205;
  intro;
  repeat
    { Summen initialisieren }
    for i:=1 to aufloesung do ysum[i]:=0;
    linien_anzahl1:=0;
    linien_anzahl2:=0;
    parameter_eingeben;
    werte_speichern;
    clrscr;
    test:=TRUE;
    writeln('Berechnung läuft...');
    berechne_f(ikern1,ikern2);
    berechne_k(ikern1,ikern2);
    berechne_w(ao1,au1,bo1,bu1,ao2,au2,bo2,bu2,ikern1,ikern2);
    skal_intensity(ikern1,ikern2);
    energien_zuordnung(ikern1,ikern2);
    zeige_spektrum_CRT(ikern1,ikern2);
    if werte_save then save;
    write(#7,'Noch eine Zuordnung (J/N) ? ');
    readln(ch);
    ch:=upcase(ch);
  until ch='N';
  parameter_save;
  profil_parameter_save;
end { main }.

{====================   P r o g r a m m - E n d e    ==================}
