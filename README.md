#Contentful 2 Hugo
A tool to create content-files for [hugo](https://gohugo.io) from content on [contentful](https://www.contentful.com).

## Installation
```
gem install c2h
```

## Usage

Place your config file in the root directory of your hugo site, name it contentful.yaml and run ***c2h -v***.

```
Usage: c2h [-cv]
    -c, --conf pad/to/configfile.yaml     Location of your configfile
                                     (default contentful.yaml)
        --help                       Show this message
    -v, --verbose                    Give more output
        --version                    Show version
```

## Config file

An example config file:

```
---
access_token: yourownpersonalaccesstokenfromcontentfulhere # Contentful token  (required)
content_dir: content  # Content dir of hugo (required)
download_images: false # Images in the content get downloaded (optional, default = false)
image_dir: static/images  # Image dir of hugo (required if download_images == true)
spaces:               # List of spaces you want to import
  abc123xyz456:       # Space key of contentful
    section: page	# Section in hugo you want to map to
    content: content  # Field you want to map as content in hugo (optional)
    filename: slug    # Field you want to use as filename (optional)
---
```
Notice: all paths are relative to the config file.

## License
[Apache](http://opensource.org/licenses/Apache-2.0)
