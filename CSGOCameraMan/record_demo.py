#The project at the URL below helped greatly in setting up the overall structure of the cameraman
#https://github.com/LangdalP/GoTimer/blob/master/go_timer.py

import multiprocessing

from listener import ListenerWrapper
from CSGOCameraMan import CSGOCameraMan

def main():
    queue = multiprocessing.Queue()
    cm = CSGOCameraMan(queue,"","not_esea")
    listener = ListenerWrapper(queue)

    listener.start()
    cm.start()

    listener.join()
    cm.join()
  
if __name__ == "__main__":
    main()