import cv2
import numpy as np
import glob
import os

img_array = []
frameRate = 6
for filename in sorted(glob.glob('../plot/*.png'), key=os.path.getmtime):
    print(filename)
    img = cv2.imread(filename)
    height, width, layers = img.shape
    size = (width, height)
    img_array.append(img)

out = cv2.VideoWriter('./project.avi', cv2.VideoWriter_fourcc(*'DIVX'), frameRate, size)

for i in range(len(img_array)):
    out.write(img_array[i])
out.release()

os.system("ffmpeg -i project.avi -vcodec libx264 project.mp4")
'''
cap = cv2.VideoCapture('./project.avi')
while cap.isOpened():
    ret, frame = cap.read()
    # if frame is read correctly ret is True
    if not ret:
        print("Can't receive frame (stream end?). Exiting ...")
        break
    gray = cv2.cvtColor(frame, cv2.COLOR_BGR2GRAY)
    cv2.imshow('frame', gray)
    if cv2.waitKey(1) == ord('q'):
        break
cap.release()
cv2.destroyAllWindows()
'''