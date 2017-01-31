from PIL import Image
import os
out ="/media/tom/shared/scaled/"
path = "/media/tom/shared/camerawork/completed/unscaled/"
m_dirs = os.listdir(path)

for m_d in m_dirs:
	count = 0
	r_dirs = os.listdir(path+m_d)
	for r_d in r_dirs:
		rw = r_d.split("_")
		curr_path = path + m_d +"/"+ r_d
		pics = os.listdir(curr_path)
		for p in pics[3:]:
			im = Image.open(curr_path+"/"+p)
			im = im.resize([200,200])
			im.save(out +"/"+ m_d+"_"+rw[1]+"_"+str(count)+"_"+str(rw[0])+"_"+p)
		count += 1