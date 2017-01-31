import os
pics = os.listdir("/media/tom/shared/scaled_train/")
out = open("train_ds.csv","w")
out.write("filename,label\n")
for p in pics:
	rw = ""
	if "CT" in p:
		rw = "1"
	else:
		rw = "0"
	out.write(p+","+rw+"\n")
out.close()

