'''
Install opencv:
pip install opencv-python==3.4.2.16
pip install opencv-contrib-python==3.4.2.16
'''

import cv2
import numpy as np
from matplotlib import pyplot as plt
from argparse import ArgumentParser
import scipy.io as sio

parser = ArgumentParser()
parser.add_argument("--UseRANSAC", type=int, default=0 )
parser.add_argument("--image1", type=str,  default='data/myleft.jpg' )
parser.add_argument("--image2", type=str,  default='data/myright.jpg' )
args = parser.parse_args()

print(args)

def FM_normalize_points(x):
    # Compute the translation matrix
    x_bar = np.mean(x, axis=0)
    xc = np.empty(x.shape)

    # Center the points
    xc[:,0] = x[:,0] - x_bar[0]
    xc[:,1] = x[:,1] - x_bar[1]

    # Compute the average point distance
    r = np.sqrt(np.sum(np.multiply(xc, xc), axis=1))
    r_bar = np.mean(r)

    # Compute the scale factor and scale the points
    s = np.sqrt(2)/r_bar
    xn = np.multiply(s,xc)

    # Compute the transformation matrix
    T = np.array([[s, 0, -np.multiply(s,x_bar[0])],[0, s, -np.multiply(s,x_bar[1])],[0,0,1]])

    return [xn, T]

def FM_by_normalized_8_point(pts1,  pts2):

    import pdb; pdb.set_trace()

	# 1. Normalize point coordinates (use a normalization matrix)
    [X1, T1] = FM_normalize_points(pts1)
    [X2, T2] = FM_normalize_points(pts2)
    # print(T1, "\n \n \n ", T2)

    # 2. Construct the N x 9 matrix A
    N = X1.shape[0]
    
    # Calculate x1, y1, x2, y2
    x1 = np.transpose(X1[0:N, 0])
    y1 = np.transpose(X1[0:N, 1])
    x2 = np.transpose(X2[0:N, 0])
    y2 = np.transpose(X2[0:N, 1])

    A = np.ones((N, 1))
    A = np.insert(A, 0, x1*x2, axis=1)
    A = np.insert(A, 1, x1*y2, axis=1)
    A = np.insert(A, 2, x1, axis=1)
    A = np.insert(A, 3, y1*x2, axis=1)
    A = np.insert(A, 4, y1*y2, axis=1)
    A = np.insert(A, 5, y1, axis=1)
    A = np.insert(A, 6, x2, axis=1)
    A = np.insert(A, 7, y2, axis=1)
    # This line is uncesessary since we already initialized the matrix to ones
    # A = np.insert(A, 8, 1, axis=1)

    # 3. SVD of A
    [U, s, VH] = np.linalg.svd(A, full_matrices=True)

    # 4. Entries of F are the elements of column vector of V corresponding to the smallest singular value 
    F = VH[-1,:].reshape(3,3, order='F')

    # 5. Enforce rank 2 constraint on F2
    F_full_rank = F.reshape(3,3, order='F')

    [U, s, VH] = np.linalg.svd(F_full_rank, full_matrices=True)
    S = np.zeros((F_full_rank.shape))
    S[:F_full_rank.shape[0], :F_full_rank.shape[1]] = np.diag(s)
    S[2,2] = 0

    F = U.dot(S.dot(VH))

    # 6. Un-normalize F
    F = np.transpose(T2).dot(F.dot(T1))
	
    # Normalize the last term of fundmental matrix F[2][2] == 1
    F = F*1./F[2][2]
    return  F

def FM_by_RANSAC(pts1,  pts2):

    n = 0
    N = pts1.shape[0]
    M = 1000

    for it in range(M):
        # choose 8 pairs of matching points randomly
        # To randomize two lists and avoid Reinventing The Wheel use sklearn 
        # Reference: https://stackoverflow.com/questions/13343347/randomizing-two-lists-and-maintaining-order-in-python
        from sklearn.utils import shuffle
        ran1, ran2 = shuffle(pts1, pts2)

        # F_i is the fundamental matrix obtained by normalized 8-point algorithm    
        F_i, _ = cv2.findFundamentalMat(ran1[0:8], ran2[0:8], cv2.FM_8POINT)

        # Test openCV results for comparision
        # F_i, _ = cv2.findFundamentalMat(pts1,pts2,cv2.FM_RANSAC)
        # array([[-5.25559184e-05, -4.31735516e-05,  1.34544979e-02],
        #     [ 3.61147427e-04, -2.51106813e-04, -2.49212090e-02],
        #     [-4.93962425e-02,  5.38821935e-02,  1.00000000e+00]])

        # Select error criteria ==3 based on my own experiment
        threshold = 3
        t = threshold*threshold
        maskptr = np.zeros((N,1), dtype='uint8')

        # Continue with the loop wehere F_i is None
        if F_i is None:
            continue

        # Flatten F for eaiser manipulation
        F_i = F_i.reshape(1,9)[0]

        # Compute errptr and the number of inliers, n_i ,  with respect to F_i
        n_i = 0
        for i in range(N):
            # Computer error for each point, determine if it's inliner or outliner
            a = F_i[0]*pts1[i][0] + F_i[1]*pts1[i][1] + F_i[2]
            b = F_i[3]*pts1[i][0] + F_i[4]*pts1[i][1] + F_i[5]
            c = F_i[6]*pts1[i][0] + F_i[7]*pts1[i][1] + F_i[8]
            s2 = 1./(a*a + b*b)
            d2 = pts2[i][0]*a + pts2[i][1]*b + c
            a = F_i[0]*pts2[i][0] + F_i[3]*pts2[i][1] + F_i[6]
            b = F_i[1]*pts2[i][0] + F_i[4]*pts2[i][1] + F_i[7]
            c = F_i[2]*pts2[i][0] + F_i[5]*pts2[i][1] + F_i[8]
            s1 = 1./(a*a + b*b)
            d1 = pts1[i][0]*a + pts1[i][1]*b + c
            # Take the max of the two set errors as the error value
            errptr = max(d1*d1*s1, d2*d2*s2)
            
            # If the error is within the pre-determined threshold, we set it to 1 in the mask
            # Otherwise, its value is 0 in the mask
            f = errptr <= t
            maskptr[i] = int(f)
            n_i += f

        if n_i > n:
            # Update n and F if it's a better results (more inliners than previous max)
            n=n_i
            F=F_i
            mask=maskptr
            print("update n", n, " rate: ", n/155)
            print("iteration ", it)
        # Increment the iterator
        it = it +1

    F = F.reshape(3,3)
    # Return values
    # F:    fundmental matrix
    # mask: inliers == 1, outliers == 0
    return  F, mask

	
