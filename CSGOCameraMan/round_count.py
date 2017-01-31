import os
t_count = 0
ct_count = 0
total = 0
path = "/media/tom/shared/camerawork/completed/unscaled/"
m_dirs = os.listdir(path)


count = 0
for m_d in m_dirs:
	
	r_dirs = os.listdir(path+m_d)
	for r_d in r_dirs:
		if "_T" in r_d:
			t_count += 1
		else:
			ct_count += 1
		count += 1	

print("Total: ", count)
print("CT: ", ct_count)#537
print("T: ", t_count)#529