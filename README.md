# Meteor

## run yet unsupported architectures

![meteorjs arm cortex udoo raspberrypi](https://lh3.googleusercontent.com/-N7bR3zreEoA/VFZRK3WdBtI/AAAAAAAAAhA/-8gPsAszTnM/w600-h498-no/meteorjs-udoo-raspi-arm-cortex.png)

Meteor is an ultra-simple environment for building modern web
applications.

With Meteor you write apps:

* in pure JavaScript
* that send data over the wire, rather than HTML
* using your choice of popular open-source libraries

Documentation is available at http://docs.meteor.com/.

Try the getting started [tutorial](https://www.meteor.com/try).

## meteor universal

Get additional information and hints to run nodejs and meteor on yet not official supported architectures at http://meteor-universal.tumblr.com/  

## Slow Start if looking for an universal bundle

If you want to run on the bleeding edge, you can run Meteor directly from a git checkout.

    git clone https://github.com/4commerce-technologies-AG/meteor.git
    cd meteor

If you're the sort of person who needs to build meteor on unsupported architectures you can build all the Meteor stuff with the provided script. This requires git, a C and C++ compiler, autotools, and scons. So if you have pre-installed your platform packages for nodejs and mongodb, the script will create an universal bundle. This also runs on ARM architectures like UDOO or Raspi.

    # for UNIVERSAL bundle
    ./scripts/generate-dev-bundle.sh

Now you can run meteor directly from the checkout.

    ./meteor --version

If you did not build the dependency bundle above, it will take a few moments to
download and install a pre-build version. Pre-builds currently exists mostly for x86 architecture. If you are looking for an universal ARM pre-build please read appendix _Pre-builds for ARM_.

##### non-core packages

After checkout there are some non-core packages not available like e.g. `npm-bcrypt`. This fork sets the ENV VAR `PACKAGE_DIRS` to include the non-core packages automatically. If you have a special concern you have to set this ENV VAR with your preferred values before calling meteor. In that case the meteor starter will NOT add the non-core packages. Some meteor examples and applications may not work properly without those packages.

If interested in details you find some more information about non-core packages at [meteor universal blog](http://meteor-universal.tumblr.com/post/111435518849/use-non-core-packages-for-your-meteor-apps)

##### meteor starter

For your comfort, you should create a symbolic link to run meteor from everywhere

    sudo ln -s meteor /usr/local/bin/meteor

##### local documentation

From your checkout, you can read the docs locally. The `/docs` directory is a
meteor application, so simply change into the `/docs` directory and launch
the app:

    cd docs/
    ../meteor

You'll then be able to read the docs locally in your browser at

    http://localhost:3000/

Note that if you run Meteor from a git checkout, you cannot pin apps to specific
Meteor releases or run using different Meteor releases using `--release`.

## Uninstalling Meteor

Aside from a short launcher shell script, Meteor installs itself inside your
home directory. To uninstall Meteor, run:

```bash
rm -rf ~/.meteor/
sudo rm /usr/local/bin/meteor
```

## Pre-builds for ARM

Since meteor stable release 1.0.3.2 we provide some pre-builds for a number of ARM architectures. There are also some downloads for `nodejs` on ARM available. We are sorry just to support a few packages but the ARM architectures are so disversified that we can't support more for the moment. In any case you should be able to generate your dev-bundle when follow the "slow start guide" above.

The pre-build downloads are available at each published release for meteor universal at [Releases page](https://github.com/4commerce-technologies-AG/meteor/releases)

Please download the fitting pre-build for your board and save it to your checkout path. If you want to use a pre-build you do not have to run `generate-dev-bundle.sh` and should download the pre-build archive before starting meteor.

Proceed as follow:

    git clone https://github.com/4commerce-technologies-AG/meteor.git
    cd meteor
    curl -L -O https://github.com/4commerce-technologies-AG/meteor/<path to pre-build>
    meteor --version

Using pre-builds will save you some time waiting for compiling and bundling.

## Developer Resources

Building an application with Meteor?

* Announcement list: sign up at http://www.meteor.com/
* Ask a question: http://stackoverflow.com/questions/tagged/meteor
* Discussion forums: https://forums.meteor.com/

Interested in Meteor Universal?

* Issue tracker: https://github.com/4commerce-technologies-AG/meteor/issues
* Knowledge Base: http://meteor-universal.tumblr.com

Interested in contributing to Meteor?

* Issue tracker: https://github.com/meteor/meteor/issues
* Contribution guidelines: https://github.com/meteor/meteor/tree/devel/Contributing.md

Visit https://github.com/meteor/meteor for the original Meteor project.