img1 = cv2.imread(args.image1,0) 
img2 = cv2.imread(args.image2,0)  

sift = cv2.xfeatures2d.SIFT_create()

# find the keypoints and descriptors with SIFT
kp1, des1 = sift.detectAndCompute(img1,None)
kp2, des2 = sift.detectAndCompute(img2,None)

# FLANN parameters
FLANN_INDEX_KDTREE = 0
index_params = dict(algorithm = FLANN_INDEX_KDTREE, trees = 5)
search_params = dict(checks=50)

flann = cv2.FlannBasedMatcher(index_params,search_params)
matches = flann.knnMatch(des1,des2,k=2)

good = []
pts1 = []
pts2 = []

# ratio test as per Lowe's paper
for i,(m,n) in enumerate(matches):
    if m.distance < 0.8*n.distance:
        good.append(m)
        pts2.append(kp2[m.trainIdx].pt)
        pts1.append(kp1[m.queryIdx].pt)
		
		
pts1 = np.int32(pts1)
pts2 = np.int32(pts2)

F = None
if args.UseRANSAC:
    F,  mask = FM_by_RANSAC(pts1,  pts2)

    # Test openCV results for comparison
    # F, mask = cv2.findFundamentalMat(pts1,pts2,cv2.FM_RANSAC)
    # print("F is " ,F)
    # array([[-3.00263243e-06,  2.51971655e-05, -8.20020396e-05],
    #    [ 6.75309899e-05, -8.49807369e-06, -4.41270397e-02],
    #    [-4.16016169e-03,  2.13888670e-02,  1.00000000e+00]])	

    # We select only inlier points
    pts1 = pts1[mask.ravel()==1]
    pts2 = pts2[mask.ravel()==1]

    print(pts1.shape)

else:
    F = FM_by_normalized_8_point(pts1, pts2)
    # This is True, which means my results is the same the openCV results
    # print(abs(F -F1) < 1e-10) 
	

def drawlines(img1,img2,lines,pts1,pts2):
    ''' img1 - image on which we draw the epilines for the points in img2
        lines - corresponding epilines '''
    r,c = img1.shape
    img1 = cv2.cvtColor(img1,cv2.COLOR_GRAY2BGR)
    img2 = cv2.cvtColor(img2,cv2.COLOR_GRAY2BGR)
    for r,pt1,pt2 in zip(lines,pts1,pts2):
        color = tuple(np.random.randint(0,255,3).tolist())
        x0,y0 = map(int, [0, -r[2]/r[1] ])
        x1,y1 = map(int, [c, -(r[2]+r[0]*c)/r[1] ])
        img1 = cv2.line(img1, (x0,y0), (x1,y1), color,1)
        img1 = cv2.circle(img1,tuple(pt1),5,color,-1)
        img2 = cv2.circle(img2,tuple(pt2),5,color,-1)
    return img1,img2
	
	
# Find epilines corresponding to points in second image,  and draw the lines on first image
lines1 = cv2.computeCorrespondEpilines(pts2.reshape(-1,1,2), 2, F)
lines1 = lines1.reshape(-1,3)
img5,img6 = drawlines(img1,img2,lines1,pts1,pts2)
plt.subplot(121),plt.imshow(img5)
plt.subplot(122),plt.imshow(img6)
plt.show()

# Find epilines corresponding to points in first image, and draw the lines on second image
lines2 = cv2.computeCorrespondEpilines(pts1.reshape(-1,1,2), 1, F)
lines2 = lines2.reshape(-1,3)
img3,img4 = drawlines(img2,img1,lines2,pts2,pts1)
plt.subplot(121),plt.imshow(img4)
plt.subplot(122),plt.imshow(img3)
plt.show()
