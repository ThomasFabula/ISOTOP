{  IPARAM.INC

   Parameter einlesen für das ISOTOP-Programm für
   jeweils   z w e i  Isotope
   A-, B-Faktoren    >  für jeweils den
   J-Drehimpulse     >  unteren/oberen Zustand
   I-Kernspin

}


{-----------------------------------------}
{--- Anfangsroutine Intro: allg. Daten  --}
{-----------------------------------------}

procedure intro;
var  ok : char;
     strx,strx1,strx2 : str12;
begin
  clrscr;
  highvideo;
  write(#201); for ij:=1 to 78 do write(#205); write(#187);
  gotoxy(1,2);
  write(#186,'   ISOTOPIE   -   Berechnung des Hfs-Spektrums zweier Isotope ');
  gotoxy(80,2); write(#186);
  gotoxy(1,3);
  write(#200); for ij:=1 to 78 do write(#205); write(#188);
  lowvideo;

  gotoxy(1,15);
  for ij:=1 to 80 do write(#205);
  gotoxy(1,17);
  for ij:=1 to 80 do write(#205);
  gotoxy(1,16);
  write(kommentar);

  repeat
    gotoxy(1,5);
    write('Bitte die Daten der Isotope eingeben :');
    gotoxy(1,7);
    write(' Welches Element (z.B.: Zirkon) : ',defaultelement);
    gotoxy(35,7);
    readln(strx);
    if ((strx<>defaultelement) and (length(strx)<>0))
     then element:=strx
     else element:=defaultelement;
    gotoxy(1,9);
    writeln('Welcher šbergang soll betrachtet werden ?');
    gotoxy(1,10);
    write(' Übergang von Zustand           : ',defaultvon);
    gotoxy(35,10);
    readln(strx1);
    gotoxy(1,11);
    write(' nach Zustand                   : ',defaultnach);
    gotoxy(35,11);
    readln(strx2);
    if ((strx1<>defaultvon) and (length(strx1)<>0))
     then vonzustand:=strx1
     else vonzustand:=defaultvon;
    if ((strx2<>defaultvon) and (length(strx2)<>0))
     then nachzustand:=strx2
     else nachzustand:=defaultnach;
    gotoxy(1,14);
    write(#7);
    write('Alle Parameter richtig (J/N) ? ');readln(ok);
    ok:=upcase(ok);
  until (ok='J');
end;

{-----------------------------------------}
{----  Eingaberoutine der Parameter  -----}
{-----------------------------------------}

procedure parameter_eingeben;
var  l,zei :integer;
     xao,xau,xbo,xbu,xjo,xju,xikern,xswp,xhauf,
     xunt,xfwhm,xaufl : real;
     strx : str8;

begin
  nulltestok:=FALSE;            { Sicherheitshalber: Parameter = Null }
  repeat
    clrscr;
    writeln('Bitte Parameter eingeben (u=unterer/o=oberer Zustand):');
    writeln('(A-, B-Faktoren in [MHz], Drehimpulse in h-Vielfachen)');
    repeat
    { Parameter aus ISOTOP.PAR abfragen }
      zei:=5;

    { Daten des Isotops Nr. 1 }
      gotoxy(1,zei-1); write('Isotop1 : ',isotop1:5);
      gotoxy(11,zei-1); readln(strx);
      if (length(strx)<>0) then isotop1:=strx;

      gotoxy(7,zei); writeln(ao1:9:4);
      xao:=realin(1,zei,'Ao1 = ',9);
      if xao<>0 then ao1:=xao;

      gotoxy(7,zei+1); writeln(au1:9:4);
      xau:=realin(1,zei+1,'Au1 = ',9);
      if xau<>0 then au1:=xau;

      gotoxy(7,zei+2); writeln(bo1:9:4);
      xbo:=realin(1,zei+2,'Bo1 = ',9);
      if xbo<>0 then bo1:=xbo;

      gotoxy(7,zei+3); writeln(bu1:9:4);
      xbu:=realin(1,zei+3,'Bu1 = ',9);
      if xbu<>0 then bu1:=xbu;

      gotoxy(7,zei+4); writeln(ikern1:3:1);
      xikern:=realin(1,zei+4,'I1  = ',3);
      if xikern<>0 then ikern1:=xikern;

      gotoxy(12,zei+5); writeln(hauf1:9:2,' [%]');
      xhauf:=realin(1,zei+5,'H„ufigk. = ',4);
      if xhauf<>0 then hauf1:=xhauf;

      gotoxy(12,zei+6); writeln(s1:9:4,' [MHz]');
      xswp:=realin(1,zei+6,'Schwpkt. = ',9);
      if xswp<>0 then s1:=xswp;

    { Daten des Isotops Nr. 2 }
      gotoxy(30,zei-1); write('Isotop2 : ',isotop2:5);
      gotoxy(40,zei-1); readln(strx);
      if (length(strx)<>0) then isotop2:=strx;

      gotoxy(36,zei); writeln(ao2:9:4);
      xao:=realin(30,zei,'Ao2 = ',9);
      if xao<>0 then ao2:=xao;

      gotoxy(36,zei+1); writeln(au2:9:4);
      xau:=realin(30,zei+1,'Au2 = ',9);
      if xau<>0 then au2:=xau;

      gotoxy(36,zei+2); writeln(bo2:9:4);
      xbo:=realin(30,zei+2,'Bo2 = ',9);
      if xbo<>0 then bo2:=xbo;

      gotoxy(36,zei+3); writeln(bu2:9:4);
      xbu:=realin(30,zei+3,'Bu2 = ',9);
      if xbu<>0 then bu2:=xbu;

      gotoxy(36,zei+4); writeln(ikern2:3:1);
      xikern:=realin(30,zei+4,'I2  = ',3);
      if xikern<>0 then ikern2:=xikern;

      gotoxy(41,zei+5); writeln(hauf2:9:2,' [%]');
      xhauf:=realin(30,zei+5,'H„ufigk. = ',4);
      if xhauf<>0 then hauf2:=xhauf;

      gotoxy(41,zei+6); writeln(s2:9:4,' [MHz]');
      xswp:=realin(30,zei+6,'Schwpkt. = ',9);
      if xswp<>0 then s2:=xswp;

    { Drehimpulse }
      gotoxy(6,zei+8); writeln(jo:3:1);
      xjo:=realin(1,zei+8,'Jo = ',3);
      if xjo<>0 then jo:=xjo;

      gotoxy(6,zei+9); writeln(ju:3:1);
      xju:=realin(1,zei+9,'Ju = ',3);
      if xju<>0 then ju:=xju;


    { Parameter aus IPROFIL.PAR abfragen }
      unt:=untergrund-205;

      gotoxy(43,zei+8); writeln(unt:4:0);
      xunt:=realin(30,zei+8,'Untergrund = ',4);
      if xunt<>0 then untergrund:=xunt+205;

      gotoxy(43,zei+9); writeln(FWHM:4:0);
      xfwhm:=realin(30,zei+9,'FWHM [MHz] = ',4);
      if xfwhm<>0 then FWHM:=xfwhm;

      gotoxy(43,zei+10); writeln(aufloesung:4);
      xaufl:=realin(30,zei+10,'Aufl”sung  = ',4);
      if xaufl<>0 then aufloesung:=trunc(xaufl);

      writeln(#7);
      gotoxy(1,zei+13);
      write('Alle Parameter richtig (J/N) ? ');readln(antwort);
      antwort:=upcase(antwort);
    until antwort='J';

    { Abfrage Drehimpulse ungleich Null }
    if (((ju=0) and (jo=0)) or (ikern1=0) or (ikern2=0)) then
      begin
        highvideo;
        gotoxy(1,19);
        for l:=1 to 80 do write(#205);
        gotoxy(1,21);
        for l:=1 to 80 do write(#205);
        gotoxy(1,20);
        writeln('ACHTUNG: Mind. ein Drehimpuls Ju, Jo  u n d  I1, I2 mssen ungleich Null sein !');
        write(#7,#7,#7);
        lowvideo;
        for t:=1 to 10000 do;
        readln;
      end
    else
      nulltestok:=TRUE;
  until nulltestok;
  is:=abs(s1-s2);  { Isotopieverschiebung }
end;


