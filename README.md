# CS289FinalProject_CNN
Application of Convolutional Neural Network to Medical Image Detection and Segmentation

Medical images obtained from Magnetic Resonance Image (MRI) in real life carry
useful information as well as garbage information, which comes from fat tissue, surrounding
tissue, water drop, etc. In this report, Convolutional Neural Network (CNN)
is used to process MRI images. Firstly, CNN is used to separate useless images from
useful images. Then, CNN is applied to segment each of the useful images to separate
the useful content of a MRI image, which in this case is disc tissue, from garbage
information. TensorFlow is used to construct the CNN in Python. To demonstrate
effectiveness of CNN, the prediction rate of categorize is shown, as well as the output
image of segmentation.
