# Blender Version: 2.80 2019-07-29

import bpy
import mathutils
from mathutils import Vector
import bmesh
from bpy import context
import numpy as np

def deCasteljau(cPoly, t):
    # deCasteljau() is adapted from the sample code shown in tutoral by TA (Johannes)
    nrCPs = len(cPoly)

    # P = (CPs, coordinates, levels)
    P = np.zeros((nrCPs, 3, nrCPs))
    P[:,:,0] = cPoly

    # Double loop to calculate level-by-level with parameter t
    for i in range (0, nrCPs):
        for j in range (0, nrCPs-i-1):
            P[j,:,i+1] = (1-t)*P[j,:,i] + t*P[j+1,:,i]

    # Return the point at the last level, 
    # which is the point to be estimated on the bezier curve
    point = P[0,:,nrCPs-1]
    return point

def Coons(t, u, curve1, curve2, curve3, curve4):
    
    # Get the 4 points which determine the smooth slide (M3)
    A = curve1[0]
    B = curve1[numPoints-1]
    C = curve3[0]
    D = curve3[numPoints-1]
    
    # Calculate M1 with curve 2 and curve 4
    M1 = (1-u*pas)*curve4[t] + u*pas*curve2[t]
    # Calculate M2 with curve 1 and curve 3
    M2 = (1-t*pas)*curve1[u] + t*pas*curve3[u]
    # Calculate M3 with the 4 points above
    M3 = (1-t*pas)*(1-u*pas)*A + t*pas*(1-u*pas)*C + (1-t*pas)*u*pas*B + t*pas*u*pas*D
    # Calculate Coon's Patch
    P = M1+M2-M3

    return P

# readVertices() is adapted from the Blender sample code shown in class by Ali
def readVertices(fileName):
    vertices=[]
    for line in open(fileName,"r"):
        if line.startswith('#'):continue
        values=line.split()
        if not values:continue
        if values[0]=='v':
            vertex=[]
            print(values)
            vertex.append(float(values[1]))
            vertex.append(float(values[2]))
            vertex.append(float(values[3]))
            vertices.append(vertex)
    return vertices

# make_Verts() is adapted from the Blender sample code shown in class by Ali
def make_Verts(file_path):
    verts=readVertices(file_path)
    return verts


# Need to change the file path to where the control points text file was saved (cp.txt)
file_path="/Users/azmariewang/Downloads/742/blenderScripts/blenderScrips/cp.txt"
# Read the control points from file
verts=make_Verts(file_path)
# Set step size to 0.05 for deCasteljau and Coon's Patch
pas = 0.05
# There will be 1/0.05+1 = 21 points in the curve in total
numPoints = int(1./pas)+1


# We will generate 4 Bezier curves from the control points
# Initialize them to empty list
curve1= []
curve2= []
curve3= []
curve4= []

i = 0
t = 0
while t< 1+pas:
    # First Curve from the first 4 control points
    curve1.append(deCasteljau(verts[0:4], t))
    # Second Curve from the second 4 control points
    curve2.append(deCasteljau(verts[4:8], t))
    # Third Curve from the third 4 control points
    curve3.append(deCasteljau(verts[8:12], t))
    # Last Curve from the last 4 control points
    curve4.append(deCasteljau(verts[12:16], t))
    i = i+1
    t = t+pas

curvedata = bpy.data.curves.new(name='Curve', type='CURVE')
curvedata.dimensions = '3D'

objectdata = bpy.data.objects.new("ObjCurve", curvedata)
bpy.context.collection.objects.link(objectdata)

# Create 4 curves with type 'BEZIER'
polyline1 = curvedata.splines.new('BEZIER')
polyline2 = curvedata.splines.new('BEZIER')
polyline3 = curvedata.splines.new('BEZIER')
polyline4 = curvedata.splines.new('BEZIER')

polyline1.bezier_points.add(numPoints-1)
polyline2.bezier_points.add(numPoints-1)
polyline3.bezier_points.add(numPoints-1)
polyline4.bezier_points.add(numPoints-1)

# Fill the Bezier curve model with points from curve1,curve2,curve3,curve4 
for num in range(numPoints):
    polyline1.bezier_points[num].co = curve1[num]
    polyline2.bezier_points[num].co = curve2[num]
    polyline3.bezier_points[num].co = curve3[num]
    polyline4.bezier_points[num].co = curve4[num]

polyline1.resolution_u = 1
polyline2.resolution_u = 1
polyline3.resolution_u = 1
polyline4.resolution_u = 1

t=0
u=0
verts = []
faces = []

# First we can fill the verts array
for t in range (numPoints):
    for u in range (numPoints):
        P = Coons(t, u, curve1, curve2, curve3, curve4)
        #print("After Coons: ", t, u, P)
        vert = (P[0],P[1],P[2]) 
        verts.append(vert)
        
# Then we can fill the faces array
count = 0
for i in range (0, numPoints *(numPoints-1)):
    if count < numPoints-1:
        # Get 4 points which can determine a face
        A = i
        B = i+1
        C = (i+numPoints)+1
        D = (i+numPoints)
        face = (A,B,C,D)
        faces.append(face)
        count = count + 1
    else:
        count = 0

# Create shell mesh and object 
mesh = bpy.data.meshes.new("wave")
object = bpy.data.objects.new("wave",mesh)
 
# Link the mesh and set location
object.location = bpy.context.scene.cursor.location
bpy.context.collection.objects.link(object)
 
# Create mesh from the vertices and faces we collected
mesh.from_pydata(verts,[],faces)
mesh.update(calc_edges=True)

# Color the mesh into light blue
mymat = bpy.data.materials.new("wave")
object = bpy.data.objects.new("wave",mesh)
mymat.diffuse_color = [0, 2.0, 5.0, 1]
mesh.materials.append(mymat)