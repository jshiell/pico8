# PICO-8 Experimentation

Some fun with [PICO-8](https://www.lexaloffle.com/pico-8.php), a fantasy 8-bit console.

## Running

You'll need PICO-8 installed in `/Applications` on a Mac, or `pico8` on the `PATH` elsewhere.

```bash
bin/pico8
```

Or, manually:
```bash
pico8 -home .
```

## Testing

There's the genesis of a test harness for [busted]() in `specs`.

    luarocks install busted
    P8_CART_PATH='carts/?.p8' busted -m 'spec/?.lua;carts/?.lua'
