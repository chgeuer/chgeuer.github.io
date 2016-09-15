---
layout: default
title: "Stuff from the web"
date: 2015-11-05
keywords:
published: true
---

# September 2016

## Use Storage Account in ARM without fully qualified domain name

```json
"vhd": {
"uri": "[concat(concat(
	reference(
		resourceId(
			resourceGroup().name, 
			'Microsoft.Storage/storageAccounts', 
			variable('storageAccountName')
			), '2015-06-15').primaryEndpoints['blob'], 'vhds/'), 'akrvirtual1', 'virtual1sys.vhd')]"
}, 
```



- [How to Set up a Distributed Elixir Cluster on Amazon EC2](http://engineering.pivotal.io/post/how-to-set-up-an-elixir-cluster-on-amazon-ec2/)
- [IElixir Notebook in Docker](https://mattvonrocketstein.github.io/heredoc/ielixir-notebook-in-docker.html)
- [cookiecutter-elixir-project](https://github.com/mattvonrocketstein/cookiecutter-elixir-project): a python-based templating engine creating Elixir projects (see also [Elixir boilerplate](https://mattvonrocketstein.github.io/heredoc/elixir-boilerplate.html))
- https://github.com/poteto/elixirconf-2016/blob/master/README.md
- Design
	- http://www.flaticon.com/packs/pokemon-go
	- http://www.sansfrancis.co/?ref=webdesignernews.com
- https://github.com/andersju/webbkoll/blob/master/lib/webbkoll/trackers.ex
- https://github.com/fishcakez/connection
- https://networkingguyblog.wordpress.com/2016/08/21/53/
- https://blogs.msdn.microsoft.com/powershell/2016/08/18/powershell-on-linux-and-open-source-2/
- https://www.typora.io/#windows
- https://aws.amazon.com/blogs/aws/amazon-elastic-block-store-ebs-update-snapshot-price-reduction-more-piopsgib/
- http://haishibai.blogspot.de/2016/08/sharing-your-service-fabric-services-as.html
- https://github.com/rrrene/credo/blob/master/README.md
- https://sachinchoolur.github.io/lightgallery.js/
- http://www.interhyp.de/bauen-kaufen/tipps-zur-finanzierung/goldene-regeln-fuer-das-richtige-immobiliendarlehen.html
- http://bitwalker.org/posts/2016-08-04-clustering-in-kubernetes/
- https://bitmovin.com/mp4box-dash-content-generation-x264/
- http://www.danielstechblog.info/using-the-latest-api-version-in-your-azure-resource-manager-templates/
- https://blogs.msdn.microsoft.com/azureossds/2016/06/29/uploading-images-to-azure-storage-from-angularjs-app/

# August 2016

## Reset the "Windows Subsystem for Linux"

See the [FAQ](https://msdn.microsoft.com/en-us/commandline/wsl/faq).

```batch
lxrun /uninstall /full
sc stop lxssmanager
rmdir /S %LOCALAPPDATA%\lxss
sc start lxssmanager
lxrun /install
```

- AWS Architecture Drawer: https://cloudcraft.co/app
	- http://codepen.io/Quelltextfabrik/pen/kuGzx
	- http://jdan.github.io/isomer/
- Microsoft Bot Framework: https://docs.botframework.com/en-us/downloads/
	- Microsoft Bot Framework Client in Elixir: https://github.com/yuyabee/bot_framework
	- Elixir Microsoft Bot Client: https://github.com/zabirauf/ex_microsoftbot
	- Create messenger bots using Elixir and Microsoft bot framework: http://www.zohaib.me/create-messenger-bots-using-elixir-and-microsoft-bot-framework/
	- https://chatbotsmagazine.com/the-complete-beginner-s-guide-to-chatbots-8280b7b906ca#.6xz7dhp79
- Distributed Cron
	- https://www.safaribooksonline.com/library/view/site-reliability-engineering/9781491929117/ch24.html
	- http://dkron.io/ / https://github.com/victorcoder/dkron
- Amazon Dash Button Stuff
 	- https://medium.com/@edwardbenson/how-i-hacked-amazon-s-5-wifi-button-to-track-baby-data-794214b0bdd8#.wtl22wp79
	- https://mpetroff.net/2015/05/amazon-dash-button-teardown/#fn2-1827
	- http://blog.nemik.net/2015/08/dash-button-corral/
	- https://github.com/dekuNukem/Amazon_Dash_Button
	- https://medium.com/@edwardbenson/how-i-hacked-amazon-s-5-wifi-button-to-track-baby-data-794214b0bdd8#.higfm3ddq
	- https://medium.com/@brody_berson/hacking-amazon-s-5-dash-button-to-order-domino-s-pizza-9d19c9d04646#.27csydbw9
	- https://github.com/hortinstein/node-dash-button/blob/master/index.js
	- http://www.dashbuttondudes.com/blog/2015/12/11/26-amazon-dash-button-hacks

# July 2016

- https://elixirweekly.net/
- https://medium.com/@bowett_11839/elixir-the-nags-hd-part-1-d6b523368ccc
- http://cloudless.pl/articles/21-front-end-packages-with-phoenix-and-brunch
- https://medium.com/@trestrantham/chat-controlled-music-with-mopidy-and-hedwig-8d6ff6ef346f
- https://github.com/swlaschin/Railway-Oriented-Programming-Example/blob/master/src/FsRopExample/Controllers.fs
- https://medium.com/developers-writing/writing-an-ember-backend-in-phoenix-f39f12725377#.x9jb3176x
- https://www.youtube.com/channel/UCIYiFWyuEytDzyju6uXW40Q
- http://elviovicosa.com/blog/2016/07/13/deploying-elixir-releases.html
- https://coreos.com/os/docs/latest/getting-started-with-docker.html
- https://github.com/strofcon/hello_semaphore
- https://semaphoreci.com/community/tutorials/dockerizing-elixir-and-phoenix-applications
- https://blog.codecentric.de/en/2016/07/iot-analytics-platform/
- http://elixir-lang.org/blog/2016/07/14/announcing-genstage/


# June 2016

- [How to upgrade an Azure VM Scale Set without shutting it down](https://msftstack.wordpress.com/2016/05/17/how-to-upgrade-an-azure-vm-scale-set-without-shutting-it-down/)
- [How to convert an Azure virtual machine to a VM Scale Set](https://msftstack.wordpress.com/2016/06/20/how-to-convert-an-azure-virtual-machine-to-a-vm-scale-set/)
- [Video: Netflix Spinnaker on Azure](https://channel9.msdn.com/Shows/Cloud+Cover/Episode-207-Netflix-Spinnaker-on-Azure-with-Andy-Glover-Richard-Guthrie-and-Arun-Chandrasekhar) ([github](https://github.com/spinnaker/) and [site](http://www.spinnaker.io/))

# March 2016

- Terraform
	- [Blog: Azure Resource Manager Support for Packer and Terraform](https://www.hashicorp.com/blog/azure-packer-terraform.html)

- HTML5 File API
    - [Use the HTML5 File API to Work with Files Locally in the Browser](https://scotch.io/tutorials/use-the-html5-file-api-to-work-with-files-locally-in-the-browser)
    - [resumable.js: A JavaScript library for providing multiple simultaneous, stable, fault-tolerant and resumable/restartable uploads via the HTML5 File API](https://github.com/23/resumable.js)
    - [File upload using Flow.JS and ASP.NET Web API](http://www.heikura.me/2014/9/27/file-upload-using-flowjs-and-aspnet-webapi)
    - [Angular file upload - flow.js](http://flowjs.github.io/ng-flow/)
    - [Upload files to Microsoft Azure Storage from JavaScript (09/2014)](https://www.returngis.net/en/2014/09/upload-files-to-microsoft-azure-storage-from-javascript/)
    - http://gauravmantri.com/2013/12/01/windows-azure-storage-and-cors-lets-have-some-fun/
    - http://ngmodules.org/modules/angular-azure-blob-upload
    - https://blogs.msdn.microsoft.com/kaevans/2015/12/18/securely-upload-to-azure-storage-with-angular/
    - S3
        - [cinely/mule-uploader](https://github.com/cinely/mule-uploader)
        - [JAndritsch/basic_s3_uploader](https://github.com/JAndritsch/basic_s3_uploader)
        - [moxiecode/plupload](https://github.com/moxiecode/plupload)
        - [SO](http://stackoverflow.com/questions/11240127/uploading-image-to-amazon-s3-with-html-javascript-jquery-with-ajax-request-n)


# February 2016

- https://tomasz.janczuk.org/2015/09/from-kafka-to-zeromq-for-log-aggregation.html
- [NGINX RTMP Proxy](https://obsproject.com/forum/resources/how-to-set-up-your-own-private-rtmp-server-using-nginx.50/)
- [Nexus 6P Wood Cover](http://www.toastmade.com/products/nexus-6p.html)
- [Ad-blocker hosts](https://github.com/StevenBlack/hosts/blob/master/readme.md)
- [IBM OpenBlockChain](https://github.com/openblockchain)
- [Wrangling Grafana and InfluxDB into a Docker image](http://simonjbeaumont.com/posts/docker-dashboard)
- [PHP / Azure Active Directory Provider for OAuth 2.0 Client](https://github.com/TheNetworg/oauth2-azure)
- [JOB SCHEDULING IN ELIXIR](http://c-rack.github.io/job-scheduling-in-elixir/#/)
- [A Modern App Developer and An Old-Timer System Developer Walk Into a Bar](http://zhen.org/blog/two-developers-walk-into-a-bar/)
- [ASP.NET WebHooks and Slack Slash Commands](https://blogs.msdn.microsoft.com/webdev/2016/02/14/asp-net-webhooks-and-slack-slash-commands/)
- Elixir
    - [Writing an Ecto adapter for RethinkDB](https://almightycouch.org/blog/rethinkdb-adapter-ecto/)
    - [Building a Slack bot using Elixir](http://cazrin.net/blog/2016/building-a-slack-bot-using-elixir/)
- [Skynet 1M threads microbenchmark](https://github.com/atemerev/skynet)
- [Developer Preview: RethinkDB now available for Windows](https://rethinkdb.com/blog/rethinkdb-windows-preview/)
- [Increase Your Email Open Rates By 50% With These 9 Subject Line Formulas](https://medium.com/posts-from-drip/increase-your-email-open-rates-by-50-with-these-9-subject-line-formulas-cfad9d26d156#.qlysi34yt)
- [Easily Encrypt your Azure VMs with KeyVault](http://derekmartin.org/2016/01/04/easily-encrypt-your-azure-vms-with-keyvault/) and [update the encryption certs](http://derekmartin.org/2016/02/11/updating-the-azure-vm-encryption-certs/)
- [jq is a lightweight and flexible command-line JSON processor](https://stedolan.github.io/jq/) ([Windows x64](https://github.com/stedolan/jq/releases/download/jq-1.5/jq-win64.exe))
    - Can now do things like `azure resource show --resource-group "my-rg" --resource-type "Microsoft.Compute/virtualMachineScaleSets" --name "myvmscaleset/virtualMachines/16/networkInterfaces/some-nic" --api-version "2015-05-01-preview" --json | jq .properties.ipConfigurations[0].properties.privateIPAddress`
- Azure Resource Manager Login Stuff
    - [Certificate-based auth with Azure Service Principals from Linux command line](http://blogs.msdn.com/b/arsen/archive/2015/09/18/certificate-based-auth-with-azure-service-principals-from-linux-command-line.aspx)
    - [Authenticating a service principal with Azure Resource Manager](https://azure.microsoft.com/en-us/documentation/articles/resource-group-authenticate-service-principal/)
    - [Python access to ARM](https://github.com/gbowerman/azurerm)
- [Erlang-style Supervisors in C# with Akka.NET and the Actor Model](http://buildplease.com/pages/supervisors-csharp/)
- [Media Source Extension WebM streaming encoder](https://github.com/etherapis/webmcoder)
- [Nodejs-based tool for optimizing SVG vector graphics files](https://github.com/svg/svgo)
- [The DSC Book](https://www.penflip.com/powershellorg/the-dsc-book)
- [Introduction to IdentityServer - Brock Allen](https://vimeo.com/154172925)
- [Introduction to Azure Docker Extension](https://ahmetalpbalkan.com/blog/azure-docker-extension/)
- [SSH: Best practices](https://blog.0xbadc0de.be/archives/300)
- [How to do distributed locking](http://martin.kleppmann.com/2016/02/08/how-to-do-distributed-locking.html)
- [Windows Access Tokens and Alternate Credentials](http://blog.cobaltstrike.com/2015/12/16/windows-access-tokens-and-alternate-credentials/)
- [Use Go to write and manage AWS Lambda services](http://gosparta.io/)

# January 2016

- [Libraries and supporting examples for use with the Ports and Adapters and CQRS architectural styles for .NET, with support for Task Queues](http://iancooper.github.io/Paramore/Brighter.html)
- [Is TLS fast yet? Yes, yes it is.](https://istlsfastyet.com)
- WhatIsMyIP from [Akamai](https://community.akamai.com/thread/1830)
- Use [Ctrl-D](http://stackoverflow.com/questions/8360215/use-ctrl-d-to-exit-and-ctrl-l-to-cls-in-powershell-console) to exit Powershell: `Set-PSReadlineKeyHandler -Key Ctrl+d -Function DeleteCharOrExit`

```
%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe -ExecutionPolicy Unrestricted -Command "Add-Content $PsHome\Profile.ps1 \"`r`nSet-PSReadlineKeyHandler -Key Ctrl+d -Function DeleteCharOrExit`r`n\""
```

- [Building Slack Bots](https://github.com/howdyai/botkit)
- [Microsoft Orleans support for Workflow Foundation (.Net 4.x System.Activities workflows)](https://github.com/OrleansContrib/Orleans.Activities)
- JavaScript
    - [React and Redux with TypeScript](http://jaysoo.ca/2015/09/26/typed-react-and-redux/)
    - [vivus, bringing your SVGs to life](http://maxwellito.github.io/vivus/)
- PostgreSQL
    - [PostgreSQL Query Plan Visualization](http://tatiyants.com/postgres-query-plan-visualization/)
    - [PostgreSQL replication with Londiste from Skytools 3](https://blog.lateral.io/2015/09/postgresql-replication-with-londiste-from-skytools-3/)
- [Understanding the new ASP.NET 5 Configuration in Startup.cs](http://mikemengell.com/asp-net5/understanding-the-new-asp-net-5-configuration-in-startup-cs/)
- [Building Resilient Microservices from the Fallacies of Distributed Computing](https://datawire.io/using-fallacies-of-distributed-computing-to-build-resilient-microservices/)
- [Y-Cloninator - Github projects from Hacker News](http://ycloninator.herokuapp.com/)
- [Big Data Ecosystem Datasheet](https://github.com/zenkay/bigdata-ecosystem/)
- Design
	- CSS Sass. [Sass Basics](http://sass-lang.com/guide) and [foundation](http://foundation.zurb.com/sites/docs/sass.html) and [gulp](https://www.npmjs.com/package/gulp-sass)
	- [How to Use Tints and Shades in Your Designs](https://designschool.canva.com/blog/tints-and-shades/)
		- [Material Design Color Palette](http://www.materialpalette.com/deep-orange/indigo)
		- [paletton.com](http://paletton.com/#uid=13w1p0kko+M5A+T5I+TyOX6z4X1)
		- [http://colourco.de/](http://colourco.de/)
	- [20 Minimal Web Designs That Don’t Rely on Images](http://line25.com/articles/20-minimal-web-designs-dont-rely-images)
	- [25 Website Designs with Unusual Color Combinations](http://line25.com/articles/25-website-designs-with-unusual-color-combinations)
- [Free e-book: Static site generators: the latest tools for building static websites](http://conferences.oreilly.com/fluent/javascript-html-us/public/content/static-site-generators?download=true)
- F#
	- [Running F# on Microsoft Azure](https://cockneycoder.wordpress.com/2016/01/20/running-fsharp-on-microsoft-azure/)
	- [F# Cheatsheet](http://dungpa.github.io/fsharp-cheatsheet/)
	- [F# Formatting: Documentation tools](http://tpetricek.github.io/FSharp.Formatting/)
	- [Join](http://fpchat.com/) [functionalprogramming.slack.com](https://functionalprogramming.slack.com/)
	- [Actor-based Concurrency with F# and Akka.NET](http://akimboyko.in.ua/presentations/ActorBasedConcurrencyFWDays.html#/)
	- [Ionide - An Atom Editor and Visual Studio Code package suite for cross platform F# development](http://ionide.io/) and [blog](http://blogs.msdn.com/b/dotnet/archive/2015/12/03/guest-post-announcing-f-support-in-visual-studio-code-with-ionide.aspx)
	- [Suave GitBook](https://www.gitbook.com/book/theimowski/suave-music-store/details)
	- [Implementing API Gateway in F# Using Rx and Suave](http://blog.tamizhvendan.in/blog/2015/12/29/implementing-api-gateway-in-f-number-using-rx-and-suave/)
- [WebSockets, caution required!](https://samsaffron.com/archive/2015/12/29/websockets-caution-required)
- Video
	- [Live video streaming on your website without streaming providers](https://datarhei.github.io/restreamer/)
	- [TN2224 is Dead. Welcome to the New Era of Content-Aware Encoding (netflix)](http://www.streaminglearningcenter.com/blogs/tn2224-is-dead-welcome-to-the-new-era-of-content-aware-encoding.html)
	- [Under the hood: Broadcasting live video to millions](https://code.facebook.com/posts/1653074404941839/under-the-hood-broadcasting-live-video-to-millions/) - Use HLS to broadcast celebrities to millions (and leverage CDN), and use RTMP to broadcast regular Joes to smaller audiences, but lower latencies (more engaging / live)
- [Build a Smart Calendar and Notification Center for Family Agendas with a Raspberry Pi](http://lifehacker.com/build-a-smart-calendar-and-notification-center-for-fami-1751637798)
- Productivity
	- [slackcat - Pipe command output and upload files to Slack from your terminal!](http://slackcat.chat/)
- [Acquia retrospective 2015](http://buytaert.net/acquia-retrospective-2015)
- Microsoft Azure
	- [Microsoft Azure Service Fabric and the Microservices Architecture (MSDN Article)](https://msdn.microsoft.com/en-us/magazine/mt595752.aspx)
	- [Linux Azure VM Scale Sets with shared storage using Lustre](http://blogs.msdn.com/b/arsen/archive/2015/12/30/linux-azure-vm-scale-sets-with-shared-storage-using-lustre.aspx)
	- [How to call the Azure Resource Manager REST API from C#](https://msftstack.wordpress.com/2016/01/03/how-to-call-the-azure-resource-manager-rest-api-from-c/)
	- [Using ADAL and the Azure Resource Manager REST API from within a Webtask](http://fabriccontroller.net/using-adal-and-the-azure-resource-manager-rest-api-from-within-a-webtask/)
	- [Deploy a custom application to Azure Service Fabric](https://github.com/Azure/azure-content/blob/master/articles/service-fabric/service-fabric-deploy-existing-app.md)
- Web Development
	- [Parse is closed](http://blog.parse.com/announcements/moving-on/) and [OSS](https://github.com/ParsePlatform/parse-server)
	- [Preact](http://developit.github.io/preact/)
	- [Run Sitecore in a Docker container on Windows Server 2016](https://developer.rackspace.com/blog/run-sitecore-in-a-docker-container-on-windows-server-2016/)
	- [Fabricator](https://fbrctr.github.io/)
	- JavaScript
		- [Angular 2 versus React: There Will Be Blood](https://medium.com/@housecor/angular-2-versus-react-there-will-be-blood-66595faafd51)
		- [The Future of Node is in Microsoft’s Fork](https://blog.andyet.com/2015/12/31/the-future-of-node-is-microsofts-fork/)
- [Disque 1.0 RC1 is out!](http://antirez.com/news/100) / [github](https://github.com/antirez/disque)
- [The Truth About Working at a Japanese Company](http://rubyronin.com/the-truth-about-working-at-a-japanese-company/)
- [Letter To A Young Programmer Considering A Startup](https://al3x.net/2013/05/23/letter-to-a-young-programmer.html)
- [JavaScript Regular Expressions made easy](https://github.com/VerbalExpressions/JSVerbalExpressions) and [C# Regular Expressions made easy](https://github.com/VerbalExpressions/CSharpVerbalExpressions) fluid
- Elixir
	- [AWS clients for Elixir](https://github.com/jkakar/aws-elixir) and [clients AWS APIs for Elixir](https://github.com/CargoSense/ex_aws) and [AWS Signature Version 4 Signing Library for Elixir](https://github.com/bryanjos/aws_auth) and [Erlang Amazon WebServices](https://github.com/x6j8x/erlaws) and [Cloud Computing library for erlang (Amazon EC2, S3, SQS, SimpleDB, Mechanical Turk, ELB)](https://github.com/erlcloud/erlcloud)
	- [Elixir : Simple Guardian - Multiple Sessions](http://blog.overstuffedgorilla.com/simple-guardian-multiple-sessions/)
	- [Atom Editor for Elixir Development](http://brainlid.org/elixir/2015/11/12/atom-editor-and-elixir.html)
	- [ElixirConf 2015 videos](http://confreaks.tv/events/elixirconf2015)
	- [Get invited to Elexir on Slack](http://bit.ly/slackelixir)
	- [Routing Securely with Phoenix Framework](http://kronicdeth.github.io/routing-securely-with-phoenix-framework/#/) and [code](https://github.com/KronicDeth/routing-securely-with-phoenix-framework)
	- [Setting Up Phoenix/Elixir With Nginx and LetsEncrypt](https://medium.com/@a4word/setting-up-phoenix-elixir-with-nginx-and-letsencrypt-ada9398a9b2c)
	- [Create Command Line Tools with Elixir](http://elixirdose.com/post/create_command_line_tools)
- AWS
	- [Using AWS Lambda functions to create print ready files](http://highscalability.com/blog/2015/12/28/using-aws-lambda-functions-to-create-print-ready-files.html)
	- [5 AWS mistakes you should avoid](https://cloudonaut.io/5-aws-mistakes-you-should-avoid/)

# December 2015

- [High Quality Video Encoding at Scale](http://techblog.netflix.com/2015/12/high-quality-video-encoding-at-scale.html?m=1)
- [Choosing between Azure Event Hub SaaS and Apache Kafka on IaaS](http://blogs.msdn.com/b/opensourcemsft/archive/2015/08/08/choose-between-azure-event-hub-and-kafka-_2d00_-what-you-need-to-know.aspx)
- [Assessing Data Store Capabilities for Polyglot Solutions](https://github.com/mspnp/azure-guidance/blob/master/Polyglot-Solutions.md)
- [Stream processing, Event sourcing, Reactive, CEP… and making sense of it all](http://www.confluent.io/blog/making-sense-of-stream-processing/)
- F#
	- [Optics for F#](https://xyncro.tech/aether/guides/lenses.html)
	- [Implementing API Gateway in F# Using Rx and Suave](http://blog.tamizhvendan.in/blog/2015/12/29/implementing-api-gateway-in-f-number-using-rx-and-suave/)
- [serialusb – a cheap USB proxy for input devices](http://blog.gimx.fr/serialusb/)
- [CSS capabilities of e-mail clients](https://www.campaignmonitor.com/css/)
- [IoT protocols landscape #IoT](https://blog.adafruit.com/2015/12/22/iot-protocols-landscape-iot/)
- [Detect and disconnect WiFi cameras in that AirBnB you’re staying in](https://julianoliver.com/output/log_2015-12-18_14-39)
- Elixir
	- [Building a web framework from scratch in Elixir](https://codewords.recurse.com/issues/five/building-a-web-framework-from-scratch-in-elixir)
	- [Introducing new open-source tools for the Elixir community](https://engineering.pinterest.com/blog/introducing-new-open-source-tools-elixir-community): [Elixometer](https://github.com/pinterest/elixometer) and [riffed - Apache Thrift bindings for Elixir](https://github.com/pinterest/riffed)
	- [active: automatically reload Erlang modules](https://github.com/synrc/active)
	- [Erlang Factory 2015 Videos Berlin](http://www.erlang-factory.com/berlin2015#speakers)
- Project Orleans
	- [Orleankka - Functional API for Microsoft Orleans](https://github.com/yevhen/orleankka)
	- [Orleans.KafkaStreamProvider](https://github.com/gigya/Orleans.KafkaStreamProvider)
- Video
	- [What the new video compression strategy from Netflix means for Apple and Amazon](https://donmelton.com/2015/12/21/what-the-new-video-compression-strategy-from-netflix-means-for-apple-and-amazon/)
- [devstash.io](https://devstash.io/)
- [Securely Upload to Azure Storage with Angular](https://blogs.msdn.microsoft.com/kaevans/2015/12/18/securely-upload-to-azure-storage-with-angular/)
- Kafka & Co.
	- [Choosing between Azure Event Hub SaaS and Apache Kafka on IaaS](http://blogs.msdn.com/b/opensourcemsft/archive/2015/08/08/choose-between-azure-event-hub-and-kafka-_2d00_-what-you-need-to-know.aspx)
	- [Assessing Data Store Capabilities for Polyglot Solutions](https://github.com/mspnp/azure-guidance/blob/master/Polyglot-Solutions.md)
	- [Stream processing, Event sourcing, Reactive, CEP... and making sense of it all](http://www.confluent.io/blog/making-sense-of-stream-processing/)
- PostgreSQL HA & ZooKeeper
	- Zalando
		- [Presentation Spilo](https://docs.google.com/presentation/d/1u20uz0IeJklSwb8gWc3dCFOCXAhdOfRYJv3cRbVgoB4/pub?start=false&loop=false&delayms=3000&slide=id.ge891ea114_2_19)
		- [zalando/patroni: Runners to orchestrate a high-availability PostgreSQL](https://github.com/zalando/patroni)
		- [zalando/spilo: Highly available elephant herd: HA PostgreSQL cluster using Docker and STUPS](https://github.com/zalando/spilo) & [docs](http://spilo.readthedocs.org/en/latest/)
	- [jinty/zgres: Postgres Failover and Management with ZooKeeper](https://github.com/jinty/zgres)
	- [joyent/manatee: Automated fault monitoring and leader-election system for strongly-consistent, highly-available writes to PostgreSQL (Joyent SDC, Manta).](https://github.com/joyent/manatee) and [docs](https://github.com/joyent/manatee/blob/master/docs/user-guide.md)
- ZooKeeper
	- [ZooKeeper Cluster (Multi-Server) Setup](http://myjeeva.com/zookeeper-cluster-setup.html)
	- [Deploying Zookeeper Ensemble](http://sanjivblogs.blogspot.de/2011/04/deploying-zookeeper-ensemble.html)
- [In praise of "boring" technology](https://labs.spotify.com/2013/02/25/in-praise-of-boring-technology/)
- [Slick vector images at freepik.com](http://www.freepik.com)
- [Deploy to Azure Resource Groups using the SDK](http://devian.co/2015/10/31/deploy-to-azure-resource-groups-using-the-sdk/)
- [The Moral Character of Cryptographic Work](http://web.cs.ucdavis.edu/~rogaway/papers/moral.html)
- [How to Build a SQL Server AlwaysOn Failover Cluster Instance with SIOS DataKeeper using Azure Resource Manager](http://azurecorner.com/sql-server-alwayson-failover-cluster-instance-with-sios-datakeeper-using-azure-resource-manager/)
- [Lessons learned - Hosting large-scale backends like the “Eurovision Song Contest” on Microsoft Azure](https://channel9.msdn.com/Events/microsoft-techncial-summit/Technical-Summit-2015-The-Next-Level/Lessons-learned-Hosting-large-scale-backends-like-the-Eurovision-Song-Contest-on-Microsoft-Azure)
- [Node.js on Windows and MAX_PATH explanation and workarounds](https://github.com/Microsoft/nodejs-guidelines/blob/master/windows-environment.md#workarounds)
- [Running Drush on Windows Azure Websites](https://sunithamk.wordpress.com/2014/04/01/drupal-running-drush-on-windows-azure-websites/)
- [HTTP Live Streaming In Javascript](https://blog.peer5.com/http-live-streaming-in-javascript/)
- [Multimedia on Linux Command Line: wget, PdfTK, ffmpeg, flac, SoX](https://sandilands.info/sgordon/multimedia-on-linux-command-line)
- [From 20 to 2,000 engineers on GitHub: Azure, GitHub and our Open Source Portal](http://www.jeff.wilcox.name/2015/11/azure-on-github/)
- [MediaInfo](https://mediaarea.net/en/MediaInfo/Download/Windows)

# November 2015

- [How to Build a SQL Server AlwaysOn Failover Cluster Instance with SIOS DataKeeper using Azure Resource Manager](http://azurecorner.com/sql-server-alwayson-failover-cluster-instance-with-sios-datakeeper-using-azure-resource-manager/)
- [Elixir](http://elixir-lang.org/) and [Phoenix Framework](http://www.phoenixframework.org/)
- Cool blog rolls: [The Morning Brew](http://blog.cwa.me.uk/) and [Morning Dew](http://www.alvinashcraft.com/)
- [Hostnames and usernames to reserve](https://ldpreload.com/blog/names-to-reserve) in SaaS systems, so regular users cannot grab them
- Cool web site designs:
	- [http://www.patrickalgrim.me/](http://www.patrickalgrim.me/)
	- [codyhouse.co/gem/horizontal-timeline/](https://codyhouse.co/gem/horizontal-timeline/)
- Windows Defender also blocks [AdWare](http://www.heise.de/security/meldung/Windows-mit-verstecktem-Adware-Killer-3023579.html). Just create under `HKEY_LOCAL_MACHINE\Software\Policies\Microsoft\Windows Defender\MpEngine` a DWORD called `MpEnablePus` with value `1`.
- [Distributed Machine Learning Toolkit](https://github.com/Microsoft/DMTK)
- [In the cloud, we trust](http://news.microsoft.com/stories/inthecloudwetrust/)
- [THE AZURE REST API, OR RATHER RESOURCE MANAGEMENT API](http://devian.co/2015/11/03/the-azure-rest-api-or-rather-resource-management-api/)
- [Streams as the team interface](https://vimeo.com/144863186)
- [C41 – DIY Film Processing at Home](http://camerafilmphoto.com/diy-film-processing-c41-home/) #photography
- [ASP.NET 5 DNX beta8, Connection Refused in Docker?](http://blog.markrendle.net/asp-net-5-dnx-beta8-connection-refused-in-docker/)

# September 2015

- Windows Service Skeleton: With the [EmptyWindowsService](https://github.com/chgeuer/EmptyWindowsService) project, I've created a simple skeleton where you can wrap your own logic in a console app, which can be executed interactively, but also carries it's own installer and Windows service host. The [Topshelf](https://github.com/Topshelf/Topshelf) project offers a more mature Nuget package for similar things, and also has a nice [Azure](https://github.com/Topshelf/Topshelf.Azure) integration to run on Worker Roles (PaaS).
- The [Azure Resource Visualizer](http://armviz.io/#) project on [Github](https://github.com/ytechie/AzureResourceVisualizer) looks like an interesting way to crawl through ARM deployments.
- [SQL Azure Performance Objective IDs for Azure Resource Manager](https://gist.github.com/chgeuer/9d7fba649880ef4ed44a)
- Powershell to convert a PFX file to BASE64: `[System.IO.File]::WriteAlltext("1.pfx.txt", [System.Convert]::ToBase64String([System.IO.File]::ReadAllBytes("1.pfx")))`
- Building Azure Service Fabric Actors with F# [Part 1](https://cockneycoder.wordpress.com/2015/08/03/building-azure-service-fabric-actors-with-f-part-1/), [Part 2](https://cockneycoder.wordpress.com/2015/08/10/building-azure-service-fabric-actors-with-f-part-2/) and [Stateless services on Azure Service Fabric in F#](https://cockneycoder.wordpress.com/2015/08/31/stateless-services-on-azure-service-fabric-in-f/)




# WIP

- http://blogs.msdn.com/b/arsen/archive/2015/09/18/certificate-based-auth-with-azure-service-principals-from-linux-command-line.aspx
- http://www.dushyantgill.com/blog/2015/05/23/developers-guide-to-auth-with-azure-resource-manager-api/
- http://www.webupd8.org/2015/06/how-to-stream-to-twitch-from-linux.html
- https://azure.microsoft.com/en-us/documentation/articles/active-directory-appmodel-v2-overview/
- https://azure.microsoft.com/en-us/documentation/articles/active-directory-v2-preview-oidc-changes/
- https://azure.microsoft.com/en-us/documentation/articles/media-services-dotnet-get-started/
- https://github.com/Azure-Samples/active-directory-dotnet-webapp-webapi-oauth2-useridentity
- https://microsoft.sharepoint.com/sites/itweb/Email/transferred-employees/Pages/Exchange-ActiveSync-(EAS)-on-Windows-Phone,-Android,-and-iOS-Devices-(Multi-Tenant).aspx
- https://msdn.microsoft.com/de-de/library/azure/dn790568.aspx
- https://msdn.microsoft.com/en-us/library/partnercenter/dn974935.aspx
- https://msdn.microsoft.com/library/azure/dn194267.aspx
- https://www.nuget.org/packages/Microsoft.IdentityModel.Clients.ActiveDirectory/
- https://www.nuget.org/packages/Microsoft.IdentityModel.Clients.ActiveDirectory
- https://azure.microsoft.com/en-us/documentation/articles/active-directory-v2-protocols/
- http://blogs.msdn.com/b/arsen/archive/2015/09/18/certificate-based-auth-with-azure-service-principals-from-linux-command-line.aspx
- http://blog.geuer-pollmann.de/pages/AzureLogin/
- https://azure.microsoft.com/en-us/documentation/articles/resource-manager-supported-services/#media-amp-cdn
- https://github.com/Azure/azurefile-dockervolumedriver/blob/master/main.go
