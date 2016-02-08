---
layout: default
title: "Saving state only once in a while in #ProjectOrleans"
date: 2014-05-14
keywords: 
---

On Microsoft's //build2014 conference, [Project Orleans][announcement] had it's public debut. You can watch the introductory [video][build2014video] here, and also [download the bits][download]. 

In Orleans, a grain can have [state][orleansPersistence], and when the grain is activated or deactivated (removed from memory), this state is automatically loaded / stored. Method on the grain can also save the grain's state to the underlying persistency provider when they think is a good time, e.g. when there were significant changes:  

```csharp
public Task Promote(int newLevel)
{
    this.State.Level = newLevel;
    return this.State.WriteStateAsync();
}
```

I was looking for a clean way to save the state on a regular basis, instead of during each invocation. This is done my a simple utility class, the 'OrleansStatePersistencyPolicy.cs': In my grain, I initialize this persistency policy. In this example, if there were fewer than 10 seconds before last invocation, the state is not saved: 

```csharp
namespace MyGrainCollection
{
    using System;
    using System.Threading.Tasks;
    using Orleans;
    using MyGrainInterfaces;

    [StorageProvider(ProviderName = "AzureTableStorage")]
    public class MyGrain : GrainBase<IMyGrainState>, IMyGrain
    {
        private readonly OrleansStatePersistencyPolicy policy = OrleansStatePersistencyPolicy.Every(TimeSpan.FromSeconds(10));

        async Task<int> IMyGrain.GetQuote()
        {
            this.State.Value++;

            // await this.State.WriteStateAsync();

            await this.policy.PersistIfNeeded(
                persist: this.State.WriteStateAsync);

            return this.State.Value;
        }
    }
}
```

Here's the simple functional approach for the persistency policy: 

```csharp
namespace MyGrainCollection
{
    using System;
    using System.Threading.Tasks;

    public class OrleansStatePersistencyPolicy
    {
        public static OrleansStatePersistencyPolicy Every(TimeSpan interval)
        {
            return new OrleansStatePersistencyPolicy(interval);
        }

        public OrleansStatePersistencyPolicy(TimeSpan interval)
        {
            this.Interval = interval;
        }

        private TimeSpan Interval { get; set; }

        private DateTimeOffset Last { get; set; }

        private bool ShouldPersist { get { return DateTimeOffset.UtcNow > this.Last.Add(this.Interval); } }

        public async Task PersistIfNeeded(Func<Task> persist)
        {
            if (ShouldPersist)
            {
                await persist();
                this.Last = DateTimeOffset.UtcNow;
            }
        }
    }
}
```

[announcement]: http://blogs.msdn.com/b/dotnet/archive/2014/04/02/available-now-preview-of-project-orleans-cloud-services-at-scale.aspx
[download]: http://aka.ms/orleans
[build2014video]: http://channel9.msdn.com/Events/Build/2014/3-641
[orleansPersistence]: http://orleans.codeplex.com/wikipage?title=Declarative%20Persistence
