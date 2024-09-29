@echo off
rem --------------------------------------------------------------------------------------------
rem ------------ Automatische Speedmessung im vorgegebenen Zyklus ------------------------------
rem
rem - Bevor die Zyklus.bat ausgefuehrt wird muss beim erstmaligen Nutzen die speedtest.exe gestartet
rem   und den Lizenzbedingungen zweimal zugestimmt werden.
rem 
rem - Anschließend Zyklus.bat starten
rem 
rem 1 Zu Beginn werden mithilfe der speedtest.exe die 10 naechsten verfuegbaren Server ermittelt.
rem 2 Nach einer kurzen Dauer wurde die Geschwindigkeit zu diesen Servern gemessen.
rem   Hierbei sollten die Messdaten verglichen werden und sich der günstigste Server gemerkt werden.
rem 3 Mindestens einen günstigen Server auswaehlen, dieser wird dann im Zyklus gemessen
rem 4 Zykluszeit kann zwischen 1-60 min gewaehlt werden
rem 5 Zykl. Messung starten
rem   Die Ergebnisse werden in die Logdatei geschrieben.
rem T Einmalige Testmessung der ausgewaehlten Server
rem 
rem Erstellung durch D. Fischer  
rem Nutzung auf eigene Gefahr!
rem
rem Version
set "version=1.4"
title Zyklischer Speedtest V%version%
rem ---------------------------------------------------------------------------------------------

rem Initialisierung Variablen(min für Zyklus)
set "delay=30"
set "ID1=56365"
set "anwahl=X"
set "abwahl=O"
set "lzeile=##########################################################################"
set "secpmin=60"
set "bcycle=0"
set "leer"=' '


rem Auswahlmenue
:zurueck
cls
@echo off
echo ################ Version: %version% #################
echo ####                                       ####
echo ####              Hauptmenue               ####
echo ####                                       ####
echo ####   Menue in Reihenfolge abarbeiten     ####
echo ####   Taste fuer gewuenschte Funktion     ####
echo ####                                       ####
echo ####   1  = Serverliste neu einlesen       ####
echo ####   2  = Serverliste pruefen            ####
echo ####   3  = Server festlegen fuer Messung  ####
echo ####   4  = Zykluszeit einstellen          ####
echo ####   5  = Zykl. Messungen starten        ####
echo ####   T  = Messung testen                 ####
echo ####   PN = Patch-Notes                    ####
echo ####                                       ####
echo ####   0  = beenden                        #### 
echo ####                                       ####  
echo #### Messung durch beenden der Batch-Datei ####  
echo ####               stoppen.                #### 
echo ############################################### 

:auswahl
set /P wahl=Auswahl: 
if /i "%wahl%"=="1" goto :readin
if /i "%wahl%"=="2" goto :fulllist
if /i "%wahl%"=="3" goto :Sset
if /i "%wahl%"=="4" goto :rythm
if /i "%wahl%"=="5" goto :start
if /i "%wahl%"=="T" goto :test
if /i "%wahl%"=="PN" goto :Patch-Notes
if /i "%wahl%"=="0" goto :exit
echo Falsche Auswahl.
goto :auswahl

:readin
cls
@echo off
rem löschen der alten Daten
del serverlist.txt
del IDlist.txt

rem Liste der Verfügbaren 10 Server auflisten und abspeichern
speedtest.exe -L >serverlist.txt


rem Liste bereinigen -> nur noch Server
for %%i in (serverlist.txt) do (
more +4 "%%i">"%%i.temp"
del "%%i"
)
ren *.temp *.

rem Auswahl vorsetzen
for /f "tokens=1,2,3* delims=" %%a in (serverlist.txt) do (
echo %abwahl%; %%a %%b %%c>> IDlist.txt
)
echo %lzeile%
type serverlist.txt
echo %lzeile%
pause
goto :zurueck

rem Liste in Konsole schreiben für User
:refresh
:Sset
cls
@echo off
echo Server zur Zyklischen Messung hinzufuegen oder entfernen
echo Zeichen an erster Stelle zeigt an ob aktiviert(X) oder deaktivert(O)
echo Es muss mindestens ein Server ausgewaehlt werden.
echo %lzeile%
type IDlist.txt
echo %lzeile%
echo.
echo    1-10 = Server akt- und deaktivieren
echo       0 = zurueck zum Menue
echo.
echo %lzeile%
rem set "wahl1=0"
set /P wahl=Auswahl:
if /i "%wahl%"=="0" goto:zurueck
if %wahl% GTR 0 (
	if %wahl% LSS 11 (
	rem HIER IST NOCH DAS AKTIVIEREN O/X tauschen nötig
	rem Server mit X werden bei der Messung ausgeführt
	setlocal enableDelayedExpansion
	set "line=0"
		for /F "tokens=1,2 delims=;" %%a in (IDlist.txt) do (
			set /a line +=1
			if !line! equ %wahl% (
				if %%a == %anwahl% (
				 echo %abwahl%;%%b >>"Temp.txt"
				)
				if %%a == %abwahl% (
				 echo %anwahl%;%%b >>"Temp.txt"
				)
			) else (
			echo %%a;%%b >>"Temp.txt"
			)
		)
		del "IDlist.txt"
		copy "Temp.txt" "IDlist.txt"
		del "Temp.txt"
	goto :refresh
	)
)
echo Falsche Eingabe!
pause
goto :refresh

