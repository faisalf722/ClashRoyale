# Clash Royale (Roblox)

A Clash Royale-inspired Roblox game built with [Rojo](https://rojo.space/) for local development.

## Project Structure

```
src/
├── server/
│   ├── ElixirManager.server.luau   -- Elixir regen & sync per player
│   └── CombatEngine.server.luau    -- Card play handler & troop spawner
├── shared/
│   └── CardData.luau               -- Card stats module (Giant, Knight, Archer)
└── client/
    └── CardController.client.luau  -- UI card selection & world click to deploy
```

## Setup

1. Install [Rojo](https://rojo.space/) (included as `rojo.exe`)
2. Run `rojo.exe serve` in this folder
3. Connect via the Rojo plugin inside Roblox Studio

## Cards

| Card   | Cost | Health | Damage | Speed | Range |
|--------|------|--------|--------|-------|-------|
| Giant  | 5    | 2000   | 120    | 10    | 5     |
| Knight | 3    | 900    | 100    | 14    | 5     |
| Archer | 3    | 300    | 60     | 14    | 25    |
