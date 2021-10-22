![Tritium: Heroes 3 in Swift](https://raw.githubusercontent.com/Sajjon/Tritium/main/Tritium/Assets.xcassets/AppIcon.appiconset/h3_icon_128.png)

# Tritium
Tritium - H3 - is an open source frontend (GUI) for Heroes of Might and Magic III in pure Swift, powered by the Swift HoMM3 game engine [`Makt`](https://github.com/Sajjon/Makt)
> ⚠️ You MUST have the resources (DATA, Maps and Music files) from the original game in order to play this. See under [Copyright](#Copyright) on where and how to buy the game if you don't own it.

# Status

> 🚨 Status NOT playable yet 🚨

I've just managed to render maps, using original game resources that `Makt` extracts. But performance is terrible, since I've literally put zero effort into this. So next is to come up with a good solution. Maybe generate a PNG image for the whole map and use a **single** [SwiftUI `Image` View](https://developer.apple.com/documentation/swiftui/image) (instead of tens of thousands).

## Progress
<img src="https://raw.githubusercontent.com/Sajjon/Tritium/main/tritium_2021-10-05_map_freedom_commit_4866371bf8e7aae6ed41b1d7d62593afc4bcd123_each_image_its_own_view.jpg">
This is the map called `"Freedom"` in Tritium, rendered using SwiftUI with a trivial completely non-optimized solution where each sprite is its own Image view. Performance is bad and scrolling in larger maps is unfeasibly bad.

## Focus
In this repo - the frontend Tritium - I focus on rendering maps only. Nothing else such as menus or nice SwiftUI code. Because I suck at SwiftUI. But most work is really done in the repo for the backend [`Makt`](https://github.com/Sajjon/Makt). 

# Copyright
All rights for the original game and its resources belong to former [The 3DO Company](https://en.wikipedia.org/wiki/The_3DO_Company). These rights were transferred to [Ubisoft](https://www.ubisoft.com/). We do not encourage and do not support any form of illegal usage of the original game. We strongly advise to purchase the original game on [Ubisoft Store](https://store.ubi.com/eu/game?pid=575ffd9ba3be1633568b4d8c) or [GOG](https://www.gog.com/game/heroes_of_might_and_magic_3_complete_edition).
