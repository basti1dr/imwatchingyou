# I'm watching You
[![Build Status](https://travis-ci.org/bdronneau/imwatchingyou.svg?branch=refactor%2Fbadges)](https://travis-ci.org/bdronneau/imwatchingyou)[![Scrutinizer Code Quality](https://scrutinizer-ci.com/g/bdronneau/imwatchingyou/badges/quality-score.png?b=master)](https://scrutinizer-ci.com/g/bdronneau/imwatchingyou/?branch=master)
[![Dependency Status](https://gemnasium.com/bdronneau/imwatchingyou.svg)](https://gemnasium.com/bdronneau/imwatchingyou) [![Codacy Badge](https://api.codacy.com/project/badge/Grade/aaf63545793f4c89a8ea2e8c275ee8f4)](https://www.codacy.com/app/basti1/imwatchingyou?utm_source=github.com&amp;utm_medium=referral&amp;utm_content=bdronneau/imwatchingyou&amp;utm_campaign=Badge_Grade)

## Install
### Vagrant
You can build a virtual machine which will contain all required dependencies to ease development on your machine. You'll
need:
- [virtualbox](https://www.virtualbox.org/wiki/Downloads)
- [vagrant](http://www.vagrantup.com/downloads.html)

Then, you will just have to type `vagrant up` to install and initialize the machine the subsequent times.
You can also access the machine by typing `vagrant ssh` if you need an access to the generated virtual machine.

NB : The `Vagrantfile` is based on the official [jessie debian box](https://atlas.hashicorp.com/debian/boxes/jessie64).
It will load the configuration which can be found in `vagrantfiles/config.yaml`. Note that the application can be accessible over
`192.168.12.34:3030` by default.

### Gems
```bash
bundle install
```

### Node modules
```bash
npm install
```

## Configuration
Copy ```config.sample.yml``` as ```config.yml``` and fill the sections you want to use in dashboard

## Usage
```bash
bundle exec dashing start
```

## Code styling checkers
### Check syntax JS
GULP is using for check syntax of all files (some files are ignored by filesJSToIgnore variable)

```bash
node_modules/gulp/bin/gulp.js
```
One file :

```bash
node_modules/gulp/bin/gulp.js --js path_to_file
```

### Check syntax ruby
```bash
bundle exec rubocop
```
