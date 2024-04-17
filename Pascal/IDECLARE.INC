{  IDECLARE.INC

    Deklarationen zu ISOTOP.PAS

    (C) 1987  Institut für Angewandte Physik
              Universität Bonn

}


{-----------------------------------------}
{--------  Variablendeklarationen   ------}
{-----------------------------------------}

const   h           =  1;     {  Planck'sches Wirkungsquantum [Js] }
        anzahl      =  30;
        lmax        = 100;    {  Anzahl aller gefundenen Linien }
        grafik_skal = 500;    { Skalierung der Intensitäten fr Bildschirm }

type    str5        = string[5];
        str8        = string[8];
        str12       = string[12];
        str15       = string[15];
        str80       = string[80];
        HFS_energie = array [1..anzahl,1..anzahl] of real;
        HFS_linie   = record
                        energy    : real;   { Linienschwerpunkt      }
                        fo        : real;   { Gesamtdrehimpuls oben  }
                        fu        : real;   { Gesamtdrehimpuls unten }
                        intensity : real;   { Linienamplitude        }
                        linewidth : real;   { Linienhalbwertsbreite  }
                      end;

var   au1,ao1,bu1,bo1      : real;        { HFS-Konstanten Isotop1   }
      au2,ao2,bu2,bo2      : real;        { HFS-Konstanten Isotop2   }
      ikern1,ikern2        : real;        { Kern-Drehimpulse         }
      isotop1              : str5;        { Bezeichnung Isotop1      }
      isotop2              : str5;        { Bezeichnung Isotop2      }
      hauf1,hauf2          : real;        { relative Häufigkeiten    }
      is                   : real;        { Isotopieverschiebung     }
      s1,s2                : real;        {  Schwerpunkte            }

      untergrund           : real;        { siehe unten }
      FWHM                 : real;        {   "     "   }
      aufloesung           : integer;
      { Variablen - Untergrund :  Untergrundrate der Linien-Intensitäten
                  - FWHM       :  Halbwertsbreite der Linien
                                  (Full-Width-Half-Maximum)
                  - Aufloesung :  Punktaufloesung der Lorentzlinie
                                  stehen in der Parameterdatei IPROFIL.PAR }

      ju,jo,j,max           : real;        {  Drehimpulse               }
      f,k                   : real;        {  Hilfsvariablen            }
      hf1,hf2,unt           : real;        {  Hilfsvariablen            }
      i,ii,ik,ij,t          : integer;     {  Hilfsvariablen            }
      intensity             : real;        {  Linien-Intensität         }
      maxxu1,maxxu2         : integer;     {  max unterer Drehimp.wert  }
      maxxo1,maxxo2         : integer;     {  max oberer Drehimpulswert }
      n,l,m                 : integer;     {  Schleifenidices           }
      fu1,fo1,ku1,ko1       : array [0..15] of real; { Drehimpulsarrays }
      fu2,fo2,ku2,ko2       : array [0..15] of real; { Drehimpulsarrays }
      wu1,wo1,wu2,wo2       : array [0..15] of real; { Energiearrays    }
      ff,kk,ww              : array [0..15] of real; { Hilfsarrays      }
      antwort,ch            : char;        {  Steuervariable            }
      test                  : boolean;     {  Programmtestflag          }
      werte_save            : boolean;     {  Werteabspeicherflag       }
      nulltestok            : boolean;     {  Testflag ob Parameter I,  }
                                           {  Jo, Ju ungleich Null sind }
      x                     : real;        {  Energiewert-Abszisse      }
      energie1,energie2     : HFS_energie; {  Energieverschiebung       }
      linie                 : array [1..lmax] of HFS_linie;
                                          {  HFS-Liniendaten           }
      energmin1,energmin2  : real;        {  Minimaler Energiewert     }
      energmax1,energmax2  : real;        {  Maximaler Energiewert     }
      energmin             : real;        {  Minimaler Energiewert     }
      energmax             : real;        {  Maximaler Energiewert     }
      hfsaufsp             : real;        {  gesamte Hfs-Aufspaltung   }
      element              : str15;       {  nach Periodensystem       }
      vonzustand           : str15;       {  Zustand von ...           }
      nachzustand          : str15;       {  ... nach Zustand          }
      spekname             : str12;       {  Dateiname des Spektrums   }
      profildatei          : str12;       {  Dateiname Profilparameter }
      datnam               : str8;        {  Hilsvariable              }
      datname              : str12;       {  Dateiname der berechneten }
                                          {  Werte: Fu, Fo, Wu, Wo, E  }
      filvar               : text;        {  File-variable             }
      linien_anzahl1       : integer;     {  Linienanzahl Isotop Nr.1  }
      linien_anzahl2       : integer;     {  Linienanzahl Isotop Nr.2  }
      defaultelement       : str15;       {  Element                   }
      defaultvon           : str15;       {  Zustand von ...           }
      defaultnach          : str15;       {  ... nach Zustand          }
      kom                  : str80;       {  Hilfsvariable             }
      kommentar            : str80;       {  Kommentarzeile            }
      pardatei             : str12;       {  Parameterdateiname        }
      meldung_param        : str80;       {  Fehlermeldung             }

      intensi      : real;            { Hilfsvariable }
      skal_intensi : real;            { Skalierung Int(max) = 100 % }
      x_links      : real;            { linke  Bildschirmkante }
      x_rechts     : real;            { rechte Bildschirmkante }
      xlo,ylo      : real;            { Hilfsvariablen Lorentz }
      deltalo      : real;            {       "           "    }
      x_min,x_max  : real;            { Hilfsvariablen Grafik  }
      delta_X,null : real;            {       "           "    }
      offset       : real;            {       "           "    }
      profil       : char;            { Auswahl Profilart (L/G)}
      sum          : char;            { Auswahl Summation      }
      profanz      : integer;         { akt. gez. Profil       }
      ysum,ysuma   : array [1..1000] of real;
                                      { Aufsummiertes Linienprofil }
      skal_sum     : real;            { Skalierung Sum(max) = 100 % }
      ijk          : integer;         { Laufindex              }
      schalter     : boolean;         { Steuervariable         }
      summi        : integer;         { Zähler für Profilberechnung }

