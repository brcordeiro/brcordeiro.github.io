---
layout: post
---
<img src="/images/fulls/07.jpg" class="fit image">
A large number of corporate applications has been built on the monolithic architecture model. It works for small applications when the development process, tests and implementation are simple. However, for big and complexes applications, the monolithic architecture may be an obstacle to development and implementation, hinders the use of a continuous delivery and limit the adoption of new technologies.

For large applications, it makes more sense to use a microservices architecture that divides the application into a set of services. Individual services are easier to understand and can be developed and deployed independently, making easier to adopt new technologies and frameworks as it can be applied to a service at a time.
Each service can be implemented independently of other services and the team may be split into several small teams, where each team is responsible for developing and implementing a single service or a set of related services. Each team can develop, deploy and scale their services, independent of all other teams.

In addition, each service starts much faster than a big monolithic application, which again, makes developers more productive and faster deployments.
The microservices architecture also improves fault isolation and makes possible independent scalability.

So, after this overview about microservice concepts, let's talk about which technology can be applied to a faster adoption of this architecture model. I'm going to introduce you to the LoopBack framework.
LoopBack is a highly-extensible, open-source Node.js framework that enables you to:

<ul>
<li>Create dynamic end-to-end REST APIs with little or no coding.</li>
<li>Access data from Oracle, MySQL, PostgreSQL, MS SQL Server, MongoDB, SOAP and other REST APIs.</li>
<li>Incorporate model relationships and access controls for complex APIs.</li>
<li>Use built-in push, geolocation, and file services for mobile apps.</li>
<li>Easily create client apps using Android, iOS, and JavaScript SDKs.</li>
<li>Run your application on-premises or in the cloud.</li>
</ul>

LoopBack consists of:
<ul>
<li>A library of Node.js modules.</li>
<li>Yeoman generators for scaffolding applications.</li>
<li>Client SDKs for iOS, Android, and web clients.</li>
</ul>

LoopBack tools include:
<ul>
<li>Command-line tool slc loopback to create applications, models, data sources, and so on.</li>
<li>StrongLoop Arc, a graphical tool for editing LoopBack applications; and for deploying and monitoring applications.</li>
</ul>

LoopBack modules
The LoopBack framework is a set of Node.js modules that you can use independently or together.
<img src="/images/fulls/loopback.png" class="fit image">

In this article you had some concepts of microservices and a glance at LoopBack. In the next articles I'm going to show you how to implement a service using LoopBack.
