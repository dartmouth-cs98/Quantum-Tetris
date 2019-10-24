# Quantum-Tetris

## Dev Environmental Setup Notes

### Conda
* Within your conda environment run the following commands
```
conda update --name base conda
conda install python==3.7
pip install qiskit
pip install pygame==1.9.2
```

### PyCharm
* Within PyCharm go to `Pycharm -> Preferences -> Project:[ProjectName] -> Project Interpreter`
* Then click on the `gear icon` on the top right and click `Add Local`. Navigate to the file `/anaconda3/envs/[ProjectName]/bin/python3.7`
* Click on this file and click add
### Running The Files
#### Tetris
* You should now be able to run the sample code for tetris using pygame. Once run using the green arrow, you should be able to click on the pop up'ed windown and play the tetris
#### Qiskit
* You should be able to run the basic qiskit code using the green arrow. The output should display the some vectors of the circuit.

## Resources
* https://github.com/dartmouth-cs98/19f-quantum-gaming.wiki.git
