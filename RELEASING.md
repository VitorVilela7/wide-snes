# How this automation works?

In order to create a patch first it is needed to assemble the code and apply it
to a legit backup of the original game. As these backups are of personal use to
the owner of the cartridge they cannot be made public available.

To circumvent this situation you'll need to create a [Dropbox App][app], 
generate a [token][token] and add it to this project Secrets under the name of
`DROPBOX_TOKEN`. Remember to upload your personal game backup to the root folder
of that app under the name `smw.sfc`.

Now every time a Pull Request is open or a git tag is pushed a Github Action 
will be triggered and, using `DROPBOX_TOKEN`, will securely download your game
backup. After that the Action can generate the patch and make it available to 
download though the `Artifacts` list or at the `Releases` page. 

Don't worry, in this manner is not possible to anyone besides you to access your
game backup.

## Step by step to release a new version

To release a new version, first make sure your local main branch is sync'd with
the main branch on Github:

```bash
git checkout master
git pull
```

Now run this command:
```
make tag-and-release VERSION=v2.0.0
```

The `make tag-and-release` command creates a git tag with the project's current
version and pushes it to Github. This will trigger a Github Action that
automatically generates a patch an make it available on the `Releases` page.

[app]: https://www.dropbox.com/developers/apps
[token]: https://www.dropbox.com/developers/reference/auth-types#user
