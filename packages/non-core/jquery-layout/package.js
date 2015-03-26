// XXX should probably nudge people toward the CSS Flexible Box Model
// flexie, rather than this

Package.describe({
  name: "jquery-layout",
  summary: "Deprecated package for JS layout",
  version: "1.0.3"
});

Package.onUse(function (api) {
  // commented out TomFreudenberg 2015-03-26
  // this will break meteor dev_bundle installation
  // if non-core packages linked into packages
  // see issue https://github.com/meteor/meteor/issues/4023
  // api.versionsFrom('1.0');
  // ---------------------------------------
  api.use('jquery');
  api.addFiles('jquery.layout.js', 'client');
});
