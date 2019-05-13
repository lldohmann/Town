return {
  version = "1.1",
  luaversion = "5.1",
  tiledversion = "0.18.0",
  orientation = "orthogonal",
  renderorder = "right-down",
  width = 11,
  height = 12,
  tilewidth = 15,
  tileheight = 16,
  nextobjectid = 1,
  properties = {},
  tilesets = {
    {
      name = "out_town1",
      firstgid = 1,
      tilewidth = 16,
      tileheight = 16,
      spacing = 0,
      margin = 0,
      image = "../assets/pallets/out_town1.png",
      imagewidth = 128,
      imageheight = 144,
      tileoffset = {
        x = 0,
        y = 0
      },
      properties = {},
      terrains = {},
      tilecount = 72,
      tiles = {}
    }
  },
  layers = {
    {
      type = "tilelayer",
      name = "Tile Layer 1",
      x = 0,
      y = 0,
      width = 11,
      height = 12,
      visible = true,
      opacity = 1,
      offsetx = 0,
      offsety = 0,
      properties = {},
      encoding = "lua",
      data = {
        1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 8,
        1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 16,
        1, 1, 1, 1, 1, 1, 1, 3, 2, 3, 24,
        1, 24, 1, 24, 1, 1, 1, 1, 26, 1, 8,
        1, 1, 3, 1, 1, 1, 1, 9, 34, 11, 16,
        1, 24, 1, 24, 1, 1, 24, 17, 42, 19, 1,
        1, 1, 1, 1, 1, 1, 3, 25, 26, 27, 4,
        1, 1, 1, 1, 1, 1, 24, 33, 34, 35, 4,
        1, 1, 1, 1, 1, 1, 3, 41, 44, 43, 4,
        1, 1, 1, 1, 1, 1, 24, 49, 52, 51, 4,
        1, 1, 1, 1, 1, 1, 3, 24, 72, 24, 3,
        72, 72, 72, 72, 72, 72, 72, 72, 72, 1, 1
      }
    }
  }
}
