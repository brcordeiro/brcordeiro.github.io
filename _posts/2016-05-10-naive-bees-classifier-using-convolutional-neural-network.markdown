---
layout: post
title: Naive Bees Classifier using Convolutional Neural Network
---
<img src="/images/fulls/11.jpg" class="fit image">
<p>Wild bees are important pollinators and the spread of colony collapse disorder has only made their role more critical. Right now it takes a lot of time and effort for researchers to gather data on wild bees. The starting point is to determine the genus - Apis (honey bee) or Bombus (bumble bee) - based on photographs of the insects, using images from BeeSpotter (http://beespotter.org/) for identifying and classifying.</p>

<p>In this article we will build a system that will read the images, scales it, create a dataset to make the classifier work well by creating reflected and translated versions of images. It then takes care of class imbalance by undersampling this enhanced dataset. All this processes data is then stored in numpy arrays.</p>

<p>The architecture of this Convolutional Neural Network is built on Python, Theano, Lasagne and others additional libraries.</p>

<p>The source code is available at https://github.com/brcordeiro</p>
