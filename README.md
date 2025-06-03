# Passback

`passback` is a command line tool for managing expenses.

> :warning: **Work in Progress**: This project is currently under development. Some features may not be complete and may change in the future.

## Installation

To install passback, you can clone the repository and compile the source code:

```sh
git clone https://github.com/alvaro17f/passback.git
cd passback
odin build .
```

then move the binary to a directory in your PATH:

```sh
sudo mv passback <PATH>
```

### NixOS

#### Run

To run passback, you can use the following command:

```sh
nix run github:alvaro17f/passback
```

If you need to pass arguments, you can use the following command:

```sh
nix run github:alvaro17f/passback -- help
```

#### Flake

Add passback to your flake.nix file:

```nix
{
    inputs = {
        passback.url = "github:alvaro17f/passback";
    };
}
```

then include it in your system configuration:

```nix
{ inputs, pkgs, ... }:
{
    home.packages = [
        inputs.passback.packages.${pkgs.system}.default
    ];
}
```

## Usage

You need to create a config file (defaults to `~/.config/passback/config.json`) with the following:

```sh
[
  {
    "name": string,
    "income": float,
    "loan": float,
    "loan_payment": float
  }
]

```

(you can extend the list with as many users as you want)

Then, simply run `passback`

```sh
***************************************************
passback - A simple CLI tool to manage your expenses
***************************************************
-p : Set config path
-h, help : Display this help message
-v, version : Display the current version
```

## License

passback is distributed under the MIT license. See the LICENSE file for more information.

```

```
