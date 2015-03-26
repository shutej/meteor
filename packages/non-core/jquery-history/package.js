Package.describe({
  name: "jquery-history",
  summary: "Deprecated package for HTML5 pushState",
  version: "1.0.2"
});

Package.onUse(function (api) {
  // commented out TomFreudenberg 2015-03-26
  // this will break meteor dev_bundle installation
  // if non-core packages linked into packages
  // see issue https://github.com/meteor/meteor/issues/4023
  // api.versionsFrom('1.0');
  // ---------------------------------------
  api.use('json', 'client');
  api.use('jquery', 'client');
  api.addFiles(['history.adapter.jquery.js',
                 'history.html4.js',
                 'history.js'],
                'client');
});
