import Cocoa
import Accelerate



var input: [Float] = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16]
var output: [Float] = [Float](repeating: 0, count: 128)


// copy into input
vDSP_mmov(input, &output[7], 8, 1, 0, 0)



////sanple to add 1 row
//float dst[4][4] = { 1,2,3,4, 5,6,7,8, 9,10,11,12 } ; //last row empty
//float src[1][4] = { 13,14,15,16 };
////to fill last row
//int numColumnsToCopy = 4;
//int numRowsToCopy = 1;
//int numColsinDst = 4;
//int numColsinSrc = 4;
//vDSP_mmov(src, &dst[3][0], numColumnsToCopy, numRowsToCopy, numColsinSrc, numColsinDst );



print(input)
print(output)




