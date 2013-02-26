Algorithms Used
===============

The bulk of our system relies on background subtraction and thresholding. We have achieved very good performance using only very simple techniques making more complicated techniques like model based skin detection somewhat superfluous. 

The first attempt was using the background image provided. However, we soon realized that there were plenty of artifacts resulting fro subtle differences between this image and the training set. We investigated the use of normalized RGB, but many of the differences were probably more due to haze, camera jitter and blur.

We found that taking an average image from all the possible data provides a much better background image while also taking care of removing most of the juggler from the image.

<%= render 'docs/avgall.html' %>

The other part of background subtraction is that we need to preserve colors of the balls, since we detect them by color later. 

<%= render 'docs/bgdiff.html' %> 

Finally we need to identify the balls, for that we convert the color into HSV colorspace and threshold on the hue. We've measured average hues of the balls and chosen constants to pick them out.

Then we simply take the biggest blob from our image and find it's centroid.

<%= render 'docs/biggest_center.html' %>

This alone turns out to work remarkably well (see below), however to improve performance further, we decided to use our tracking information. One constraint on the domain seems to be that the balls only travel a certain distance in one time step. We measured what that is. Because this is the case, we only want to look in the region of the image which is a certain distance away from the last position. We decided to set this area to 3 standard deviations of the mean of the distances between successive frames of the true data set (the complete data set fits within 2.5 standard deviation).

This allows us to get rid of some complete misclassifications like detecting the reflection of the ball in the window.

Performance
===========

To evaluate performance two metrics are used. Firstly we count the number of misclassifications, which we define as any detection that is more then 10 pixels away from the true data set. Secondly, we track the average (euclidian) distance from the true data set.

The full system achieves 99.327% within 10px of true center (97.980% for the red ball, 100.000% for the yellow ball, 100.000% for the blue ball). Average distance from true center was 1.836px (SD=1.830).

The system without the tracking system is slightly worse, but still achieves 97.306% within 10 pixels of true center and in average is 5.975 pixels (SD=36.486799) from the true center.


Example images
==============



Discussion
==========

One of the problems with using an average image is that if the system should be used as an online system, finding the balls in the first couple of images can be quite difficult. As a simulation of how this behaves we start with the basic background image and as more images come in we iteratively improve our background image. This makes the first roughly five images quite off, but converges quite quickly to fairly smooth detection.

<%= render 'docs/avg_adaptive.html' %>

The results we get from doing this online decrease to 88.215% of detected balls within 10px of true center. 

Appendix: Remaining Source Code
===============================

<%= render 'docs/main.html' %>


Thresholding functions
----------------------

<%= render 'docs/thresh_blue.html' %>
<%= render 'docs/thresh_yellow.html' %>
<%= render 'docs/thresh_red.html' %>
