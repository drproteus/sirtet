# SIRTET (2014)
## tetrominos in lua

### running
* have Love2d on your system (`apt install love`, for example)
* `git clone https://github.com/drproteus/sirtet.git`
* `love sirtet`

### controls
* any key starts from the title.
* `left` and `right` to move your piece side to side.
* `up` rotates clockwise.
* `down` accelerates downward motion
* `space` hard drops the piece where it would fall vertically.
* `p` pauses the game
* when paused, `q` exits the application
* `g` toggles ghosting (initially off)
* `1-0` sets the "level" to this number-- just modifies speed where the higher the level, the faster the piece (save 0, which is MAX LEVEL).

**NOTE**: there is no counter-clockwise motion... yet!

![screen1](screenshots/screen1.png)

---

### Bonus: LastFM Top Albums (at the time) Tileset
```
love sirtet images/96.png
```
![screen96](screenshots/screen96.png)
