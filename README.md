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

## Supporting a new ESO release

* Set the maximum compatible API version (the second number on the `APIVersion` line in `NoResearchDupes.txt`) to the latest ESO API version as per [this list][apiversions].
* Test that the addon works as expected.
* Publish a release by following steps above.

## License

[LICENSE.txt](LICENSE.txt)


[esoui]: https://www.esoui.com/downloads/info2964-NoResearchDupes.html
[apiversions]: https://wiki.esoui.com/APIVersion
