---
layout: default
title: "Code snippets"
---

```haskell
-- greetIfCool2.hs
module GreetIfCool2 where

  greetIfCool :: String -> IO ()
  greetIfCool coolness =
    if cool coolness
      then putStrLn "eyyyyy. What's shakin'?"
    else
      putStrLn "pshhhh."
    where cool v =
            v == "downright frosty yo"
```

### RxGo `FlatMap`

```go
import (
	"github.com/reactivex/rxgo/handlers"
	"github.com/reactivex/rxgo/iterable"
	"github.com/reactivex/rxgo/observable"
	"github.com/reactivex/rxgo/observer"
)

func main() {
// primeSequence := observable.Just([]interface{}{2, 3, 5, 7, 11, 13})
	it, _ := iterable.New([]interface{}{
		[]interface{}{11, 12, 13, 14, 15},
		[]interface{}{21, 22, 23, 24, 25},
		[]interface{}{31, 32, 33, 34, 35},
	})
	primeSequence := observable.From(it)
	const maxInParallel = 1
	sub := primeSequence.
		FlatMap(func(primes interface{}) observable.Observable {
			return observable.Create(func(emitter *observer.Observer, disposed bool) {
				for _, prime := range primes.([]interface{}) {
					emitter.OnNext(prime)
				}
				emitter.OnDone()
			})
		}, maxInParallel).
		// Last().
		Subscribe(handlers.NextFunc(func(prime interface{}) {
			fmt.Println("Prime -> ", prime)
		}))

	<-sub
}
```


## Rust

```rust
#[derive(Debug)]
pub struct Node {
    s: String,
    number: u32,
}

fn main() {
    let n = create_node();
    n.foo()
}

fn create_node() -> Node {
    let mut n = Node {
        number: 1,
        s: "v1".to_string(),
    };
    n.foo();
    println!("Replace {}", n.update_s("v4".to_string()));
    n
}

impl Node {
    pub fn foo(&self) {
        println!("Hello {:?}", self);
    }

    pub fn update_s(&mut self, s: String) -> String {
        std::mem::replace(&mut self.s, s)
    }
}
```