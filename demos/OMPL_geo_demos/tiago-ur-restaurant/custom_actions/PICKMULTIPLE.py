import kautham_python_interface as kautham

import ktmpb_python_interface

#from ktmpb_python_interface  import writePath
#from ktmpb_python_interface  import computeGraspControls

import xml.etree.ElementTree as ET
from collections import defaultdict

global path
global path_r
global pickmultiple
pickmultiple = defaultdict(lambda: defaultdict(dict))

def PICKMULTIPLE(node, pickmultiple,info,Line):  #management of the action on the task plan
    print("**************************************************************************")
    print("  PICKMULTIPLE ACTION  ")
    print("**************************************************************************")
    action=Line[0]
    rob= Line[1]
    obstacle = Line[2]
    #glass = Line[3]
    fromLocation = Line[3]

    print(action +" "+rob+" "+obstacle+" "+fromLocation)
    obsName = pickmultiple['Obj'] #Object_name
    obsNameA = pickmultiple['ObjA'] #Obj1_name
    print("This is test")
    print(obsName)
    print(obsNameA)
    robotIndex = pickmultiple['Rob'] #Robot_name 
    linkIndex = pickmultiple['Link']
    init = pickmultiple['Regioncontrols']
    Robot_control=pickmultiple['Cont']
    print("PREASSIGN")
    #Set robot control
    kautham.kSetRobControlsNoQuery(node, Robot_control)

    if 'Graspcontrols' in pickmultiple.keys():
        grasp_control =pickmultiple['Graspcontrols']
        for grasp in grasp_control.keys():
            #Set the move query in Kautham
            goal=grasp_control[str(grasp)]
            print("Searching path to Move to object position " )
            print("....Init= ", init)
            print("----Goal= ", goal)
            print("****Robot Control=",Robot_control)
            #Set robot control
            kautham.kSetRobControlsNoQuery(node, Robot_control)
            #Set the move query in Kautham
            kautham.kSetQuery(node, init,goal)
            #Solve query
            print("Solving Query to pickmultiple object")
            kautham.kSetPlannerParameter(node, "_Incremental (0/1)","0") #to assure a fresh GetPath
            path=kautham.kGetPath(node, 1)
            if path :
                print("-------- Path found: Moving to object position " )
                print('Storing Grasp Controls Used = ',grasp)
                info.graspControlsUsed=grasp
                break
            else:
                print("**************************************************************************")
                print("Get path Failed! No Move possible, Infeasible Task Plan\nTrying next graspcontrol")
                print("**************************************************************************")
    #Write path to taskfile
    if path:
        print("STARTING TASKFILE WRITING")
        print(info.taskfile)
        info.taskfile.write("\t<Transit>\n")
        k = sorted(list(path.keys()))[-1][1]+1 #number of joints
        p = sorted(list(path.keys()))[-1][0]+1 #number of points in the path
        for i in range(p):
            tex=''
            for j in range(0,k):
                tex=tex + str(path[i,j]) + " "
            ktmpb_python_interface.writePath(info.taskfile,tex)
        info.taskfile.write("\t</Transit>\n")
        kautham.kMoveRobot(node, goal)
    else:
        print("**************************************************************************")
        print("Get path Failed! No Move possible, Infeasible Task Plan")
        print("**************************************************************************")
        return False#break


    #Send pickmultiple query to kautham
    print("PREATACH")

    print ("Pickmultipleing object",obsName)
    kautham.kAttachObject(node, robotIndex, linkIndex, obsName)    
    kautham.kAttachObject(node, robotIndex, linkIndex, obsNameA)
    print("POSTATTSCH")

    #Move back to the home configuration of the region with the pickmultipleed object
    print("Searching path to Move back to the home configuration of the region")
    print("Init= ", goal)
    print("Goal= ", init)
    print("Robot Control=",Robot_control)
    #Set robot control
    kautham.kSetRobControlsNoQuery(node, Robot_control)
    kautham.kSetQuery(node, goal,init)
    kautham.kSetPlannerParameter(node, "_Incremental (0/1)","0") #to assure a fresh GetPath
    #kautham.kSetPlannerParameter(node, "Sampler 0(r) 1(h) 2(sdk) 3(g)","1")

    path_r= kautham.kGetPath(node, 1)
    if path_r:
        print("-------- Path found: Moving to the home configuration of the region " )
        #start transfer
        info.graspedobject= True
        #info.taskfile.write("\t<Transfer object = \"%s\" robot = \"%d\" link = \"%d\">\n" % (obsName, robotIndex, linkIndex))
        #Multitransfer
        info.taskfile.write("\t<MultiTransfer numobjects =\"2\" object1 = \"%s\" object2 = \"%s\" robot = \"%d\" link = \"%d\">\n" % (obsName, obsNameA, robotIndex, linkIndex))


        k = sorted(list(path_r.keys()))[-1][1]+1 #number of joints
        p = sorted(list(path_r.keys()))[-1][0]+1 #number of points in the path
        for i in range(p):
            tex=''
            for j in range(0,k):
                tex=tex + str(path_r[i,j]) + " "
            ktmpb_python_interface.writePath(info.taskfile,tex)
        kautham.kMoveRobot(node, init)
        #info.taskfile.write("\t</MultiTransfer>")

    else:
        print("**************************************************************************")
        print("Get path Failed! No Move after pickmultiple possible, Infeasible Task Plan")
        print("**************************************************************************")
        return False

    return True
    #return

def Pickmultiple_read(action_element): #reading from the tamp configuration file

    for val in action_element.attrib:
        globals()[val] = action_element.attrib[val]

    pickmultiple = {}
    grasp={}

    for el in action_element:
        try:
            globals()[el.tag] = int(el.text)
        except:
            try:
                globals()[el.tag] = [float(f) for f in str(el.text).strip().split()]
            except:
                globals()[el.tag] = str(el.text).strip()
        if el.tag == 'Graspcontrols': #variables with multiple entries should be added the same way
            grasp_name = el.get('grasp')
            graspcontrol= el.text
            graspcontrol=[float(f) for f in graspcontrol.split()]
            grasp[grasp_name]= graspcontrol
            globals()[el.tag] = grasp

        pickmultiple.update({el.tag : globals()[el.tag]})

    if len(grasp)==0:
        print('No grasp conf found - This may be a problem')
    else:
        print('grasp = ', grasp)

    return pickmultiple
