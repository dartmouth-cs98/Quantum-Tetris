##  Quantum Tetris

Quantum Tetris is your traditional tetris game game who has several twists based on the concepts of quantum computing. Additionally, to implement this quantum functionality it uses IBM's qiskit library found [here](https://qiskit.org) which runs in the cloud on IBM's quantum computers.

To play our game you can go here: http://quantumtetris.surge.sh/

Backend can accessed via https://q-tetris-backend.herokuapp.com/

Link to [mockups](https://www.figma.com/file/ry3c6LBXIAP5A63igUO6YE/Quantum-Tetris?node-id=0%3A1).
## Architecture

The architecture of our project consists of a backend flask server that uses a PostgreSQL database to hold our player info. Our frontend is a simple html webpage that uses various graphics libraries to implement changes. We use GoDot to run our game in browser.

## Setup
### Dev Environmental Setup Notes
#### Conda
* The easiest way to manage all of our packages that we will need is with a Conda environment.
* If you don't have one yet, you can set one up [here](https://anaconda.org/)
* Once you set up your conda environment run the following commands.
```
conda update --name base conda
conda install python==3.7
python3 -m pip install --user qiskit
```
###### Note:
If you get an error regarding an "ssl" error run the following commands
```
brew uninstall openssl
brew install openssl
```

If you get an error trying to run the server in Pycharm like "ModuleNotFoundError: No module named 'app'" ensure than the folder "server" is marked as a source root

#### PyCharm
* Within PyCharm go to `Pycharm -> Preferences -> Project:[ProjectName] -> Project Interpreter`
* Then click on the `gear icon` on the top right and click `Add Local`. Navigate to the file `/anaconda3/envs/[ProjectName]/bin/python3.7`
* Click on this file and click add
* Additionally to set the environmental variable that you will need. go to `Pycharm -> Click on file name next to the green run button -> Edit configurations -> Click the ... to the left of the environmental variables dropdown -> add the following 2 environemntal variables DATABASE_URL=postgresql://localhost/quantum_tetris and APP_SETTINGS= config.DevelopmentConfig `

### How to Set Up Front End
* Navigate to the webapp directory
* Run the following commands
```
yarn
yarn start
```

### How to Set Up Backend
* Navigate to the server directory
* Make sure you have python3 installed if not install it [here]( https://www.python.org/downloads/)
* Also for local devving you will need to run a postgresql database in the background. The easiest way to set this up would be to follow the instructions found [here](https://postgresapp.com/)
* Run the following commands
```
pip install flask
pip install flask-cors
pip install sqlalchemy
export FLASK_APP=application
export FLASK_ENV=development
export DATABASE_URL="postgresql://localhost/quantum_tetris"
export PORT=5000
export APP_SETTINGS="config.DevelopmentConfig"
python -m application.manage db init
python -m application.manage db migrate
python -m application.manage db update
python -m application.manage runserver
```

## Deployment

#### Front end
* To deploy any local changes to surge, you can type `yarn deploy` while in the `webapp` directory
#### Back end
* To deploy any local changes to heroku, you can type `yarn heroku` while in the project's root directory.
## Authors

Trevor Glasgow, Oliver Levy, Henry Hilton and Rafael Brantley

## Acknowledgments
Tim Tregubov and Charles Palmer

## Resources

* Quantum Computing Notes: https://github.com/dartmouth-cs98/19f-quantum-gaming/wiki/Quantum-Computing-Notes
* Game Library Notes: https://github.com/dartmouth-cs98/19f-quantum-gaming/wiki/Game-Libraries-Research
