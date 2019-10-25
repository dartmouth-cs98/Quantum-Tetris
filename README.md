# Quantum-Tetris

Quantum Tetris is your traditional tetris game game with several twists based on quantum mechanics and using a REAL quantum computer. Link to mockups https://www.figma.com/file/ry3c6LBXIAP5A63igUO6YE/Quantum-Tetris?node-id=0%3A1
## Architecture

So far the architecture of our project consists of a backend flask server and frontend react webpage. More to come with the exact architecture.

## Setup

### How to Set Up Front End
* Navigate to the Landing Page directory
* Run the following commands
```
yarn
yarn start
```
* NOTE: This is a remnant of the flask tutorial that I completed from CS52. I could have stripped it of all of its inner workings so that it would be truly a "Hello World" type set up. However, I think the already set up server will help us when it comes time to flesh out the front end

### How to Set Up Backend
* Navigate to the flask directory
* Make sure you have python3 installed if not install it here https://www.python.org/downloads/
* Run this command to install flask 
```
pip install flask
```
* Lastly the following commands you will be presented with a hello worldish screen when you follow the link in the terminal
```
export FLASK_APP=app
export FLASK_ENV=development
python -m flask run
```
* NOTE: This is a remanent of the flask tutorial that I completed from CS52. I could have stripped it of all of its inner workings so that it would be truly a "Hello World" type set up. However, I think the already set up server will help us when it comes time to flesh out the backend
### Dev Environmental Setup Notes

#### Conda
* Within your conda environment run the following commands
```
conda update --name base conda
conda install python==3.7
pip install qiskit
pip install pygame==1.9.2
```

#### PyCharm
* Within PyCharm go to `Pycharm -> Preferences -> Project:[ProjectName] -> Project Interpreter`
* Then click on the `gear icon` on the top right and click `Add Local`. Navigate to the file `/anaconda3/envs/[ProjectName]/bin/python3.7`
* Click on this file and click add

## Deployment

### Running The Files
#### Tetris
* You should now be able to run the sample code for tetris using pygame. Once run using the green arrow, you should be able to click on the pop up'ed windown and play the tetris
#### Qiskit
* You should be able to run the basic qiskit code using the green arrow. The output should display the some vectors of the circuit.

## Authors

Trevor Glasgow, Oliver Levy, Henry Hilton and Rafael Brantley

## Acknowledgments
Tim Tregubov and Charles Palmer

## Resources

* Quantum Computing Notes: https://github.com/dartmouth-cs98/19f-quantum-gaming/wiki/Quantum-Computing-Notes
* Game Library Notes: https://github.com/dartmouth-cs98/19f-quantum-gaming/wiki/Game-Libraries-Research
