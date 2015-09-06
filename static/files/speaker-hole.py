# Speaker hole drill pattern
# a simple script that draws a speaker pattern with the wellknown 8-16-20-20-20... holes pattern
# feel free to reuse!
# Japalan @ http://kalshagar.wikispaces.com/
# 2012/08/16

from tkinter import *
import math

def cercle (x,y,rayon, couleur='black', pfill=''):
	can1.create_oval(x-rayon,y-rayon, x+rayon,y+rayon, outline=couleur, width=1, fill=pfill)

def multicircle (splitin,rayonCenter, holerayon):
	for z in range(1,splitin+1):
		x1 = rayonCenter * math.sin(z * 2 * math.pi / splitin) + winw/2
		y1 = rayonCenter * math.cos(z * 2 * math.pi / splitin) + winh/2
		cercle (x1,y1,holerayon,pfill='black')
	
#globals
hole = 8
winw = 500
winh = 500
root = Tk()
can1 = Canvas(root,bg='whitesmoke',height=winw,width=winh)
can1.pack(side=LEFT)

#mire
can1.create_line(winw/2,0,winw/2,winh,width=1,fill='red')
can1.create_line(0,winh/2,winw,winh/2,width=1,fill='red')

#cercles concentriques
#"trace d'un cercle de centre (x,y) et de rayon r"
#r = 100
#can1.create_oval(winw/2-r, winh/2-r, winw/2+r, winh/2+r, outline='red', width=1)
#cercle (winw/2, winh/2,rayon = 200, couleur='green')

for r in range(1,6):
	cercle(winw/2, winh/2,rayon = r * 40, couleur='Gainsboro')
	
#one in the center
cercle(winw/2,winw/2,rayon=hole,pfill='black')
#premier cercle, 8
multicircle(splitin=8, rayonCenter=40, holerayon=hole)
#then 16
multicircle(splitin=16, rayonCenter=80, holerayon=hole)
#then 20 multiple times
multicircle(splitin=20, rayonCenter=120, holerayon=hole)
multicircle(splitin=20, rayonCenter=160, holerayon=hole)
multicircle(splitin=20, rayonCenter=200, holerayon=hole)

#final : main loop and listen to events
root.mainloop()

