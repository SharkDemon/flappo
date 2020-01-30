[![MIT license](http://img.shields.io/badge/license-MIT-brightgreen.svg)](http://opensource.org/licenses/MIT)
[![HitCount](http://hits.dwyl.io/SharkDemon/flappo.svg)](http://hits.dwyl.io/SharkDemon/flappo)

# flappo

Flappo is a Flappy Bird remake implemented in Lua, using [Love](https://love2d.org/) (the 2D game engine).

## Screenshot

![Flappo](screenshot.png)

## Running the program (Windows)

Typically I install Love to one of my tools directories, create a LOVE_HOME environment variable, and set that environment variable to the Love installation directory.

Then I navigate to the project folder and setup a batch file containing the following command:

```
"%LOVE_HOME:\=/%/love.exe" --console "%cd:\=/%"
```
