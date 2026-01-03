@echo off
echo Démarrage de l'application Muscu EPS...

:: Ouvre le navigateur par défaut
start "" "http://localhost:5173"

:: Lance le serveur de développement
call npm run dev

pause
