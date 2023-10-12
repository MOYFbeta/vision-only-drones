import torch
from PIL import Image
import numpy as np

import matplotlib
matplotlib.use('TkAgg')
import matplotlib.pyplot as plt
import matplotlib.patches as patches

model = torch.hub.load('ultralytics/yolov5', 'custom',
                       path='exp6\\best.pt'
                       )


def sort_coordinates(coordinates):
    sorted_coords = sorted(coordinates, key=lambda coord: (-coord[0], coord[1]))
    return sorted_coords

def read_yolov5_labels(label_file_path):
    with open(label_file_path, 'r') as f:
        lines = f.readlines()

    coordinates = []
    for line in lines:
        data = line.strip().split()
        if len(data) > 1:
            class_id = int(data[0])
            x_center = float(data[1])
            y_center = float(data[2])
            coordinates.append([x_center, y_center])

    sorted_coords = sort_coordinates(coordinates)
    return sorted_coords

error = 0
num = 0
dataset_no = '_3'
for i in range(500):

    image = Image.open(f'C:\\Users\\14152\\Desktop\\drone\\dataset{dataset_no}\\images\\{i}.jpg')
    label_path = f'C:\\Users\\14152\\Desktop\\drone\\dataset{dataset_no}\\labels\\{i}.txt'
    if image.mode == 'RGBA':
        image = image.convert('RGB')

    predictions = model(image, size=640)

    boxes = predictions.xyxy[0].cpu().numpy()
    scores = boxes[:, 4]
    labels = boxes[:, 5]



    #fig, ax = plt.subplots(1)
    #image_array = np.array(image)
    #ax.imshow(image_array)

    cent = []

    for box, score, label in zip(boxes, scores, labels):
        num = num + 1
        
        x1, y1, x2, y2 = box[:4]
        # width = x2 - x1
        # height = y2 - y1
        
        # rect = patches.Rectangle((x1, y1), width, height, linewidth=1, edgecolor='r', facecolor='none')
        # ax.add_patch(rect)
        
        # label_text = f'{score:.2f}'
        # ax.text(x1, y1, label_text, bbox=dict(facecolor='white', alpha=0.5))
        
        cent.append([(x1+x2)/(2*image.width),(y1+y2)/(2*image.height)])

    pred = np.array(sort_coordinates(cent))
    truth = np.array(read_yolov5_labels(label_path))

    if(len(truth)==len(pred)):
        for j in range(len(truth)):
            distance = np.linalg.norm(pred[j] - truth[j])
            error += distance
    elif(len(pred) > 0):
        for j in range(len(truth)):
            min_dis = 999
            for k in range(len(pred)):
                min_dis = min(np.linalg.norm(pred[k] - truth[j]),min_dis)
            error += min(min_dis,10)
    else:
        pass

print(error/num)


    # plt.axis('off')
    # plt.show()