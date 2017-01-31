import multiprocessing
import os
from Queue import Empty
import chili_screen as cs
#  3 to 2 changes
# queue == Queue
# chili's code only works in python 2

class CSGOCameraMan(multiprocessing.Process):
	def __init__(self,msg_queue,match_id,data_source):
		multiprocessing.Process.__init__(self)
		self.msg_queue = msg_queue
		self.prev_round = 0
		self.t_score = 0
		self.ct_score = 0
		self.seq = 0
		self.score_swap_lock = 1
		if not(os.path.isdir("X:/camerawork/working")):
			os.mkdir("X:/camerawork/working")
		self.path = "X:/camerawork/working/"
		if data_source == "esea":
			self.live_flag = False
		else:
			self.live_flag = True
		self.halftime_flag = False
		self.halftime_lock = True
		self.match_id = match_id
		self.t_score = 0
		self.ct_score = 0
		self.ct_name = ""
		self.t_name = ""
#"phase": "intermission",
	def check_queue(self):
		try:
			message = self.msg_queue.get_nowait()
			if message[0] == 0:
				self.live_flag = True
				self.ct_name = message[2]
				self.t_name = message[1]
				print("RIGHT U ARE BOB")
			elif message[0] == 1:#message [2,curr_round]
				if(self.live_flag and not(self.halftime_flag)):
					print("CHICKA")
					self.snap(message[1])
			elif message[0] == 2:#update round[3,new_round]
				if(self.live_flag and not(self.halftime_flag)):
					print("Updating Round + Cleaning to " + str(message[1]+message[2])+"\n")
					prw = ""
					prw = self.update_round(message[1],message[2])#curr t score, curr ct score
					if(prw):
						os.rename("X:/camerawork/working","X:/camerawork/"+str(message[1]+message[2])+"_"+prw)
						os.mkdir("X:/camerawork/working")
			elif message[0] == 3:#halftime handler
				if self.halftime_lock:#if it goes live again we want to be there for it

					print("Handling that halftime")
					prw = ""
					prw = self.update_round(message[1],message[2])#curr t score, curr ct score
					if(prw):
						os.rename("X:/camerawork/working","X:/camerawork/"+str(message[1]+message[2])+"_"+prw)
						os.mkdir("X:/camerawork/working")				
					self.halftime_flag = True
					if message[3] == "freezetime":#possibly need to flip side scores when half changes
						print("Breaking halftime")
						self.halftime_flag = False
						self.halftime_lock = False
						if(self.score_swap_lock):
							self.t_score = self.t_score + self.ct_score
							self.ct_score = self.t_score - self.ct_score
							self.t_score = self.t_score - self.ct_score
							print("Swapping scoires at half")
							self.score_swap_lock = 0						
			else:	
				pass
		except Empty:
			pass

	def run(self):
		while(True):
			self.check_queue()
    
	def snap(self,curr_round):
		mmap = cs.grab_screen([-1491,523,-1091,923])#ImageGrab.grab(bbox=(1056,485,1456,885))
		mmap.save(self.path+str(curr_round)+"_"+str(self.seq)+".png")
		self.seq += 1

	def update_round(self,t_score,ct_score):
		if((t_score+ct_score) != self.prev_round): #it's new round
			if(self.t_score < t_score):
					prev_round_win = "T"
			elif(self.ct_score < ct_score):
				prev_round_win = "CT"
			self.prev_round = t_score+ct_score
			self.seq = 0
			self.t_score = t_score
			self.ct_score = ct_score
			return(str(prev_round_win))
			#if self.prev_round == 15:
			#	self.live_flag = False
