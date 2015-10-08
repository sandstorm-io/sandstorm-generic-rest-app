@0xc945a94d4bbd9654;

using Spk = import "/sandstorm/package.capnp";
# This imports:
#   $SANDSTORM_HOME/latest/usr/include/sandstorm/package.capnp
# Check out that file to see the full, documented package definition format.

const pkgdef :Spk.PackageDefinition = (
  # The package definition. Note that the spk tool looks specifically for the
  # "pkgdef" constant.

  id = "yf28s4grwdkftt3apeae7d3xr5xp2sjf2xedeq7x9a89gp3j15th",
  # Your app ID is actually its public key. The private key was placed in
  # your keyring. All updates must be signed with the same key.

  manifest = (
    # This manifest is included in your app package to tell Sandstorm
    # about your app.

    appTitle = (defaultText = "J(A)SON Datastore"),

    appVersion = 0,  # Increment this for every release.

    appMarketingVersion = (defaultText = "0.1.0"),
    # Human-readable representation of appVersion. Should match the way you
    # identify versions of your app in documentation and marketing.

    actions = [
      # Define your "new document" handlers here.
      ( title = (defaultText = "New J(A)SON Datastore"),
        command = .myCommand
        # The command to run when starting for the first time. (".myCommand"
        # is just a constant defined at the bottom of the file.)
      )
    ],

    continueCommand = .myCommand
    # This is the command called to start your app back up after it has been
    # shut down for inactivity. Here we're using the same command as for
    # starting a new instance, but you could use different commands for each
    # case.
  ),

  sourceMap = (
    # The following directories will be copied into your package.
    searchPath = [
      ( sourcePath = ".meteor-spk/deps" ),
      ( sourcePath = ".meteor-spk/bundle" )
    ]
  ),

  alwaysInclude = [ "." ],
  # This says that we always want to include all files from the source map.
  # (An alternative is to automatically detect dependencies by watching what
  # the app opens while running in dev mode. To see what that looks like,
  # run `spk init` without the -A option.)

  bridgeConfig = (
    apiPath = "/api",
    viewInfo = (
      permissions = [(name = "get"), (name = "post")],
      roles = [(title = (defaultText = "admin"),
                permissions = [true,true],
                verbPhrase = (defaultText = "can view all data")),
               (title = (defaultText = "poster"),
                permissions = [false,true],
                verbPhrase = (defaultText = "can post data"),
                default = true)],
    )
  )
);

const myCommand :Spk.Manifest.Command = (
  # Here we define the command used to start up your server.
  argv = ["/sandstorm-http-bridge", "4000", "--", "node", "start.js"],
  environ = [
    # Note that this defines the *entire* environment seen by your app.
    (key = "PATH", value = "/usr/local/bin:/usr/bin:/bin")
  ]
);
