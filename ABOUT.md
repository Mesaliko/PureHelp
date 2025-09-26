fatcow
======

 > 3926 Free "Farm-Fresh Web Icons"
 > Download hundreds of FREE, beautifully designed icons from FatCow Web Hosting! Icon set includes both 16 and 32 pixel versions of icons shown below.

*My intention with this repository is to allow its installation via bower*

`bower install fatcow --save`

### Terms of Use
These icon sets are licensed under a Creative Commons Attribution 3.0 License. This means you can freely use these icons for any purpose, private and commercial, including online services, templates, themes and software. However, you should include a link to this page (http://www.fatcow.com/free-icons) in your credits (software or website). The icons may not be resold, sub-licensed, rented, transferred or otherwise made available for use. Please link to this page on fatcow.com if you would like to spread the word.

Free FatCow-Farm Fresh Icons
http://www.fatcow.com/free-icons

FatCow Farm-Fresh final release (3926 icons, 5 parts):
- fatcow-hosting-icons-3.9.2.zip default (10.9 Mb)
- fatcow-hosting-icons-3.9.2-color.zip (11.1 Mb)
- fatcow-hosting-icons-3.9.2-grey.zip (6.9 Mb)
- fatcow-hosting-icons-3.9.2-ico.zip (8.9 Mb)
- fatcow-hosting-icons-3.9.2-all.zip (30.7 Mb)
- fatcow-hosting-icons-3.9.2-ai-src.zip (2.82 !Gb)


Farm-Fresh v3.92, 10-04-2014
-----------------------------------------
- 126 new 32x32 and 16x16 icons added (total of 252 files)
- 139 icons renamed as per Tango Icon Theme Guidelines
- 10 new 48x48 and 96x96 Retina ready icons (added)
- Adobe Illustrator .ai vector source files (added)
- greyscale version of color icons in .png (added)
- .ico files of all .png icons files (added)
- icons sorted by 11 base colors (added)
---------------------------------------------------------------------------------

Farm-Fresh v3.80, 10-25-2013
-----------------------------------------
- 300 new 32x32 and 16x16 icons added (total of 600)
---------------------------------------------------------------------------------

Farm-Fresh v3.50, 29-03-2013
-----------------------------------------
- 500 new 32x32 and 16x16 icons added (total of 1,000)


These icons are licensed under a Creative Commons Attribution 3.0 License.
http://creativecommons.org/licenses/by/3.0/us/ if you do not know how to link
back to FatCow's website, you can ask https://plus.google.com/+MarcisGasuns
Biggest icon set drawn by a single designer (in pixel smooth style) worldwide.

We are unavailable for custom icon design work. The project is
closed (April 2014) and we do not plan to draw more metaphors.
http://twitter.com/FatCow
http://plus.google.com/+FatCow
http://www.facebook.com/FatCow

---------------------------------------------------------------------------------

© Copyright 2009-2014 FatCow Web Hosting. All rights reserved.
http://www.fatcow.com

All other trademarks and copyrights
are property of their respective owners.

---------------------------------------------------------------------------------

Original readme (from author of the icons)
----------

Silk icon set 1.3

_________________________________________

Mark James
http://www.famfamfam.com/lab/icons/silk/

_________________________________________

This work is licensed under a
Creative Commons Attribution 2.5 License.
[ http://creativecommons.org/licenses/by/2.5/ ]

This means you may use it for any purpose,
and make any changes you like.
All I ask is that you include a link back
to this page in your credits.

Are you using this icon set? Send me an email
(including a link or picture if available) to
mjames@gmail.com

Any other questions about this icon set please
contact mjames@gmail.com



About the rest (all this repository but the icons)
----------

All the content of this repository (excepted the icon pack) 
is licensed under the [MIT license](http://opensource.org/licenses/MIT).

Though, it is just composed a few trivial json files and a Readme.

# famfamfam-silk

[![NPM version](https://img.shields.io/npm/v/famfamfam-silk.svg)](https://www.npmjs.org/package/famfamfam-silk)
[![Bower version](https://img.shields.io/bower/v/famfamfam-silk.svg)](http://bower.io/search/?q=famfamfam-silk)
[![Packagist version](https://img.shields.io/packagist/v/legacy-icons/famfamfam-silk.svg)](https://packagist.org/packages/legacy-icons/famfamfam-silk)
[![Nuget version](https://img.shields.io/nuget/v/famfamfam-silk.svg)](https://www.nuget.org/packages/famfamfam-silk/)

[![Dependency Status](https://img.shields.io/david/dev/legacy-icons/famfamfam-silk.svg)](https://david-dm.org/legacy-icons/famfamfam-silk)
[![Build Status](https://img.shields.io/travis/legacy-icons/famfamfam-silk.svg)](https://travis-ci.org/legacy-icons/famfamfam-silk)


## About

The `Silk` icon pack, as available on [famfamfam website](http://www.famfamfam.com/lab/icons/silk/).

All credits for these icons go to their original author: Mark James (mjames@gmail.com)

The aim of this project is to make this icon pack available through various package managers, such as:

- [NPM](https://npmjs.org)
- [Bower](http://bower.io)
- [Packagist](https://packagist.org)
- [NuGet](https://www.nuget.org)

All icons are supplied in PNG format.


## CSS spritesheets

You can insert the icons directly into your HTML with a common IMG tag:

```html
<img alt="Delete" src="dist/png/key_delete.png" width="16" height="16">
```


In addition to the icons by themselves, this project also ships a CSS spritesheet for the icon-pack. This spritesheet allows to load the entire icon-pack in just 1 image, and thus reduce HTTP calls.

This is what it actually looks:

![Spritesheet](https://raw.githubusercontent.com/legacy-icons/famfamfam-silk/master/dist/sprite/famfamfam-silk.png)


All the positioning of the icons inside this alone image is made through CSS, which allows you to just add block-type tags with the proper class and get the same result:

```html
<div class="famfamfam-silk key_delete"></div>
```

Just remember to add the CSS stylesheet to the HEAD of your HTML page!


## Install

### Get the package with NPM

> npm install famfamfam-silk


### Get the package with Bower

> bower install famfamfam-silk


### Get the package with Composer / Packagist

> composer require legacy-icons/famfamfam-silk


### Get the package with NuGet

> Install-Package famfamfam-silk


## Build the whole project or your custom project

We use [Gulp](http://gulpjs.com/) to build the project, so if you want to re-build or customize this project, you'll need Gulp.

After gulp is installed, and your CLI is pointed to your work directory, first install the dependencies:

**with NPM 2.x.x**

> npm install

**with NPM 3.x.x** (resolve dependencies for `node-spritesheet` before this module's ones)

> npm install grunt grunt-contrib-coffee grunt-contrib-clean

> npm install

then be sure that you have *[ImageMagick](http://www.imagemagick.org/script/binary-releases.php)* installed for building spritesheet.

then, you can run the `gulp build` task to build the project:

> gulp build


### What the build task does?

First, it takes PNG files from the `src` folder, and pastes them to the `dist` folder.

Then it creates a spritesheet from the PNG images located in the `src` folder, and thus creates the `sprite` folder in `dist`.

If, for example you just want `application_put` and `monitor_edit` icons in a spritesheet, you just have to fork this project, point your CLI to the working directory, 
empty the `src` directory, except `application_put` and `monitor_edit` icons in PNG format, and then run the `gulp build` task.

You'll get the proper spritesheet and copies of the icons directly in the `dist` folder.


## License

See [License](https://github.com/legacy-icons/famfamfam-silk/blob/master/LICENSE.md)
