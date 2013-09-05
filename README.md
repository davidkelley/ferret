Ferret
==

This project utilizes [Bower](https://github.com/bower/bower) and [GruntJS](http://gruntjs.com/) to create a build. Ensure that you have both tools installed before continuing.

Setup
-

Once you have resolved all of the project's dependencies, run the following commands to finish setting up your environment:

<pre>
$ npm install
$ bower install
$ grunt build
</pre>

Bower
-

Twitter Bower is used to manage third-party application dependencies, such as RequireJS and jQuery. More information is available on its README, https://github.com/bower/bower/blob/master/README.md

GruntJS
-

This project uses GruntJS to transform the coffeescript un-structured source files into a structured, minified and optimized Chrome extension. The following tasks are executed by GruntJS:

* Coffeelint all files to ensure they conform with project coding standards
* Copy the Manifest file into the build directory
* Concatenate all external libraries from bower into a singular file (build/libs.js)
* Compile all Coffeescript into Javascript and insert them into their respective location inside the `build` directory.
* Run the RequireJS optimizer to resolve module dependencies and resolve the application to one file.
* Uglify all Javascript inside the `build` directory.

Communicating with Ferret
-

Messages are passed to Ferret via the standard cross-extension message passing mechanisms that Google details in their documentation here[http://developer.chrome.com/extensions/messaging.html].

*Messages should take the following form:*

<pre>
{
	"controller": "device-controller",
	"type": "device-action-type",
	"action": "action-to-perform-on-device",
	"arguments": ["action-arg-1", "action-arg-2", ...]
}
</pre>

*Replies are received from Ferret in a similar fashion, *

<pre>
{
	"controller": "device-controller",
	"type": "device-action-type",
	"action": "action-to-perform-on-device",
	"success": true,
	"data": [...]
}