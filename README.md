# Garage

## TODO

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
- [x] Build details
  - [x] engine
    - [x] cylinder
    - [ ] Cylinder tuning (porting etc)
    - head
    - piston
    - [x] cases -- going to handle these as separate engines
    - [x] crank
  - [x] carb
    - [x] make
    - [x] model
    - [x] jets
  - [x] ignition
    - [x] cdi box
  - [x] transmission
    - [x] clutch
    - [x] GEARING
      - [x] How to handle vespa, hobbit?
    - [x] variator
    - [x] pulley
  - [x] exhaust
  - [x] forks
  - [x] wheels
- [ ] Image flagging
- [x] Client-side image upload + auto upload
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
