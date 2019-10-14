---
layout: default
title: "Locally evaluating Azure ARM templates"
date: 2019-10-14 12:30:00
---

## Establishing a fast feedback loop for ARM Template Language Expressions

In the past years, I've spent much time authoring Azure resource manager (ARM) templates, i.e. JSON documents which describe deployments in Microsoft's Azure cloud environment. These JSON-based ARM documents can contain so-called ARM template language expressions, which are represented by JSON strings. For example, the JSON object ```{ "someInteger": "[add(1, mul(2, 3))]" }``` would be transformed into ```{ "someInteger": 7 }```. The string with brackets  `"[...]"` means that the inner content needs to be evaluated, and the string be replaced by the value.

I have a couple of challenges authoring ARM templates:

- errors in complex template expressions often only show up, after I submit the deployment to Azure and the content is evaluated by ARM, which can take seconds to minutes.
- error messages are sometimes a bit 'obscure', because ARM parses the JSON doc into an object, and the error message says that expression xyz, in line *1*, character position 12320, is illegal. So ARM on the server flattens the document into a single line.
- Overall, the feedback loop is quite slow.

In order to solve my pain point, I started a small hobby project, the "Microsoft ARM Evaluator" [github.com/chgeuer/ex_microsoft_arm_evaluator](https://github.com/chgeuer/ex_microsoft_arm_evaluator). This tool runs on the developer laptop, it reads an existing ARM file, parses and evaluates the TLE expressions, and writes the evaluated result to a second file. In order to make it easy to compare the input and result, the tool uses a custom JSON parser which preserves whitespace within the JSON document:

<p><img src="/img/2019-10-14-arm-evaluator/armeval01.png"
     width="600px" alt="Side-by-side comparison of input and result JSON" /></p>

### Demo video

<p><a href="https://www.youtube.com/watch?v=CbSphrybZFQ">
<img src="/img/2019-10-14-arm-evaluator/armevalyoutube.png"
     width="600px" alt="Demo video" />
</a></p>

### Running the code

The application is written in Elixir, a language running on top of the Erlang virtual machine. You currently need to install Erlang and Elixir locally on your machine, and then clone and compile the application:

- Once cloned, run `mix deps.get` and `mix compile` in the project directory.
- On Windows, set the environment variable `iex_with_werl=true`, so that the Elixir interactive shell runs as separate window.
- Within the Elixir console, you do a few things now:
  - `alias Microsoft.Azure.TemplateLanguageExpressions.{Resource, Context, DeploymentContext, Evaluator.Resource}` saves us some typing on a few Elixir module names.
  - `login_cred = DemoUtil.login()` triggers a device authentication flow against the Azure management API. Login in a browser via [microsoft.com/devicelogin](https://microsoft.com/devicelogin)
  - `sub = "724467b5-bee4-484b-bf13-d6a5505d2b51"` sets a subscription ID
  - `deploymentContext = %DeploymentContext{ subscriptionId: sub, resourceGroup: "longterm" } |> DeploymentContext.with_device_login(login_cred)` creates a deplyoment context against which to evaluate the ARM template file.
  - `DemoUtil.transform("sample_files/1.json", deploymentContext, %{})` now reads the `1.json` file from the samples directory, and creates a `1.json.result.json` file, with all evaluabtable pieces expanded.

Special thanks for José Valim (inventor of Elixir) for creating [nimble parsec](https://github.com/plataformatec/nimble_parsec), a slick parser combinator library which I used for whitespace- and comment-aware JSON parsing, and Azure template language expression parsing.

### Interesting bits

Check the ARM unit tests, to understand how the TLE expressions evaluate to JSON values: [test/static_tests.json](https://github.com/chgeuer/ex_microsoft_arm_evaluator/blob/master/test/static_tests.json)
