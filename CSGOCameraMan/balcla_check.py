import re
import random

f = open("test_ds.csv","r")
lines = f.readlines()
f.close()
lines = lines[1:]
lock = True
#while(lock):
tr_l = []
te_l = []
tr_count_t = 0
tr_count_ct = 0
random.shuffle(lines)
random.shuffle(lines)
random.shuffle(lines)

print(round(.9*len(lines)))

tr_l = lines[:int(round(.9*len(lines)))]
te_l = lines[int(round(.9*len(lines))):]

for l in lines:
	l = re.sub("\n","",l)
	l = re.sub("\r","",l)
	path,rw = l.split(",")
	if(int(rw) == 1):
		tr_count_ct += 1
	else:
		tr_count_t += 1
print("test T " + str(tr_count_t))
print("test CT " + str(tr_count_ct))
tr_bal = round(float(tr_count_ct / (tr_count_t+tr_count_ct)),2)
'''
te_count_t = 0
te_count_ct = 0

for l in te_l:
	l = re.sub("\n","",l)
	path,rw = l.split(",")
	if(int(rw) == 1):
		te_count_ct += 1
	else:
		te_count_t += 1
print("TEST T " + str(te_count_t))
print("TEST CT " + str(te_count_ct))
te_bal = round(float(te_count_ct / (te_count_t+te_count_ct)),2)
if (abs(te_bal - tr_bal) <= .005): #if the difference between the class balance in train vs test is 3 or less percent we good
	lock = False

tr = open("full_train.csv","w")
te = open("full_test.csv","w")
tr.write("filename,label\n")
for i in tr_l:
	tr.write("/media/tom/shared/scaled/" + i)
tr.close()
te.write("filename,label\n")
for i in te_l:
	te.write("/media/tom/shared/scaled/" + i)
te.close()

tr = open("full_train.csv","w")
tr.write("filename,label\n")
for i in lines:
	tr.write("/media/tom/shared/scaled_train/" + i)
tr.close()
f = open("test_ds.csv","r")
lines = f.readlines()
f.close()
lines = lines[1:]
tr = open("full_test.csv","w")
tr.write("filename,label\n")
for i in lines:
	tr.write("/media/tom/shared/scaled_test/" + i)
tr.close()
'''