:fulllist
rem Sicherheitsabfrage
cls
@echo off
echo ####################################################
echo #### Die Serverliste zu pruefen ist zeitspielig ####
echo #### und nur einmalig zum ermitteln der Server  ####
echo #### noetig. Trotzdem durchfuehren?             ####
echo ####   Y  = Ja                                  #### 
echo ####   N  = Nein                                ####
echo ####                                            #### 
echo ####################################################

:auswahl3
set /P wahl=Auswahl: 
if /i "%wahl%"=="Y" goto :fullliststart
if /i "%wahl%"=="N" goto :zurueck
echo Falsche Auswahl.
goto :auswahl3

:fullliststart
rem Ausführung eines Speedtests an jeden Server
for /f "tokens=1,2* delims= " %%a in (serverlist.txt) do (
speedtest.exe -s %%a
)
pause
goto :zurueck


:start
cls
@echo off
echo %time:~0,-3% Messung mit %delay%min.-Zyklus gestartet
goto :readtime

:timeout
timeout %waittime% /nobreak
goto :measuring

:rythm
cls
@echo off
set /a ten=%delay%/10
if %ten% == 0 (
	set print= %delay%
) else (
	set print=%delay%
)
echo ###################################################
echo ####                                           ####
echo ####           Bitte waehle den Zyklus         ####
echo ####  Aktueller Zyklus: %print% min.                ####
echo ####                                           ####
echo ####  1-60 = Minuten festlegen                 ####
echo ####     0 = zurueck                           #### 
echo ####                                           #### 
echo ###################################################

:auswahl_Z
set /P wahl=Auswahl:
if /i "%wahl%"=="0" goto:zurueck
rem findstr /b ":%wahl%" "%~f0">nul || (echo Auswahl nicht gefunden & goto:auswahl_Z)
rem goto:%wahl%

if %wahl% GTR 0 (
	if %wahl% LSS 61 (
		set /a delay=%wahl% %% 100
		goto :rythm
	) else (
		echo Auswahl nicht zulaessig!
		pause
		goto :rythm
	)
) else (
	echo Auswahl nicht zulaessig!
	pause
	goto :rythm
)



:readtime
set "bcycle=1"
rem Abfrage der Zeit und extrahieren der Minute
set systemtime=%time:~3,-6%
set systemsec=%time:~6,-3%

rem Errechnung der zu wartenden Minuten
set /a a=(1%systemtime%-100) %% %delay%
rem echo Letzter Messpunkt vor %a% min.
set /a b=%delay%-%a%
set /a waittime=%b%*%secpmin%-(1%systemsec%-100)
rem echo Naechster Messpunkt in %b% min.
goto :timeout

rem Messung anstossen
:test
set "bcycle=0"
:measuring
set /A start=(1%time:~3,-6%-100)*%secpmin%+(1%time:~6,-3%-100)
echo %time:~0,-3% Messung gestartet
for /f "tokens=1,2,3* delims=; " %%a in (IDlist.txt) do (
	if %%a==%anwahl% (
		echo | set /p= ""%date:~0,10% %time:~0,5%"," >>Speedtest.log
		speedtest.exe --accept-gdpr -s %%b -f csv>>Speedtest.log
	)
)

rem Dauer der Messung fuer Userinfo
set /A stop=(1%time:~3,-6%-100)*%secpmin%+(1%time:~6,-3%-100)
set /A diff=%stop%-%start%
echo %time:~0,-3% Messung ausgefuehrt (%diff%s)
if %bcycle% == 1 (
	goto :readtime
) else (
	pause
	goto :zurueck
)

rem Patch-Notes
:Patch-Notes
cls
@echo off
echo ############################################################
echo ####                                                    ####
echo ####                    Patch-Notes                     ####
echo ####                    ===========                     #### 
echo ####                                                    ####
echo ####  1.0   Beta-Test                                   ####
echo ####  1.1   Integration Serverlist                      ####
echo ####  1.2   Integration Serverauswahl                   ####
echo ####  1.3   Anpassung Zeiten und Userinfos              ####
echo ####  1.4   Beseitigung math. Octal-Fehler              ####
echo ####                                                    ####
echo ####                                                    ####
echo ############################################################
pause
goto :zurueck

:exit
exit