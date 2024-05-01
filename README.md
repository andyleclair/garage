# Garage

## Completed

- [x] Upload photos for builds
- [x] Likes
- [x] Comments
- [x] Slugs
- [x] Password Reset
- [x] User settings page
- [x] User profile page
- [x] User fancy colors
- [x] Build picture carousel
- [x] Build image management
- [x] Rich text editing for Build
- [x] Reorder images
- [x] Actually send emails
- [x] Set prod credentials
- [x] Seeds
- [x] Client-side image upload + auto upload

## TODO

- [ ] Build details
  - [x] engine
    - [x] cylinder
    - [x] Cylinder tuning (porting etc)
    - [x] crank
  - [x] carb
    - [x] tuning
    - [x] size
    - [x] make
    - [x] model
    - [x] jets
  - [x] ignition
    - [x] ignition tuning
      - [x] cdi box
      - [x] timing (degrees? mm btdc?)
  - [ ] transmission
    - [x] clutch
    - [x] GEARING
      - [x] How to handle vespa, hobbit?
    - [x] variator
    - [x] pulley
    - [x] variator tuning
      - [x] weights
  - [x] exhaust
- [ ] Image flagging
- [ ] Tools
  - Gearing calculator
  - blowdown etc.
- [ ] Import from garage / puchshop
- [ ] Dark mode
- [ ] Chat
- [ ] Better index page
- [ ] Logo
- [ ] Atomic design
- [ ] Add signed up users to mailing list
- [ ] Caching
- [ ] Delete users if requested
- [ ] Site news
- [ ] User roles
- [ ] Clubs
- [ ] Rallies
- [ ] Stats on parts
- [ ] Switch from using streams everywhere

## Known Issues

- [x] Image uploads are broken in prod

### Installation

#### Language

To install Elixir and Erlang, I use [mise](https://github.com/jdx/mise).
After installing `mise`, install the required versions by running `mise install`.

#### Dependencies

To start the Phoenix server:

- Run `mix setup` to install and setup dependencies
- Start Phoenix endpoint with `mix phx.server` or inside IEx with `iex -S mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.
