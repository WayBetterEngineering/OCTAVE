#on windows run in cmd as admin or if using power shell as admin Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser

#on windows after running as admin cd cd C:\Users\ cd to desired install location from here

#example cd C:\Users\YourUserName\Downloads

git clone https://github.com/WayBetterEngineering/OCTAVE.git
cd OCTAVE

python -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate

pip install -r requirements.txt
