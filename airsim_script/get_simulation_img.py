import airsim
from PIL import Image
import cv2
import numpy as np
import io,json,time,random,os

NUM_IMG = 500

class airsim_image_generator:
    def __init__(self,file_path = "", output_path = ".") -> None:
        if file_path == "":
            document_path = os.path.expanduser("~\\Documents")
            file_path = os.path.join(document_path, "Airsim", "settings.json")
        
        self.client = airsim.MultirotorClient()
        self._read_airsim_config_(file_path)

        self.output_path = os.path.join(os.path.relpath(output_path) , "dataset")
        self.image_path = os.path.join(self.output_path , "images")
        self.label_path = os.path.join(self.output_path , "labels")
        os.makedirs(self.image_path, exist_ok=True)
        os.makedirs(self.label_path, exist_ok=True)

        self.dataset_index = 0
        
        

    def simulation_loop(self, xy_range = 5, h_range = 2, h0 = -10):

        self._rand_distribute_(xy_range,h_range,h0)
        #self.set_distribute()
        
        img = self._capture_cam_front_()
        angle_xy, angle_z, drone_index = self._calculate_relative_angle_(1)
        
        pos_in_img, img_drone_index = self._get_pos_in_img_(angle_xy,angle_z,drone_index)

        self._pic_to_yolov5_(self.dataset_index,img,pos_in_img)
        self.dataset_index = self.dataset_index + 1

        return img, pos_in_img, img_drone_index

    def _read_airsim_config_(self,file_path):
        # 读取JSON文件
        with open(file_path, 'r') as json_file:
            data = json.load(json_file)
            
            try:
                self.im_width = data["CameraDefaults"]["CaptureSettings"][0]["Width"]
                self.im_height = data["CameraDefaults"]["CaptureSettings"][0]["Height"]
                self.fov = data["CameraDefaults"]["CaptureSettings"][0]["FOV_Degrees"]
            except:
                self.im_width = 256
                self.im_height = 144
                self.fov = 90

            vehicles_dict = data.get("Vehicles", {})
            self.num_drones = len(vehicles_dict)
        
        self._get_airsim_camera_K_()
    
    def _get_airsim_camera_K_(self):
        fov_rad = np.radians(self.fov)
        fx = (self.im_width/2) / (np.tan(fov_rad/2))
        fy = fx
        self.K = np.array([
            [fx,    0,      self.im_width/2],
            [0,     fy,     self.im_height/2],
            [0,     0,      1]
        ])

    def _rand_distribute_(self, xy_range, h_range, h0, x0_range = 50):
        drones = [f'Drone{i+1}' for i in range(self.num_drones)]
        x0 = random.uniform(-x0_range,x0_range)
        y0 = random.uniform(-x0_range,x0_range)
        for drone in drones:
            if drone != "Drone1":
                x = random.uniform(10-xy_range*0.5, 10+xy_range*0.5) + x0
                y = random.uniform(-xy_range*1.25, xy_range*1.25) + y0
                z = random.uniform(h0 - h_range, h0 + h_range)
            else:
                x = x0
                y = y0
                z = h0
            self.client.simSetVehiclePose(airsim.Pose(airsim.Vector3r(x, y, z),
                                                      airsim.to_quaternion(0, 0, 0)), 
                                                      True, 
                                                      vehicle_name=drone)
        
    
    def set_distribute(self,pos = [[0,0,-10],[5,-4,-10],[5,0,-12],[5,5,-13],[5,10,-14]]):
        drones = [f'Drone{i+1}' for i in range(self.num_drones)]
        l = len(pos)
        for index, drone in enumerate(drones):
            if index > l - 1:
                return
            self.client.simSetVehiclePose(airsim.Pose(airsim.Vector3r(pos[index][0],pos[index][1],pos[index][2]),
                                                      airsim.to_quaternion(0, 0, 0)), 
                                                      True, 
                                                      vehicle_name=drone)
        


    def _calculate_relative_angle_(self, idx):
        drones = [f'Drone{i+1}' for i in range(self.num_drones)]

        angle_xy = np.zeros(self.num_drones - 1)
        angle_z = np.zeros(self.num_drones - 1)
        drone_index = np.zeros(self.num_drones - 1)

        pose = self.client.simGetVehiclePose(vehicle_name=f'Drone{idx}')
        p0 = np.array([pose.position.x_val,pose.position.y_val,pose.position.z_val])

        i = int(0)
        x_std = np.array([1,0,0])
        
        for index, drone in enumerate(drones):
            if drone == f'Drone{idx}':
                continue
            pose = self.client.simGetVehiclePose(vehicle_name=drone)
            p1 = np.array([pose.position.x_val,pose.position.y_val,pose.position.z_val])
            realtive = p1 - p0
            angle_xy[i] = np.arccos(np.dot(realtive[:-1], x_std[:-1]) / (np.linalg.norm(realtive[:-1])))
            if np.cross(x_std[:-1],realtive[:-1]) < 0:
                angle_xy[i] = -angle_xy[i]
            #distance_xy = np.linalg.norm(realtive[:-1])
            angle_z[i] = np.arctan2(realtive[2], np.abs(realtive[0]))
            drone_index[i] = index

            i = i+1
                
        return angle_xy, angle_z, drone_index

    def _capture_cam_front_(self):
        responses = self.client.simGetImages([
            airsim.ImageRequest(camera_name='front_center', image_type=airsim.ImageType.Scene)
        ])
        self.client.simPause(False)
        image = Image.open(io.BytesIO(responses[0].image_data_uint8))
        return image

    def _get_pos_in_img_(self, angle_xy, angle_z, drone_index):

        # 相机内参矩阵
        fx = self.K[0][0]
        fy = self.K[1][1]
        cx = self.K[0][2]
        cy = self.K[1][2]
        height = cx * 2
        width = cy * 2

        # 初始化返回值
        pos_in_img = []
        img_drone_index = []

        for i, (xy_angle, z_angle, index) in enumerate(zip(angle_xy, angle_z, drone_index)):
               
            u = fx*np.tan(xy_angle) * 1.05
            v = fy*np.tan(z_angle) * 1.05
            x = u + cx
            y = v + cy

            # 如果投影点在图像内，则添加到返回列表中
            if 0 <= x < height and 0 <= y < width:
                pos_in_img.append([x, y])
                img_drone_index.append(index)

        return np.array(pos_in_img), img_drone_index
    
    def _undistorted_image_(self, im):
        im_cv = cv2.cvtColor(np.array(im), cv2.COLOR_RGB2BGR)
    
        distortion_params = self.client.simGetDistortionParams(camera_name="front_center",vehicle_name="Drone1")

        distortion_coeffs = np.array(distortion_params)
        new_camera_matrix = self.K

        undistorted_im = cv2.undistort(im_cv, self.K, distortion_coeffs, None, new_camera_matrix)
        undistorted_im_pil = Image.fromarray(cv2.cvtColor(undistorted_im, cv2.COLOR_BGR2RGB))
        
        return undistorted_im_pil
    
    def _pic_to_yolov5_(self,id,img,pos_in_img,box_width = 0.04, box_height = 0.02):
        h,w = img.size
        realtive_pos = np.zeros_like(pos_in_img)
        realtive_pos[:,0]  = pos_in_img[:,0]/ h
        realtive_pos[:,1]  = pos_in_img[:,1]/ w
        img = self._undistorted_image_(img)
        img = img.convert('RGB')
        img.save(os.path.join(self.image_path, f"{id}.jpg"))
        
        with open(os.path.join(self.label_path, f"{id}.txt"), 'w' ) as f:
            f.writelines(f'0 {pos[0]} {pos[1]} {box_width} {box_height}\n' for pos in realtive_pos)
        f.close()
        

if __name__ == "__main__":
    imgen = airsim_image_generator()
    import matplotlib.pyplot as plt
    plt.ion()

    
    for i in range(NUM_IMG):
        img, pos_in_img, img_drone_index = imgen.simulation_loop(h0= -50)
        # plt.imshow(imgen._undistorted_image_(img))
        # plt.scatter(pos_in_img[:,0],pos_in_img[:,1])
        # plt.pause(0.1)
        # plt.cla()