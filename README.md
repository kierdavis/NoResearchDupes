# NoResearchDupes

Information for users (what this addon does, how to install it, how to get help)
is available on the [addon's page on esoui.com][esoui].

## Release process

* Increase `AddOnVersion` in NoResearchDupes.txt.
* Create a git tag `v$VERSION`.
* Run `tools/release.sh $VERSION` to create ZIP file.
* Push `main` branch and tags to Github.
* Create a Github release and attach the new ZIP file.
* Upload new ZIP file to esoui.com.

## License

[LICENSE.txt](LICENSE.txt)


[esoui]: https://www.esoui.com/downloads/info2964-NoResearchDupes.html
