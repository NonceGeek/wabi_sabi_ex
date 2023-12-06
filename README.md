# WABI SABI Web Framework（诧寂）

「五色令人目盲，五音令人耳聾，五味令人口爽，馳騁畋獵令人心發狂，難得之貨令人行妨。是以聖人為腹不為目，故去彼取此。 」

—— 道德經·拾贰

目前市面上主流的 Web 框架非常炫目。然而，WABI SABI Web Framework 遵循一条逆反的路径 —— 大 DAO 至简。

通过渲染 Markdown 文档，得到 Ascii 风格的 App/dApp —— 「把一切复杂隐藏在幕后」。

LOVE❤️ & PEACE🕊.

<img width="1401" alt="image" src="https://github.com/NonceGeek/wabi_sabi_ex/assets/12784118/e57c19f7-0b89-40a2-a216-9347d634cafe">

## Quick Start

A clean install of the Phoenix 1.7 (RC) along with:

- Alpine JS - using a CDN to avoid needing `node_modules`
- 🌺 [Petal Components Library](https://github.com/petalframework/petal_components)
- Maintained and sponsored by [Petal Framework](https://petal.build)

### Get up and running

Optionally change your database name in `dev.exs`.

1. Setup the project with `mix setup`
2. Start Phoenix endpoint with `mix phx.server` or inside IEx with `iex -S mix phx.server`
3. Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

### Phoenix 1.7 generators

The CRUD generators (eg. `mix phx.gen.live`) will produce code that doesn't quite work. Basically, they will use components defined in `core_components.ex` that we have renamed due to naming clashes with Petal Components.
To fix, simply do a find and replace in the generated code:

```
Replace `.modal` with `.phx_modal`
Replace `.table` with `.phx_table`
Replace `.button` with `.phx_button`
```

This should make it work but it'll be using a different style of buttons/tables/modal to Petal Components. To work with Petal Components you will need to replace all buttons/tables/modal with the Petal Component versions.

Petal Pro currently comes with a generator to build CRUD interfaces with Petal Components. You can purchase it [here](https://petal.build/pro).

### Renaming your project

Your app module is currently called `WabiSabiEx`. There is a script file included that will rename your project to anything you like in one go.
Using `rename_project` to rename it by mix. 

