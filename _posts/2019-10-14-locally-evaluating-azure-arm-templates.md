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
