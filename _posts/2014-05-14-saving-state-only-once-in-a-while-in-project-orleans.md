---
layout: default
title: "Saving state only once in a while in #ProjectOrleans"
date: 2014-05-14
keywords: 
---


On Microsoft's //build2014 conference, [Project Orleans][announcement] had it's public debut. You can watch the introductory [video][build2014video] here, and also [download the bits][download]. 

In Orleans, a grain can have [state][orleansPersistence], and when the grain is activated or deactivated (removed from memory), this state is automatically loaded / stored. Method on the grain can also save the grain's state to the underlying persistency provider when they think is a good time, e.g. when there were significant changes:  

{% gist chgeuer/a6aa664adc01221577b9 OldGrain.cs  %}

I was looking for a clean way to save the state on a regular basis, instead of during each invocation. This is done my a simple utility class, the 'OrleansStatePersistencyPolicy.cs': In my grain, I initialize this persistency policy. In this example, if there were fewer than 10 seconds before last invocation, the state is not saved: 

{% gist chgeuer/a6aa664adc01221577b9 MyGrain.cs  %}

Here's the simple functional approach for the persistency policy: 

{% gist chgeuer/a6aa664adc01221577b9 OrleansStatePersistencyPolicy.cs  %}


[announcement]: http://blogs.msdn.com/b/dotnet/archive/2014/04/02/available-now-preview-of-project-orleans-cloud-services-at-scale.aspx
[download]: http://aka.ms/orleans
[build2014video]: http://channel9.msdn.com/Events/Build/2014/3-641
[orleansPersistence]: http://orleans.codeplex.com/wikipage?title=Declarative%20Persistence
