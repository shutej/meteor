# Meteor

## run yet unsupported architectures

![meteorjs arm cortex udoo raspberrypi](https://lh3.googleusercontent.com/-N7bR3zreEoA/VFZRK3WdBtI/AAAAAAAAAhA/-8gPsAszTnM/w600-h498-no/meteorjs-udoo-raspi-arm-cortex.png)

Meteor is an ultra-simple environment for building modern web
applications.

With Meteor you write apps:

* in pure JavaScript
* that send data over the wire, rather than HTML
* using your choice of popular open-source libraries

Documentation is available at http://docs.meteor.com/

Get additional information and hints to run nodejs and meteor on yet not official supported architectures at http://meteor-universal.tumblr.com/  

## Slow Start if looking for an universal bundle

If you want to run on the bleeding edge, you
can run Meteor directly from a git checkout.

    git clone https://github.com/4commerce-technologies-AG/meteor.git
    cd meteor

If you're the sort of person who needs to build meteor on unsupported architectures
you can build all the Meteor stuff with the provided script. This requires git, a C and C++ compiler,
autotools, and scons. So if you have pre-installed your platform packages for
nodejs and mongodb, the script will create an universal bundle. This
also runs on ARM architectures like UDOO or Raspi.

    # for UNIVERSAL bundle
    ./scripts/generate-dev-bundle.sh

Now you can run meteor directly from the checkout (if you did not
build the dependency bundle above, this will take a few moments to
download a pre-build version).

    ./meteor --help

For your comfort, you should create a symbolic link to run meteor from everywhere

    sudo ln -s meteor /usr/local/bin/meteor

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

    rm -rf path/to/clone/meteor/
    sudo rm /usr/local/bin/meteor

## Developer Resources

Building an application with Meteor?

* Announcement list: sign up at http://www.meteor.com/
* Ask a question: http://stackoverflow.com/questions/tagged/meteor
* Discussion forums: https://forums.meteor.com/

Interested in contributing to Meteor?

* Issue tracker: https://github.com/meteor/meteor/issues
* Contribution guidelines: https://github.com/meteor/meteor/tree/devel/Contributing.md

We are hiring!  Visit https://www.meteor.com/jobs to
learn more about working full-time on the Meteor project.

