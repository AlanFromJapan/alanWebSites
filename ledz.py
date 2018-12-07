##################################################################################################
##        A small module to blink Led when a page is served (because I can)                     ##
##################################################################################################

# External module imports
#import RPi.GPIO as GPIO
import time
from concurrent import futures

# Pin Definitons:
_ledPin = 21
# blink ON duration in sec
_blink_duration = 0.15

# https://stackoverflow.com/questions/19033818/how-to-call-a-function-on-a-running-python-thread
# https://docs.python.org/3.4/library/concurrent.futures.html
# generating the executor takes time (200-300 ms on  the Raspi Zero) so do it once and reuse it thoughout the whole program execution
_executor = futures.ThreadPoolExecutor(max_workers=5)

########################################################################
## The blink function: pass the call to a worker thread to allow server to continue do serve pages 
def ledz_blink():
    #Multithreading
    _b = _blinker()
    _executor.submit(_b.blink)
    
########################################################################
# Multithreading needs a class, there it is
# https://stackoverflow.com/questions/19033818/how-to-call-a-function-on-a-running-python-thread
class _blinker:
    def blink(self):
#        GPIO.output(_ledPin, True)
        time.sleep(_blink_duration)    
#        GPIO.output(_ledPin, False)

########################################################################
## Init function, call it on startup        
def ledz_init(c):
    print ("INFO: called ledz_init()")

    #read pin from config
    global _ledPin
    _ledPin = c.getint("Ledz", "pin")
    # Pin Setup:
#    GPIO.setmode(GPIO.BCM) # Broadcom pin-numbering scheme
#    GPIO.setup(_ledPin, GPIO.OUT) # LED pin set as output
    # Initial state for LEDs:
#    GPIO.output(_ledPin, GPIO.LOW)

########################################################################
## Finalization, call on close    
def ledz_finalize():
    print ("INFO: called ledz_finalize()") 
#    GPIO.cleanup() # cleanup all GPIO
