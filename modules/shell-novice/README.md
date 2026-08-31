## shell-novice modules

This directory contains `learnr` tutorials for the [shell-novice](https://swcarpentry.github.io/shell-novice/) lessons provided by the Software Carpentry foundation.

### Server-side setup

Clone this repository:

```bash
git clone https://github.com/johnsonra/ai4teaching
```

Copy this `shell-novice/` directory to the Shiny server directory, for example:

```bash
cp -r ~/ai4teaching/modules/shell-novice /srv/shiny-server/.
```

Initialize the database with something like:

```R
ai4teaching::dbinit(file.path('/var', 'shiny', 'submissions.sqlite'))
```

Also need to add a `.Renvrion` file with values for `ENCRYPTION_KEY` AND `GEMINI_API_KEY`.

Make sure all files have the proper permissions. (In order to run my lesson summary script, I also need to have access to the database file, so I created a group called "shinyAdmin".)

```bash
# ownership
chown shiny:shinyAdmin --recursive /var/shiny

# permissions
chmod 770 /var/shiny
chmod 660 /var/shiny/*
```

### Load the module

When loading the module, you should use a url something like [https://server.com/shell-novice/01_intro_nav.Rmd](https://server.com/shell-novice/01_intro_nav.Rmd).
