Algorithms Used
===============

The bulk of our system relies on background subtraction and thresholding. We have achieved very good performance using only very simple techniques making more complicated techniques like model based skin detection somewhat superfluous. 

The first attempt was using the background image provided. However, we soon realized that there were plenty of artifacts resulting fro subtle differences between this image and the training set. We investigated the use of normalized RGB, but many of the differences were probably more due to haze, camera jitter and blur.

We found that taking an average image from all the possible data provides a much better background image while also taking care of removing most of the juggler from the image.

<%= render >

The other part of background 


Performance
-----------

TODO

Example images
--------------

Each processing stage, balls, clothing, skin.

Trajectories.

Examples of successful and unsuccessful detections.

Detection statistics
--------------------

TODO

Discussion
==========

One of the problems with using an average image is that if the system should be used as an online system, finding the balls in the first couple of images can be quite difficult. As a simulation of how this behaves we start with the basic background image and as more images come in we iteratively improve our background image. This makes the first roughly five images quite off, but converges quite quickly to fairly smooth detection.

<%= render 'docs/avg_adaptive.html' %>

The results we get from doing this online decrease to 88.215% of detected balls within 10px of true center. 

Source code
===========

<%= render 'docs/main.html' %>