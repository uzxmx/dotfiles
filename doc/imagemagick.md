# ImageMagick

## How to create a canvas?

```
convert -size 300x300 canvas:white output.png
```

Ref: https://www.imagemagick.org/Usage/canvas/

## How to replace white with transparency?

```
convert input.png -transparent white output.png

# If not perfectly white, use `-fuzz`
convert input.png -fuzz XX% -transparent white output.png
```
