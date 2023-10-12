import os
import random
import cv2

def visualize_random_images(dataset_path, num_images=5):
    image_folder = os.path.join(dataset_path, 'images')
    label_folder = os.path.join(dataset_path, 'labels')

    if not os.path.exists(image_folder) or not os.path.exists(label_folder):
        print("Error: Dataset folders not found!")
        return

    image_files = os.listdir(image_folder)
    image_files = [file for file in image_files if file.endswith(('.jpg', '.png', '.jpeg'))]
    num_images = min(num_images, len(image_files))

    if num_images == 0:
        print("Error: No image files found in the dataset!")
        return

    for _ in range(num_images):
        image_file = random.choice(image_files)
        image_path = os.path.join(image_folder, image_file)

        label_file = os.path.splitext(image_file)[0] + '.txt'
        label_path = os.path.join(label_folder, label_file)

        if not os.path.exists(label_path):
            continue

        image = cv2.imread(image_path)
        height, width = image.shape[:2]

        with open(label_path, 'r') as f:
            lines = f.readlines()

        for line in lines:
            class_id, x_center, y_center, box_width, box_height = map(float, line.split())
            x1 = int((x_center - box_width / 2) * width)
            y1 = int((y_center - box_height / 2) * height)
            x2 = int((x_center + box_width / 2) * width)
            y2 = int((y_center + box_height / 2) * height)

            image = cv2.rectangle(image, (x1, y1), (x2, y2), (0, 255, 0), 2)

        cv2.imshow('Image with Bounding Boxes', image)
        cv2.waitKey(0)
        cv2.destroyAllWindows()

if __name__ == "__main__":
    path_to_dataset = "./dataset"
    num_images_to_visualize = 5
    visualize_random_images(path_to_dataset, num_images_to_visualize)