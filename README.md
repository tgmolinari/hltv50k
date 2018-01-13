# hltv50k
Python code to grab screenshots from CS:GO while it's playing back a demo, and accompanying Torch code that takes the resulting screenshots and attempts to learn to classify which side (terrorist or counter-terrorist) will win a round given a single image. 

# implementation notes
The Python code is currently built for Python 2.7, but the changes to upgrade it to Python 3 compatibility are commented out right below the imports. The Torch code was built in Torch 7, and I intend to fix it up to work with cutorch as I now have a GPU that has enough memory to hold the dataset + model in memory.

# resources
Huge thanks to [this project by Peder Langdal](https://github.com/LangdalP/GoTimer) for inspiring the HTTP listener.
