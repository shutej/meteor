![meteor-universal-logo meteorjs arm cortex udoo raspberrypi odroid](https://cloud.githubusercontent.com/assets/410087/10517017/2c32e7d6-735b-11e5-9677-3caf479af53a.png)



# Meteor

Meteor is an ultra-simple environment for building modern web
applications.

With Meteor you write apps:

* in pure JavaScript
* that send data over the wire, rather than HTML
* using your choice of popular open-source libraries

Documentation is available at http://docs.meteor.com/.

Try the getting started [tutorial](https://www.meteor.com/try).

<br/>

# Meteor universal fork

## enable the yet unsupported architectures

The meteor universal fork allows to run meteorjs on yet not officially
supported architectures. Especially ARM processors ARMv6 and ARMv7 
(UDOO, Raspberry Pi, Banana Pi, ODroid etc.) are provided due to our 
pre-built dev_bundles.

The universal fork will try use any official meteor binaries as long as 
they does support the target architecture. All universal pre-built 
bundles are available at our [BINTRAY Repository](https://bintray.com/4commerce-technologies-ag/meteor-universal)

<br/>

## Quick Start

... on supported architectures like ARMv6, ARMv7, i686, x86_64 and OSs like
Debian (derivates), Ubuntu, Arch, CentOS, OSX, Windows.

<br/>
##### Get Meteor (e.g. into your $HOME):

```bash
cd $HOME

git clone --depth 1 https://github.com/4commerce-technologies-AG/meteor.git
```

<br/>
##### Check installed version:

```bash
$HOME/meteor/meteor --version
```

> Running the above command for the first time will try to download
> a compatible pre-built dev_bundle and finish the installation.
> Depending on your hardware this may take some time.

<br/>
##### Create and run a "Hello World" example (optionally):

```bash
cd $HOME

$HOME/meteor/meteor create hello-world

cd hello-world

$HOME/meteor/meteor
```

<br/>
##### Create and run a "reactJS" example (optionally):

```bash
cd $HOME

$HOME/meteor/meteor create --example simple-todos-react

cd simple-todos-react

$HOME/meteor/meteor
```

<br/>

## Slow Start

... if looking for self building your dev_bundles or on not getting a
pre-built dev_bundle for your platform.

If you're the sort of person who needs to build meteor on unsupported
architectures you can build all the Meteor stuff with the provided scripts.
This requires git, a C and C++ compiler, autotools and scons etc.

You may also decide to build the bundled node and mongodb sources for your platform
or to use the system wide installed packages of them. We suggest to build 
at least the bundle nodejs sources if possible, to be sure that these versions
are compatible. We have ported the bundled mongodb sources to ARM architecture
yet, so this might not be be able to compile on your architecture. We
suggest to use and install the system available binaries for mongo in
any case that pre-built dev_bundle are not available. Please have a look
at our [Meteor Universal Blog](http://meteor-universal.tumblr.com) for
a lot of documentation about setting up your system to build the sources.


<br/>
##### Get Meteor (e.g. into your $HOME):

```bash
cd $HOME

git clone --depth 1 https://github.com/4commerce-technologies-AG/meteor.git

cd meteor
```

<br/>
##### Build bundled node:

```bash
scripts/build-node-for-dev-bundle.sh
```

<br/>
##### Check mongodb installation:

```bash
sudo apt-get install mongodb
```

<br/>
##### Build meteor dev_bundle:

```bash
scripts/generate-dev-bundle.sh
```

<br/>
##### Check installed version:

```bash
$HOME/meteor/meteor --version
```

> If you were successful in building your dev_bundles, you created
> your local dev_bundle tarballs. Now running the above command for
> the first time will use this local tarballs and finish the meteor
> installation. Depending on your hardware this may take some time.

<br/>
##### Create and run Hello World:

If all was successfully build and installed, you may continue with
your first meteor example.

```bash
cd $HOME

$HOME/meteor/meteor create hello-world

cd hello-world

$HOME/meteor/meteor
```

<br/>

## Good to know

<br/>
##### Meteor starter

For your comfort, you should set an alias or update your $PATH to run meteor from everywhere.

```bash
alias meteor="$HOME/meteor/meteor"
```

<br/>
##### Non-core packages

After checkout there are some non-core packages not available like e.g. `npm-bcrypt`. This fork sets the ENV VAR `PACKAGE_DIRS` to include the non-core packages automatically. If you have a special concern you have to set this ENV VAR with your preferred values before calling meteor. In that case the meteor starter will NOT add the non-core packages. Some meteor examples and applications may not work properly without those packages.

If interested in details you find some more information about non-core packages at [meteor universal blog](http://meteor-universal.tumblr.com/post/111435518849/use-non-core-packages-for-your-meteor-apps)

<br/>
##### Local documentation

From your checkout, you can read the docs locally. The `/docs` directory is a
meteor application, so simply change into the `/docs` directory and launch
the app:

```bash
cd $HOME/meteor/docs

$HOME/meteor/meteor
```

You'll be able to read the docs locally in your browser at

```
http://localhost:3000/
```

<br/>
##### Running special releases

Note that if you run Meteor from a git checkout, you cannot pin apps to specific
Meteor releases or run using different Meteor releases using `--release`.

But you may checkout different releases of meteor in seperate directories to
run special releases.

```bash
cd $HOME

git clone --depth 1 -b "release/1.2.0.2" https://github.com/4commerce-technologies-AG/meteor.git meteor-1.2.0.2

$HOME/meteor-1.2.0.2/meteor --version
```

> Only since release 1.2.0.2 we provide the pre-built dev_bundles for ARM
> if you need to use previous realeases, you have to build the dev_bundles
> once by yourself.

<br/>
## Uninstalling Meteor

This meteor fork will not install or create any global files – except your developments
all will stay inside the local meteor directory. To uninstall Meteor, just drop that directory (e.g.):

```bash
rm -r $HOME/meteor
```

<br/>
## Pre-builds for ARM

Since meteor stable release 1.2.0.2 we provide pre-builds for ARMv6 and ARMv7 at our 
[BINTRAY Repository](https://bintray.com/4commerce-technologies-ag/meteor-universal). 
The embedded installer inside the meteor launcher will try to download the correct
pre-built dev_bundle automatically.

If you are looking for compatible node packages they are also available at BINTRAY.

<br/>

## Developer Resources

<br/>
##### Building an application with Meteor?

* Announcement list: sign up at http://www.meteor.com/
* Ask a question: http://stackoverflow.com/questions/tagged/meteor
* Discussion forums: https://forums.meteor.com/

<br/>
##### Interested in Meteor Universal?

* Issue tracker: https://github.com/4commerce-technologies-AG/meteor/issues
* Knowledge Base: http://meteor-universal.tumblr.com
* BinTray dev_bundles repository: [https://bintray.com/4commerce-technologies-ag/meteor-universal](https://bintray.com/4commerce-technologies-ag/meteor-universal)
* ARM compatible fork for mongodb: [https://github.com/4commerce-technologies-AG/mongo](https://github.com/4commerce-technologies-AG/mongo/commits/ssl-r2.6.7)
* ARM compatible fork for node-fibers: [https://github.com/4commerce-technologies-AG/node-fibers](https://github.com/4commerce-technologies-AG/node-fibers/commits/master)

<br/>
##### Interested in contributing to Meteor?

* Issue tracker: https://github.com/meteor/meteor/issues
* Contribution guidelines: https://github.com/meteor/meteor/tree/devel/Contributing.md

<br/>
##### Original Meteor project

* Visit https://github.com/meteor/meteor

<br/>

## Author & Credits

This fork is supported by [Tom Freudenberg](http://about.me/tom.freudenberg) and the people from [4commerce technologies AG](http://www.4commerce.de/). All work is released under the MIT license

Thanks to [Meteor Development Group](https://www.meteor.com) for having initiated this project.
