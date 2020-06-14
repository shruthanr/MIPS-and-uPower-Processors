Simulator for the nanoPower ISA

Default registers:
0: To store zero
30: System Call Code
29: Argument for system call
28: Output of system call

Requirments:
Python 3.x
Numpy (pip install numpy)
bitstring (pip install bitstring)

Run using:
python simulate.py (or python3 simulate.py)  // complete execution
python simulate_step.py (or python3 simulate_step.py) // For step-by-step execution

Set the filename parameter in the file mm.py to run the code written in the nanoPower ISA. It should be in a .txt format. 